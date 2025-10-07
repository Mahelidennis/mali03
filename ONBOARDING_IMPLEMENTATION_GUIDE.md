# Mali Onboarding Flow Implementation Guide

## Overview
This document describes the implementation of the 3-screen onboarding flow for the Mali app, matching the visual design specifications.

## Architecture

### 📁 File Structure

```
lib/
├── models/
│   └── onboarding_models.dart       # Data models for onboarding
├── services/
│   └── onboarding_service.dart      # Business logic for onboarding
└── screens/
    └── onboarding/
        ├── welcome_screen.dart       # Screen 1: Welcome
        ├── vibe_selection_screen.dart # Screen 2: Vibe Selection
        ├── permissions_screen.dart    # Screen 3: Permissions & Privacy
        └── onboarding_flow.dart       # Flow controller
```

## 🎨 Screens

### 1. Welcome Screen
**Purpose**: Introduce Mali and set the tone for the app

**Components**:
- 👋 Waving hand emoji (80px)
- Heading: "Hey there, future boss babe! 💅"
- Description: Introduces Mali as a financial big sister
- Primary button: "Get Started"

**Navigation**: Moves to Vibe Selection Screen

### 2. Vibe Selection Screen
**Purpose**: Let users choose how Mali communicates with them

**Components**:
- Progress indicator (pink bar)
- Heading: "Choose your vibe"
- Description: Explains vibe selection
- Three vibe options:
  1. **Sassy & Bold** (💁‍♀️) - "Your hype-woman for all things money"
  2. **Encouraging & Gentle** (😊) - "A soft nudge in the right direction"
  3. **No-Nonsense & Direct** (😠) - "Just the facts, straight up"
- Primary button: "Continue" (disabled until selection)

**Navigation**: Moves to Permissions Screen

### 3. Permissions Screen
**Purpose**: Request access permissions and explain privacy

**Components**:
- 🔒 Lock emoji (80px)
- Heading: "Your Privacy is Our Priority"
- Description: Explains why permissions are needed
- Privacy policy link (opens externally)
- Two buttons:
  - "Agree & Continue" (primary)
  - "Manage Permissions Later" (secondary)

**Navigation**: Completes onboarding and enters main app

## 🔧 Services

### OnboardingService
**Location**: `lib/services/onboarding_service.dart`

**Methods**:
```dart
// State management
Future<OnboardingState> getOnboardingState()
Future<bool> saveOnboardingState(OnboardingState state)

// Vibe management
List<MaliVibe> getAvailableVibes()
MaliVibe? getVibeById(String id)
Future<bool> selectVibe(String vibeId)
Future<MaliVibe?> getUserSelectedVibe()

// Progress tracking
Future<bool> completeWelcome()
Future<bool> acceptPermissions()
Future<bool> completeOnboarding()
Future<bool> isOnboardingComplete()

// Utility
Future<bool> resetOnboarding()  // For testing
```

## 💾 Data Models

### MaliVibe
```dart
class MaliVibe {
  final String id;              // Unique identifier
  final String title;           // Display name
  final String description;     // User-facing description
  final String emoji;           // Emoji representation
  final String color;           // Color theme
  final bool isSelected;        // Selection state
}
```

### OnboardingState
```dart
class OnboardingState {
  final bool hasCompletedWelcome;
  final String? selectedVibeId;
  final bool hasAcceptedPermissions;
  final bool hasCompletedOnboarding;
}
```

## 🎯 Integration

### Main App Integration
The onboarding flow is integrated into the main app through `OnboardingWrapper`:

```dart
@override
Widget build(BuildContext context) {
  return OnboardingWrapper(
    child: MainApp(),
  );
}
```

**OnboardingWrapper** automatically:
- Checks if onboarding is complete
- Shows onboarding flow if not complete
- Shows main app if complete
- Handles loading states

## 🎨 Design System

### Colors
- **Primary Pink**: `#EE2B8D` - Buttons, selections, accents
- **Light Pink Background**: `#FDF2F8` - App background
- **Text Dark**: `#181114` - Primary text
- **Text Gray**: `#6B7280` - Secondary text
- **Border Gray**: `#E5E7EB` - Borders

### Typography
- **Headings**: 28px, Bold, Dark text
- **Body**: 16px, Regular, Dark text
- **Buttons**: 16px, Semi-bold, White on pink

### Spacing
- **Horizontal padding**: 24px
- **Vertical spacing**: 16-32px
- **Button height**: 56px
- **Icon size**: 80px (emojis)

### Components
- **Buttons**: 
  - Border radius: 12px
  - Height: 56px
  - Full width
  - Pink background with white text
- **Cards** (vibe options):
  - Border radius: 12px
  - Padding: 20px
  - Selected: Pink border (2px), light pink background
  - Unselected: Gray border (1px), white background

## 📱 User Flow

```
App Launch
    ↓
OnboardingWrapper checks completion
    ├─→ [Complete] → Main App
    └─→ [Not Complete] → Onboarding Flow
                             ↓
                        Welcome Screen
                             ↓
                        [Get Started]
                             ↓
                        Vibe Selection
                             ↓
                        [Select & Continue]
                             ↓
                        Permissions Screen
                             ↓
                    [Agree or Manage Later]
                             ↓
                    Mark onboarding complete
                             ↓
                          Main App
```

## 🔄 State Management

### Storage
- Uses `SharedPreferences` for persistence
- Stores onboarding state as JSON
- Key: `'mali_onboarding_state'`

### State Flow
1. User opens app
2. `OnboardingWrapper` loads onboarding state
3. If incomplete, shows appropriate screen
4. User progresses through screens
5. Each screen updates state
6. Final screen marks onboarding complete
7. State saved to SharedPreferences
8. Main app loads

## 🧪 Testing

### Manual Testing
1. **First Launch**: Should show welcome screen
2. **Navigation**: Should progress through all 3 screens
3. **Back Navigation**: Should allow going back
4. **Vibe Selection**: Should require selection before continuing
5. **Permissions**: Both buttons should work
6. **Completion**: Should show main app after completion
7. **Re-launch**: Should go directly to main app

### Reset Onboarding
```dart
await OnboardingService.instance.resetOnboarding();
// App will show onboarding again on next launch
```

## 🔗 Dependencies

### Required Packages
```yaml
dependencies:
  shared_preferences: ^2.0.0  # State persistence
  url_launcher: ^6.1.0        # Privacy policy links
```

## 📝 Future Enhancements

### Potential Improvements
1. **Analytics**: Track onboarding completion rates
2. **A/B Testing**: Test different copy and designs
3. **Animations**: Add smooth transitions between screens
4. **Personalization**: Remember user's vibe across app
5. **Skip Option**: Allow advanced users to skip
6. **Tutorial**: Add optional tutorial after onboarding
7. **Re-onboarding**: Allow users to change vibe in settings

## 🎯 Integration with Existing Features

### Vibe Usage
The selected vibe can be used throughout the app:

```dart
// Get user's selected vibe
final vibe = await OnboardingService.instance.getUserSelectedVibe();

// Use vibe to customize Mali's responses
if (vibe?.id == 'sassy_bold') {
  // Use sassy tone in AI responses
} else if (vibe?.id == 'encouraging_gentle') {
  // Use gentle tone in AI responses
} else if (vibe?.id == 'no_nonsense_direct') {
  // Use direct tone in AI responses
}
```

### Permissions Integration
The permissions screen integrates with existing permission services:
- SMS Permission Screen
- Privacy Policy Screen
- Settings Screen

## 🚀 Deployment

The onboarding flow is automatically included when building the app:

```bash
# Build for web
flutter build web --release

# Build for Android
flutter build apk --release

# Build for iOS
flutter build ios --release
```

## ✅ Checklist

- [x] Welcome screen implemented
- [x] Vibe selection screen implemented
- [x] Permissions screen implemented
- [x] OnboardingService created
- [x] Data models created
- [x] Main app integration complete
- [x] State persistence implemented
- [x] Navigation flow working
- [x] Design system matching
- [x] Documentation complete

## 📚 Related Documentation

- `PRIVACY_POLICY.md` - Privacy policy details
- `SMS_CONSENT_DOCUMENTATION.md` - SMS permissions
- `USER_GUIDE.md` - User-facing documentation
- `MALI_COACH_IMPLEMENTATION_GUIDE.md` - AI coaching features

---

**Last Updated**: October 7, 2025
**Version**: 1.0.0
**Author**: Mali Development Team
