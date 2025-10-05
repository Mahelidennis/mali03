import 'dart:convert';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import 'financial_personality_service.dart';

enum EmotionalState {
  calm,           // Relaxed and balanced
  stressed,       // Feeling overwhelmed
  anxious,        // Worried about money
  excited,        // Enthusiastic and optimistic
  sad,            // Feeling down or depressed
  angry,          // Frustrated or angry
  confident,      // Feeling secure and capable
  overwhelmed,    // Too much to handle
  motivated,      // Ready to take action
  discouraged,    // Feeling defeated
  hopeful,        // Optimistic about the future
  guilty,         // Feeling bad about spending/saving
}

enum TherapyType {
  mindfulness,    // Breathing and meditation
  cognitive,      // Reframing thoughts
  behavioral,     // Changing actions
  emotional,      // Processing feelings
  motivational,   // Building confidence
  educational,    // Learning about finances
  supportive,     // Providing comfort
  challenging,    // Pushing for growth
}

class EmotionalSession {
  final String id;
  final EmotionalState detectedState;
  final TherapyType therapyType;
  final String title;
  final String description;
  final List<String> exercises;
  final Map<String, dynamic> context;
  final DateTime createdAt;
  final int duration; // in minutes
  final bool isCompleted;
  final double effectiveness; // 0.0 to 1.0

  EmotionalSession({
    required this.id,
    required this.detectedState,
    required this.therapyType,
    required this.title,
    required this.description,
    required this.exercises,
    required this.context,
    required this.createdAt,
    required this.duration,
    this.isCompleted = false,
    this.effectiveness = 0.0,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'detectedState': detectedState.toString().split('.').last,
    'therapyType': therapyType.toString().split('.').last,
    'title': title,
    'description': description,
    'exercises': exercises,
    'context': context,
    'createdAt': createdAt.toIso8601String(),
    'duration': duration,
    'isCompleted': isCompleted,
    'effectiveness': effectiveness,
  };

  factory EmotionalSession.fromJson(Map<String, dynamic> json) {
    return EmotionalSession(
      id: json['id'],
      detectedState: EmotionalState.values.firstWhere(
        (e) => e.toString().split('.').last == json['detectedState'],
      ),
      therapyType: TherapyType.values.firstWhere(
        (e) => e.toString().split('.').last == json['therapyType'],
      ),
      title: json['title'],
      description: json['description'],
      exercises: List<String>.from(json['exercises']),
      context: Map<String, dynamic>.from(json['context']),
      createdAt: DateTime.parse(json['createdAt']),
      duration: json['duration'],
      isCompleted: json['isCompleted'] ?? false,
      effectiveness: json['effectiveness']?.toDouble() ?? 0.0,
    );
  }
}

class EmotionalTherapyService {
  static const String _sessionsKey = 'emotional_sessions';
  static const String _stateHistoryKey = 'emotional_state_history';
  static const String _therapyProgressKey = 'therapy_progress';

  // Detect emotional state from user input and context
  static Future<EmotionalState> detectEmotionalState(
    String userInput,
    Map<String, dynamic> context,
  ) async {
    final inputLower = userInput.toLowerCase();
    
    // Keyword-based detection
    final stressKeywords = ['stressed', 'overwhelmed', 'too much', 'can\'t handle', 'pressure'];
    final anxietyKeywords = ['worried', 'anxious', 'nervous', 'scared', 'afraid', 'panic'];
    final excitementKeywords = ['excited', 'thrilled', 'amazing', 'great', 'awesome', 'fantastic'];
    final sadnessKeywords = ['sad', 'depressed', 'down', 'blue', 'miserable', 'hopeless'];
    final angerKeywords = ['angry', 'mad', 'furious', 'frustrated', 'annoyed', 'irritated'];
    final confidenceKeywords = ['confident', 'sure', 'capable', 'ready', 'strong', 'powerful'];
    final motivationKeywords = ['motivated', 'inspired', 'ready', 'let\'s go', 'excited to'];
    final guiltKeywords = ['guilty', 'bad', 'wrong', 'shouldn\'t', 'regret', 'ashamed'];
    
    // Count keyword matches
    int stressCount = _countKeywords(inputLower, stressKeywords);
    int anxietyCount = _countKeywords(inputLower, anxietyKeywords);
    int excitementCount = _countKeywords(inputLower, excitementKeywords);
    int sadnessCount = _countKeywords(inputLower, sadnessKeywords);
    int angerCount = _countKeywords(inputLower, angerKeywords);
    int confidenceCount = _countKeywords(inputLower, confidenceKeywords);
    int motivationCount = _countKeywords(inputLower, motivationKeywords);
    int guiltCount = _countKeywords(inputLower, guiltKeywords);
    
    // Context-based detection
    if (context['financial_stress'] == true) {
      stressCount += 2;
    }
    if (context['recent_loss'] == true) {
      sadnessCount += 2;
    }
    if (context['recent_success'] == true) {
      excitementCount += 2;
    }
    if (context['budget_exceeded'] == true) {
      anxietyCount += 1;
      guiltCount += 1;
    }
    
    // Determine dominant emotion
    final emotions = {
      EmotionalState.stressed: stressCount,
      EmotionalState.anxious: anxietyCount,
      EmotionalState.excited: excitementCount,
      EmotionalState.sad: sadnessCount,
      EmotionalState.angry: angerCount,
      EmotionalState.confident: confidenceCount,
      EmotionalState.motivated: motivationCount,
      EmotionalState.guilty: guiltCount,
    };
    
    // Find the emotion with highest count
    EmotionalState dominantState = EmotionalState.calm;
    int maxCount = 0;
    
    for (final entry in emotions.entries) {
      if (entry.value > maxCount) {
        maxCount = entry.value;
        dominantState = entry.key;
      }
    }
    
    // If no strong emotion detected, check for calm indicators
    if (maxCount == 0) {
      final calmKeywords = ['okay', 'fine', 'good', 'alright', 'calm', 'peaceful'];
      final calmCount = _countKeywords(inputLower, calmKeywords);
      if (calmCount > 0) {
        dominantState = EmotionalState.calm;
      }
    }
    
    // Log emotional state
    await _logEmotionalState(dominantState, context);
    
    return dominantState;
  }

  // Count keyword matches in text
  static int _countKeywords(String text, List<String> keywords) {
    int count = 0;
    for (final keyword in keywords) {
      if (text.contains(keyword)) {
        count++;
      }
    }
    return count;
  }

  // Create therapy session based on emotional state
  static Future<EmotionalSession> createTherapySession(
    EmotionalState emotionalState,
    FinancialPersonality? personality,
    Map<String, dynamic> context,
  ) async {
    final personalityType = personality?.type ?? FinancialPersonalityType.spender;
    
    switch (emotionalState) {
      case EmotionalState.stressed:
        return _createStressTherapySession(personalityType, context);
      
      case EmotionalState.anxious:
        return _createAnxietyTherapySession(personalityType, context);
      
      case EmotionalState.sad:
        return _createSadnessTherapySession(personalityType, context);
      
      case EmotionalState.angry:
        return _createAngerTherapySession(personalityType, context);
      
      case EmotionalState.overwhelmed:
        return _createOverwhelmTherapySession(personalityType, context);
      
      case EmotionalState.discouraged:
        return _createDiscouragementTherapySession(personalityType, context);
      
      case EmotionalState.guilty:
        return _createGuiltTherapySession(personalityType, context);
      
      case EmotionalState.excited:
        return _createExcitementTherapySession(personalityType, context);
      
      case EmotionalState.confident:
        return _createConfidenceTherapySession(personalityType, context);
      
      case EmotionalState.motivated:
        return _createMotivationTherapySession(personalityType, context);
      
      case EmotionalState.hopeful:
        return _createHopeTherapySession(personalityType, context);
      
      default:
        return _createCalmTherapySession(personalityType, context);
    }
  }

  // Stress therapy session
  static EmotionalSession _createStressTherapySession(
    FinancialPersonalityType personalityType,
    Map<String, dynamic> context,
  ) {
    String title;
    String description;
    List<String> exercises;
    TherapyType therapyType;
    
    switch (personalityType) {
      case FinancialPersonalityType.spender:
        title = "Let's Breathe Through This Together 💅";
        description = "I know money stress can feel overwhelming, especially when you want to enjoy life. Let's take a moment to center ourselves and find some peace.";
        exercises = [
          "Take 5 deep breaths and imagine your stress floating away",
          "Write down 3 things you're grateful for right now",
          "Set a small, achievable financial goal for today",
          "Treat yourself to something free that brings you joy"
        ];
        therapyType = TherapyType.mindfulness;
        break;
        
      case FinancialPersonalityType.saver:
        title = "Financial Stress Relief";
        description = "I understand you're feeling stressed about money. Let's work through this systematically and find some relief.";
        exercises = [
          "Review your financial situation objectively",
          "Identify the top 3 stressors and create action plans",
          "Practice the 4-7-8 breathing technique",
          "Schedule a specific time to address financial concerns"
        ];
        therapyType = TherapyType.cognitive;
        break;
        
      case FinancialPersonalityType.avoider:
        title = "Gentle Stress Support 🌸";
        description = "I see you're feeling stressed about finances. That's completely normal. Let's take this one small step at a time.";
        exercises = [
          "Spend 2 minutes just breathing deeply",
          "Write down one small thing you can do today",
          "Remember that it's okay to ask for help",
          "Take a break and do something you enjoy"
        ];
        therapyType = TherapyType.supportive;
        break;
        
      default:
        title = "Stress Management Session";
        description = "Let's work through your financial stress together and find some relief.";
        exercises = [
          "Practice deep breathing for 3 minutes",
          "Identify what's causing the most stress",
          "Create a simple action plan",
          "Take a break and return with fresh perspective"
        ];
        therapyType = TherapyType.mindfulness;
    }
    
    return EmotionalSession(
      id: _generateId(),
      detectedState: EmotionalState.stressed,
      therapyType: therapyType,
      title: title,
      description: description,
      exercises: exercises,
      context: context,
      createdAt: DateTime.now(),
      duration: 10,
    );
  }

  // Anxiety therapy session
  static EmotionalSession _createAnxietyTherapySession(
    FinancialPersonalityType personalityType,
    Map<String, dynamic> context,
  ) {
    String title;
    String description;
    List<String> exercises;
    
    switch (personalityType) {
      case FinancialPersonalityType.worrier:
        title = "I'm Here to Help You Through This 💙";
        description = "I know how overwhelming financial anxiety can feel. You're not alone, and we'll get through this together.";
        exercises = [
          "Ground yourself with the 5-4-3-2-1 technique",
          "Write down your biggest financial worry and challenge it",
          "Create a simple emergency plan to feel more secure",
          "Practice progressive muscle relaxation"
        ];
        break;
        
      case FinancialPersonalityType.analyzer:
        title = "Anxiety Management Through Analysis";
        description = "Let's use your analytical nature to work through this anxiety systematically.";
        exercises = [
          "Create a detailed list of your financial concerns",
          "Research and fact-check your biggest worries",
          "Develop a contingency plan for worst-case scenarios",
          "Practice data-driven decision making"
        ];
        break;
        
      default:
        title = "Anxiety Relief Session";
        description = "Let's work through your financial anxiety step by step.";
        exercises = [
          "Practice the box breathing technique",
          "Identify and challenge anxious thoughts",
          "Create a simple action plan",
          "Focus on what you can control"
        ];
    }
    
    return EmotionalSession(
      id: _generateId(),
      detectedState: EmotionalState.anxious,
      therapyType: TherapyType.cognitive,
      title: title,
      description: description,
      exercises: exercises,
      context: context,
      createdAt: DateTime.now(),
      duration: 15,
    );
  }

  // Sadness therapy session
  static EmotionalSession _createSadnessTherapySession(
    FinancialPersonalityType personalityType,
    Map<String, dynamic> context,
  ) {
    String title;
    String description;
    List<String> exercises;
    
    switch (personalityType) {
      case FinancialPersonalityType.spender:
        title = "Your Feelings Matter, Beautiful 💕";
        description = "I can see you're feeling down about money. It's okay to feel this way. Let's work through it together with kindness.";
        exercises = [
          "Write a letter to yourself with compassion",
          "Think of 3 small things that bring you joy",
          "Plan one small treat that fits your budget",
          "Remember that your worth isn't tied to money"
        ];
        break;
        
      case FinancialPersonalityType.avoider:
        title = "Gentle Support for Your Sadness 🌸";
        description = "I'm here for you during this difficult time. Let's take gentle steps to help you feel better.";
        exercises = [
          "Spend time with someone you love",
          "Do one small act of self-care",
          "Write down what you're grateful for",
          "Remember that this feeling will pass"
        ];
        break;
        
      default:
        title = "Supporting You Through Sadness";
        description = "I'm here to help you through this difficult time with your finances.";
        exercises = [
          "Practice self-compassion",
          "Reach out to someone you trust",
          "Focus on small positive actions",
          "Remember your past successes"
        ];
    }
    
    return EmotionalSession(
      id: _generateId(),
      detectedState: EmotionalState.sad,
      therapyType: TherapyType.emotional,
      title: title,
      description: description,
      exercises: exercises,
      context: context,
      createdAt: DateTime.now(),
      duration: 12,
    );
  }

  // Anger therapy session
  static EmotionalSession _createAngerTherapySession(
    FinancialPersonalityType personalityType,
    Map<String, dynamic> context,
  ) {
    String title;
    String description;
    List<String> exercises;
    
    switch (personalityType) {
      case FinancialPersonalityType.rebel:
        title = "Channel That Energy, Maverick 🔥";
        description = "I can feel your frustration! Let's channel that energy into something productive and empowering.";
        exercises = [
          "Write down what's making you angry and why",
          "Find one way to take control of the situation",
          "Use your anger as fuel for positive change",
          "Create a plan to address the root cause"
        ];
        break;
        
      case FinancialPersonalityType.achiever:
        title = "Transform Anger into Action";
        description = "I see you're frustrated. Let's use that energy to drive positive change in your financial situation.";
        exercises = [
          "Identify what's within your control",
          "Create an action plan to address the issue",
          "Set a challenging but achievable goal",
          "Use your competitive nature to overcome obstacles"
        ];
        break;
        
      default:
        title = "Managing Financial Anger";
        description = "Let's work through your frustration and find constructive ways to address it.";
        exercises = [
          "Take deep breaths and count to 10",
          "Identify what's really making you angry",
          "Find one constructive action you can take",
          "Practice expressing your feelings calmly"
        ];
    }
    
    return EmotionalSession(
      id: _generateId(),
      detectedState: EmotionalState.angry,
      therapyType: TherapyType.behavioral,
      title: title,
      description: description,
      exercises: exercises,
      context: context,
      createdAt: DateTime.now(),
      duration: 8,
    );
  }

  // Overwhelm therapy session
  static EmotionalSession _createOverwhelmTherapySession(
    FinancialPersonalityType personalityType,
    Map<String, dynamic> context,
  ) {
    String title;
    String description;
    List<String> exercises;
    
    switch (personalityType) {
      case FinancialPersonalityType.avoider:
        title = "One Step at a Time, Sweetie 🌸";
        description = "I can see you're feeling overwhelmed. That's totally okay! Let's break everything down into tiny, manageable pieces.";
        exercises = [
          "Write down everything that feels overwhelming",
          "Pick just ONE thing to focus on today",
          "Set a timer for 5 minutes and work on that one thing",
          "Celebrate completing that one small task"
        ];
        break;
        
      case FinancialPersonalityType.analyzer:
        title = "Systematic Overwhelm Relief";
        description = "I understand you're feeling overwhelmed. Let's use your analytical skills to break this down systematically.";
        exercises = [
          "Create a master list of all financial tasks",
          "Categorize tasks by priority and urgency",
          "Focus on the top 3 most important items",
          "Create a timeline for tackling each category"
        ];
        break;
        
      default:
        title = "Overwhelm Management";
        description = "Let's work through this overwhelming feeling step by step.";
        exercises = [
          "Take 3 deep breaths and ground yourself",
          "List everything that feels overwhelming",
          "Pick the smallest, easiest task to start with",
          "Set a timer and work for just 10 minutes"
        ];
    }
    
    return EmotionalSession(
      id: _generateId(),
      detectedState: EmotionalState.overwhelmed,
      therapyType: TherapyType.cognitive,
      title: title,
      description: description,
      exercises: exercises,
      context: context,
      createdAt: DateTime.now(),
      duration: 15,
    );
  }

  // Discouragement therapy session
  static EmotionalSession _createDiscouragementTherapySession(
    FinancialPersonalityType personalityType,
    Map<String, dynamic> context,
  ) {
    String title;
    String description;
    List<String> exercises;
    
    switch (personalityType) {
      case FinancialPersonalityType.achiever:
        title = "You're Stronger Than You Know 💪";
        description = "I can see you're feeling discouraged, but I know your determination. Let's remind you of your strength and get back on track.";
        exercises = [
          "Write down 3 past successes you're proud of",
          "Set one small, achievable goal for today",
          "Remember that setbacks are part of the journey",
          "Create a plan to get back on track"
        ];
        break;
        
      case FinancialPersonalityType.optimist:
        title = "Your Optimism Will Return ✨";
        description = "I know you're feeling down right now, but your natural optimism is still there. Let's help it shine through again.";
        exercises = [
          "Write down 3 things you're grateful for",
          "Visualize your financial goals coming true",
          "Think of one small positive action you can take",
          "Remember that this feeling is temporary"
        ];
        break;
        
      default:
        title = "Rekindling Your Motivation";
        description = "Let's work through this discouragement and help you find your motivation again.";
        exercises = [
          "Reflect on what you've accomplished so far",
          "Set one very small goal for today",
          "Remember why you started this journey",
          "Take one small step forward"
        ];
    }
    
    return EmotionalSession(
      id: _generateId(),
      detectedState: EmotionalState.discouraged,
      therapyType: TherapyType.motivational,
      title: title,
      description: description,
      exercises: exercises,
      context: context,
      createdAt: DateTime.now(),
      duration: 10,
    );
  }

  // Guilt therapy session
  static EmotionalSession _createGuiltTherapySession(
    FinancialPersonalityType personalityType,
    Map<String, dynamic> context,
  ) {
    String title;
    String description;
    List<String> exercises;
    
    switch (personalityType) {
      case FinancialPersonalityType.spender:
        title = "Let's Release This Guilt, Beautiful 💕";
        description = "I can feel the guilt you're carrying about money. It's okay to make mistakes - that's how we learn and grow.";
        exercises = [
          "Write a letter of forgiveness to yourself",
          "Identify one lesson you learned from this experience",
          "Make a small, positive financial choice today",
          "Remember that your worth isn't defined by money"
        ];
        break;
        
      case FinancialPersonalityType.saver:
        title = "Guilt-Free Financial Growth";
        description = "I understand you're feeling guilty about your financial choices. Let's work through this with compassion and understanding.";
        exercises = [
          "Reflect on what you learned from this experience",
          "Create a plan to move forward positively",
          "Practice self-compassion and forgiveness",
          "Focus on what you can control going forward"
        ];
        break;
        
      default:
        title = "Working Through Financial Guilt";
        description = "Let's address this guilt you're feeling and help you move forward with self-compassion.";
        exercises = [
          "Acknowledge your feelings without judgment",
          "Identify what you can learn from this experience",
          "Make a plan to do better next time",
          "Practice self-forgiveness"
        ];
    }
    
    return EmotionalSession(
      id: _generateId(),
      detectedState: EmotionalState.guilty,
      therapyType: TherapyType.emotional,
      title: title,
      description: description,
      exercises: exercises,
      context: context,
      createdAt: DateTime.now(),
      duration: 12,
    );
  }

  // Excitement therapy session
  static EmotionalSession _createExcitementTherapySession(
    FinancialPersonalityType personalityType,
    Map<String, dynamic> context,
  ) {
    String title;
    String description;
    List<String> exercises;
    
    switch (personalityType) {
      case FinancialPersonalityType.spender:
        title = "Channel That Excitement Wisely! 💅✨";
        description = "I love your energy! Let's make sure this excitement leads to smart financial decisions that bring you lasting joy.";
        exercises = [
          "Write down what's making you excited",
          "Set a budget for this exciting opportunity",
          "Think about how this fits your long-term goals",
          "Plan how to make this excitement last"
        ];
        break;
        
      case FinancialPersonalityType.optimist:
        title = "Harness Your Positive Energy! 🌟";
        description = "Your excitement is contagious! Let's channel this positive energy into achieving your financial goals.";
        exercises = [
          "Write down your financial dreams and goals",
          "Create an action plan to achieve them",
          "Share your excitement with someone supportive",
          "Use this energy to tackle challenging tasks"
        ];
        break;
        
      default:
        title = "Channeling Your Excitement";
        description = "I love your enthusiasm! Let's make sure this excitement leads to positive financial outcomes.";
        exercises = [
          "Identify what's causing your excitement",
          "Create a plan to leverage this energy",
          "Set some exciting but realistic goals",
          "Use this momentum to tackle important tasks"
        ];
    }
    
    return EmotionalSession(
      id: _generateId(),
      detectedState: EmotionalState.excited,
      therapyType: TherapyType.motivational,
      title: title,
      description: description,
      exercises: exercises,
      context: context,
      createdAt: DateTime.now(),
      duration: 8,
    );
  }

  // Confidence therapy session
  static EmotionalSession _createConfidenceTherapySession(
    FinancialPersonalityType personalityType,
    Map<String, dynamic> context,
  ) {
    String title;
    String description;
    List<String> exercises;
    
    switch (personalityType) {
      case FinancialPersonalityType.achiever:
        title = "You're Absolutely Crushing It! 🏆";
        description = "I can see your confidence shining through! Let's use this momentum to tackle even bigger financial goals.";
        exercises = [
          "Set a challenging but achievable financial goal",
          "Create a plan to push your boundaries",
          "Share your success with others",
          "Use this confidence to help someone else"
        ];
        break;
        
      case FinancialPersonalityType.saver:
        title = "Your Financial Confidence is Inspiring! 💪";
        description = "I love seeing you feel confident about your finances! Let's build on this strength and continue growing.";
        exercises = [
          "Reflect on what's making you feel confident",
          "Set a new financial challenge for yourself",
          "Consider sharing your knowledge with others",
          "Plan your next financial milestone"
        ];
        break;
        
      default:
        title = "Building on Your Confidence";
        description = "I can see you're feeling confident about your finances! Let's use this positive energy to achieve even more.";
        exercises = [
          "Identify what's contributing to your confidence",
          "Set a new goal that excites you",
          "Use this confidence to tackle something challenging",
          "Share your positive energy with others"
        ];
    }
    
    return EmotionalSession(
      id: _generateId(),
      detectedState: EmotionalState.confident,
      therapyType: TherapyType.motivational,
      title: title,
      description: description,
      exercises: exercises,
      context: context,
      createdAt: DateTime.now(),
      duration: 6,
    );
  }

  // Motivation therapy session
  static EmotionalSession _createMotivationTherapySession(
    FinancialPersonalityType personalityType,
    Map<String, dynamic> context,
  ) {
    String title;
    String description;
    List<String> exercises;
    
    switch (personalityType) {
      case FinancialPersonalityType.achiever:
        title = "Let's Channel This Motivation! 🚀";
        description = "I love your motivation! Let's use this energy to tackle your most important financial goals.";
        exercises = [
          "Write down your top 3 financial priorities",
          "Create a detailed action plan for each",
          "Set specific deadlines for your goals",
          "Track your progress daily"
        ];
        break;
        
      case FinancialPersonalityType.optimist:
        title = "Your Motivation is Contagious! ✨";
        description = "I can feel your positive energy! Let's channel this motivation into creating amazing financial outcomes.";
        exercises = [
          "Visualize your financial dreams coming true",
          "Create a vision board for your goals",
          "Share your motivation with someone supportive",
          "Take action on your most important goal today"
        ];
        break;
        
      default:
        title = "Harnessing Your Motivation";
        description = "I love seeing you motivated! Let's use this energy to make real progress on your financial goals.";
        exercises = [
          "Identify what's driving your motivation",
          "Set specific, actionable goals",
          "Create a plan to maintain this momentum",
          "Take action on your most important priority"
        ];
    }
    
    return EmotionalSession(
      id: _generateId(),
      detectedState: EmotionalState.motivated,
      therapyType: TherapyType.motivational,
      title: title,
      description: description,
      exercises: exercises,
      context: context,
      createdAt: DateTime.now(),
      duration: 8,
    );
  }

  // Hope therapy session
  static EmotionalSession _createHopeTherapySession(
    FinancialPersonalityType personalityType,
    Map<String, dynamic> context,
  ) {
    String title;
    String description;
    List<String> exercises;
    
    switch (personalityType) {
      case FinancialPersonalityType.optimist:
        title = "Your Hope is Beautiful! 🌈";
        description = "I can feel your hope and optimism! This positive energy is exactly what you need to achieve your financial dreams.";
        exercises = [
          "Write down your most hopeful financial vision",
          "Create a plan to make it a reality",
          "Share your hope with someone who needs it",
          "Take one small step toward your vision today"
        ];
        break;
        
      case FinancialPersonalityType.spender:
        title = "Hope and Smart Choices! 💕";
        description = "I love your hopeful energy! Let's channel this optimism into making choices that bring you lasting joy and security.";
        exercises = [
          "Balance your hope with practical planning",
          "Set goals that excite you and are achievable",
          "Create a budget that allows for both fun and security",
          "Use your hope to inspire others"
        ];
        break;
        
      default:
        title = "Nurturing Your Hope";
        description = "I can see your hope shining through! Let's use this positive energy to create real financial progress.";
        exercises = [
          "Write down what you're hopeful about",
          "Create a plan to nurture this hope",
          "Set goals that align with your vision",
          "Take action to make your hope a reality"
        ];
    }
    
    return EmotionalSession(
      id: _generateId(),
      detectedState: EmotionalState.hopeful,
      therapyType: TherapyType.motivational,
      title: title,
      description: description,
      exercises: exercises,
      context: context,
      createdAt: DateTime.now(),
      duration: 8,
    );
  }

  // Calm therapy session
  static EmotionalSession _createCalmTherapySession(
    FinancialPersonalityType personalityType,
    Map<String, dynamic> context,
  ) {
    String title;
    String description;
    List<String> exercises;
    
    switch (personalityType) {
      case FinancialPersonalityType.saver:
        title = "Maintaining Your Financial Peace 🌸";
        description = "I love seeing you in such a calm, balanced state! Let's use this peaceful energy to make thoughtful financial decisions.";
        exercises = [
          "Reflect on what's contributing to your calm",
          "Review your financial goals with clarity",
          "Make any necessary adjustments to your plan",
          "Enjoy this peaceful moment and plan for the future"
        ];
        break;
        
      case FinancialPersonalityType.avoider:
        title = "Your Calm is Beautiful 💙";
        description = "I'm so glad you're feeling calm! This is the perfect time to gently work on your financial goals without pressure.";
        exercises = [
          "Take a moment to appreciate your calm state",
          "Gently review your financial situation",
          "Make one small, positive financial choice",
          "Plan how to maintain this peaceful energy"
        ];
        break;
        
      default:
        title = "Nurturing Your Calm";
        description = "I love seeing you so calm and centered! Let's use this peaceful energy to make thoughtful financial decisions.";
        exercises = [
          "Appreciate your current state of mind",
          "Review your financial goals with clarity",
          "Make any necessary adjustments to your plan",
          "Plan how to maintain this balance"
        ];
    }
    
    return EmotionalSession(
      id: _generateId(),
      detectedState: EmotionalState.calm,
      therapyType: TherapyType.mindfulness,
      title: title,
      description: description,
      exercises: exercises,
      context: context,
      createdAt: DateTime.now(),
      duration: 6,
    );
  }

  // Log emotional state
  static Future<void> _logEmotionalState(
    EmotionalState state,
    Map<String, dynamic> context,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final historyString = prefs.getString(_stateHistoryKey) ?? '[]';
    final history = List<Map<String, dynamic>>.from(jsonDecode(historyString));
    
    history.add({
      'state': state.toString().split('.').last,
      'context': context,
      'timestamp': DateTime.now().toIso8601String(),
    });
    
    // Keep only last 100 emotional states
    if (history.length > 100) {
      history.removeRange(0, history.length - 100);
    }
    
    await prefs.setString(_stateHistoryKey, jsonEncode(history));
  }

  // Save therapy session
  static Future<void> saveTherapySession(EmotionalSession session) async {
    final prefs = await SharedPreferences.getInstance();
    final sessionsString = prefs.getString(_sessionsKey) ?? '[]';
    final sessions = List<Map<String, dynamic>>.from(jsonDecode(sessionsString));
    
    sessions.add(session.toJson());
    
    // Keep only last 50 sessions
    if (sessions.length > 50) {
      sessions.removeRange(0, sessions.length - 50);
    }
    
    await prefs.setString(_sessionsKey, jsonEncode(sessions));
  }

  // Get therapy sessions
  static Future<List<EmotionalSession>> getTherapySessions() async {
    final prefs = await SharedPreferences.getInstance();
    final sessionsString = prefs.getString(_sessionsKey) ?? '[]';
    final sessionsJson = List<Map<String, dynamic>>.from(jsonDecode(sessionsString));
    
    return sessionsJson.map((json) => EmotionalSession.fromJson(json)).toList();
  }

  // Mark session as completed
  static Future<void> markSessionCompleted(String sessionId, double effectiveness) async {
    final sessions = await getTherapySessions();
    final session = sessions.firstWhere(
      (s) => s.id == sessionId,
      orElse: () => throw Exception('Session not found'),
    );
    
    final updatedSession = EmotionalSession(
      id: session.id,
      detectedState: session.detectedState,
      therapyType: session.therapyType,
      title: session.title,
      description: session.description,
      exercises: session.exercises,
      context: session.context,
      createdAt: session.createdAt,
      duration: session.duration,
      isCompleted: true,
      effectiveness: effectiveness,
    );
    
    await _updateSession(updatedSession);
  }

  // Update session
  static Future<void> _updateSession(EmotionalSession session) async {
    final prefs = await SharedPreferences.getInstance();
    final sessionsString = prefs.getString(_sessionsKey) ?? '[]';
    final sessions = List<Map<String, dynamic>>.from(jsonDecode(sessionsString));
    
    final index = sessions.indexWhere((s) => s['id'] == session.id);
    if (index != -1) {
      sessions[index] = session.toJson();
      await prefs.setString(_sessionsKey, jsonEncode(sessions));
    }
  }

  // Generate unique ID
  static String _generateId() {
    return DateTime.now().millisecondsSinceEpoch.toString() + 
           Random().nextInt(1000).toString();
  }
}
