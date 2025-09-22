import 'package:firebase_auth/firebase_auth.dart';

/// Authentication result model
class AuthResult {
  final bool success;
  final String? message;
  final User? user;
  final AuthException? error;

  AuthResult({
    required this.success,
    this.message,
    this.user,
    this.error,
  });

  factory AuthResult.success(User user, {String? message}) {
    return AuthResult(
      success: true,
      user: user,
      message: message,
    );
  }

  factory AuthResult.failure(AuthException error, {String? message}) {
    return AuthResult(
      success: false,
      error: error,
      message: message,
    );
  }
}

/// User registration data model
class RegistrationData {
  final String email;
  final String password;
  final String confirmPassword;
  final String fullName;
  final String? phoneNumber;
  final String gender;
  final String preferredLanguage;
  final bool acceptTerms;
  final bool acceptPrivacy;
  final bool subscribeToNewsletter;

  RegistrationData({
    required this.email,
    required this.password,
    required this.confirmPassword,
    required this.fullName,
    this.phoneNumber,
    required this.gender,
    required this.preferredLanguage,
    required this.acceptTerms,
    required this.acceptPrivacy,
    this.subscribeToNewsletter = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'fullName': fullName,
      'phoneNumber': phoneNumber,
      'gender': gender,
      'preferredLanguage': preferredLanguage,
      'acceptTerms': acceptTerms,
      'acceptPrivacy': acceptPrivacy,
      'subscribeToNewsletter': subscribeToNewsletter,
    };
  }

  factory RegistrationData.fromJson(Map<String, dynamic> json) {
    return RegistrationData(
      email: json['email'] ?? '',
      password: '', // Never store password in JSON
      confirmPassword: '', // Never store password in JSON
      fullName: json['fullName'] ?? '',
      phoneNumber: json['phoneNumber'],
      gender: json['gender'] ?? 'female',
      preferredLanguage: json['preferredLanguage'] ?? 'en',
      acceptTerms: json['acceptTerms'] ?? false,
      acceptPrivacy: json['acceptPrivacy'] ?? false,
      subscribeToNewsletter: json['subscribeToNewsletter'] ?? false,
    );
  }
}

/// Login data model
class LoginData {
  final String email;
  final String password;
  final bool rememberMe;

  LoginData({
    required this.email,
    required this.password,
    this.rememberMe = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'rememberMe': rememberMe,
    };
  }
}

/// Password reset data model
class PasswordResetData {
  final String email;

  PasswordResetData({required this.email});

  Map<String, dynamic> toJson() {
    return {
      'email': email,
    };
  }
}

/// User profile data for authentication
class AuthUserProfile {
  final String uid;
  final String email;
  final String? displayName;
  final String? photoURL;
  final String? phoneNumber;
  final bool emailVerified;
  final DateTime createdAt;
  final DateTime lastSignIn;
  final String? providerId;
  final Map<String, dynamic> customClaims;
  final bool isAnonymous;

  AuthUserProfile({
    required this.uid,
    required this.email,
    this.displayName,
    this.photoURL,
    this.phoneNumber,
    required this.emailVerified,
    required this.createdAt,
    required this.lastSignIn,
    this.providerId,
    this.customClaims = const {},
    this.isAnonymous = false,
  });

  factory AuthUserProfile.fromFirebaseUser(User user) {
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
      isAnonymous: user.isAnonymous,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'photoURL': photoURL,
      'phoneNumber': phoneNumber,
      'emailVerified': emailVerified,
      'createdAt': createdAt.toIso8601String(),
      'lastSignIn': lastSignIn.toIso8601String(),
      'providerId': providerId,
      'customClaims': customClaims,
      'isAnonymous': isAnonymous,
    };
  }

  factory AuthUserProfile.fromJson(Map<String, dynamic> json) {
    return AuthUserProfile(
      uid: json['uid'] ?? '',
      email: json['email'] ?? '',
      displayName: json['displayName'],
      photoURL: json['photoURL'],
      phoneNumber: json['phoneNumber'],
      emailVerified: json['emailVerified'] ?? false,
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      lastSignIn: DateTime.parse(json['lastSignIn'] ?? DateTime.now().toIso8601String()),
      providerId: json['providerId'],
      customClaims: Map<String, dynamic>.from(json['customClaims'] ?? {}),
      isAnonymous: json['isAnonymous'] ?? false,
    );
  }

  AuthUserProfile copyWith({
    String? uid,
    String? email,
    String? displayName,
    String? photoURL,
    String? phoneNumber,
    bool? emailVerified,
    DateTime? createdAt,
    DateTime? lastSignIn,
    String? providerId,
    Map<String, dynamic>? customClaims,
    bool? isAnonymous,
  }) {
    return AuthUserProfile(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoURL: photoURL ?? this.photoURL,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      emailVerified: emailVerified ?? this.emailVerified,
      createdAt: createdAt ?? this.createdAt,
      lastSignIn: lastSignIn ?? this.lastSignIn,
      providerId: providerId ?? this.providerId,
      customClaims: customClaims ?? this.customClaims,
      isAnonymous: isAnonymous ?? this.isAnonymous,
    );
  }
}

/// Authentication state model
class AuthState {
  final bool isAuthenticated;
  final bool isLoading;
  final AuthUserProfile? user;
  final String? error;
  final bool isEmailVerified;
  final bool isAnonymous;

  AuthState({
    this.isAuthenticated = false,
    this.isLoading = false,
    this.user,
    this.error,
    this.isEmailVerified = false,
    this.isAnonymous = false,
  });

  AuthState copyWith({
    bool? isAuthenticated,
    bool? isLoading,
    AuthUserProfile? user,
    String? error,
    bool? isEmailVerified,
    bool? isAnonymous,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isLoading: isLoading ?? this.isLoading,
      user: user ?? this.user,
      error: error ?? this.error,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      isAnonymous: isAnonymous ?? this.isAnonymous,
    );
  }

  bool get hasError => error != null;
  bool get isLoggedIn => isAuthenticated && user != null;
  bool get needsEmailVerification => isAuthenticated && !isEmailVerified && !isAnonymous;
}

/// Social login providers
enum SocialLoginProvider {
  google,
  apple,
  facebook,
  twitter,
  github,
}

/// Two-factor authentication data
class TwoFactorAuthData {
  final String phoneNumber;
  final String verificationId;
  final int? resendToken;

  TwoFactorAuthData({
    required this.phoneNumber,
    required this.verificationId,
    this.resendToken,
  });
}

/// Biometric authentication data
class BiometricAuthData {
  final bool isEnabled;
  final bool isAvailable;
  final String? biometricType; // 'fingerprint', 'face', 'iris'
  final DateTime? lastUsed;

  BiometricAuthData({
    this.isEnabled = false,
    this.isAvailable = false,
    this.biometricType,
    this.lastUsed,
  });

  Map<String, dynamic> toJson() {
    return {
      'isEnabled': isEnabled,
      'isAvailable': isAvailable,
      'biometricType': biometricType,
      'lastUsed': lastUsed?.toIso8601String(),
    };
  }

  factory BiometricAuthData.fromJson(Map<String, dynamic> json) {
    return BiometricAuthData(
      isEnabled: json['isEnabled'] ?? false,
      isAvailable: json['isAvailable'] ?? false,
      biometricType: json['biometricType'],
      lastUsed: json['lastUsed'] != null ? DateTime.parse(json['lastUsed']) : null,
    );
  }
}

/// Session data model
class SessionData {
  final String sessionId;
  final String userId;
  final DateTime createdAt;
  final DateTime expiresAt;
  final String? deviceId;
  final String? deviceName;
  final String? ipAddress;
  final String? userAgent;
  final bool isActive;

  SessionData({
    required this.sessionId,
    required this.userId,
    required this.createdAt,
    required this.expiresAt,
    this.deviceId,
    this.deviceName,
    this.ipAddress,
    this.userAgent,
    this.isActive = true,
  });

  Map<String, dynamic> toJson() {
    return {
      'sessionId': sessionId,
      'userId': userId,
      'createdAt': createdAt.toIso8601String(),
      'expiresAt': expiresAt.toIso8601String(),
      'deviceId': deviceId,
      'deviceName': deviceName,
      'ipAddress': ipAddress,
      'userAgent': userAgent,
      'isActive': isActive,
    };
  }

  factory SessionData.fromJson(Map<String, dynamic> json) {
    return SessionData(
      sessionId: json['sessionId'] ?? '',
      userId: json['userId'] ?? '',
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      expiresAt: DateTime.parse(json['expiresAt'] ?? DateTime.now().toIso8601String()),
      deviceId: json['deviceId'],
      deviceName: json['deviceName'],
      ipAddress: json['ipAddress'],
      userAgent: json['userAgent'],
      isActive: json['isActive'] ?? true,
    );
  }

  bool get isExpired => DateTime.now().isAfter(expiresAt);
}

/// Custom authentication exceptions
class AuthException implements Exception {
  final String message;
  final String? code;
  final dynamic details;

  AuthException(this.message, {this.code, this.details});

  @override
  String toString() => 'AuthException: $message';

  // Common Firebase Auth error codes
  static AuthException fromFirebaseAuthException(FirebaseAuthException e) {
    String message;
    switch (e.code) {
      case 'user-not-found':
        message = 'No user found with this email address.';
        break;
      case 'wrong-password':
        message = 'Incorrect password. Please try again.';
        break;
      case 'email-already-in-use':
        message = 'An account already exists with this email address.';
        break;
      case 'weak-password':
        message = 'Password is too weak. Please choose a stronger password.';
        break;
      case 'invalid-email':
        message = 'Invalid email address format.';
        break;
      case 'user-disabled':
        message = 'This account has been disabled.';
        break;
      case 'too-many-requests':
        message = 'Too many attempts. Please try again later.';
        break;
      case 'operation-not-allowed':
        message = 'This operation is not allowed.';
        break;
      case 'invalid-credential':
        message = 'Invalid credentials. Please check your email and password.';
        break;
      case 'account-exists-with-different-credential':
        message = 'An account already exists with a different sign-in method.';
        break;
      case 'credential-already-in-use':
        message = 'This credential is already associated with a different user.';
        break;
      case 'invalid-verification-code':
        message = 'Invalid verification code.';
        break;
      case 'invalid-verification-id':
        message = 'Invalid verification ID.';
        break;
      case 'missing-verification-code':
        message = 'Verification code is required.';
        break;
      case 'missing-verification-id':
        message = 'Verification ID is required.';
        break;
      case 'quota-exceeded':
        message = 'Quota exceeded. Please try again later.';
        break;
      case 'network-request-failed':
        message = 'Network error. Please check your internet connection.';
        break;
      default:
        message = e.message ?? 'An authentication error occurred.';
    }
    return AuthException(message, code: e.code, details: e);
  }
}
