import 'dart:convert';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import 'financial_personality_service.dart';

enum BehaviorType {
  spending,           // User is spending money
  saving,            // User is saving money
  planning,          // User is making financial plans
  avoiding,          // User is avoiding financial tasks
  emotional,         // User shows emotional financial behavior
  impulsive,         // User makes impulsive decisions
  analytical,        // User is analyzing financial data
  goalOriented,      // User is working toward goals
  stressed,          // User shows financial stress
  confident,         // User shows financial confidence
}

enum RiskLevel {
  low,      // Safe financial behavior
  medium,   // Some concern, needs monitoring
  high,     // Risky behavior, needs intervention
  critical  // Dangerous behavior, immediate action needed
}

class BehaviorPattern {
  final BehaviorType type;
  final double frequency;      // How often this behavior occurs (0.0 to 1.0)
  final double intensity;      // How strong this behavior is (0.0 to 1.0)
  final RiskLevel riskLevel;
  final DateTime lastObserved;
  final Map<String, dynamic> context;

  BehaviorPattern({
    required this.type,
    required this.frequency,
    required this.intensity,
    required this.riskLevel,
    required this.lastObserved,
    required this.context,
  });

  Map<String, dynamic> toJson() => {
    'type': type.toString().split('.').last,
    'frequency': frequency,
    'intensity': intensity,
    'riskLevel': riskLevel.toString().split('.').last,
    'lastObserved': lastObserved.toIso8601String(),
    'context': context,
  };

  factory BehaviorPattern.fromJson(Map<String, dynamic> json) {
    return BehaviorPattern(
      type: BehaviorType.values.firstWhere(
        (e) => e.toString().split('.').last == json['type'],
      ),
      frequency: json['frequency'].toDouble(),
      intensity: json['intensity'].toDouble(),
      riskLevel: RiskLevel.values.firstWhere(
        (e) => e.toString().split('.').last == json['riskLevel'],
      ),
      lastObserved: DateTime.parse(json['lastObserved']),
      context: Map<String, dynamic>.from(json['context']),
    );
  }
}

class BehavioralAnalysisService {
  static const String _patternsKey = 'behavior_patterns';
  static const String _eventsKey = 'behavior_events';
  static const String _insightsKey = 'behavior_insights';

  // Analyze user behavior in real-time
  static Future<BehaviorPattern> analyzeBehavior(
    String action,
    Map<String, dynamic> context,
  ) async {
    final behaviorType = _classifyBehavior(action, context);
    final patterns = await _getBehaviorPatterns();
    
    // Find existing pattern or create new one
    BehaviorPattern? existingPattern;
    for (final pattern in patterns) {
      if (pattern.type == behaviorType) {
        existingPattern = pattern;
        break;
      }
    }

    // Calculate frequency and intensity
    final frequency = await _calculateFrequency(behaviorType);
    final intensity = _calculateIntensity(action, context);
    final riskLevel = _assessRiskLevel(behaviorType, frequency, intensity, context);

    final pattern = BehaviorPattern(
      type: behaviorType,
      frequency: frequency,
      intensity: intensity,
      riskLevel: riskLevel,
      lastObserved: DateTime.now(),
      context: context,
    );

    // Update patterns
    if (existingPattern != null) {
      patterns.removeWhere((p) => p.type == behaviorType);
    }
    patterns.add(pattern);

    // Save updated patterns
    await _saveBehaviorPatterns(patterns);

    // Log this behavior event
    await _logBehaviorEvent(action, context, pattern);

    return pattern;
  }

  // Classify behavior type based on action and context
  static BehaviorType _classifyBehavior(String action, Map<String, dynamic> context) {
    final actionLower = action.toLowerCase();
    
    // Spending behaviors
    if (actionLower.contains('expense') || 
        actionLower.contains('spend') || 
        actionLower.contains('purchase') ||
        actionLower.contains('buy')) {
      return BehaviorType.spending;
    }
    
    // Saving behaviors
    if (actionLower.contains('save') || 
        actionLower.contains('deposit') || 
        actionLower.contains('invest') ||
        actionLower.contains('goal')) {
      return BehaviorType.saving;
    }
    
    // Planning behaviors
    if (actionLower.contains('budget') || 
        actionLower.contains('plan') || 
        actionLower.contains('forecast') ||
        actionLower.contains('strategy')) {
      return BehaviorType.planning;
    }
    
    // Avoiding behaviors
    if (actionLower.contains('skip') || 
        actionLower.contains('ignore') || 
        actionLower.contains('postpone') ||
        actionLower.contains('avoid')) {
      return BehaviorType.avoiding;
    }
    
    // Emotional behaviors (detected from context)
    if (context['emotional_state'] == 'stressed' ||
        context['emotional_state'] == 'anxious' ||
        context['emotional_state'] == 'excited') {
      return BehaviorType.emotional;
    }
    
    // Impulsive behaviors
    if (context['is_impulsive'] == true ||
        context['time_since_last_action'] < 300) { // Less than 5 minutes
      return BehaviorType.impulsive;
    }
    
    // Analytical behaviors
    if (actionLower.contains('analyze') || 
        actionLower.contains('review') || 
        actionLower.contains('report') ||
        actionLower.contains('chart')) {
      return BehaviorType.analytical;
    }
    
    // Goal-oriented behaviors
    if (actionLower.contains('goal') || 
        actionLower.contains('target') || 
        actionLower.contains('milestone')) {
      return BehaviorType.goalOriented;
    }
    
    // Default to spending if unclear
    return BehaviorType.spending;
  }

  // Calculate how frequently this behavior occurs
  static Future<double> _calculateFrequency(BehaviorType type) async {
    final events = await _getBehaviorEvents();
    final now = DateTime.now();
    final thirtyDaysAgo = now.subtract(const Duration(days: 30));
    
    // Count occurrences in last 30 days
    final recentEvents = events.where((event) {
      final timestamp = DateTime.parse(event['timestamp']);
      return timestamp.isAfter(thirtyDaysAgo) && 
             event['pattern']['type'] == type.toString().split('.').last;
    }).length;
    
    // Normalize to 0.0 to 1.0 scale
    return (recentEvents / 30).clamp(0.0, 1.0);
  }

  // Calculate intensity of current behavior
  static double _calculateIntensity(String action, Map<String, dynamic> context) {
    double intensity = 0.5; // Base intensity
    
    // Amount-based intensity
    if (context['amount'] != null) {
      final amount = context['amount'] as double;
      if (amount > 1000) intensity += 0.3;
      else if (amount > 500) intensity += 0.2;
      else if (amount > 100) intensity += 0.1;
    }
    
    // Time-based intensity
    if (context['time_since_last_action'] != null) {
      final timeSince = context['time_since_last_action'] as int;
      if (timeSince < 60) intensity += 0.3; // Less than 1 minute
      else if (timeSince < 300) intensity += 0.2; // Less than 5 minutes
      else if (timeSince < 1800) intensity += 0.1; // Less than 30 minutes
    }
    
    // Emotional intensity
    if (context['emotional_state'] != null) {
      final emotionalState = context['emotional_state'] as String;
      switch (emotionalState) {
        case 'excited':
        case 'stressed':
        case 'anxious':
          intensity += 0.2;
          break;
        case 'calm':
        case 'confident':
          intensity -= 0.1;
          break;
      }
    }
    
    // Impulsive intensity
    if (context['is_impulsive'] == true) {
      intensity += 0.3;
    }
    
    return intensity.clamp(0.0, 1.0);
  }

  // Assess risk level based on behavior patterns
  static RiskLevel _assessRiskLevel(
    BehaviorType type,
    double frequency,
    double intensity,
    Map<String, dynamic> context,
  ) {
    // High-risk behaviors
    if (type == BehaviorType.impulsive && intensity > 0.7) {
      return RiskLevel.critical;
    }
    
    if (type == BehaviorType.spending && frequency > 0.8 && intensity > 0.6) {
      return RiskLevel.high;
    }
    
    if (type == BehaviorType.avoiding && frequency > 0.9) {
      return RiskLevel.high;
    }
    
    if (type == BehaviorType.emotional && intensity > 0.8) {
      return RiskLevel.high;
    }
    
    // Medium-risk behaviors
    if (frequency > 0.6 && intensity > 0.5) {
      return RiskLevel.medium;
    }
    
    if (type == BehaviorType.spending && frequency > 0.5) {
      return RiskLevel.medium;
    }
    
    // Low-risk behaviors
    if (type == BehaviorType.saving || type == BehaviorType.planning) {
      return RiskLevel.low;
    }
    
    if (frequency < 0.3 && intensity < 0.4) {
      return RiskLevel.low;
    }
    
    return RiskLevel.medium;
  }

  // Get all behavior patterns
  static Future<List<BehaviorPattern>> _getBehaviorPatterns() async {
    final prefs = await SharedPreferences.getInstance();
    final patternsString = prefs.getString(_patternsKey) ?? '[]';
    final patternsJson = List<Map<String, dynamic>>.from(jsonDecode(patternsString));
    
    return patternsJson.map((json) => BehaviorPattern.fromJson(json)).toList();
  }

  // Save behavior patterns
  static Future<void> _saveBehaviorPatterns(List<BehaviorPattern> patterns) async {
    final prefs = await SharedPreferences.getInstance();
    final patternsJson = patterns.map((pattern) => pattern.toJson()).toList();
    await prefs.setString(_patternsKey, jsonEncode(patternsJson));
  }

  // Log behavior event
  static Future<void> _logBehaviorEvent(
    String action,
    Map<String, dynamic> context,
    BehaviorPattern pattern,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final eventsString = prefs.getString(_eventsKey) ?? '[]';
    final events = List<Map<String, dynamic>>.from(jsonDecode(eventsString));
    
    events.add({
      'action': action,
      'context': context,
      'pattern': pattern.toJson(),
      'timestamp': DateTime.now().toIso8601String(),
    });
    
    // Keep only last 1000 events
    if (events.length > 1000) {
      events.removeRange(0, events.length - 1000);
    }
    
    await prefs.setString(_eventsKey, jsonEncode(events));
  }

  // Get behavior events
  static Future<List<Map<String, dynamic>>> _getBehaviorEvents() async {
    final prefs = await SharedPreferences.getInstance();
    final eventsString = prefs.getString(_eventsKey) ?? '[]';
    return List<Map<String, dynamic>>.from(jsonDecode(eventsString));
  }

  // Get current behavior insights
  static Future<Map<String, dynamic>> getBehaviorInsights() async {
    final patterns = await _getBehaviorPatterns();
    final personality = await FinancialPersonalityService.getCurrentPersonality();
    
    // Find dominant behaviors
    final dominantBehaviors = patterns.where((p) => p.frequency > 0.5).toList();
    dominantBehaviors.sort((a, b) => b.frequency.compareTo(a.frequency));
    
    // Find high-risk behaviors
    final highRiskBehaviors = patterns.where((p) => 
      p.riskLevel == RiskLevel.high || p.riskLevel == RiskLevel.critical
    ).toList();
    
    // Calculate overall risk score
    double overallRisk = 0.0;
    if (patterns.isNotEmpty) {
      final totalRisk = patterns.fold(0.0, (sum, pattern) {
        double riskValue = 0.0;
        switch (pattern.riskLevel) {
          case RiskLevel.low:
            riskValue = 0.2;
            break;
          case RiskLevel.medium:
            riskValue = 0.5;
            break;
          case RiskLevel.high:
            riskValue = 0.8;
            break;
          case RiskLevel.critical:
            riskValue = 1.0;
            break;
        }
        return sum + (riskValue * pattern.frequency);
      });
      overallRisk = totalRisk / patterns.length;
    }
    
    // Generate insights based on personality
    List<String> insights = [];
    if (personality != null) {
      final personalityType = personality.type;
      
      // Spender insights
      if (personalityType == FinancialPersonalityType.spender) {
        final spendingPattern = patterns.firstWhere(
          (p) => p.type == BehaviorType.spending,
          orElse: () => BehaviorPattern(
            type: BehaviorType.spending,
            frequency: 0.0,
            intensity: 0.0,
            riskLevel: RiskLevel.low,
            lastObserved: DateTime.now(),
            context: {},
          ),
        );
        
        if (spendingPattern.frequency > 0.7) {
          insights.add("You're spending frequently - consider setting spending limits");
        }
        if (spendingPattern.intensity > 0.6) {
          insights.add("Your spending amounts are high - try the 24-hour rule");
        }
      }
      
      // Saver insights
      if (personalityType == FinancialPersonalityType.saver) {
        final savingPattern = patterns.firstWhere(
          (p) => p.type == BehaviorType.saving,
          orElse: () => BehaviorPattern(
            type: BehaviorType.saving,
            frequency: 0.0,
            intensity: 0.0,
            riskLevel: RiskLevel.low,
            lastObserved: DateTime.now(),
            context: {},
          ),
        );
        
        if (savingPattern.frequency < 0.3) {
          insights.add("You could benefit from more regular saving habits");
        }
        if (savingPattern.intensity > 0.8) {
          insights.add("Great saving intensity! Consider investing some of your savings");
        }
      }
      
      // Avoider insights
      if (personalityType == FinancialPersonalityType.avoider) {
        final avoidingPattern = patterns.firstWhere(
          (p) => p.type == BehaviorType.avoiding,
          orElse: () => BehaviorPattern(
            type: BehaviorType.avoiding,
            frequency: 0.0,
            intensity: 0.0,
            riskLevel: RiskLevel.low,
            lastObserved: DateTime.now(),
            context: {},
          ),
        );
        
        if (avoidingPattern.frequency > 0.5) {
          insights.add("You're avoiding financial tasks - try breaking them into smaller steps");
        }
      }
    }
    
    // General insights based on patterns
    if (overallRisk > 0.7) {
      insights.add("High financial risk detected - consider reducing impulsive behaviors");
    } else if (overallRisk < 0.3) {
      insights.add("Great financial behavior patterns! Keep up the good work");
    }
    
    return {
      'overallRisk': overallRisk,
      'dominantBehaviors': dominantBehaviors.take(3).map((p) => p.toJson()).toList(),
      'highRiskBehaviors': highRiskBehaviors.map((p) => p.toJson()).toList(),
      'insights': insights,
      'totalPatterns': patterns.length,
      'lastUpdated': DateTime.now().toIso8601String(),
    };
  }

  // Detect if user needs immediate intervention
  static Future<bool> needsIntervention() async {
    final patterns = await _getBehaviorPatterns();
    
    // Check for critical risk patterns
    for (final pattern in patterns) {
      if (pattern.riskLevel == RiskLevel.critical) {
        return true;
      }
      
      // Check for recent high-risk behavior
      if (pattern.riskLevel == RiskLevel.high && 
          DateTime.now().difference(pattern.lastObserved).inHours < 24) {
        return true;
      }
    }
    
    return false;
  }

  // Get recommended actions based on behavior patterns
  static Future<List<String>> getRecommendedActions() async {
    final patterns = await _getBehaviorPatterns();
    final personality = await FinancialPersonalityService.getCurrentPersonality();
    final actions = <String>[];
    
    // Actions based on high-risk behaviors
    for (final pattern in patterns) {
      if (pattern.riskLevel == RiskLevel.high || pattern.riskLevel == RiskLevel.critical) {
        switch (pattern.type) {
          case BehaviorType.impulsive:
            actions.add("Set up spending alerts for amounts over \$50");
            actions.add("Try the 24-hour rule before making purchases");
            break;
          case BehaviorType.spending:
            actions.add("Create a monthly spending budget");
            actions.add("Use cash for discretionary spending");
            break;
          case BehaviorType.avoiding:
            actions.add("Schedule 15 minutes daily for financial tasks");
            actions.add("Set up automatic bill payments");
            break;
          case BehaviorType.emotional:
            actions.add("Practice mindfulness before financial decisions");
            actions.add("Create a financial stress management plan");
            break;
          default:
            break;
        }
      }
    }
    
    // Actions based on personality
    if (personality != null) {
      switch (personality.type) {
        case FinancialPersonalityType.spender:
          actions.add("Set up automatic savings transfers");
          actions.add("Create a 'fun money' budget category");
          break;
        case FinancialPersonalityType.saver:
          actions.add("Consider investing some of your savings");
          actions.add("Set aside money for experiences and enjoyment");
          break;
        case FinancialPersonalityType.avoider:
          actions.add("Start with small, manageable financial tasks");
          actions.add("Use Mali's gentle reminders feature");
          break;
        default:
          break;
      }
    }
    
    return actions.take(5).toList(); // Return top 5 recommendations
  }
}

