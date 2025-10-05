import 'dart:async';
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/auth_models.dart';
import 'validation_service.dart';

/// Main authentication service
class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Stream controller for auth state changes
  static Stream<AuthState> get authStateChanges => _authStateController.stream;
  static final StreamController<AuthState> _authStateController = StreamController<AuthState>.broadcast();
  
  // Current auth state
  static AuthState _currentState = AuthState();
  static AuthState get currentState => _currentState;
  
  // Local storage keys
  static const String _userDataKey = 'user_auth_data';
  static const String _rememberMeKey = 'remember_me';
  static const String _biometricEnabledKey = 'biometric_enabled';
  static const String _lastLoginKey = 'last_login';

  /// Initialize auth service
  static Future<void> initialize() async {
    // Listen to Firebase auth state changes
    _auth.authStateChanges().listen((User? user) {
      _updateAuthState(user);
    });
    
    // Check for existing session
    await _checkExistingSession();
  }

  /// Register new user with email and password
  static Future<AuthResult> registerWithEmail(RegistrationData data) async {
    try {
      // Validate registration data
      final validation = _validateRegistrationData(data);
      if (!validation.isValid) {
        return AuthResult.failure(
          AuthException(validation.errorMessage),
          message: 'Please fix the validation errors',
        );
      }

      // Create user with Firebase Auth
      final UserCredential credential = await _auth.createUserWithEmailAndPassword(
        email: data.email,
        password: data.password,
      );

      final User? user = credential.user;
      if (user == null) {
        return AuthResult.failure(
          AuthException('Failed to create user account'),
        );
      }

      // Update user profile
      await user.updateDisplayName(data.fullName);
      
      // Send email verification with custom action code settings
      await user.sendEmailVerification(
        ActionCodeSettings(
          url: 'https://mali-prod.web.app/#/verify-email',
          handleCodeInApp: true,
          iOSBundleId: 'com.example.mali03',
          androidPackageName: 'com.example.mali03',
          androidInstallApp: true,
          androidMinimumVersion: '21',
        ),
      );

      // Save user data to Firestore
      await _saveUserProfile(user, data);

      // Update auth state
      _updateAuthState(user);

      return AuthResult.success(
        user,
        message: 'Account created successfully! Please verify your email.',
      );
    } on FirebaseAuthException catch (e) {
      return AuthResult.failure(
        AuthException.fromFirebaseAuthException(e),
      );
    } catch (e) {
      return AuthResult.failure(
        AuthException('Registration failed: ${e.toString()}'),
      );
    }
  }

  /// Sign in with email and password
  static Future<AuthResult> signInWithEmail(LoginData data) async {
    try {
      // Validate login data
      final validation = _validateLoginData(data);
      if (!validation.isValid) {
        return AuthResult.failure(
          AuthException(validation.errorMessage),
        );
      }

      // Sign in with Firebase Auth
      final UserCredential credential = await _auth.signInWithEmailAndPassword(
        email: data.email,
        password: data.password,
      );

      final User? user = credential.user;
      if (user == null) {
        return AuthResult.failure(
          AuthException('Sign in failed'),
        );
      }

      // Save remember me preference
      if (data.rememberMe) {
        await _saveRememberMe(data);
      }

      // Update last login
      await _updateLastLogin();

      // Update auth state
      _updateAuthState(user);

      return AuthResult.success(
        user,
        message: 'Welcome back!',
      );
    } on FirebaseAuthException catch (e) {
      return AuthResult.failure(
        AuthException.fromFirebaseAuthException(e),
      );
    } catch (e) {
      return AuthResult.failure(
        AuthException('Sign in failed: ${e.toString()}'),
      );
    }
  }

  /// Sign in anonymously
  static Future<AuthResult> signInAnonymously() async {
    try {
      final UserCredential credential = await _auth.signInAnonymously();
      final User? user = credential.user;
      
      if (user == null) {
        return AuthResult.failure(
          AuthException('Anonymous sign in failed'),
        );
      }

      _updateAuthState(user);
      return AuthResult.success(user, message: 'Signed in anonymously');
    } on FirebaseAuthException catch (e) {
      return AuthResult.failure(
        AuthException.fromFirebaseAuthException(e),
      );
    } catch (e) {
      return AuthResult.failure(
        AuthException('Anonymous sign in failed: ${e.toString()}'),
      );
    }
  }

  /// Sign out
  static Future<AuthResult> signOut() async {
    try {
      await _auth.signOut();
      await _clearUserData();
      _updateAuthState(null);
      return AuthResult(
        success: true,
        message: 'Signed out successfully',
      );
    } catch (e) {
      return AuthResult.failure(
        AuthException('Sign out failed: ${e.toString()}'),
      );
    }
  }

  /// Send password reset email
  static Future<AuthResult> sendPasswordResetEmail(PasswordResetData data) async {
    try {
      // Validate email
      if (!_AuthValidationHelper.isValidEmail(data.email)) {
        return AuthResult.failure(
          AuthException('Invalid email address'),
        );
      }

      await _auth.sendPasswordResetEmail(email: data.email);
      
      return AuthResult(
        success: true,
        message: 'Password reset email sent! Check your inbox.',
      );
    } on FirebaseAuthException catch (e) {
      return AuthResult.failure(
        AuthException.fromFirebaseAuthException(e),
      );
    } catch (e) {
      return AuthResult.failure(
        AuthException('Failed to send password reset email: ${e.toString()}'),
      );
    }
  }

  /// Resend email verification
  static Future<AuthResult> resendEmailVerification() async {
    try {
      final User? user = _auth.currentUser;
      if (user == null) {
        return AuthResult.failure(
          AuthException('No user signed in'),
        );
      }

      if (user.emailVerified) {
        return AuthResult.failure(
          AuthException('Email is already verified'),
        );
      }

      await user.sendEmailVerification(
        ActionCodeSettings(
          url: 'https://mali-prod.web.app/#/verify-email',
          handleCodeInApp: true,
          iOSBundleId: 'com.example.mali03',
          androidPackageName: 'com.example.mali03',
          androidInstallApp: true,
          androidMinimumVersion: '21',
        ),
      );
      
      return AuthResult.success(
        user,
        message: 'Verification email sent!',
      );
    } on FirebaseAuthException catch (e) {
      return AuthResult.failure(
        AuthException.fromFirebaseAuthException(e),
      );
    } catch (e) {
      return AuthResult.failure(
        AuthException('Failed to send verification email: ${e.toString()}'),
      );
    }
  }

  /// Update user profile
  static Future<AuthResult> updateProfile({
    String? displayName,
    String? photoURL,
    String? phoneNumber,
  }) async {
    try {
      final User? user = _auth.currentUser;
      if (user == null) {
        return AuthResult.failure(
          AuthException('No user signed in'),
        );
      }

      // Update Firebase Auth profile
      await user.updateDisplayName(displayName);
      if (photoURL != null) {
        await user.updatePhotoURL(photoURL);
      }

      // Update Firestore profile
      await _updateFirestoreProfile(user.uid, {
        if (displayName != null) 'displayName': displayName,
        if (photoURL != null) 'photoURL': photoURL,
        if (phoneNumber != null) 'phoneNumber': phoneNumber,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      _updateAuthState(user);
      
      return AuthResult.success(
        user,
        message: 'Profile updated successfully',
      );
    } catch (e) {
      return AuthResult.failure(
        AuthException('Failed to update profile: ${e.toString()}'),
      );
    }
  }

  /// Change password
  static Future<AuthResult> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final User? user = _auth.currentUser;
      if (user == null) {
        return AuthResult.failure(
          AuthException('No user signed in'),
        );
      }

      // Re-authenticate user
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );
      
      await user.reauthenticateWithCredential(credential);
      
      // Update password
      await user.updatePassword(newPassword);
      
      return AuthResult.success(
        user,
        message: 'Password changed successfully',
      );
    } on FirebaseAuthException catch (e) {
      return AuthResult.failure(
        AuthException.fromFirebaseAuthException(e),
      );
    } catch (e) {
      return AuthResult.failure(
        AuthException('Failed to change password: ${e.toString()}'),
      );
    }
  }

  /// Delete user account
  static Future<AuthResult> deleteAccount(String password) async {
    try {
      final User? user = _auth.currentUser;
      if (user == null) {
        return AuthResult.failure(
          AuthException('No user signed in'),
        );
      }

      // Re-authenticate user
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: password,
      );
      
      await user.reauthenticateWithCredential(credential);
      
      // Delete user data from Firestore
      await _deleteUserData(user.uid);
      
      // Delete user account
      await user.delete();
      
      await _clearUserData();
      _updateAuthState(null);
      
      return AuthResult(
        success: true,
        message: 'Account deleted successfully',
      );
    } on FirebaseAuthException catch (e) {
      return AuthResult.failure(
        AuthException.fromFirebaseAuthException(e),
      );
    } catch (e) {
      return AuthResult.failure(
        AuthException('Failed to delete account: ${e.toString()}'),
      );
    }
  }

  /// Get current user
  static User? get currentUser => _auth.currentUser;

  /// Check if user is signed in
  static bool get isSignedIn => _auth.currentUser != null;

  /// Check if email is verified
  static bool get isEmailVerified => _auth.currentUser?.emailVerified ?? false;

  /// Check if user is anonymous
  static bool get isAnonymous => _auth.currentUser?.isAnonymous ?? false;

  /// Handle email verification from deep link
  static Future<AuthResult> handleEmailVerification(String actionCode) async {
    try {
      // Verify the action code
      await _auth.applyActionCode(actionCode);
      
      // Reload the user to get updated verification status
      await _auth.currentUser?.reload();
      
      // Update auth state
      _updateAuthState(_auth.currentUser);
      
      return AuthResult.success(
        _auth.currentUser!,
        message: 'Email verified successfully!',
      );
    } on FirebaseAuthException catch (e) {
      return AuthResult.failure(
        AuthException.fromFirebaseAuthException(e),
      );
    } catch (e) {
      return AuthResult.failure(
        AuthException('Failed to verify email: ${e.toString()}'),
      );
    }
  }

  /// Get user profile from Firestore
  static Future<AuthUserProfile?> getUserProfile() async {
    try {
      final User? user = _auth.currentUser;
      if (user == null) return null;

      final doc = await _firestore
          .collection('users')
          .doc(user.uid)
          .get();

      if (!doc.exists) return null;

      final data = doc.data()!;
      return AuthUserProfile(
        uid: user.uid,
        email: user.email ?? '',
        displayName: user.displayName,
        photoURL: user.photoURL,
        phoneNumber: user.phoneNumber,
        emailVerified: user.emailVerified,
        createdAt: user.metadata.creationTime ?? DateTime.now(),
        lastSignIn: user.metadata.lastSignInTime ?? DateTime.now(),
        providerId: user.providerData.isNotEmpty ? user.providerData.first.providerId : null,
        customClaims: Map<String, dynamic>.from(data['customClaims'] ?? {}),
        isAnonymous: user.isAnonymous,
      );
    } catch (e) {
      print('Error getting user profile: $e');
      return null;
    }
  }

  // ==================== PRIVATE METHODS ====================

  static void _updateAuthState(User? user) {
    final newState = AuthState(
      isAuthenticated: user != null,
      user: user != null ? AuthUserProfile.fromFirebaseUser(user) : null,
      isEmailVerified: user?.emailVerified ?? false,
      isAnonymous: user?.isAnonymous ?? false,
    );

    _currentState = newState;
    _authStateController.add(newState);
  }

  static Future<void> _checkExistingSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final rememberMe = prefs.getBool(_rememberMeKey) ?? false;
      
      if (rememberMe && _auth.currentUser != null) {
        _updateAuthState(_auth.currentUser);
      }
    } catch (e) {
      print('Error checking existing session: $e');
    }
  }

  static Future<void> _saveUserProfile(User user, RegistrationData data) async {
    try {
      await _firestore.collection('users').doc(user.uid).set({
        'uid': user.uid,
        'email': user.email,
        'displayName': user.displayName,
        'phoneNumber': data.phoneNumber,
        'gender': data.gender,
        'preferredLanguage': data.preferredLanguage,
        'emailVerified': user.emailVerified,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'lastSignIn': FieldValue.serverTimestamp(),
        'customClaims': {},
        'isAnonymous': user.isAnonymous,
        'registrationData': data.toJson(),
      });
    } catch (e) {
      print('Error saving user profile: $e');
    }
  }

  static Future<void> _updateFirestoreProfile(String uid, Map<String, dynamic> data) async {
    try {
      await _firestore.collection('users').doc(uid).update(data);
    } catch (e) {
      print('Error updating Firestore profile: $e');
    }
  }

  static Future<void> _deleteUserData(String uid) async {
    try {
      // Delete user document
      await _firestore.collection('users').doc(uid).delete();
      
      // Delete user's financial data
      await _firestore.collection('expenses').where('userId', isEqualTo: uid).get().then((snapshot) {
        for (final doc in snapshot.docs) {
          doc.reference.delete();
        }
      });
      
      await _firestore.collection('budgets').where('userId', isEqualTo: uid).get().then((snapshot) {
        for (final doc in snapshot.docs) {
          doc.reference.delete();
        }
      });
      
      await _firestore.collection('goals').where('userId', isEqualTo: uid).get().then((snapshot) {
        for (final doc in snapshot.docs) {
          doc.reference.delete();
        }
      });
    } catch (e) {
      print('Error deleting user data: $e');
    }
  }

  static Future<void> _saveRememberMe(LoginData data) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_rememberMeKey, true);
      await prefs.setString(_userDataKey, jsonEncode(data.toJson()));
    } catch (e) {
      print('Error saving remember me: $e');
    }
  }

  static Future<void> _updateLastLogin() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_lastLoginKey, DateTime.now().toIso8601String());
    } catch (e) {
      print('Error updating last login: $e');
    }
  }

  static Future<void> _clearUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_userDataKey);
      await prefs.remove(_rememberMeKey);
      await prefs.remove(_biometricEnabledKey);
    } catch (e) {
      print('Error clearing user data: $e');
    }
  }

  static ValidationResult _validateRegistrationData(RegistrationData data) {
    final errors = <String>[];

    // Email validation
    if (data.email.trim().isEmpty) {
      errors.add('Email is required');
    } else if (!_AuthValidationHelper.isValidEmail(data.email)) {
      errors.add('Invalid email format');
    }

    // Password validation
    if (data.password.isEmpty) {
      errors.add('Password is required');
    } else if (data.password.length < 6) {
      errors.add('Password must be at least 6 characters');
    }

    // Confirm password validation
    if (data.confirmPassword.isEmpty) {
      errors.add('Please confirm your password');
    } else if (data.password != data.confirmPassword) {
      errors.add('Passwords do not match');
    }

    // Full name validation
    if (data.fullName.trim().isEmpty) {
      errors.add('Full name is required');
    } else if (data.fullName.trim().length < 2) {
      errors.add('Full name must be at least 2 characters');
    }

    // Phone number validation (optional)
    if (data.phoneNumber != null && data.phoneNumber!.isNotEmpty) {
      if (!_AuthValidationHelper.isValidPhoneNumber(data.phoneNumber!)) {
        errors.add('Invalid phone number format');
      }
    }

    // Terms and privacy validation
    if (!data.acceptTerms) {
      errors.add('You must accept the terms and conditions');
    }

    if (!data.acceptPrivacy) {
      errors.add('You must accept the privacy policy');
    }

    return ValidationResult(
      isValid: errors.isEmpty,
      errors: errors,
    );
  }

  static ValidationResult _validateLoginData(LoginData data) {
    final errors = <String>[];

    // Email validation
    if (data.email.trim().isEmpty) {
      errors.add('Email is required');
    } else if (!_AuthValidationHelper.isValidEmail(data.email)) {
      errors.add('Invalid email format');
    }

    // Password validation
    if (data.password.isEmpty) {
      errors.add('Password is required');
    }

    return ValidationResult(
      isValid: errors.isEmpty,
      errors: errors,
    );
  }

  /// Dispose resources
  static void dispose() {
    _authStateController.close();
  }
}

// Helper methods for validation
class _AuthValidationHelper {
  static bool isValidEmail(String email) {
    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    return emailRegex.hasMatch(email);
  }

  static bool isValidPhoneNumber(String phone) {
    final digitsOnly = phone.replaceAll(RegExp(r'[^\d]'), '');
    return digitsOnly.length >= 7 && digitsOnly.length <= 15;
  }
}
