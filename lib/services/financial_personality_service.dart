import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

enum FinancialPersonalityType {
  spender,        // Loves spending, struggles with saving
  saver,         // Naturally frugal, enjoys saving
  avoider,       // Avoids thinking about money, procrastinates
  analyzer,      // Loves data, over-analyzes decisions
  optimist,      // Always positive, sometimes unrealistic
  worrier,       // Anxious about money, needs reassurance
  rebel,         // Resists traditional financial advice
  achiever       // Goal-oriented, competitive
}

class FinancialPersonality {
  final FinancialPersonalityType type;
  final String name;
  final String description;
  final List<String> strengths;
  final List<String> challenges;
  final Map<String, String> coachingStyle;
  final double confidence; // 0.0 to 1.0

  FinancialPersonality({
    required this.type,
    required this.name,
    required this.description,
    required this.strengths,
    required this.challenges,
    required this.coachingStyle,
    required this.confidence,
  });

  Map<String, dynamic> toJson() => {
    'type': type.toString().split('.').last,
    'name': name,
    'description': description,
    'strengths': strengths,
    'challenges': challenges,
    'coachingStyle': coachingStyle,
    'confidence': confidence,
  };

  factory FinancialPersonality.fromJson(Map<String, dynamic> json) {
    return FinancialPersonality(
      type: FinancialPersonalityType.values.firstWhere(
        (e) => e.toString().split('.').last == json['type'],
      ),
      name: json['name'],
      description: json['description'],
      strengths: List<String>.from(json['strengths']),
      challenges: List<String>.from(json['challenges']),
      coachingStyle: Map<String, String>.from(json['coachingStyle']),
      confidence: json['confidence'].toDouble(),
    );
  }
}

class FinancialPersonalityService {
  static const String _personalityKey = 'financial_personality';
  static const String _assessmentKey = 'personality_assessment';
  static const String _behaviorHistoryKey = 'behavior_history';

  // Personality definitions with coaching styles
  static final Map<FinancialPersonalityType, FinancialPersonality> _personalities = {
    FinancialPersonalityType.spender: FinancialPersonality(
      type: FinancialPersonalityType.spender,
      name: "The Enthusiast",
      description: "You love experiencing life and aren't afraid to spend on what brings you joy.",
      strengths: ["Lives in the moment", "Values experiences", "Generous", "Optimistic"],
      challenges: ["Impulse spending", "Difficulty saving", "Avoids budgets", "Emotional spending"],
      coachingStyle: {
        "tone": "enthusiastic and supportive",
        "approach": "focus on mindful spending and value-based purchases",
        "motivation": "experiences and joy",
        "warnings": "gentle reminders about future goals"
      },
      confidence: 0.0,
    ),
    FinancialPersonalityType.saver: FinancialPersonality(
      type: FinancialPersonalityType.saver,
      name: "The Strategist",
      description: "You naturally prefer saving and find satisfaction in building wealth over time.",
      strengths: ["Disciplined", "Future-focused", "Patient", "Risk-aware"],
      challenges: ["May miss opportunities", "Overly cautious", "Difficulty enjoying money", "Perfectionist"],
      coachingStyle: {
        "tone": "analytical and encouraging",
        "approach": "balance saving with reasonable enjoyment",
        "motivation": "long-term security and growth",
        "warnings": "remind about living in the present"
      },
      confidence: 0.0,
    ),
    FinancialPersonalityType.avoider: FinancialPersonality(
      type: FinancialPersonalityType.avoider,
      name: "The Peacekeeper",
      description: "You prefer to avoid financial stress and may procrastinate on money decisions.",
      strengths: ["Avoids financial stress", "Flexible", "Non-materialistic", "Easy-going"],
      challenges: ["Procrastination", "Lack of planning", "Avoids difficult conversations", "Reactive approach"],
      coachingStyle: {
        "tone": "gentle and non-judgmental",
        "approach": "small, manageable steps",
        "motivation": "peace of mind and simplicity",
        "warnings": "soft nudges without pressure"
      },
      confidence: 0.0,
    ),
    FinancialPersonalityType.analyzer: FinancialPersonality(
      type: FinancialPersonalityType.analyzer,
      name: "The Researcher",
      description: "You love data, research, and making informed financial decisions.",
      strengths: ["Data-driven", "Thorough", "Informed", "Strategic"],
      challenges: ["Analysis paralysis", "Overwhelmed by options", "Perfectionist", "Slow to act"],
      coachingStyle: {
        "tone": "detailed and evidence-based",
        "approach": "provide comprehensive data and analysis",
        "motivation": "optimal outcomes and efficiency",
        "warnings": "present clear, actionable insights"
      },
      confidence: 0.0,
    ),
    FinancialPersonalityType.optimist: FinancialPersonality(
      type: FinancialPersonalityType.optimist,
      name: "The Dreamer",
      description: "You're naturally optimistic about money and believe everything will work out.",
      strengths: ["Positive attitude", "Resilient", "Creative", "Inspiring"],
      challenges: ["May be unrealistic", "Underestimates risks", "Avoids negative scenarios", "Overconfident"],
      coachingStyle: {
        "tone": "upbeat and realistic",
        "approach": "balance optimism with practical planning",
        "motivation": "achieving dreams and goals",
        "warnings": "gentle reality checks with encouragement"
      },
      confidence: 0.0,
    ),
    FinancialPersonalityType.worrier: FinancialPersonality(
      type: FinancialPersonalityType.worrier,
      name: "The Guardian",
      description: "You're naturally cautious about money and want to protect what you have.",
      strengths: ["Risk-aware", "Protective", "Thorough", "Cautious"],
      challenges: ["Excessive worry", "Missed opportunities", "Overly conservative", "Stress"],
      coachingStyle: {
        "tone": "reassuring and supportive",
        "approach": "build confidence through small wins",
        "motivation": "security and peace of mind",
        "warnings": "provide reassurance and gradual exposure"
      },
      confidence: 0.0,
    ),
    FinancialPersonalityType.rebel: FinancialPersonality(
      type: FinancialPersonalityType.rebel,
      name: "The Maverick",
      description: "You resist traditional financial advice and prefer your own path.",
      strengths: ["Independent", "Creative", "Non-conformist", "Innovative"],
      challenges: ["Resists structure", "May ignore good advice", "Impulsive", "Stubborn"],
      coachingStyle: {
        "tone": "respectful and alternative",
        "approach": "present options, not rules",
        "motivation": "freedom and independence",
        "warnings": "suggest rather than prescribe"
      },
      confidence: 0.0,
    ),
    FinancialPersonalityType.achiever: FinancialPersonality(
      type: FinancialPersonalityType.achiever,
      name: "The Champion",
      description: "You're goal-oriented and competitive about your financial success.",
      strengths: ["Goal-focused", "Competitive", "Driven", "Results-oriented"],
      challenges: ["May be too intense", "Impatient", "Perfectionist", "Burnout risk"],
      coachingStyle: {
        "tone": "motivational and challenging",
        "approach": "set ambitious but achievable goals",
        "motivation": "achievement and recognition",
        "warnings": "remind about balance and sustainability"
      },
      confidence: 0.0,
    ),
  };

  // Assessment questions
  static final List<Map<String, dynamic>> _assessmentQuestions = [
    {
      "question": "When you see something you want to buy, you usually:",
      "options": {
        "Buy it immediately if you can afford it": "spender",
        "Research it thoroughly before deciding": "analyzer",
        "Wait and see if you still want it later": "saver",
        "Avoid thinking about it": "avoider",
        "Feel excited about the possibilities": "optimist",
        "Worry about the financial impact": "worrier",
        "Question why you need it": "rebel",
        "Set a goal to earn it": "achiever",
      }
    },
    {
      "question": "Your ideal financial future looks like:",
      "options": {
        "Having amazing experiences and memories": "spender",
        "A well-diversified, optimized portfolio": "analyzer",
        "A comfortable nest egg for security": "saver",
        "Not having to think about money much": "avoider",
        "Achieving all your dreams": "optimist",
        "Being completely secure and protected": "worrier",
        "Financial independence on your own terms": "rebel",
        "Beating all your financial goals": "achiever",
      }
    },
    {
      "question": "When you receive unexpected money, you:",
      "options": {
        "Treat yourself to something special": "spender",
        "Research the best way to invest it": "analyzer",
        "Put it directly into savings": "saver",
        "Don't think about it much": "avoider",
        "Get excited about new possibilities": "optimist",
        "Worry about what to do with it": "worrier",
        "Use it for something unconventional": "rebel",
        "Add it to your next goal": "achiever",
      }
    },
    {
      "question": "Your biggest financial fear is:",
      "options": {
        "Missing out on life experiences": "spender",
        "Making the wrong financial decision": "analyzer",
        "Not having enough for emergencies": "saver",
        "Having to deal with financial stress": "avoider",
        "Not achieving your dreams": "optimist",
        "Losing everything you've built": "worrier",
        "Being trapped by traditional financial systems": "rebel",
        "Not reaching your potential": "achiever",
      }
    },
    {
      "question": "When setting financial goals, you prefer to:",
      "options": {
        "Focus on experiences and enjoyment": "spender",
        "Create detailed, data-driven plans": "analyzer",
        "Set conservative, achievable targets": "saver",
        "Keep goals simple and flexible": "avoider",
        "Dream big and work backwards": "optimist",
        "Plan for worst-case scenarios": "worrier",
        "Create your own unique approach": "rebel",
        "Set challenging, competitive goals": "achiever",
      }
    },
  ];

  // Get current personality
  static Future<FinancialPersonality?> getCurrentPersonality() async {
    final prefs = await SharedPreferences.getInstance();
    final personalityString = prefs.getString(_personalityKey);
    
    if (personalityString == null) return null;
    
    final personalityJson = jsonDecode(personalityString);
    return FinancialPersonality.fromJson(personalityJson);
  }

  // Save personality
  static Future<void> savePersonality(FinancialPersonality personality) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_personalityKey, jsonEncode(personality.toJson()));
  }

  // Get assessment questions
  static List<Map<String, dynamic>> getAssessmentQuestions() {
    return _assessmentQuestions;
  }

  // Calculate personality from assessment
  static Future<FinancialPersonality> calculatePersonality(List<String> answers) async {
    final scores = <FinancialPersonalityType, int>{};
    
    // Initialize scores
    for (final type in FinancialPersonalityType.values) {
      scores[type] = 0;
    }
    
    // Count answers
    for (final answer in answers) {
      for (final question in _assessmentQuestions) {
        for (final entry in question['options'].entries) {
          if (entry.key == answer) {
            final type = FinancialPersonalityType.values.firstWhere(
              (e) => e.toString().split('.').last == entry.value,
            );
            scores[type] = (scores[type] ?? 0) + 1;
          }
        }
      }
    }
    
    // Find dominant type
    FinancialPersonalityType dominantType = FinancialPersonalityType.spender;
    int maxScore = 0;
    
    for (final entry in scores.entries) {
      if (entry.value > maxScore) {
        maxScore = entry.value;
        dominantType = entry.key;
      }
    }
    
    // Calculate confidence (0.0 to 1.0)
    final totalAnswers = answers.length;
    final confidence = totalAnswers > 0 ? maxScore / totalAnswers : 0.0;
    
    // Get personality with confidence
    final personality = _personalities[dominantType]!;
    return FinancialPersonality(
      type: personality.type,
      name: personality.name,
      description: personality.description,
      strengths: personality.strengths,
      challenges: personality.challenges,
      coachingStyle: personality.coachingStyle,
      confidence: confidence,
    );
  }

  // Track behavior patterns
  static Future<void> trackBehavior(String behavior, Map<String, dynamic> context) async {
    final prefs = await SharedPreferences.getInstance();
    final historyString = prefs.getString(_behaviorHistoryKey) ?? '[]';
    final history = List<Map<String, dynamic>>.from(jsonDecode(historyString));
    
    history.add({
      'behavior': behavior,
      'context': context,
      'timestamp': DateTime.now().toIso8601String(),
    });
    
    // Keep only last 100 behaviors
    if (history.length > 100) {
      history.removeRange(0, history.length - 100);
    }
    
    await prefs.setString(_behaviorHistoryKey, jsonEncode(history));
  }

  // Get behavior patterns
  static Future<List<Map<String, dynamic>>> getBehaviorHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final historyString = prefs.getString(_behaviorHistoryKey) ?? '[]';
    return List<Map<String, dynamic>>.from(jsonDecode(historyString));
  }

  // Update personality based on behavior
  static Future<void> updatePersonalityFromBehavior() async {
    final currentPersonality = await getCurrentPersonality();
    if (currentPersonality == null) return;
    
    final behaviorHistory = await getBehaviorHistory();
    final recentBehaviors = behaviorHistory.where((b) {
      final timestamp = DateTime.parse(b['timestamp']);
      return DateTime.now().difference(timestamp).inDays <= 30;
    }).toList();
    
    // Analyze patterns and adjust confidence
    // This is a simplified version - in reality, you'd use ML
    double newConfidence = currentPersonality.confidence;
    
    // Example: If user consistently shows saver behavior, increase confidence
    final saverBehaviors = recentBehaviors.where((b) => 
      b['behavior'] == 'saved_money' || 
      b['behavior'] == 'avoided_impulse_purchase'
    ).length;
    
    if (saverBehaviors > 5) {
      newConfidence = (newConfidence + 0.1).clamp(0.0, 1.0);
    }
    
    // Update personality with new confidence
    final updatedPersonality = FinancialPersonality(
      type: currentPersonality.type,
      name: currentPersonality.name,
      description: currentPersonality.description,
      strengths: currentPersonality.strengths,
      challenges: currentPersonality.challenges,
      coachingStyle: currentPersonality.coachingStyle,
      confidence: newConfidence,
    );
    
    await savePersonality(updatedPersonality);
  }
}

