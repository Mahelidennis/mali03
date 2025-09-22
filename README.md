# Mali - Your Personal Financial AI Assistant 💰

A beautiful Flutter web application that helps you manage your finances with the help of an AI assistant named Mali.

## Features

- 🤖 **AI-Powered Chat**: Get personalized financial advice from Mali
- 💳 **Expense Tracking**: Track your daily expenses with categories
- 💰 **Income Management**: Monitor your income sources
- 🎯 **Goal Setting**: Set and track financial goals
- 📊 **Financial Reports**: Visualize your financial data
- 🔐 **User Authentication**: Secure login with Firebase
- 📱 **Responsive Design**: Works on desktop and mobile

## Tech Stack

- **Frontend**: Flutter Web
- **Backend**: Firebase (Authentication, Firestore, Storage)
- **Deployment**: Vercel
- **State Management**: Flutter StatefulWidget

## Getting Started

### Prerequisites

- Flutter SDK (3.0+)
- Firebase project
- Node.js (for deployment)

### Installation

1. Clone the repository
2. Install Flutter dependencies:
   ```bash
   flutter pub get
   ```

3. Configure Firebase:
   - Add your Firebase configuration to `lib/firebase_options.dart`
   - Enable Authentication, Firestore, and Storage in Firebase Console

4. Run the app:
   ```bash
   flutter run -d chrome
   ```

### Deployment

This app is configured for deployment on Vercel:

1. Build the web app:
   ```bash
   flutter build web --release
   ```

2. Deploy to Vercel:
   - Connect your GitHub repository to Vercel
   - Vercel will automatically detect the Flutter app and deploy it

## Project Structure

```
lib/
├── main.dart                 # App entry point
├── models/                   # Data models
├── services/                 # Business logic services
├── screens/                  # UI screens
│   ├── auth/                # Authentication screens
│   ├── finance_screen.dart  # Combined finance management
│   ├── goals_screen.dart    # Goals and budget tracking
│   └── enhanced_mali_chat.dart # AI chat interface
├── widgets/                  # Reusable UI components
└── firebase_options.dart     # Firebase configuration
```

## Features in Detail

### Mali AI Assistant
- Personalized financial advice
- Multiple personality modes (Sassy & Bold, Encouraging & Gentle, Professional & Direct)
- Context-aware responses based on your financial data
- Beautiful animated interface

### Financial Management
- **Expense Tracking**: Add, edit, and categorize expenses
- **Income Management**: Track multiple income sources
- **Budget Tracking**: Set and monitor budgets
- **Goal Setting**: Create and track financial goals
- **Reports**: Visualize spending patterns and trends

### User Experience
- **Guest Mode**: Try the app without creating an account
- **Authentication**: Secure login with email/password or anonymous
- **Responsive Design**: Optimized for all screen sizes
- **Dark/Light Theme**: Automatic theme switching

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Support

For support, email support@mali-app.com or create an issue in this repository.

---

Made with ❤️ by the Mali Team