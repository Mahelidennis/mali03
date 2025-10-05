import 'dart:convert';
import 'package:http/http.dart' as http;
import 'offline_mali_service.dart';
import 'groq_service.dart';
import '../config/api_config.dart';

/// Hybrid Mali service that tries API first, falls back to offline intelligence
class HybridMaliService {
  
  /// Get Mali's response with API fallback
  static Future<String> getMaliResponse({
    required String userMessage,
    required Map<String, dynamic> financialContext,
    required String selectedVibe,
    List<Map<String, String>>? conversationHistory,
    bool preferOffline = false,
  }) async {
    
    // If offline is preferred or no API key, use offline service
    if (preferOffline || !ApiConfig.isGroqConfigured) {
      return OfflineMaliService.getMaliResponse(
        userMessage: userMessage,
        financialContext: financialContext,
        selectedVibe: selectedVibe,
        conversationHistory: conversationHistory,
      );
    }

    try {
      // Try Groq API first
      final apiResponse = await GroqService.getMaliCoachingResponse(
        userMessage: userMessage,
        financialContext: financialContext,
        conversationHistory: conversationHistory,
      );
      
      if (apiResponse.isNotEmpty) {
        return apiResponse;
      }
    } catch (e) {
      print('Groq API failed, falling back to offline: $e');
    }

    // Fallback to offline service
    return OfflineMaliService.getMaliResponse(
      userMessage: userMessage,
      financialContext: financialContext,
      selectedVibe: selectedVibe,
      conversationHistory: conversationHistory,
    );
  }

  /// Check if we have a valid API key
  static bool _hasValidApiKey() {
    return ApiConfig.isGroqConfigured;
  }


  /// Test API connectivity
  static Future<bool> testApiConnection() async {
    return await GroqService.testConnection();
  }
}
