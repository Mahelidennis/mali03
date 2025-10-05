# Mali Financial Assistant 💪

**Empowering Financial Freedom Through Technology**

Mali is your personal financial big sister, designed to help young women make smart money decisions with practical financial knowledge and empowering support. Built with Flutter and powered by AI, Mali provides comprehensive financial management tools, automatic transaction tracking, and personalized financial advice.

## 🌟 Features

### Core Financial Management
- **Budget Tracking**: Set and monitor monthly budgets
- **Expense Management**: Track and categorize expenses
- **Income Tracking**: Monitor all income sources
- **Goal Setting**: Create and track financial goals
- **Financial Reports**: Comprehensive financial analytics

### AI-Powered Assistant
- **Mali Chat**: Your sassy and supportive financial big sister
- **Personalized Advice**: AI-powered financial recommendations
- **Context Awareness**: Remembers your financial situation
- **Real-time Insights**: Instant financial insights and tips

### SMS Integration (Phase 1)
- **Automatic M-PESA Tracking**: Automatically track M-PESA transactions
- **Smart Categorization**: AI-powered expense categorization
- **Real-time Updates**: Transactions appear immediately
- **Privacy-First**: Local processing, secure storage

### Advanced Features
- **Multi-Platform**: Available on Android, iOS, and Web
- **Cloud Sync**: Optional cloud synchronization
- **Data Export**: Export your financial data
- **Offline Support**: Core features work offline

## 🚀 Getting Started

### Prerequisites
- Flutter SDK 3.0.0 or higher
- Dart SDK 3.0.0 or higher
- Android Studio or VS Code
- Firebase project setup

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/your-username/mali03.git
   cd mali03
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure Firebase**
   - Add your `google-services.json` to `android/app/`
   - Add your `GoogleService-Info.plist` to `ios/Runner/`
   - Update Firebase configuration in `lib/firebase_options.dart`

4. **Run the app**
   ```bash
   flutter run
   ```

### Web Deployment

1. **Build for web**
   ```bash
   flutter build web --release
   ```

2. **Deploy to Firebase**
   ```bash
   firebase deploy --only hosting
   ```

## 📱 Platform Support

- **Android**: 7.0+ (API level 24+)
- **iOS**: 12.0+
- **Web**: Modern browsers with JavaScript enabled
- **Desktop**: Windows, macOS, Linux (experimental)

## 🏗️ Architecture

### Tech Stack
- **Frontend**: Flutter 3.0+
- **Backend**: Firebase (Auth, Firestore, Storage)
- **AI Services**: OpenRouter API
- **State Management**: Flutter State Management
- **Local Storage**: SharedPreferences
- **SMS Integration**: SMS Advanced (Android)

### Project Structure
```
lib/
├── config/                 # Configuration files
├── models/                 # Data models
├── screens/                # UI screens
├── services/               # Business logic services
├── widgets/                # Reusable UI components
├── utils/                  # Utility functions
└── main.dart              # App entry point
```

## 🔒 Privacy and Security

### Data Protection
- **Local Processing**: SMS messages processed locally
- **Encryption**: Bank-level encryption for all data
- **No Raw Storage**: Raw SMS content never stored
- **User Control**: Full control over your data

### Compliance
- **Data Protection Act 2019 (Kenya)**: Full compliance
- **GDPR (EU)**: Compliance with EU data protection laws
- **CCPA (California)**: Compliance with California privacy laws
- **Financial Regulations**: CBK and financial services compliance

## 📚 Documentation

### User Documentation
- [User Guide](USER_GUIDE.md) - Comprehensive user guide
- [SMS Integration Guide](SMS_CONSENT_DOCUMENTATION.md) - SMS integration details
- [Privacy Policy](PRIVACY_POLICY.md) - Privacy policy and data handling
- [Terms of Service](TERMS_OF_SERVICE.md) - Terms and conditions

### Technical Documentation
- [Data Protection Policy](DATA_PROTECTION_POLICY.md) - Data protection framework
- [Legal Disclaimers](LEGAL_DISCLAIMERS.md) - Legal disclaimers and limitations
- [Company Protection Framework](COMPANY_PROTECTION_FRAMEWORK.md) - Company protection measures

### API Documentation
- [OpenRouter API Integration](lib/services/openrouter_service.dart) - AI service integration
- [Firebase Services](lib/services/) - Firebase integration services
- [SMS Services](lib/services/sms_service_factory.dart) - SMS integration services

## 🛠️ Development

### Setting Up Development Environment

1. **Install Flutter**
   ```bash
   # Follow official Flutter installation guide
   # https://flutter.dev/docs/get-started/install
   ```

2. **Install Dependencies**
   ```bash
   flutter pub get
   ```

3. **Run Tests**
   ```bash
   flutter test
   ```

4. **Build APK**
   ```bash
   flutter build apk --release
   ```

### Code Style
- Follow Flutter/Dart style guidelines
- Use meaningful variable and function names
- Add comments for complex logic
- Maintain consistent indentation

### Contributing
1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## 🔧 Configuration

### Environment Variables
Create a `.env` file in the root directory:
```env
OPENROUTER_API_KEY=your_openrouter_api_key
FIREBASE_PROJECT_ID=your_firebase_project_id
```

### Firebase Configuration
1. Create a Firebase project
2. Enable Authentication, Firestore, and Storage
3. Download configuration files
4. Update `lib/firebase_options.dart`

### SMS Integration Setup
1. Add SMS permissions to `android/app/src/main/AndroidManifest.xml`
2. Configure SMS service in `lib/services/sms_service_factory.dart`
3. Test SMS integration on physical device

## 🚀 Deployment

### Android
1. **Generate signed APK**
   ```bash
   flutter build apk --release
   ```

2. **Upload to Google Play Store**
   - Follow Google Play Console guidelines
   - Ensure compliance with store policies

### iOS
1. **Build for iOS**
   ```bash
   flutter build ios --release
   ```

2. **Upload to App Store**
   - Follow Apple App Store guidelines
   - Ensure compliance with store policies

### Web
1. **Build for web**
   ```bash
   flutter build web --release
   ```

2. **Deploy to Firebase Hosting**
   ```bash
   firebase deploy --only hosting
   ```

## 📊 Analytics and Monitoring

### Firebase Analytics
- User engagement tracking
- Feature usage analytics
- Performance monitoring
- Crash reporting

### Custom Analytics
- Financial goal tracking
- Budget adherence monitoring
- User behavior analysis
- Feature adoption metrics

## 🔐 Security Considerations

### Data Security
- All data encrypted in transit and at rest
- Local processing of sensitive data
- Secure key management
- Regular security audits

### Privacy Protection
- Minimal data collection
- User consent for all data processing
- Data retention policies
- User data deletion capabilities

## 🌍 Internationalization

### Supported Languages
- English (primary)
- Swahili (secondary)
- Additional languages planned

### Localization
- Currency formatting
- Date/time formatting
- Cultural considerations
- Regional compliance

## 📈 Roadmap

### Phase 1 (Current)
- ✅ Core financial management
- ✅ AI chat integration
- ✅ SMS M-PESA tracking
- ✅ Web deployment

### Phase 2 (Planned)
- 🔄 Enhanced ML-based parsing
- 🔄 Email integration for bank statements
- 🔄 Receipt OCR processing
- 🔄 Advanced spending pattern analysis

### Phase 3 (Future)
- 📋 Multi-source data integration
- 📋 Predictive financial modeling
- 📋 Goal-based recommendations
- 📋 Advanced AI insights

## 🤝 Support

### User Support
- **Email**: support@mali-app.com
- **Website**: www.mali-app.com
- **Community**: community.mali-app.com
- **FAQ**: Check our frequently asked questions

### Developer Support
- **Documentation**: Comprehensive technical documentation
- **API Reference**: Detailed API documentation
- **Code Examples**: Sample code and tutorials
- **Community**: Developer community and forums

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- **Flutter Team**: For the amazing framework
- **Firebase Team**: For the backend services
- **OpenRouter Team**: For AI services
- **Community**: For feedback and contributions

## 📞 Contact

- **Email**: hello@mali-app.com
- **Website**: www.mali-app.com
- **Twitter**: @MaliApp
- **LinkedIn**: Mali Financial Assistant

---

**Mali Financial Assistant**  
*Empowering Financial Freedom Through Technology*

*Built with ❤️ for young women who want to take control of their finances*