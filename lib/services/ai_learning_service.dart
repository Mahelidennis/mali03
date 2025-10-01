import 'dart:convert';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import 'financial_personality_service.dart';
import 'behavioral_analysis_service.dart';
import 'coaching_intervention_service.dart';
import 'emotional_therapy_service.dart';

class AILearningService {
  static const String _learningDataKey = 'ai_learning_data';
  static const String _conversationHistoryKey = 'conversation_history';
  static const String _userPreferencesKey = 'user_preferences';
  static const String _responseEffectivenessKey = 'response_effectiveness';

  // Learn from user interactions
  static Future<void> learnFromInteraction(
    String userInput,
    String aiResponse,
    Map<String, dynamic> context,
  ) async {
    // Save conversation
    await _saveConversation(userInput, aiResponse, context);
    
    // Analyze user sentiment and preferences
    await _analyzeUserSentiment(userInput, context);
    
    // Update personality understanding
    await _updatePersonalityUnderstanding(context);
    
    // Learn response preferences
    await _learnResponsePreferences(userInput, aiResponse, context);
    
    // Update coaching strategies
    await _updateCoachingStrategies(context);
  }

  // Save conversation for learning
  static Future<void> _saveConversation(
    String userInput,
    String aiResponse,
    Map<String, dynamic> context,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final historyString = prefs.getString(_conversationHistoryKey) ?? '[]';
    final history = List<Map<String, dynamic>>.from(jsonDecode(historyString));
    
    history.add({
      'userInput': userInput,
      'aiResponse': aiResponse,
      'context': context,
      'timestamp': DateTime.now().toIso8601String(),
      'sessionId': context['sessionId'] ?? 'unknown',
    });
    
    // Keep only last 100 conversations
    if (history.length > 100) {
      history.removeRange(0, history.length - 100);
    }
    
    await prefs.setString(_conversationHistoryKey, jsonEncode(history));
  }

  // Analyze user sentiment and emotional state
  static Future<void> _analyzeUserSentiment(
    String userInput,
    Map<String, dynamic> context,
  ) async {
    final emotionalState = await EmotionalTherapyService.detectEmotionalState(
      userInput,
      context,
    );
    
    // Update emotional state history
    await _updateEmotionalStateHistory(emotionalState, context);
    
    // Learn emotional triggers
    await _learnEmotionalTriggers(userInput, emotionalState, context);
  }

  // Update emotional state history
  static Future<void> _updateEmotionalStateHistory(
    EmotionalState state,
    Map<String, dynamic> context,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final historyString = prefs.getString('emotional_state_history') ?? '[]';
    final history = List<Map<String, dynamic>>.from(jsonDecode(historyString));
    
    history.add({
      'state': state.toString().split('.').last,
      'context': context,
      'timestamp': DateTime.now().toIso8601String(),
    });
    
    // Keep only last 50 emotional states
    if (history.length > 50) {
      history.removeRange(0, history.length - 50);
    }
    
    await prefs.setString('emotional_state_history', jsonEncode(history));
  }

  // Learn emotional triggers
  static Future<void> _learnEmotionalTriggers(
    String userInput,
    EmotionalState state,
    Map<String, dynamic> context,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final triggersString = prefs.getString('emotional_triggers') ?? '{}';
    final triggers = Map<String, dynamic>.from(jsonDecode(triggersString));
    
    final stateKey = state.toString().split('.').last;
    if (!triggers.containsKey(stateKey)) {
      triggers[stateKey] = [];
    }
    
    // Extract potential triggers from context
    final potentialTriggers = <String>[];
    
    if (context['budget_exceeded'] == true) {
      potentialTriggers.add('budget_exceeded');
    }
    if (context['goal_missed'] == true) {
      potentialTriggers.add('goal_missed');
    }
    if (context['unexpected_expense'] == true) {
      potentialTriggers.add('unexpected_expense');
    }
    if (context['financial_stress'] == true) {
      potentialTriggers.add('financial_stress');
    }
    
    // Add triggers to history
    for (final trigger in potentialTriggers) {
      if (!triggers[stateKey].contains(trigger)) {
        triggers[stateKey].add(trigger);
      }
    }
    
    await prefs.setString('emotional_triggers', jsonEncode(triggers));
  }

  // Update personality understanding
  static Future<void> _updatePersonalityUnderstanding(
    Map<String, dynamic> context,
  ) async {
    final personality = await FinancialPersonalityService.getCurrentPersonality();
    if (personality == null) return;
    
    // Track behavior patterns for personality validation
    // await BehavioralAnalysisService.trackBehavior(
    //   'personality_validation',
    //   context,
    // );
    
    // Update personality confidence based on behavior consistency
    await _updatePersonalityConfidence(personality, context);
  }

  // Update personality confidence
  static Future<void> _updatePersonalityConfidence(
    FinancialPersonality personality,
    Map<String, dynamic> context,
  ) async {
    // Analyze if current behavior matches personality type
    final behaviorConsistency = await _analyzeBehaviorConsistency(
      personality.type,
      context,
    );
    
    // Update confidence based on consistency
    double newConfidence = personality.confidence;
    if (behaviorConsistency > 0.7) {
      newConfidence = (newConfidence + 0.05).clamp(0.0, 1.0);
    } else if (behaviorConsistency < 0.3) {
      newConfidence = (newConfidence - 0.05).clamp(0.0, 1.0);
    }
    
    // Update personality if confidence changed significantly
    if ((newConfidence - personality.confidence).abs() > 0.1) {
      final updatedPersonality = FinancialPersonality(
        type: personality.type,
        name: personality.name,
        description: personality.description,
        strengths: personality.strengths,
        challenges: personality.challenges,
        coachingStyle: personality.coachingStyle,
        confidence: newConfidence,
      );
      
      await FinancialPersonalityService.savePersonality(updatedPersonality);
    }
  }

  // Analyze behavior consistency with personality
  static Future<double> _analyzeBehaviorConsistency(
    FinancialPersonalityType personalityType,
    Map<String, dynamic> context,
  ) async {
    // Get recent behavior patterns
    // final behaviorHistory = await BehavioralAnalysisService.getBehaviorHistory();
    // final recentBehaviors = behaviorHistory.where((b) {
    //   final timestamp = DateTime.parse(b['timestamp']);
    //   return DateTime.now().difference(timestamp).inDays <= 7;
    // }).toList();
    final recentBehaviors = <Map<String, dynamic>>[];
    
    // Define expected behaviors for each personality type
    final expectedBehaviors = _getExpectedBehaviors(personalityType);
    
    // Calculate consistency score
    int consistentBehaviors = 0;
    int totalBehaviors = recentBehaviors.length;
    
    for (final behavior in recentBehaviors) {
      final behaviorType = behavior['behavior'] as String;
      if (expectedBehaviors.contains(behaviorType)) {
        consistentBehaviors++;
      }
    }
    
    return totalBehaviors > 0 ? consistentBehaviors / totalBehaviors : 0.5;
  }

  // Get expected behaviors for personality type
  static List<String> _getExpectedBehaviors(FinancialPersonalityType type) {
    switch (type) {
      case FinancialPersonalityType.spender:
        return ['expense_added', 'impulse_purchase', 'entertainment_spending'];
      case FinancialPersonalityType.saver:
        return ['saving_goal_set', 'budget_created', 'expense_avoided'];
      case FinancialPersonalityType.avoider:
        return ['task_postponed', 'notification_dismissed', 'avoidance_behavior'];
      case FinancialPersonalityType.analyzer:
        return ['data_analyzed', 'report_viewed', 'detailed_planning'];
      case FinancialPersonalityType.optimist:
        return ['goal_set', 'positive_feedback', 'future_planning'];
      case FinancialPersonalityType.worrier:
        return ['risk_assessment', 'safety_check', 'conservative_choice'];
      case FinancialPersonalityType.rebel:
        return ['alternative_approach', 'rule_questioned', 'independent_choice'];
      case FinancialPersonalityType.achiever:
        return ['goal_completed', 'milestone_reached', 'challenge_accepted'];
    }
  }

  // Learn response preferences
  static Future<void> _learnResponsePreferences(
    String userInput,
    String aiResponse,
    Map<String, dynamic> context,
  ) async {
    // Analyze response effectiveness (simplified)
    final effectiveness = await _analyzeResponseEffectiveness(
      userInput,
      aiResponse,
      context,
    );
    
    // Update response preferences
    await _updateResponsePreferences(aiResponse, effectiveness, context);
  }

  // Analyze response effectiveness
  static Future<double> _analyzeResponseEffectiveness(
    String userInput,
    String aiResponse,
    Map<String, dynamic> context,
  ) async {
    // Simple heuristic-based effectiveness analysis
    double effectiveness = 0.5; // Base effectiveness
    
    // Check for positive indicators
    if (context['user_satisfied'] == true) {
      effectiveness += 0.3;
    }
    if (context['action_taken'] == true) {
      effectiveness += 0.2;
    }
    if (context['follow_up_question'] == true) {
      effectiveness += 0.1;
    }
    
    // Check for negative indicators
    if (context['user_frustrated'] == true) {
      effectiveness -= 0.3;
    }
    if (context['conversation_ended'] == true) {
      effectiveness -= 0.2;
    }
    
    return effectiveness.clamp(0.0, 1.0);
  }

  // Update response preferences
  static Future<void> _updateResponsePreferences(
    String aiResponse,
    double effectiveness,
    Map<String, dynamic> context,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final preferencesString = prefs.getString(_userPreferencesKey) ?? '{}';
    final preferences = Map<String, dynamic>.from(jsonDecode(preferencesString));
    
    // Extract response characteristics
    final responseLength = aiResponse.length;
    final hasEmojis = aiResponse.contains(RegExp(r'[^\x00-\x7F]'));
    final hasQuestions = aiResponse.contains('?');
    final hasSuggestions = aiResponse.contains('try') || aiResponse.contains('consider');
    
    // Update preferences based on effectiveness
    if (effectiveness > 0.7) {
      // Positive response - reinforce these characteristics
      preferences['preferred_length'] = responseLength;
      preferences['prefers_emojis'] = hasEmojis;
      preferences['prefers_questions'] = hasQuestions;
      preferences['prefers_suggestions'] = hasSuggestions;
    }
    
    await prefs.setString(_userPreferencesKey, jsonEncode(preferences));
  }

  // Update coaching strategies
  static Future<void> _updateCoachingStrategies(
    Map<String, dynamic> context,
  ) async {
    final personality = await FinancialPersonalityService.getCurrentPersonality();
    if (personality == null) return;
    
    // Analyze intervention effectiveness
    await _analyzeInterventionEffectiveness(context);
    
    // Update coaching timing preferences
    await _updateCoachingTiming(context);
    
    // Learn communication style preferences
    await _learnCommunicationStyle(context);
  }

  // Analyze intervention effectiveness
  static Future<void> _analyzeInterventionEffectiveness(
    Map<String, dynamic> context,
  ) async {
    final interventions = await CoachingInterventionService.getInterventions();
    final recentInterventions = interventions.where((i) {
      return DateTime.now().difference(i.createdAt).inDays <= 7;
    }).toList();
    
    // Analyze which intervention types are most effective
    final effectivenessByType = <InterventionType, List<double>>{};
    
    for (final intervention in recentInterventions) {
      // Simple effectiveness calculation based on user actions
      double effectiveness = 0.5;
      if (context['intervention_acted_upon'] == true) {
        effectiveness = 0.8;
      } else if (context['intervention_dismissed'] == true) {
        effectiveness = 0.2;
      }
      
      if (!effectivenessByType.containsKey(intervention.type)) {
        effectivenessByType[intervention.type] = [];
      }
      effectivenessByType[intervention.type]!.add(effectiveness);
    }
    
    // Update intervention preferences
    await _updateInterventionPreferences(effectivenessByType);
  }

  // Update intervention preferences
  static Future<void> _updateInterventionPreferences(
    Map<InterventionType, List<double>> effectivenessByType,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final preferencesString = prefs.getString('intervention_preferences') ?? '{}';
    final preferences = Map<String, dynamic>.from(jsonDecode(preferencesString));
    
    // Calculate average effectiveness for each type
    for (final entry in effectivenessByType.entries) {
      final type = entry.key.toString().split('.').last;
      final effectivenessScores = entry.value;
      final averageEffectiveness = effectivenessScores.reduce((a, b) => a + b) / effectivenessScores.length;
      
      preferences[type] = averageEffectiveness;
    }
    
    await prefs.setString('intervention_preferences', jsonEncode(preferences));
  }

  // Update coaching timing
  static Future<void> _updateCoachingTiming(
    Map<String, dynamic> context,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final timingString = prefs.getString('coaching_timing') ?? '{}';
    final timing = Map<String, dynamic>.from(jsonDecode(timingString));
    
    final currentHour = DateTime.now().hour;
    final dayOfWeek = DateTime.now().weekday;
    
    // Track when user is most responsive
    if (context['user_engaged'] == true) {
      if (!timing.containsKey('responsive_hours')) {
        timing['responsive_hours'] = <int>[];
      }
      timing['responsive_hours'].add(currentHour);
      
      if (!timing.containsKey('responsive_days')) {
        timing['responsive_days'] = <int>[];
      }
      timing['responsive_days'].add(dayOfWeek);
    }
    
    await prefs.setString('coaching_timing', jsonEncode(timing));
  }

  // Learn communication style
  static Future<void> _learnCommunicationStyle(
    Map<String, dynamic> context,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final styleString = prefs.getString('communication_style') ?? '{}';
    final style = Map<String, dynamic>.from(jsonDecode(styleString));
    
    // Track user's communication preferences
    if (context['user_input'] != null) {
      final userInput = context['user_input'] as String;
      
      // Analyze communication characteristics
      final usesEmojis = userInput.contains(RegExp(r'[^\x00-\x7F]'));
      final usesFormalLanguage = userInput.contains('please') || userInput.contains('thank you');
      final usesCasualLanguage = userInput.contains('hey') || userInput.contains('cool');
      final asksQuestions = userInput.contains('?');
      
      // Update style preferences
      if (usesEmojis) {
        style['prefers_emojis'] = (style['prefers_emojis'] ?? 0) + 1;
      }
      if (usesFormalLanguage) {
        style['prefers_formal'] = (style['prefers_formal'] ?? 0) + 1;
      }
      if (usesCasualLanguage) {
        style['prefers_casual'] = (style['prefers_casual'] ?? 0) + 1;
      }
      if (asksQuestions) {
        style['asks_questions'] = (style['asks_questions'] ?? 0) + 1;
      }
    }
    
    await prefs.setString('communication_style', jsonEncode(style));
  }

  // Get personalized response based on learning
  static Future<String> getPersonalizedResponse(
    String userInput,
    Map<String, dynamic> context,
  ) async {
    final personality = await FinancialPersonalityService.getCurrentPersonality();
    final preferences = await _getUserPreferences();
    final communicationStyle = await _getCommunicationStyle();
    
    // Generate base response
    String response = _generateBaseResponse(userInput, personality, context);
    
    // Personalize based on learning
    response = _personalizeResponse(response, preferences, communicationStyle);
    
    // Learn from this interaction
    await learnFromInteraction(userInput, response, context);
    
    return response;
  }

  // Generate base response
  static String _generateBaseResponse(
    String userInput,
    FinancialPersonality? personality,
    Map<String, dynamic> context,
  ) {
    // This is a simplified response generator
    // In a real implementation, you'd use a more sophisticated AI model
    
    final personalityType = personality?.type ?? FinancialPersonalityType.spender;
    final coachingStyle = personality?.coachingStyle ?? {};
    
    // Generate response based on personality and context
    switch (personalityType) {
      case FinancialPersonalityType.spender:
        return _generateSpenderResponse(userInput, context);
      case FinancialPersonalityType.saver:
        return _generateSaverResponse(userInput, context);
      case FinancialPersonalityType.avoider:
        return _generateAvoiderResponse(userInput, context);
      default:
        return _generateGenericResponse(userInput, context);
    }
  }

  // Generate spender response
  static String _generateSpenderResponse(String userInput, Map<String, dynamic> context) {
    final responses = [
      "I love your enthusiasm! 💅 Let's make sure this spending aligns with your goals.",
      "That sounds exciting! Want to check if it fits your budget first?",
      "I can feel your excitement! Let's make this a smart financial choice.",
    ];
    
    return responses[Random().nextInt(responses.length)];
  }

  // Generate saver response
  static String _generateSaverResponse(String userInput, Map<String, dynamic> context) {
    final responses = [
      "I appreciate your careful approach. Let's analyze this decision together.",
      "Your analytical mindset is great! Here's what I think about this situation.",
      "I can see you're being thoughtful about this. Let me help you evaluate the options.",
    ];
    
    return responses[Random().nextInt(responses.length)];
  }

  // Generate avoider response
  static String _generateAvoiderResponse(String userInput, Map<String, dynamic> context) {
    final responses = [
      "No pressure at all! Let's take this one small step at a time. 🌸",
      "I understand this might feel overwhelming. We can tackle this gently together.",
      "It's totally okay to feel unsure. Let's break this down into manageable pieces.",
    ];
    
    return responses[Random().nextInt(responses.length)];
  }

  // Generate generic response
  static String _generateGenericResponse(String userInput, Map<String, dynamic> context) {
    final responses = [
      "I'm here to help you with that. Let's work through this together.",
      "That's a great question! Let me help you think through this.",
      "I understand your concern. Here's how we can approach this.",
    ];
    
    return responses[Random().nextInt(responses.length)];
  }

  // Personalize response
  static String _personalizeResponse(
    String response,
    Map<String, dynamic> preferences,
    Map<String, dynamic> communicationStyle,
  ) {
    // Adjust response based on learned preferences
    if (preferences['prefers_emojis'] == true && !response.contains(RegExp(r'[^\x00-\x7F]'))) {
      response += ' 💕';
    }
    
    if (preferences['prefers_casual'] == true) {
      response = response.replaceAll('I understand', 'I get it');
      response = response.replaceAll('Let us', 'Let\'s');
    }
    
    return response;
  }

  // Get user preferences
  static Future<Map<String, dynamic>> _getUserPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final preferencesString = prefs.getString(_userPreferencesKey) ?? '{}';
    return Map<String, dynamic>.from(jsonDecode(preferencesString));
  }

  // Get communication style
  static Future<Map<String, dynamic>> _getCommunicationStyle() async {
    final prefs = await SharedPreferences.getInstance();
    final styleString = prefs.getString('communication_style') ?? '{}';
    return Map<String, dynamic>.from(jsonDecode(styleString));
  }

  // Get learning insights
  static Future<Map<String, dynamic>> getLearningInsights() async {
    final personality = await FinancialPersonalityService.getCurrentPersonality();
    final preferences = await _getUserPreferences();
    final communicationStyle = await _getCommunicationStyle();
    final emotionalTriggers = await _getEmotionalTriggers();
    
    return {
      'personality': personality?.toJson(),
      'preferences': preferences,
      'communicationStyle': communicationStyle,
      'emotionalTriggers': emotionalTriggers,
      'lastUpdated': DateTime.now().toIso8601String(),
    };
  }

  // Get emotional triggers
  static Future<Map<String, dynamic>> _getEmotionalTriggers() async {
    final prefs = await SharedPreferences.getInstance();
    final triggersString = prefs.getString('emotional_triggers') ?? '{}';
    return Map<String, dynamic>.from(jsonDecode(triggersString));
  }
}
