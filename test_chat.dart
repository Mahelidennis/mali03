import 'lib/services/offline_mali_service.dart';

void main() {
  // Test the offline Mali service
  final financialContext = {
    'totalExpenses': 50000.0,
    'totalIncome': 75000.0,
    'activeGoals': 3,
    'budgetStatus': 'Under Budget',
  };

  print('Testing Mali Chat Service...\n');

  // Test different types of messages
  final testMessages = [
    'Hello Mali!',
    'Help me with my budget',
    'I want to save more money',
    'What should I do about my expenses?',
    'How can I invest my money?',
  ];

  for (final message in testMessages) {
    final response = OfflineMaliService.getMaliResponse(
      userMessage: message,
      financialContext: financialContext,
      selectedVibe: 'Sassy & Bold',
    );
    
    print('User: $message');
    print('Mali: $response\n');
    print('-' * 50 + '\n');
  }
}
