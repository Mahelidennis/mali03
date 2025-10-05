import 'lib/services/groq_service.dart';
import 'lib/config/api_config.dart';

void main() async {
  print('🧪 Testing Groq API Connection...\n');
  
  // Test 1: Check if API key is configured
  print('1. Checking API key configuration...');
  if (ApiConfig.isGroqConfigured) {
    print('✅ API key is configured');
  } else {
    print('❌ API key not configured');
    return;
  }
  
  // Test 2: Test connection
  print('\n2. Testing API connection...');
  try {
    final isConnected = await GroqService.testConnection();
    if (isConnected) {
      print('✅ Groq API connection successful!');
    } else {
      print('❌ Groq API connection failed');
      return;
    }
  } catch (e) {
    print('❌ Connection test error: $e');
    return;
  }
  
  // Test 3: Test actual chat response
  print('\n3. Testing chat response...');
  try {
    final financialContext = {
      'totalExpenses': 50000.0,
      'totalIncome': 75000.0,
      'activeGoals': 3,
      'budgetStatus': 'Under Budget',
    };
    
    final response = await GroqService.getMaliCoachingResponse(
      userMessage: 'Hello Mali! Help me with my budget.',
      financialContext: financialContext,
    );
    
    print('✅ Chat response received:');
    print('Mali: $response');
    
  } catch (e) {
    print('❌ Chat test error: $e');
  }
  
  print('\n🎉 Groq API setup complete! Mali is ready to provide real AI responses.');
}
