import 'dart:convert';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import 'financial_personality_service.dart';
import 'behavioral_analysis_service.dart';

enum InterventionType {
  gentle,        // Soft, encouraging message
  warning,       // More direct warning
  urgent,        // Immediate attention needed
  celebration,   // Positive reinforcement
  educational,   // Teaching moment
  motivational,  // Inspiring message
}

enum InterventionTrigger {
  spendingAlert,     // User is about to overspend
  budgetExceeded,    // Budget limit reached
  impulsiveBehavior, // Detected impulsive spending
  goalStagnation,    // No progress on goals
  emotionalSpending, // Spending due to emotions
  avoidancePattern,  // Avoiding financial tasks
  successMilestone,  // Achieved a goal
  riskBehavior,      // High-risk financial behavior
  positiveHabit,     // Good financial behavior
  learningOpportunity, // Educational moment
}

class CoachingIntervention {
  final String id;
  final InterventionType type;
  final InterventionTrigger trigger;
  final String title;
  final String message;
  final List<String> actions;
  final Map<String, dynamic> context;
  final DateTime createdAt;
  final bool isRead;
  final bool isDismissed;
  final int priority; // 1-10, higher is more urgent

  CoachingIntervention({
    required this.id,
    required this.type,
    required this.trigger,
    required this.title,
    required this.message,
    required this.actions,
    required this.context,
    required this.createdAt,
    this.isRead = false,
    this.isDismissed = false,
    required this.priority,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type.toString().split('.').last,
    'trigger': trigger.toString().split('.').last,
    'title': title,
    'message': message,
    'actions': actions,
    'context': context,
    'createdAt': createdAt.toIso8601String(),
    'isRead': isRead,
    'isDismissed': isDismissed,
    'priority': priority,
  };

  factory CoachingIntervention.fromJson(Map<String, dynamic> json) {
    return CoachingIntervention(
      id: json['id'],
      type: InterventionType.values.firstWhere(
        (e) => e.toString().split('.').last == json['type'],
      ),
      trigger: InterventionTrigger.values.firstWhere(
        (e) => e.toString().split('.').last == json['trigger'],
      ),
      title: json['title'],
      message: json['message'],
      actions: List<String>.from(json['actions']),
      context: Map<String, dynamic>.from(json['context']),
      createdAt: DateTime.parse(json['createdAt']),
      isRead: json['isRead'] ?? false,
      isDismissed: json['isDismissed'] ?? false,
      priority: json['priority'],
    );
  }
}

class CoachingInterventionService {
  static const String _interventionsKey = 'coaching_interventions';
  static const String _settingsKey = 'intervention_settings';

  // Generate intervention based on current behavior
  static Future<CoachingIntervention?> generateIntervention(
    String action,
    Map<String, dynamic> context,
  ) async {
    // Analyze current behavior
    final behaviorPattern = await BehavioralAnalysisService.analyzeBehavior(action, context);
    final personality = await FinancialPersonalityService.getCurrentPersonality();
    
    // Determine if intervention is needed
    final trigger = _determineTrigger(behaviorPattern, context);
    if (trigger == null) return null;
    
    // Check if we should suppress this intervention
    if (await _shouldSuppressIntervention(trigger)) return null;
    
    // Generate appropriate intervention
    final intervention = await _createIntervention(
      trigger,
      behaviorPattern,
      personality,
      context,
    );
    
    // Save intervention
    await _saveIntervention(intervention);
    
    return intervention;
  }

  // Determine what triggered the intervention
  static InterventionTrigger? _determineTrigger(
    BehaviorPattern pattern,
    Map<String, dynamic> context,
  ) {
    // High-risk behaviors
    if (pattern.riskLevel == RiskLevel.critical) {
      return InterventionTrigger.riskBehavior;
    }
    
    // Impulsive spending
    if (pattern.type == BehaviorType.impulsive && 
        context['amount'] != null && 
        context['amount'] > 100) {
      return InterventionTrigger.impulsiveBehavior;
    }
    
    // Budget exceeded
    if (context['budget_exceeded'] == true) {
      return InterventionTrigger.budgetExceeded;
    }
    
    // Emotional spending
    if (pattern.type == BehaviorType.emotional && 
        pattern.type == BehaviorType.spending) {
      return InterventionTrigger.emotionalSpending;
    }
    
    // Avoidance pattern
    if (pattern.type == BehaviorType.avoiding && pattern.frequency > 0.7) {
      return InterventionTrigger.avoidancePattern;
    }
    
    // Positive behaviors
    if (pattern.type == BehaviorType.saving && pattern.intensity > 0.6) {
      return InterventionTrigger.positiveHabit;
    }
    
    if (pattern.type == BehaviorType.goalOriented && pattern.frequency > 0.5) {
      return InterventionTrigger.successMilestone;
    }
    
    // Learning opportunities
    if (pattern.type == BehaviorType.analytical) {
      return InterventionTrigger.learningOpportunity;
    }
    
    return null;
  }

  // Check if intervention should be suppressed
  static Future<bool> _shouldSuppressIntervention(InterventionTrigger trigger) async {
    final prefs = await SharedPreferences.getInstance();
    final settingsString = prefs.getString(_settingsKey) ?? '{}';
    final settings = Map<String, dynamic>.from(jsonDecode(settingsString));
    
    // Check if user has disabled this type of intervention
    final disabledTriggers = List<String>.from(settings['disabledTriggers'] ?? []);
    if (disabledTriggers.contains(trigger.toString().split('.').last)) {
      return true;
    }
    
    // Check rate limiting
    final lastIntervention = settings['lastIntervention'] as String?;
    if (lastIntervention != null) {
      final lastTime = DateTime.parse(lastIntervention);
      final timeSince = DateTime.now().difference(lastTime);
      
      // Don't show interventions more than once per hour
      if (timeSince.inMinutes < 60) {
        return true;
      }
    }
    
    return false;
  }

  // Create intervention based on trigger and personality
  static Future<CoachingIntervention> _createIntervention(
    InterventionTrigger trigger,
    BehaviorPattern pattern,
    FinancialPersonality? personality,
    Map<String, dynamic> context,
  ) async {
    final personalityType = personality?.type ?? FinancialPersonalityType.spender;
    final coachingStyle = personality?.coachingStyle ?? {};
    
    switch (trigger) {
      case InterventionTrigger.impulsiveBehavior:
        return _createImpulsiveSpendingIntervention(pattern, personalityType, context);
      
      case InterventionTrigger.budgetExceeded:
        return _createBudgetExceededIntervention(pattern, personalityType, context);
      
      case InterventionTrigger.emotionalSpending:
        return _createEmotionalSpendingIntervention(pattern, personalityType, context);
      
      case InterventionTrigger.avoidancePattern:
        return _createAvoidanceIntervention(pattern, personalityType, context);
      
      case InterventionTrigger.positiveHabit:
        return _createPositiveHabitIntervention(pattern, personalityType, context);
      
      case InterventionTrigger.successMilestone:
        return _createSuccessMilestoneIntervention(pattern, personalityType, context);
      
      case InterventionTrigger.riskBehavior:
        return _createRiskBehaviorIntervention(pattern, personalityType, context);
      
      case InterventionTrigger.learningOpportunity:
        return _createLearningOpportunityIntervention(pattern, personalityType, context);
      
      default:
        return _createGenericIntervention(trigger, pattern, personalityType, context);
    }
  }

  // Impulsive spending intervention
  static CoachingIntervention _createImpulsiveSpendingIntervention(
    BehaviorPattern pattern,
    FinancialPersonalityType personalityType,
    Map<String, dynamic> context,
  ) {
    final amount = context['amount'] as double? ?? 0.0;
    
    String title;
    String message;
    List<String> actions;
    InterventionType type;
    
    switch (personalityType) {
      case FinancialPersonalityType.spender:
        title = "Hold up, bestie! 💅";
        message = "I see you're about to spend \$${amount.toStringAsFixed(0)} on something. That's a pretty big purchase! Want to take a moment to think about it? Maybe ask yourself: 'Will this bring me joy in 6 months?'";
        actions = ["Wait 24 hours", "Add to wishlist", "Set a spending limit"];
        type = InterventionType.gentle;
        break;
        
      case FinancialPersonalityType.saver:
        title = "Spending Alert ⚠️";
        message = "You're about to make a \$${amount.toStringAsFixed(0)} purchase. This seems unusual for your saving nature. Is this aligned with your financial goals?";
        actions = ["Review budget", "Consider alternatives", "Delay purchase"];
        type = InterventionType.warning;
        break;
        
      case FinancialPersonalityType.avoider:
        title = "Quick Check-in 🌸";
        message = "I noticed a \$${amount.toStringAsFixed(0)} purchase. No pressure, but would you like to take a quick look at your budget first?";
        actions = ["Check budget", "Set reminder", "Skip for now"];
        type = InterventionType.gentle;
        break;
        
      default:
        title = "Spending Pause";
        message = "You're about to spend \$${amount.toStringAsFixed(0)}. Consider if this aligns with your financial goals.";
        actions = ["Review goals", "Check budget", "Proceed anyway"];
        type = InterventionType.warning;
    }
    
    return CoachingIntervention(
      id: _generateId(),
      type: type,
      trigger: InterventionTrigger.impulsiveBehavior,
      title: title,
      message: message,
      actions: actions,
      context: context,
      createdAt: DateTime.now(),
      priority: 8,
    );
  }

  // Budget exceeded intervention
  static CoachingIntervention _createBudgetExceededIntervention(
    BehaviorPattern pattern,
    FinancialPersonalityType personalityType,
    Map<String, dynamic> context,
  ) {
    final category = context['category'] as String? ?? 'this category';
    final overage = context['overage'] as double? ?? 0.0;
    
    String title;
    String message;
    List<String> actions;
    
    switch (personalityType) {
      case FinancialPersonalityType.spender:
        title = "Oops! Budget Alert 💅";
        message = "You've gone over your $category budget by \$${overage.toStringAsFixed(0)}. No worries, it happens! Want to adjust your budget or cut back elsewhere?";
        actions = ["Adjust budget", "Find savings", "Track better"];
        break;
        
      case FinancialPersonalityType.saver:
        title = "Budget Exceeded";
        message = "You've exceeded your $category budget by \$${overage.toStringAsFixed(0)}. Let's review and adjust your spending plan.";
        actions = ["Review budget", "Analyze spending", "Make adjustments"];
        break;
        
      default:
        title = "Budget Alert";
        message = "You've exceeded your $category budget by \$${overage.toStringAsFixed(0)}. Consider adjusting your spending.";
        actions = ["Review budget", "Adjust spending", "Set alerts"];
    }
    
    return CoachingIntervention(
      id: _generateId(),
      type: InterventionType.warning,
      trigger: InterventionTrigger.budgetExceeded,
      title: title,
      message: message,
      actions: actions,
      context: context,
      createdAt: DateTime.now(),
      priority: 7,
    );
  }

  // Emotional spending intervention
  static CoachingIntervention _createEmotionalSpendingIntervention(
    BehaviorPattern pattern,
    FinancialPersonalityType personalityType,
    Map<String, dynamic> context,
  ) {
    final emotionalState = context['emotional_state'] as String? ?? 'stressed';
    
    String title;
    String message;
    List<String> actions;
    
    switch (emotionalState) {
      case 'stressed':
        title = "I see you're stressed 💙";
        message = "Shopping when stressed can feel good in the moment, but it might add more stress later. Want to try a different way to feel better?";
        actions = ["Take a walk", "Call a friend", "Practice breathing", "Shop anyway"];
        break;
        
      case 'sad':
        title = "I'm here for you 💕";
        message = "I know you're feeling down, and shopping might seem like it'll help. But let's think about what would really make you feel better.";
        actions = ["Watch a movie", "Treat yourself to a bath", "Call someone you love", "Buy something small"];
        break;
        
      case 'excited':
        title = "Feeling the excitement! 🎉";
        message = "I love your energy! But let's make sure this purchase fits your budget before you get too excited.";
        actions = ["Check budget first", "Set a limit", "Go for it!", "Wait a bit"];
        break;
        
      default:
        title = "Emotional Spending Alert";
        message = "I notice you're shopping while feeling $emotionalState. Take a moment to consider if this purchase will truly help.";
        actions = ["Pause and think", "Check your feelings", "Proceed if needed"];
    }
    
    return CoachingIntervention(
      id: _generateId(),
      type: InterventionType.gentle,
      trigger: InterventionTrigger.emotionalSpending,
      title: title,
      message: message,
      actions: actions,
      context: context,
      createdAt: DateTime.now(),
      priority: 6,
    );
  }

  // Avoidance pattern intervention
  static CoachingIntervention _createAvoidanceIntervention(
    BehaviorPattern pattern,
    FinancialPersonalityType personalityType,
    Map<String, dynamic> context,
  ) {
    String title;
    String message;
    List<String> actions;
    
    switch (personalityType) {
      case FinancialPersonalityType.avoider:
        title = "No pressure, but... 🌸";
        message = "I've noticed you've been avoiding some financial tasks. That's totally okay! Want to try tackling just one small thing today?";
        actions = ["Check one account", "Review one bill", "Set one goal", "Not today"];
        break;
        
      case FinancialPersonalityType.worrier:
        title = "I understand the worry 💙";
        message = "Financial tasks can feel overwhelming. Let's break this down into tiny, manageable steps. You don't have to do everything at once.";
        actions = ["Start with 5 minutes", "Ask for help", "Take it slow", "Skip for now"];
        break;
        
      default:
        title = "Gentle Reminder";
        message = "I've noticed some financial tasks have been piling up. Would you like to tackle one small thing today?";
        actions = ["Pick one task", "Set a timer", "Ask for help", "Maybe later"];
    }
    
    return CoachingIntervention(
      id: _generateId(),
      type: InterventionType.gentle,
      trigger: InterventionTrigger.avoidancePattern,
      title: title,
      message: message,
      actions: actions,
      context: context,
      createdAt: DateTime.now(),
      priority: 4,
    );
  }

  // Positive habit intervention
  static CoachingIntervention _createPositiveHabitIntervention(
    BehaviorPattern pattern,
    FinancialPersonalityType personalityType,
    Map<String, dynamic> context,
  ) {
    String title;
    String message;
    List<String> actions;
    
    switch (personalityType) {
      case FinancialPersonalityType.spender:
        title = "Look at you go! 💅✨";
        message = "I'm so proud of you for saving money! This is a huge step for you. Keep up this amazing energy!";
        actions = ["Set another goal", "Celebrate this win", "Share with friends", "Keep going"];
        break;
        
      case FinancialPersonalityType.saver:
        title = "Consistent as always! 💪";
        message = "Your saving habits are impressive! You're building such a strong financial foundation.";
        actions = ["Review progress", "Set new goals", "Consider investing", "Keep it up"];
        break;
        
      default:
        title = "Great job! 🎉";
        message = "I love seeing you make positive financial choices! You're building great habits.";
        actions = ["Track progress", "Set new goals", "Celebrate", "Continue"];
    }
    
    return CoachingIntervention(
      id: _generateId(),
      type: InterventionType.celebration,
      trigger: InterventionTrigger.positiveHabit,
      title: title,
      message: message,
      actions: actions,
      context: context,
      createdAt: DateTime.now(),
      priority: 3,
    );
  }

  // Success milestone intervention
  static CoachingIntervention _createSuccessMilestoneIntervention(
    BehaviorPattern pattern,
    FinancialPersonalityType personalityType,
    Map<String, dynamic> context,
  ) {
    final goalName = context['goal_name'] as String? ?? 'your goal';
    final progress = context['progress'] as double? ?? 0.0;
    
    String title;
    String message;
    List<String> actions;
    
    switch (personalityType) {
      case FinancialPersonalityType.achiever:
        title = "You're crushing it! 🏆";
        message = "Amazing progress on $goalName! You're ${(progress * 100).round()}% there. Your determination is inspiring!";
        actions = ["Set next milestone", "Increase the goal", "Share the win", "Keep pushing"];
        break;
        
      case FinancialPersonalityType.optimist:
        title = "Dreams becoming reality! ✨";
        message = "Look at you making $goalName happen! ${(progress * 100).round()}% complete - your positive energy is working!";
        actions = ["Visualize the finish", "Plan the celebration", "Share the joy", "Keep believing"];
        break;
        
      default:
        title = "Milestone reached! 🎯";
        message = "Congratulations on reaching ${(progress * 100).round()}% of $goalName! You're making great progress.";
        actions = ["Review the journey", "Set next goal", "Celebrate", "Continue"];
    }
    
    return CoachingIntervention(
      id: _generateId(),
      type: InterventionType.celebration,
      trigger: InterventionTrigger.successMilestone,
      title: title,
      message: message,
      actions: actions,
      context: context,
      createdAt: DateTime.now(),
      priority: 2,
    );
  }

  // Risk behavior intervention
  static CoachingIntervention _createRiskBehaviorIntervention(
    BehaviorPattern pattern,
    FinancialPersonalityType personalityType,
    Map<String, dynamic> context,
  ) {
    String title;
    String message;
    List<String> actions;
    
    switch (personalityType) {
      case FinancialPersonalityType.worrier:
        title = "I'm concerned about you 💙";
        message = "I've noticed some risky financial behavior that might cause you stress later. Let's talk about this and find a safer path.";
        actions = ["Talk to Mali", "Review the situation", "Get support", "Take a break"];
        break;
        
      case FinancialPersonalityType.rebel:
        title = "Hey, let's chat 💭";
        message = "I respect your independence, but I'm seeing some patterns that could be risky. Want to explore some alternatives?";
        actions = ["Discuss options", "Find alternatives", "Trust your instincts", "Ignore this"];
        break;
        
      default:
        title = "Important Alert ⚠️";
        message = "I've detected some high-risk financial behavior. Let's address this before it becomes a bigger issue.";
        actions = ["Review behavior", "Seek advice", "Make changes", "Dismiss"];
    }
    
    return CoachingIntervention(
      id: _generateId(),
      type: InterventionType.urgent,
      trigger: InterventionTrigger.riskBehavior,
      title: title,
      message: message,
      actions: actions,
      context: context,
      createdAt: DateTime.now(),
      priority: 10,
    );
  }

  // Learning opportunity intervention
  static CoachingIntervention _createLearningOpportunityIntervention(
    BehaviorPattern pattern,
    FinancialPersonalityType personalityType,
    Map<String, dynamic> context,
  ) {
    String title;
    String message;
    List<String> actions;
    
    switch (personalityType) {
      case FinancialPersonalityType.analyzer:
        title = "Data insights incoming! 📊";
        message = "I see you're diving deep into your finances. Want to explore some advanced analysis techniques?";
        actions = ["Learn more", "Try new tools", "Share insights", "Keep analyzing"];
        break;
        
      case FinancialPersonalityType.achiever:
        title = "Level up opportunity! 🚀";
        message = "You're already doing great with financial analysis. Ready to take it to the next level?";
        actions = ["Set advanced goals", "Learn new strategies", "Challenge yourself", "Stay current"];
        break;
        
      default:
        title = "Learning moment! 📚";
        message = "I noticed you're analyzing your finances. Want to learn some new insights about your patterns?";
        actions = ["Explore insights", "Learn more", "Apply knowledge", "Skip for now"];
    }
    
    return CoachingIntervention(
      id: _generateId(),
      type: InterventionType.educational,
      trigger: InterventionTrigger.learningOpportunity,
      title: title,
      message: message,
      actions: actions,
      context: context,
      createdAt: DateTime.now(),
      priority: 3,
    );
  }

  // Generic intervention
  static CoachingIntervention _createGenericIntervention(
    InterventionTrigger trigger,
    BehaviorPattern pattern,
    FinancialPersonalityType personalityType,
    Map<String, dynamic> context,
  ) {
    return CoachingIntervention(
      id: _generateId(),
      type: InterventionType.gentle,
      trigger: trigger,
      title: "Financial Check-in",
      message: "I noticed some activity in your finances. Want to review what's happening?",
      actions: ["Review", "Learn more", "Dismiss"],
      context: context,
      createdAt: DateTime.now(),
      priority: 5,
    );
  }

  // Save intervention
  static Future<void> _saveIntervention(CoachingIntervention intervention) async {
    final prefs = await SharedPreferences.getInstance();
    final interventionsString = prefs.getString(_interventionsKey) ?? '[]';
    final interventions = List<Map<String, dynamic>>.from(jsonDecode(interventionsString));
    
    interventions.add(intervention.toJson());
    
    // Keep only last 50 interventions
    if (interventions.length > 50) {
      interventions.removeRange(0, interventions.length - 50);
    }
    
    await prefs.setString(_interventionsKey, jsonEncode(interventions));
    
    // Update last intervention time
    final settingsString = prefs.getString(_settingsKey) ?? '{}';
    final settings = Map<String, dynamic>.from(jsonDecode(settingsString));
    settings['lastIntervention'] = DateTime.now().toIso8601String();
    await prefs.setString(_settingsKey, jsonEncode(settings));
  }

  // Get all interventions
  static Future<List<CoachingIntervention>> getInterventions() async {
    final prefs = await SharedPreferences.getInstance();
    final interventionsString = prefs.getString(_interventionsKey) ?? '[]';
    final interventionsJson = List<Map<String, dynamic>>.from(jsonDecode(interventionsString));
    
    return interventionsJson.map((json) => CoachingIntervention.fromJson(json)).toList();
  }

  // Get unread interventions
  static Future<List<CoachingIntervention>> getUnreadInterventions() async {
    final interventions = await getInterventions();
    return interventions.where((i) => !i.isRead && !i.isDismissed).toList();
  }

  // Mark intervention as read
  static Future<void> markAsRead(String interventionId) async {
    final interventions = await getInterventions();
    final intervention = interventions.firstWhere(
      (i) => i.id == interventionId,
      orElse: () => throw Exception('Intervention not found'),
    );
    
    final updatedIntervention = CoachingIntervention(
      id: intervention.id,
      type: intervention.type,
      trigger: intervention.trigger,
      title: intervention.title,
      message: intervention.message,
      actions: intervention.actions,
      context: intervention.context,
      createdAt: intervention.createdAt,
      isRead: true,
      isDismissed: intervention.isDismissed,
      priority: intervention.priority,
    );
    
    await _updateIntervention(updatedIntervention);
  }

  // Dismiss intervention
  static Future<void> dismissIntervention(String interventionId) async {
    final interventions = await getInterventions();
    final intervention = interventions.firstWhere(
      (i) => i.id == interventionId,
      orElse: () => throw Exception('Intervention not found'),
    );
    
    final updatedIntervention = CoachingIntervention(
      id: intervention.id,
      type: intervention.type,
      trigger: intervention.trigger,
      title: intervention.title,
      message: intervention.message,
      actions: intervention.actions,
      context: intervention.context,
      createdAt: intervention.createdAt,
      isRead: intervention.isRead,
      isDismissed: true,
      priority: intervention.priority,
    );
    
    await _updateIntervention(updatedIntervention);
  }

  // Update intervention
  static Future<void> _updateIntervention(CoachingIntervention intervention) async {
    final prefs = await SharedPreferences.getInstance();
    final interventionsString = prefs.getString(_interventionsKey) ?? '[]';
    final interventions = List<Map<String, dynamic>>.from(jsonDecode(interventionsString));
    
    final index = interventions.indexWhere((i) => i['id'] == intervention.id);
    if (index != -1) {
      interventions[index] = intervention.toJson();
      await prefs.setString(_interventionsKey, jsonEncode(interventions));
    }
  }

  // Generate unique ID
  static String _generateId() {
    return DateTime.now().millisecondsSinceEpoch.toString() + 
           Random().nextInt(1000).toString();
  }
}

