# Mali - Your Financial Big Sister 💅✨

Mali is your AI-powered financial assistant with a strong feminist voice, big sister vibes, and lots of sassy quotes. She roasts you when you spend too much, provides deep insights about your money, and suggests personalized financial products to boost your savings.

## 🌟 Features

- **AI Financial Assistant** - Get sassy, personalized financial advice
- **Expense Tracking** - Track your spending with smart categorization
- **Budget Management** - Set and monitor budgets with alerts
- **Goal Setting** - Save towards your financial goals
- **Financial Reports** - Detailed insights and analytics
- **Backup & Restore** - Secure data backup and synchronization
- **Multi-language Support** - English, Kiswahili, Sheng
- **Local Kenyan Wisdom** - Culturally relevant financial advice

## 🚀 Quick Start

### Prerequisites
- Flutter SDK (3.8.1 or higher)
- Dart SDK
- Android Studio / VS Code
- Firebase account (for cloud features)

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/mali03.git
   cd mali03
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure Firebase** (Optional)
   - Create a Firebase project
   - Add `google-services.json` to `android/app/`
   - Add `GoogleService-Info.plist` to `ios/Runner/`

4. **Run the app**
   ```bash
   flutter run
   ```

## 📱 Deployment

### Web Deployment (Firebase Hosting)

1. **Build for web**
   ```bash
   flutter build web
   ```

2. **Deploy to Firebase**
   ```bash
   firebase deploy --only hosting
   ```

### Mobile App Deployment

#### Android (Google Play)
1. **Build APK**
   ```bash
   flutter build apk --release
   ```

2. **Upload to Google Play Console**
   - Create a developer account
   - Upload the APK
   - Configure store listing

#### iOS (App Store)
1. **Build for iOS**
   ```bash
   flutter build ios --release
   ```

2. **Upload to App Store Connect**
   - Use Xcode to archive and upload
   - Configure store listing

## 🔧 Development

### Project Structure
```
lib/
├── main.dart                 # App entry point
├── main_app.dart            # Main app widget
├── home_screen.dart         # Home screen
├── chat_screen.dart         # AI chat interface
├── expense_tracker.dart     # Expense tracking
├── budget_tracker.dart      # Budget management
├── goals_screen.dart        # Financial goals
├── profile_screen.dart      # User profile
├── backup_restore_screen.dart # Data backup
└── assets/                 # Images and resources
```

### Key Dependencies
- `shared_preferences` - Local data storage
- `firebase_core` - Firebase integration
- `firebase_auth` - User authentication
- `cloud_firestore` - Cloud database
- `http` - API requests
- `flutter_localizations` - Multi-language support

## 🛡️ Security & Backup

- **Local Data Storage** - Sensitive data stored locally
- **Secure Backups** - Encrypted backup system
- **Firebase Security** - Cloud data protection
- **Privacy First** - User data protection

## 🌍 Localization

Mali supports multiple languages:
- English (Default)
- Kiswahili
- Sheng (Kenyan slang)

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🆘 Support

- **Documentation**: [Wiki](https://github.com/yourusername/mali03/wiki)
- **Issues**: [GitHub Issues](https://github.com/yourusername/mali03/issues)
- **Discussions**: [GitHub Discussions](https://github.com/yourusername/mali03/discussions)

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- Firebase for backend services
- Kenyan financial community for insights
- All contributors and beta testers

---

**Made with 💅✨ by the Mali team**
