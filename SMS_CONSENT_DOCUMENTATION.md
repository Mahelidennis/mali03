# SMS Integration - Consent and Permission Documentation

**Mali Financial Assistant**  
**Version 1.0 - December 2024**

## 1. Overview

This document provides comprehensive information about Mali's SMS integration feature, including what data is collected, how it's processed, and your rights as a user. This is essential reading before enabling SMS tracking.

## 2. What is SMS Integration?

SMS Integration allows Mali to automatically track your M-PESA and mobile money transactions by reading SMS messages from your phone. This eliminates the need for manual data entry and provides a complete picture of your financial activity.

### 2.1 How It Works
1. **Permission Request**: Mali requests permission to read SMS messages
2. **Message Filtering**: Only M-PESA and mobile money messages are processed
3. **Data Extraction**: Transaction details are automatically extracted
4. **Local Processing**: All processing happens on your device
5. **Secure Storage**: Only processed transaction data is stored

### 2.2 Benefits
- **Automatic Tracking**: No need to manually enter transactions
- **Complete Picture**: Captures all M-PESA activity
- **Real-time Updates**: Transactions appear immediately
- **Accurate Categorization**: Smart categorization of expenses
- **Time Saving**: Eliminates manual data entry

## 3. What Data is Collected

### 3.1 SMS Messages Processed
Mali only processes SMS messages from the following senders:
- **MPESA**: M-PESA transaction confirmations
- **Safaricom**: M-PESA service messages
- **Other Mobile Money**: Similar services (with your consent)

### 3.2 Data Extracted
For each transaction, Mali extracts:
- **Transaction Amount**: The amount of money involved
- **Recipient/Sender**: Who you sent money to or received from
- **Date and Time**: When the transaction occurred
- **Transaction Type**: Send, receive, buy goods, pay bills, withdraw, etc.
- **Reference Number**: Transaction reference (if available)

### 3.3 Data NOT Collected
Mali does NOT collect or process:
- **Personal Messages**: Your personal SMS conversations
- **Other App Messages**: Messages from other apps or services
- **Bank Messages**: Bank SMS messages (unless specifically enabled)
- **Marketing Messages**: Promotional or marketing SMS
- **Raw SMS Content**: The full text of SMS messages

## 4. Data Processing and Storage

### 4.1 Local Processing
- **Device-Only**: All SMS processing happens on your device
- **No Cloud Upload**: Raw SMS messages are never uploaded to the cloud
- **Immediate Processing**: Messages are processed as soon as they arrive
- **Temporary Storage**: Raw messages are processed and discarded

### 4.2 Processed Data Storage
- **Transaction Records**: Only extracted transaction data is stored
- **Local Storage**: Data stored securely on your device
- **Encrypted Storage**: All stored data is encrypted
- **Optional Cloud Sync**: You can choose to sync data to the cloud

### 4.3 Data Retention
- **Local Storage**: Data retained on your device until deleted
- **Cloud Storage**: Optional cloud backup (if enabled)
- **Retention Period**: You control how long data is retained
- **Automatic Deletion**: Old data can be automatically deleted

## 5. Your Rights and Controls

### 5.1 Permission Control
- **Grant Permission**: You choose whether to enable SMS tracking
- **Revoke Permission**: You can disable SMS tracking anytime
- **Selective Tracking**: Choose which accounts to track
- **Granular Control**: Control what data is processed

### 5.2 Data Control
- **View Data**: See all processed transaction data
- **Edit Data**: Correct or modify transaction details
- **Delete Data**: Remove specific transactions or all data
- **Export Data**: Download your transaction history

### 5.3 Privacy Controls
- **Data Minimization**: Only necessary data is processed
- **Purpose Limitation**: Data used only for financial tracking
- **Transparency**: Clear information about data processing
- **Accountability**: We're accountable for data protection

## 6. Security and Privacy

### 6.1 Security Measures
- **Local Processing**: SMS messages never leave your device
- **Encryption**: All stored data is encrypted
- **Access Controls**: Strict access controls and authentication
- **Regular Audits**: Regular security audits and assessments

### 6.2 Privacy Protection
- **Data Minimization**: Collect only necessary data
- **Purpose Limitation**: Use data only for stated purposes
- **Retention Limits**: Retain data only as long as necessary
- **User Control**: You control your data

### 6.3 Third-Party Sharing
- **No Raw Data**: Raw SMS content is never shared
- **Processed Data Only**: Only transaction summaries may be shared
- **Limited Sharing**: Shared only with trusted service providers
- **Your Consent**: Shared only with your explicit consent

## 7. Legal and Regulatory Compliance

### 7.1 Data Protection Laws
- **Data Protection Act 2019 (Kenya)**: Full compliance with Kenyan data protection laws
- **GDPR (EU)**: Compliance with EU data protection regulations
- **CCPA (California)**: Compliance with California privacy laws
- **Industry Standards**: Adherence to financial services data protection standards

### 7.2 Financial Regulations
- **Central Bank of Kenya**: Compliance with CBK regulations
- **Financial Services Act**: Adherence to financial services laws
- **Consumer Protection**: Compliance with consumer protection laws
- **Anti-Money Laundering**: Adherence to AML regulations

### 7.3 Consent Requirements
- **Explicit Consent**: Clear, informed consent required
- **Granular Consent**: Consent for specific data processing activities
- **Withdrawable Consent**: You can withdraw consent anytime
- **Documented Consent**: All consent is properly documented

## 8. Risks and Considerations

### 8.1 Potential Risks
- **Data Breach**: Risk of unauthorized access to your data
- **Privacy Concerns**: Concerns about data collection and use
- **Technical Issues**: Potential technical problems with SMS processing
- **Battery Usage**: SMS processing may use additional battery

### 8.2 Mitigation Measures
- **Strong Security**: Robust security measures to prevent breaches
- **Transparency**: Clear information about data processing
- **User Control**: Full control over your data
- **Regular Updates**: Regular security and privacy updates

### 8.3 Your Responsibilities
- **Device Security**: Keep your device secure and updated
- **Permission Management**: Manage SMS permissions carefully
- **Data Review**: Regularly review your transaction data
- **Report Issues**: Report any security or privacy concerns

## 9. Alternative Options

### 9.1 Manual Entry
- **Full Control**: Complete control over data entry
- **No SMS Access**: No need to grant SMS permissions
- **Custom Categories**: Create your own categories
- **Selective Entry**: Enter only transactions you want to track

### 9.2 Hybrid Approach
- **Selective SMS**: Enable SMS for specific accounts only
- **Manual Supplement**: Add transactions manually as needed
- **Custom Rules**: Set custom rules for SMS processing
- **Regular Review**: Regularly review and correct SMS data

### 9.3 Third-Party Integration
- **Bank Integration**: Connect directly to your bank account
- **Email Integration**: Process bank statements via email
- **API Integration**: Use official banking APIs
- **Manual Import**: Import data from other financial apps

## 10. Consent Process

### 10.1 Initial Consent
1. **Information Display**: Clear information about SMS integration
2. **Benefits Explanation**: Explanation of benefits and features
3. **Risks Disclosure**: Information about potential risks
4. **Consent Request**: Clear request for consent
5. **Permission Grant**: Grant SMS permission through device settings

### 10.2 Ongoing Consent
- **Regular Review**: Periodic review of consent
- **Change Notifications**: Notification of any changes
- **Consent Renewal**: Renewal of consent as needed
- **Withdrawal Process**: Easy process to withdraw consent

### 10.3 Consent Withdrawal
- **Immediate Effect**: Consent withdrawal takes effect immediately
- **Data Deletion**: Option to delete all SMS-related data
- **Service Continuation**: App continues to work without SMS integration
- **Re-consent**: Can re-enable SMS integration anytime

## 11. Technical Implementation

### 11.1 SMS Reading
- **Permission-Based**: Requires explicit user permission
- **Filtered Reading**: Only reads M-PESA messages
- **Local Processing**: All processing happens on device
- **Secure Handling**: Secure handling of SMS data

### 11.2 Data Processing
- **Regex Parsing**: Pattern matching to extract transaction data
- **Machine Learning**: AI-powered categorization
- **Error Handling**: Robust error handling and validation
- **Performance Optimization**: Efficient processing algorithms

### 11.3 Data Storage
- **Local Database**: Secure local database storage
- **Encryption**: All data encrypted at rest
- **Backup**: Optional encrypted backup
- **Sync**: Optional cloud synchronization

## 12. User Education and Support

### 12.1 Educational Resources
- **User Guide**: Comprehensive user guide
- **Video Tutorials**: Step-by-step video guides
- **FAQ Section**: Frequently asked questions
- **Best Practices**: Tips for effective use

### 12.2 Support Channels
- **In-App Help**: Help feature within the app
- **Email Support**: support@mali-app.com
- **Community Forum**: User community and support
- **Live Chat**: Real-time support during business hours

### 12.3 Training and Awareness
- **Privacy Training**: Regular privacy and security training
- **User Education**: Ongoing user education about data protection
- **Awareness Campaigns**: Regular awareness campaigns
- **Feedback Collection**: Regular feedback collection and improvement

## 13. Monitoring and Compliance

### 13.1 Compliance Monitoring
- **Regular Audits**: Regular compliance audits
- **Privacy Impact Assessments**: Regular privacy impact assessments
- **Regulatory Updates**: Monitoring of regulatory changes
- **Best Practice Updates**: Regular updates to best practices

### 13.2 User Rights Monitoring
- **Consent Tracking**: Tracking of user consent
- **Data Subject Requests**: Handling of data subject requests
- **Complaint Handling**: Processing of privacy complaints
- **Remediation**: Remediation of privacy issues

### 13.3 Continuous Improvement
- **Feedback Integration**: Integration of user feedback
- **Process Improvement**: Continuous process improvement
- **Technology Updates**: Regular technology updates
- **Training Updates**: Regular training updates

## 14. Contact Information

### 14.1 Privacy Questions
- **Email**: privacy@mali-app.com
- **Phone**: [Privacy Contact Number]
- **Address**: [Company Address]
- **Response Time**: Within 30 days

### 14.2 Technical Support
- **Email**: support@mali-app.com
- **Phone**: [Support Contact Number]
- **Live Chat**: Available in app
- **Response Time**: Within 24 hours

### 14.3 Data Protection Officer
- **Email**: dpo@mali-app.com
- **Phone**: [DPO Contact Number]
- **Address**: [Company Address]
- **Response Time**: Within 30 days

## 15. Conclusion

SMS integration is a powerful feature that can significantly improve your financial tracking experience. However, it's important to understand what data is collected, how it's processed, and your rights as a user.

### Key Points to Remember:
- **Your Choice**: SMS integration is completely optional
- **Your Control**: You have full control over your data
- **Your Rights**: You have comprehensive privacy rights
- **Your Security**: We use industry-standard security measures
- **Your Support**: We're here to help with any questions

### Before Enabling SMS Integration:
1. **Read This Document**: Understand what's involved
2. **Consider Alternatives**: Think about manual entry options
3. **Ask Questions**: Contact us if you have any concerns
4. **Make an Informed Decision**: Choose what's right for you

### After Enabling SMS Integration:
1. **Monitor Your Data**: Regularly review your transaction data
2. **Report Issues**: Let us know about any problems
3. **Update Preferences**: Adjust settings as needed
4. **Stay Informed**: Keep up with updates and changes

Remember: You can disable SMS integration anytime, and we'll delete all related data if you request it.

---

**Mali Financial Assistant**  
*Empowering Financial Freedom Through Technology*

*This document is effective as of December 2024 and applies to all SMS integration features of Mali Financial Assistant.*

