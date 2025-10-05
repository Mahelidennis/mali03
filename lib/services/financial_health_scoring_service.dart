import 'dart:convert';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import 'financial_personality_service.dart';
import 'behavioral_analysis_service.dart';

enum HealthMetric {
  spendingControl,    // How well user controls spending
  savingHabits,       // Regular saving behavior
  goalProgress,       // Progress toward financial goals
  budgetAdherence,    // Following budget plans
  emotionalStability, // Emotional relationship with money
  financialLiteracy,  // Knowledge and understanding
  riskManagement,     // Managing financial risks
  futurePlanning,     // Long-term planning behavior
}

enum AchievementType {
  streak,           // Consecutive days of good behavior
  milestone,        // Reaching specific goals
  improvement,      // Significant improvement in metrics
  consistency,      // Consistent good behavior
  learning,         // Completing educational content
  challenge,        // Completing specific challenges
  social,           // Sharing or helping others
  recovery,         // Bouncing back from setbacks
}

class HealthScore {
  final double overallScore;      // 0.0 to 100.0
  final Map<HealthMetric, double> metricScores;
  final String level;             // Beginner, Intermediate, Advanced, Expert
  final String badge;             // Current achievement badge
  final List<String> strengths;
  final List<String> improvements;
  final DateTime lastUpdated;
  final int streakDays;
  final int totalAchievements;

  HealthScore({
    required this.overallScore,
    required this.metricScores,
    required this.level,
    required this.badge,
    required this.strengths,
    required this.improvements,
    required this.lastUpdated,
    required this.streakDays,
    required this.totalAchievements,
  });

  Map<String, dynamic> toJson() => {
    'overallScore': overallScore,
    'metricScores': metricScores.map((k, v) => MapEntry(k.toString().split('.').last, v)),
    'level': level,
    'badge': badge,
    'strengths': strengths,
    'improvements': improvements,
    'lastUpdated': lastUpdated.toIso8601String(),
    'streakDays': streakDays,
    'totalAchievements': totalAchievements,
  };

  factory HealthScore.fromJson(Map<String, dynamic> json) {
    final metricScoresMap = <HealthMetric, double>{};
    final metricScoresJson = Map<String, dynamic>.from(json['metricScores']);
    
    for (final entry in metricScoresJson.entries) {
      final metric = HealthMetric.values.firstWhere(
        (e) => e.toString().split('.').last == entry.key,
      );
      metricScoresMap[metric] = entry.value.toDouble();
    }
    
    return HealthScore(
      overallScore: json['overallScore'].toDouble(),
      metricScores: metricScoresMap,
      level: json['level'],
      badge: json['badge'],
      strengths: List<String>.from(json['strengths']),
      improvements: List<String>.from(json['improvements']),
      lastUpdated: DateTime.parse(json['lastUpdated']),
      streakDays: json['streakDays'],
      totalAchievements: json['totalAchievements'],
    );
  }
}

class Achievement {
  final String id;
  final String title;
  final String description;
  final AchievementType type;
  final String icon;
  final int points;
  final DateTime earnedAt;
  final bool isNew;

  Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.icon,
    required this.points,
    required this.earnedAt,
    this.isNew = false,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'type': type.toString().split('.').last,
    'icon': icon,
    'points': points,
    'earnedAt': earnedAt.toIso8601String(),
    'isNew': isNew,
  };

  factory Achievement.fromJson(Map<String, dynamic> json) {
    return Achievement(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      type: AchievementType.values.firstWhere(
        (e) => e.toString().split('.').last == json['type'],
      ),
      icon: json['icon'],
      points: json['points'],
      earnedAt: DateTime.parse(json['earnedAt']),
      isNew: json['isNew'] ?? false,
    );
  }
}

class FinancialHealthScoringService {
  static const String _healthScoreKey = 'financial_health_score';
  static const String _achievementsKey = 'achievements';
  static const String _dailyStreakKey = 'daily_streak';
  static const String _challengesKey = 'challenges';

  // Calculate overall financial health score
  static Future<HealthScore> calculateHealthScore() async {
    final personality = await FinancialPersonalityService.getCurrentPersonality();
    final behaviorInsights = await BehavioralAnalysisService.getBehaviorInsights();
    
    // Calculate individual metric scores
    final metricScores = <HealthMetric, double>{};
    
    // Spending Control (0-100)
    metricScores[HealthMetric.spendingControl] = await _calculateSpendingControlScore();
    
    // Saving Habits (0-100)
    metricScores[HealthMetric.savingHabits] = await _calculateSavingHabitsScore();
    
    // Goal Progress (0-100)
    metricScores[HealthMetric.goalProgress] = await _calculateGoalProgressScore();
    
    // Budget Adherence (0-100)
    metricScores[HealthMetric.budgetAdherence] = await _calculateBudgetAdherenceScore();
    
    // Emotional Stability (0-100)
    metricScores[HealthMetric.emotionalStability] = await _calculateEmotionalStabilityScore();
    
    // Financial Literacy (0-100)
    metricScores[HealthMetric.financialLiteracy] = await _calculateFinancialLiteracyScore();
    
    // Risk Management (0-100)
    metricScores[HealthMetric.riskManagement] = await _calculateRiskManagementScore();
    
    // Future Planning (0-100)
    metricScores[HealthMetric.futurePlanning] = await _calculateFuturePlanningScore();
    
    // Calculate overall score (weighted average)
    final overallScore = _calculateOverallScore(metricScores, personality);
    
    // Determine level and badge
    final level = _determineLevel(overallScore);
    final badge = _determineBadge(metricScores, personality);
    
    // Identify strengths and improvements
    final strengths = _identifyStrengths(metricScores);
    final improvements = _identifyImprovements(metricScores);
    
    // Get streak and achievements
    final streakDays = await _getCurrentStreak();
    final totalAchievements = await _getTotalAchievements();
    
    final healthScore = HealthScore(
      overallScore: overallScore,
      metricScores: metricScores,
      level: level,
      badge: badge,
      strengths: strengths,
      improvements: improvements,
      lastUpdated: DateTime.now(),
      streakDays: streakDays,
      totalAchievements: totalAchievements,
    );
    
    // Save the score
    await _saveHealthScore(healthScore);
    
    // Check for new achievements
    await _checkForNewAchievements(healthScore);
    
    return healthScore;
  }

  // Calculate spending control score
  static Future<double> _calculateSpendingControlScore() async {
    final prefs = await SharedPreferences.getInstance();
    final expensesString = prefs.getStringList('user_expenses') ?? [];
    
    if (expensesString.isEmpty) return 50.0; // Neutral score for new users
    
    // Analyze spending patterns
    double totalSpending = 0;
    int impulsePurchases = 0;
    int plannedPurchases = 0;
    
    for (final expenseString in expensesString) {
      final expense = jsonDecode(expenseString);
      totalSpending += expense['amount'] ?? 0.0;
      
      if (expense['is_impulsive'] == true) {
        impulsePurchases++;
      } else {
        plannedPurchases++;
      }
    }
    
    // Calculate score based on impulse vs planned ratio
    final totalPurchases = impulsePurchases + plannedPurchases;
    if (totalPurchases == 0) return 50.0;
    
    final plannedRatio = plannedPurchases / totalPurchases;
    final impulseRatio = impulsePurchases / totalPurchases;
    
    // Base score from planned ratio, penalize impulse purchases
    double score = (plannedRatio * 80) - (impulseRatio * 30);
    
    return score.clamp(0.0, 100.0);
  }

  // Calculate saving habits score
  static Future<double> _calculateSavingHabitsScore() async {
    final prefs = await SharedPreferences.getInstance();
    final goalsString = prefs.getStringList('user_goals') ?? [];
    
    if (goalsString.isEmpty) return 30.0; // Low score for no goals
    
    double totalSaved = 0;
    double totalTarget = 0;
    int activeGoals = 0;
    
    for (final goalString in goalsString) {
      final goal = jsonDecode(goalString);
      if (goal['isCompleted'] != true) {
        totalSaved += goal['currentAmount'] ?? 0.0;
        totalTarget += goal['targetAmount'] ?? 0.0;
        activeGoals++;
      }
    }
    
    if (activeGoals == 0) return 30.0;
    
    // Calculate progress ratio
    final progressRatio = totalTarget > 0 ? totalSaved / totalTarget : 0.0;
    
    // Score based on progress and consistency
    double score = (progressRatio * 60) + (activeGoals * 5);
    
    return score.clamp(0.0, 100.0);
  }

  // Calculate goal progress score
  static Future<double> _calculateGoalProgressScore() async {
    final prefs = await SharedPreferences.getInstance();
    final goalsString = prefs.getStringList('user_goals') ?? [];
    
    if (goalsString.isEmpty) return 20.0;
    
    int completedGoals = 0;
    int totalGoals = goalsString.length;
    double totalProgress = 0;
    
    for (final goalString in goalsString) {
      final goal = jsonDecode(goalString);
      if (goal['isCompleted'] == true) {
        completedGoals++;
      } else {
        final current = goal['currentAmount'] ?? 0.0;
        final target = goal['targetAmount'] ?? 0.0;
        if (target > 0) {
          totalProgress += (current / target).clamp(0.0, 1.0);
        }
      }
    }
    
    final completionRate = completedGoals / totalGoals;
    final averageProgress = totalGoals > 0 ? totalProgress / totalGoals : 0.0;
    
    double score = (completionRate * 50) + (averageProgress * 50);
    
    return score.clamp(0.0, 100.0);
  }

  // Calculate budget adherence score
  static Future<double> _calculateBudgetAdherenceScore() async {
    final prefs = await SharedPreferences.getInstance();
    final budgetsString = prefs.getStringList('user_budgets') ?? [];
    final expensesString = prefs.getStringList('user_expenses') ?? [];
    
    if (budgetsString.isEmpty) return 40.0; // Medium score for no budget
    
    double totalBudget = 0;
    double totalSpent = 0;
    
    // Calculate total budget
    for (final budgetString in budgetsString) {
      final budget = jsonDecode(budgetString);
      totalBudget += budget['amount'] ?? 0.0;
    }
    
    // Calculate total spent this month
    final now = DateTime.now();
    for (final expenseString in expensesString) {
      final expense = jsonDecode(expenseString);
      final expenseDate = DateTime.parse(expense['date']);
      if (expenseDate.year == now.year && expenseDate.month == now.month) {
        totalSpent += expense['amount'] ?? 0.0;
      }
    }
    
    if (totalBudget == 0) return 40.0;
    
    final adherenceRatio = totalSpent / totalBudget;
    
    // Score based on adherence (under budget = good)
    double score;
    if (adherenceRatio <= 1.0) {
      score = 100 - (adherenceRatio * 20); // 80-100 for under budget
    } else {
      score = 80 - ((adherenceRatio - 1.0) * 40); // Penalty for over budget
    }
    
    return score.clamp(0.0, 100.0);
  }

  // Calculate emotional stability score
  static Future<double> _calculateEmotionalStabilityScore() async {
    final behaviorInsights = await BehavioralAnalysisService.getBehaviorInsights();
    final overallRisk = behaviorInsights['overallRisk'] as double? ?? 0.5;
    
    // Lower risk = higher emotional stability
    double score = (1.0 - overallRisk) * 100;
    
    // Check for emotional spending patterns
    final highRiskBehaviors = behaviorInsights['highRiskBehaviors'] as List? ?? [];
    final emotionalBehaviors = highRiskBehaviors.where((behavior) => 
      behavior['type'] == 'emotional'
    ).length;
    
    if (emotionalBehaviors > 0) {
      score -= emotionalBehaviors * 10;
    }
    
    return score.clamp(0.0, 100.0);
  }

  // Calculate financial literacy score
  static Future<double> _calculateFinancialLiteracyScore() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Check for educational content engagement
    final therapySessions = await _getCompletedTherapySessions();
    final educationalSessions = therapySessions.where((session) => 
      session['therapyType'] == 'educational'
    ).length;
    
    // Check for goal setting and planning
    final goalsString = prefs.getStringList('user_goals') ?? [];
    final budgetsString = prefs.getStringList('user_budgets') ?? [];
    
    // Check for financial reports usage
    final reportsViewed = prefs.getInt('reports_viewed') ?? 0;
    
    // Calculate score based on engagement
    double score = 20; // Base score
    score += educationalSessions * 10;
    score += goalsString.length * 5;
    score += budgetsString.length * 5;
    score += reportsViewed * 2;
    
    return score.clamp(0.0, 100.0);
  }

  // Calculate risk management score
  static Future<double> _calculateRiskManagementScore() async {
    final prefs = await SharedPreferences.getInstance();
    final goalsString = prefs.getStringList('user_goals') ?? [];
    
    // Check for emergency fund
    bool hasEmergencyFund = false;
    for (final goalString in goalsString) {
      final goal = jsonDecode(goalString);
      if (goal['category'] == 'Emergency Fund') {
        hasEmergencyFund = true;
        break;
      }
    }
    
    // Check for diversified goals
    final categories = <String>{};
    for (final goalString in goalsString) {
      final goal = jsonDecode(goalString);
      categories.add(goal['category'] ?? 'Other');
    }
    
    double score = 30; // Base score
    if (hasEmergencyFund) score += 30;
    score += categories.length * 10; // Diversification bonus
    
    return score.clamp(0.0, 100.0);
  }

  // Calculate future planning score
  static Future<double> _calculateFuturePlanningScore() async {
    final prefs = await SharedPreferences.getInstance();
    final goalsString = prefs.getStringList('user_goals') ?? [];
    
    if (goalsString.isEmpty) return 20.0;
    
    int longTermGoals = 0;
    int shortTermGoals = 0;
    
    for (final goalString in goalsString) {
      final goal = jsonDecode(goalString);
      final targetDate = DateTime.tryParse(goal['targetDate'] ?? '');
      if (targetDate != null) {
        final daysUntilTarget = targetDate.difference(DateTime.now()).inDays;
        if (daysUntilTarget > 365) {
          longTermGoals++;
        } else {
          shortTermGoals++;
        }
      }
    }
    
    double score = 20; // Base score
    score += longTermGoals * 15; // Long-term planning bonus
    score += shortTermGoals * 10; // Short-term planning bonus
    
    return score.clamp(0.0, 100.0);
  }

  // Calculate overall score with personality weighting
  static double _calculateOverallScore(
    Map<HealthMetric, double> metricScores,
    FinancialPersonality? personality,
  ) {
    // Default weights
    final weights = <HealthMetric, double>{
      HealthMetric.spendingControl: 0.15,
      HealthMetric.savingHabits: 0.15,
      HealthMetric.goalProgress: 0.15,
      HealthMetric.budgetAdherence: 0.15,
      HealthMetric.emotionalStability: 0.10,
      HealthMetric.financialLiteracy: 0.10,
      HealthMetric.riskManagement: 0.10,
      HealthMetric.futurePlanning: 0.10,
    };
    
    // Adjust weights based on personality
    if (personality != null) {
      switch (personality.type) {
        case FinancialPersonalityType.spender:
          weights[HealthMetric.spendingControl] = 0.25;
          weights[HealthMetric.emotionalStability] = 0.15;
          break;
        case FinancialPersonalityType.saver:
          weights[HealthMetric.savingHabits] = 0.25;
          weights[HealthMetric.riskManagement] = 0.15;
          break;
        case FinancialPersonalityType.avoider:
          weights[HealthMetric.emotionalStability] = 0.20;
          weights[HealthMetric.financialLiteracy] = 0.15;
          break;
        case FinancialPersonalityType.analyzer:
          weights[HealthMetric.financialLiteracy] = 0.20;
          weights[HealthMetric.futurePlanning] = 0.15;
          break;
        default:
          break;
      }
    }
    
    // Calculate weighted average
    double totalScore = 0.0;
    for (final entry in metricScores.entries) {
      totalScore += entry.value * weights[entry.key]!;
    }
    
    return totalScore;
  }

  // Determine user level
  static String _determineLevel(double overallScore) {
    if (overallScore >= 90) return 'Expert';
    if (overallScore >= 75) return 'Advanced';
    if (overallScore >= 60) return 'Intermediate';
    if (overallScore >= 40) return 'Beginner';
    return 'Novice';
  }

  // Determine current badge
  static String _determineBadge(
    Map<HealthMetric, double> metricScores,
    FinancialPersonality? personality,
  ) {
    // Find highest scoring metric
    HealthMetric highestMetric = HealthMetric.spendingControl;
    double highestScore = 0.0;
    
    for (final entry in metricScores.entries) {
      if (entry.value > highestScore) {
        highestScore = entry.value;
        highestMetric = entry.key;
      }
    }
    
    // Return badge based on highest metric
    switch (highestMetric) {
      case HealthMetric.spendingControl:
        return 'Spending Master';
      case HealthMetric.savingHabits:
        return 'Saving Champion';
      case HealthMetric.goalProgress:
        return 'Goal Achiever';
      case HealthMetric.budgetAdherence:
        return 'Budget Pro';
      case HealthMetric.emotionalStability:
        return 'Zen Master';
      case HealthMetric.financialLiteracy:
        return 'Financial Scholar';
      case HealthMetric.riskManagement:
        return 'Risk Guardian';
      case HealthMetric.futurePlanning:
        return 'Future Visionary';
    }
  }

  // Identify strengths
  static List<String> _identifyStrengths(Map<HealthMetric, double> metricScores) {
    final strengths = <String>[];
    
    for (final entry in metricScores.entries) {
      if (entry.value >= 80) {
        switch (entry.key) {
          case HealthMetric.spendingControl:
            strengths.add('Excellent spending control');
            break;
          case HealthMetric.savingHabits:
            strengths.add('Strong saving habits');
            break;
          case HealthMetric.goalProgress:
            strengths.add('Great goal achievement');
            break;
          case HealthMetric.budgetAdherence:
            strengths.add('Consistent budget following');
            break;
          case HealthMetric.emotionalStability:
            strengths.add('Emotionally stable with money');
            break;
          case HealthMetric.financialLiteracy:
            strengths.add('High financial knowledge');
            break;
          case HealthMetric.riskManagement:
            strengths.add('Excellent risk management');
            break;
          case HealthMetric.futurePlanning:
            strengths.add('Strong future planning');
            break;
        }
      }
    }
    
    return strengths;
  }

  // Identify improvements
  static List<String> _identifyImprovements(Map<HealthMetric, double> metricScores) {
    final improvements = <String>[];
    
    for (final entry in metricScores.entries) {
      if (entry.value < 60) {
        switch (entry.key) {
          case HealthMetric.spendingControl:
            improvements.add('Work on impulse spending control');
            break;
          case HealthMetric.savingHabits:
            improvements.add('Develop regular saving habits');
            break;
          case HealthMetric.goalProgress:
            improvements.add('Set and work toward financial goals');
            break;
          case HealthMetric.budgetAdherence:
            improvements.add('Create and follow a budget');
            break;
          case HealthMetric.emotionalStability:
            improvements.add('Work on emotional relationship with money');
            break;
          case HealthMetric.financialLiteracy:
            improvements.add('Increase financial knowledge');
            break;
          case HealthMetric.riskManagement:
            improvements.add('Improve risk management strategies');
            break;
          case HealthMetric.futurePlanning:
            improvements.add('Develop long-term financial planning');
            break;
        }
      }
    }
    
    return improvements;
  }

  // Get current streak
  static Future<int> _getCurrentStreak() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_dailyStreakKey) ?? 0;
  }

  // Get total achievements
  static Future<int> _getTotalAchievements() async {
    final achievements = await getAchievements();
    return achievements.length;
  }

  // Get completed therapy sessions
  static Future<List<Map<String, dynamic>>> _getCompletedTherapySessions() async {
    final prefs = await SharedPreferences.getInstance();
    final sessionsString = prefs.getString('emotional_sessions') ?? '[]';
    final sessions = List<Map<String, dynamic>>.from(jsonDecode(sessionsString));
    
    return sessions.where((session) => session['isCompleted'] == true).toList();
  }

  // Save health score
  static Future<void> _saveHealthScore(HealthScore healthScore) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_healthScoreKey, jsonEncode(healthScore.toJson()));
  }

  // Get health score
  static Future<HealthScore?> getHealthScore() async {
    final prefs = await SharedPreferences.getInstance();
    final scoreString = prefs.getString(_healthScoreKey);
    
    if (scoreString == null) return null;
    
    final scoreJson = jsonDecode(scoreString);
    return HealthScore.fromJson(scoreJson);
  }

  // Check for new achievements
  static Future<void> _checkForNewAchievements(HealthScore healthScore) async {
    final achievements = await getAchievements();
    final existingIds = achievements.map((a) => a.id).toSet();
    
    // Check for level achievements
    await _checkLevelAchievements(healthScore, existingIds);
    
    // Check for streak achievements
    await _checkStreakAchievements(healthScore, existingIds);
    
    // Check for metric achievements
    await _checkMetricAchievements(healthScore, existingIds);
  }

  // Check level achievements
  static Future<void> _checkLevelAchievements(
    HealthScore healthScore,
    Set<String> existingIds,
  ) async {
    final levelAchievements = {
      'level_beginner': {'level': 'Beginner', 'points': 10},
      'level_intermediate': {'level': 'Intermediate', 'points': 25},
      'level_advanced': {'level': 'Advanced', 'points': 50},
      'level_expert': {'level': 'Expert', 'points': 100},
    };
    
    for (final entry in levelAchievements.entries) {
      if (!existingIds.contains(entry.key) && healthScore.level == entry.value['level']) {
        await _addAchievement(Achievement(
          id: entry.key,
          title: '${entry.value['level']} Level Reached!',
          description: 'You\'ve reached the ${entry.value['level']} level in financial health!',
          type: AchievementType.milestone,
          icon: '🏆',
          points: entry.value!['points'] as int,
          earnedAt: DateTime.now(),
          isNew: true,
        ));
      }
    }
  }

  // Check streak achievements
  static Future<void> _checkStreakAchievements(
    HealthScore healthScore,
    Set<String> existingIds,
  ) async {
    final streakAchievements = {
      'streak_7': {'days': 7, 'points': 20},
      'streak_30': {'days': 30, 'points': 50},
      'streak_100': {'days': 100, 'points': 100},
    };
    
    for (final entry in streakAchievements.entries) {
      if (!existingIds.contains(entry.key) && healthScore.streakDays >= (entry.value!['days'] as int)) {
        await _addAchievement(Achievement(
          id: entry.key,
          title: '${entry.value!['days']}-Day Streak!',
          description: 'You\'ve maintained good financial habits for ${entry.value!['days']} days!',
          type: AchievementType.streak,
          icon: '🔥',
          points: entry.value!['points'] as int,
          earnedAt: DateTime.now(),
          isNew: true,
        ));
      }
    }
  }

  // Check metric achievements
  static Future<void> _checkMetricAchievements(
    HealthScore healthScore,
    Set<String> existingIds,
  ) async {
    for (final entry in healthScore.metricScores.entries) {
      if (entry.value >= 90) {
        final achievementId = 'metric_${entry.key.toString().split('.').last}_excellent';
        if (!existingIds.contains(achievementId)) {
          await _addAchievement(Achievement(
            id: achievementId,
            title: '${_getMetricDisplayName(entry.key)} Master!',
            description: 'You\'ve achieved excellence in ${_getMetricDisplayName(entry.key).toLowerCase()}!',
            type: AchievementType.improvement,
            icon: '⭐',
            points: 30,
            earnedAt: DateTime.now(),
            isNew: true,
          ));
        }
      }
    }
  }

  // Get metric display name
  static String _getMetricDisplayName(HealthMetric metric) {
    switch (metric) {
      case HealthMetric.spendingControl:
        return 'Spending Control';
      case HealthMetric.savingHabits:
        return 'Saving Habits';
      case HealthMetric.goalProgress:
        return 'Goal Progress';
      case HealthMetric.budgetAdherence:
        return 'Budget Adherence';
      case HealthMetric.emotionalStability:
        return 'Emotional Stability';
      case HealthMetric.financialLiteracy:
        return 'Financial Literacy';
      case HealthMetric.riskManagement:
        return 'Risk Management';
      case HealthMetric.futurePlanning:
        return 'Future Planning';
    }
  }

  // Add achievement
  static Future<void> _addAchievement(Achievement achievement) async {
    final prefs = await SharedPreferences.getInstance();
    final achievementsString = prefs.getString(_achievementsKey) ?? '[]';
    final achievements = List<Map<String, dynamic>>.from(jsonDecode(achievementsString));
    
    achievements.add(achievement.toJson());
    
    await prefs.setString(_achievementsKey, jsonEncode(achievements));
  }

  // Get achievements
  static Future<List<Achievement>> getAchievements() async {
    final prefs = await SharedPreferences.getInstance();
    final achievementsString = prefs.getString(_achievementsKey) ?? '[]';
    final achievementsJson = List<Map<String, dynamic>>.from(jsonDecode(achievementsString));
    
    return achievementsJson.map((json) => Achievement.fromJson(json)).toList();
  }

  // Update daily streak
  static Future<void> updateDailyStreak() async {
    final prefs = await SharedPreferences.getInstance();
    final lastUpdate = prefs.getString('last_streak_update');
    final now = DateTime.now();
    
    if (lastUpdate != null) {
      final lastDate = DateTime.parse(lastUpdate);
      final daysDifference = now.difference(lastDate).inDays;
      
      if (daysDifference == 1) {
        // Consecutive day
        final currentStreak = prefs.getInt(_dailyStreakKey) ?? 0;
        await prefs.setInt(_dailyStreakKey, currentStreak + 1);
      } else if (daysDifference > 1) {
        // Streak broken
        await prefs.setInt(_dailyStreakKey, 1);
      }
    } else {
      // First time
      await prefs.setInt(_dailyStreakKey, 1);
    }
    
    await prefs.setString('last_streak_update', now.toIso8601String());
  }

  // Mark achievement as seen
  static Future<void> markAchievementAsSeen(String achievementId) async {
    final achievements = await getAchievements();
    final achievement = achievements.firstWhere(
      (a) => a.id == achievementId,
      orElse: () => throw Exception('Achievement not found'),
    );
    
    final updatedAchievement = Achievement(
      id: achievement.id,
      title: achievement.title,
      description: achievement.description,
      type: achievement.type,
      icon: achievement.icon,
      points: achievement.points,
      earnedAt: achievement.earnedAt,
      isNew: false,
    );
    
    await _updateAchievement(updatedAchievement);
  }

  // Update achievement
  static Future<void> _updateAchievement(Achievement achievement) async {
    final prefs = await SharedPreferences.getInstance();
    final achievementsString = prefs.getString(_achievementsKey) ?? '[]';
    final achievements = List<Map<String, dynamic>>.from(jsonDecode(achievementsString));
    
    final index = achievements.indexWhere((a) => a['id'] == achievement.id);
    if (index != -1) {
      achievements[index] = achievement.toJson();
      await prefs.setString(_achievementsKey, jsonEncode(achievements));
    }
  }
}

