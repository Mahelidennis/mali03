# 🔐 Authentication System Guide

This guide explains the comprehensive authentication system implemented for the Mali financial assistant app.

## 📋 Overview

The authentication system provides:
- **Email/Password Authentication** - Traditional sign-up and sign-in
- **Anonymous Authentication** - Guest access for trial users
- **Email Verification** - Secure account activation
- **Password Reset** - Self-service password recovery
- **Profile Management** - User profile updates and management
- **Session Management** - Secure session handling
- **Data Protection** - User data isolation and security

## 🏗️ Architecture

```
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│   UI Layer      │    │  Service Layer   │    │  Firebase Layer │
│                 │    │                  │    │                 │
│ • Login Screen  │◄───┤ • AuthService    │◄───┤ • Firebase Auth │
│ • Register      │    │ • AuthWrapper    │    │ • Firestore     │
│ • Profile Mgmt  │    │ • Validation     │    │ • Storage       │
└─────────────────┘    └──────────────────┘    └─────────────────┘
```

## 📊 Data Models

### Core Authentication Models

#### 1. AuthResult
```dart
class AuthResult {
  final bool success;
  final String? message;
  final User? user;
  final AuthException? error;
}
```

#### 2. RegistrationData
```dart
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
}
```

#### 3. LoginData
```dart
class LoginData {
  final String email;
  final String password;
  final bool rememberMe;
}
```

#### 4. AuthUserProfile
```dart
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
}
```

#### 5. AuthState
```dart
class AuthState {
  final bool isAuthenticated;
  final bool isLoading;
  final AuthUserProfile? user;
  final String? error;
  final bool isEmailVerified;
  final bool isAnonymous;
}
```

## 🔧 Services

### 1. AuthService

Main authentication service with Firebase integration:

```dart
// Initialize auth service
await AuthService.initialize();

// Register new user
final result = await AuthService.registerWithEmail(registrationData);

// Sign in with email
final result = await AuthService.signInWithEmail(loginData);

// Sign in anonymously
final result = await AuthService.signInAnonymously();

// Sign out
await AuthService.signOut();

// Send password reset email
await AuthService.sendPasswordResetEmail(resetData);

// Update user profile
await AuthService.updateProfile(
  displayName: 'New Name',
  photoURL: 'https://example.com/photo.jpg',
);

// Change password
await AuthService.changePassword(
  currentPassword: 'oldPassword',
  newPassword: 'newPassword',
);

// Delete account
await AuthService.deleteAccount('password');

// Get current user
final user = AuthService.currentUser;

// Check authentication status
final isSignedIn = AuthService.isSignedIn;
final isEmailVerified = AuthService.isEmailVerified;
final isAnonymous = AuthService.isAnonymous;
```

### 2. AuthWrapper

Manages authentication state and routing:

```dart
class AuthWrapper extends StatefulWidget {
  // Automatically handles:
  // - Loading states
  // - Authentication checks
  // - Email verification requirements
  // - Error handling
  // - Route management
}
```

## 🚀 Usage Examples

### 1. Basic Authentication Flow

```dart
// Check if user is authenticated
if (AuthService.isSignedIn) {
  // User is logged in
  final user = AuthService.currentUser;
  print('User ID: ${user?.uid}');
  print('Email: ${user?.email}');
} else {
  // User needs to sign in
  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => const LoginScreen()),
  );
}
```

### 2. User Registration

```dart
final registrationData = RegistrationData(
  email: 'user@example.com',
  password: 'securePassword123',
  confirmPassword: 'securePassword123',
  fullName: 'John Doe',
  phoneNumber: '+1234567890',
  gender: 'male',
  preferredLanguage: 'en',
  acceptTerms: true,
  acceptPrivacy: true,
  subscribeToNewsletter: false,
);

final result = await AuthService.registerWithEmail(registrationData);

if (result.success) {
  // Registration successful
  print('User registered: ${result.user?.uid}');
} else {
  // Handle error
  print('Registration failed: ${result.error?.message}');
}
```

### 3. User Login

```dart
final loginData = LoginData(
  email: 'user@example.com',
  password: 'securePassword123',
  rememberMe: true,
);

final result = await AuthService.signInWithEmail(loginData);

if (result.success) {
  // Login successful
  Navigator.pushReplacement(
    context,
    MaterialPageRoute(builder: (context) => const MainApp()),
  );
} else {
  // Handle error
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(result.error?.message ?? 'Login failed')),
  );
}
```

### 4. Profile Management

```dart
// Get user profile
final profile = await AuthService.getUserProfile();
if (profile != null) {
  print('Name: ${profile.displayName}');
  print('Email: ${profile.email}');
  print('Phone: ${profile.phoneNumber}');
}

// Update profile
final result = await AuthService.updateProfile(
  displayName: 'New Display Name',
  phoneNumber: '+1234567890',
);

if (result.success) {
  print('Profile updated successfully');
}
```

### 5. Password Management

```dart
// Send password reset email
final resetData = PasswordResetData(email: 'user@example.com');
final result = await AuthService.sendPasswordResetEmail(resetData);

if (result.success) {
  print('Password reset email sent');
}

// Change password
final result = await AuthService.changePassword(
  currentPassword: 'oldPassword',
  newPassword: 'newSecurePassword123',
);

if (result.success) {
  print('Password changed successfully');
}
```

## 📱 Screens

### 1. LoginScreen
- Email/password authentication
- Remember me functionality
- Forgot password link
- Anonymous sign-in option
- Social login integration (ready)

### 2. RegisterScreen
- Complete registration form
- Data validation
- Terms and privacy acceptance
- Email verification flow

### 3. EmailVerificationScreen
- Email verification status
- Resend verification email
- Manual verification check

### 4. ForgotPasswordScreen
- Password reset request
- Email confirmation
- Resend functionality

### 5. ProfileManagementScreen
- Profile information editing
- Photo upload
- Password change
- Account deletion

### 6. AuthWrapper
- Authentication state management
- Automatic routing
- Loading states
- Error handling

## 🔒 Security Features

### Data Protection
- User data is isolated by user ID
- Sensitive data is encrypted in transit
- Local storage is secured
- Firebase security rules protect cloud data

### Authentication Security
- Email verification required
- Strong password validation
- Session management
- Automatic sign-out on errors

### Privacy Compliance
- Terms and conditions acceptance
- Privacy policy acknowledgment
- Data deletion on account removal
- User consent for data processing

## 🧪 Testing

### Test Authentication System

Use the `AuthTestScreen` to test all authentication features:

```dart
// Navigate to test screen
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => const AuthTestScreen(),
  ),
);
```

### Test Features
- Anonymous sign-in
- Sign-out
- User profile retrieval
- Auth state checking
- Password reset
- Profile updates
- Navigation to auth screens

## 🔄 State Management

### AuthState Stream
```dart
// Listen to auth state changes
AuthService.authStateChanges.listen((AuthState state) {
  if (state.isAuthenticated) {
    // User is logged in
    print('User: ${state.user?.email}');
  } else {
    // User is not logged in
    print('No user logged in');
  }
});
```

### Reactive UI Updates
The authentication system automatically updates the UI when:
- User signs in/out
- Email verification status changes
- Profile is updated
- Authentication errors occur

## 🚨 Error Handling

### Common Error Scenarios

#### 1. Network Errors
```dart
try {
  final result = await AuthService.signInWithEmail(loginData);
  if (!result.success) {
    // Handle authentication error
    print('Auth error: ${result.error?.message}');
  }
} catch (e) {
  // Handle network or other errors
  print('Network error: $e');
}
```

#### 2. Validation Errors
```dart
// Registration data validation
final validation = ValidationService.validateRegistrationData(data);
if (!validation.isValid) {
  // Show validation errors
  for (final error in validation.errors) {
    print('Validation error: $error');
  }
}
```

#### 3. Firebase Auth Errors
```dart
// Firebase-specific error handling
try {
  await AuthService.registerWithEmail(data);
} on FirebaseAuthException catch (e) {
  switch (e.code) {
    case 'email-already-in-use':
      print('Email already registered');
      break;
    case 'weak-password':
      print('Password too weak');
      break;
    case 'invalid-email':
      print('Invalid email format');
      break;
    default:
      print('Auth error: ${e.message}');
  }
}
```

## 📱 Platform Support

### Supported Platforms
- ✅ Android
- ✅ iOS
- ✅ Web
- ✅ Windows
- ✅ macOS
- ✅ Linux

### Firebase Services Used
- Firebase Authentication
- Cloud Firestore (user profiles)
- Firebase Storage (profile images)

## 🔧 Configuration

### Firebase Setup

1. **Enable Authentication Methods**
   - Email/Password
   - Anonymous (optional)

2. **Configure Firestore Security Rules**
   ```javascript
   rules_version = '2';
   service cloud.firestore {
     match /databases/{database}/documents {
       match /users/{userId} {
         allow read, write: if request.auth != null && request.auth.uid == userId;
       }
     }
   }
   ```

3. **Configure Firebase Storage Rules**
   ```javascript
   rules_version = '2';
   service firebase.storage {
     match /b/{bucket}/o {
       match /users/{userId}/{allPaths=**} {
         allow read, write: if request.auth != null && request.auth.uid == userId;
       }
     }
   }
   ```

### Environment Configuration

No additional environment variables needed. The system uses Firebase configuration files:
- `android/app/google-services.json`
- `ios/Runner/GoogleService-Info.plist`

## 🚀 Deployment

### Production Checklist

1. **Firebase Configuration**
   - [ ] Production Firebase project created
   - [ ] Authentication methods enabled
   - [ ] Security rules configured
   - [ ] App registered for all platforms

2. **App Configuration**
   - [ ] Firebase config files updated
   - [ ] App signing configured
   - [ ] Deep linking configured (if needed)

3. **Testing**
   - [ ] All authentication flows tested
   - [ ] Error scenarios tested
   - [ ] Performance tested
   - [ ] Security tested

## 🐛 Troubleshooting

### Common Issues

1. **"No user signed in"**
   - Check if user is actually signed in
   - Verify Firebase configuration
   - Check network connectivity

2. **"Email not verified"**
   - Check spam folder
   - Resend verification email
   - Verify email address

3. **"Invalid credentials"**
   - Check email/password combination
   - Verify user exists
   - Check for typos

4. **"Network error"**
   - Check internet connection
   - Verify Firebase project status
   - Check firewall settings

### Debug Mode

Enable debug logging:

```dart
// Add to main.dart
import 'package:flutter/foundation.dart';

void main() {
  if (kDebugMode) {
    // Enable debug logging
  }
  runApp(MyApp());
}
```

## 📚 Additional Resources

- [Firebase Authentication Documentation](https://firebase.google.com/docs/auth)
- [Flutter Firebase Auth Plugin](https://pub.dev/packages/firebase_auth)
- [Firebase Security Rules](https://firebase.google.com/docs/firestore/security/get-started)
- [Flutter State Management](https://flutter.dev/docs/development/data-and-backend/state-mgmt)

## 🤝 Contributing

When adding new authentication features:

1. Update auth models if needed
2. Add validation rules
3. Update auth service
4. Create/update UI screens
5. Add tests
6. Update documentation

## 📄 License

This authentication system is part of the Mali financial assistant project and follows the same license terms.
