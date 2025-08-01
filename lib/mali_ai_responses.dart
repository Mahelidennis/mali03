import 'user_profile.dart';

class MaliAIResponses {
  static String getWelcomeMessage(UserProfile? profile) {
    if (profile == null) {
      return "Hey! 👋 I'm Mali, your financial big sister. Ready to get your money right? 💅";
    }

    final greeting = profile.genderGreeting;
    final emoji = profile.genderEmoji;
    
    return "$greeting $emoji! I'm Mali, your financial big ${profile.genderPronoun}. Ready to crush your money goals? 💪";
  }

  static String getSpendingResponse(String message, UserProfile? profile, Map<String, dynamic>? spendingData) {
    final lowerMessage = message.toLowerCase();
    final greeting = profile?.genderGreeting ?? 'Hey';
    final pronoun = profile?.genderPronoun ?? 'sister';

    // Coffee spending (very common in Kenya)
    if (lowerMessage.contains('coffee') || lowerMessage.contains('java') || lowerMessage.contains('starbucks')) {
      return "$greeting, you and that coffee habit! ☕ This month you've spent KSh ${spendingData?['coffee'] ?? '8,000'} on coffee alone! That's like buying a new phone every 4 months. Maybe try making coffee at home? 💡";
    }

    // Transport spending
    if (lowerMessage.contains('uber') || lowerMessage.contains('taxi') || lowerMessage.contains('transport')) {
      return "$greeting, these Uber rides are eating your money! 🚗 You've spent KSh ${spendingData?['transport'] ?? '5,000'} this month on transport. Consider walking or using matatus for short distances! 💪";
    }

    // Food/restaurant spending
    if (lowerMessage.contains('food') || lowerMessage.contains('restaurant') || lowerMessage.contains('eat')) {
      return "$greeting, you're spending like a CEO at restaurants! 🍽️ KSh ${spendingData?['food'] ?? '12,000'} on food this month. Maybe try cooking at home? Your wallet will thank you! 💰";
    }

    // Shopping/online purchases
    if (lowerMessage.contains('shop') || lowerMessage.contains('buy') || lowerMessage.contains('purchase')) {
      return "$greeting, online shopping is your weakness! 🛍️ You've spent KSh ${spendingData?['shopping'] ?? '15,000'} this month. Remember, every shilling counts! 💸";
    }

    // General spending
    if (lowerMessage.contains('spend') || lowerMessage.contains('bought')) {
      return "$greeting, you spending money like it's going out of style! 😂 What did you buy this time? Let me help you track that spending! 📱";
    }

    return "$greeting, tell me more about your spending! I'm here to help you make smart financial decisions! 💪";
  }

  static String getSavingResponse(String message, UserProfile? profile, Map<String, dynamic>? savingData) {
    final greeting = profile?.genderGreeting ?? 'Hey';
    final pronoun = profile?.genderPronoun ?? 'sister';

    if (message.toLowerCase().contains('save') || message.toLowerCase().contains('saving')) {
      final currentSavings = savingData?['current'] ?? 0.0;
      final monthlyGoal = savingData?['monthly_goal'] ?? 10000.0;
      final percentage = (currentSavings / monthlyGoal * 100).round();

      if (percentage >= 100) {
        return "YES! That's my $pronoun! 🎉 You've exceeded your savings goal! You're absolutely killing it! 💪";
      } else if (percentage >= 70) {
        return "$greeting, you're almost there! 💪 You've saved ${percentage}% of your goal. Keep pushing! 🔥";
      } else if (percentage >= 40) {
        return "Good progress, $pronoun! 💪 You're ${percentage}% to your goal. Let's keep the momentum going! 🚀";
      } else {
        return "$greeting, we need to step up the savings game! 💡 You're only ${percentage}% to your goal. Let's get serious about this! 💪";
      }
    }

    return "$greeting, what's your savings goal? I'm here to cheer you on! 🎯";
  }

  static String getGoalResponse(String message, UserProfile? profile, Map<String, dynamic>? goalData) {
    final greeting = profile?.genderGreeting ?? 'Hey';
    final pronoun = profile?.genderPronoun ?? 'sister';

    if (message.toLowerCase().contains('goal') || message.toLowerCase().contains('target')) {
      final activeGoals = goalData?['active_count'] ?? 0;
      final completedGoals = goalData?['completed_count'] ?? 0;

      if (completedGoals > 0) {
        return "$greeting, you've completed $completedGoals goals! 🎉 That's what I'm talking about! You're a goal-crushing machine! 💪";
      } else if (activeGoals > 0) {
        return "$greeting, you have $activeGoals active goals! 🎯 Let's focus on one at a time and crush them! 💪";
      } else {
        return "$greeting, let's set some financial goals! 🎯 What do you want to achieve? I'll help you get there! ✨";
      }
    }

    return "$greeting, tell me about your goals! I'm here to help you achieve them! 🎯";
  }

  static String getIncomeResponse(String message, UserProfile? profile, Map<String, dynamic>? incomeData) {
    final greeting = profile?.genderGreeting ?? 'Hey';
    final pronoun = profile?.genderPronoun ?? 'sister';

    if (message.toLowerCase().contains('salary') || message.toLowerCase().contains('income') || message.toLowerCase().contains('money')) {
      final monthlyIncome = incomeData?['monthly'] ?? profile?.monthlyIncome ?? 0.0;
      
      if (monthlyIncome > 0) {
        return "$greeting, money coming in! 💰 That's what I like to hear! Your monthly income is KSh ${monthlyIncome.toStringAsFixed(0)}. How are you planning to use it? Let's make sure you're not just spending it all! 💅";
      } else {
        return "$greeting, let's talk about your income! 💰 What's your monthly salary? I'll help you budget it properly! 💪";
      }
    }

    return "$greeting, tell me about your income! I'm here to help you manage it wisely! 💰";
  }

  static String getBudgetResponse(String message, UserProfile? profile, Map<String, dynamic>? budgetData) {
    final greeting = profile?.genderGreeting ?? 'Hey';
    final pronoun = profile?.genderPronoun ?? 'sister';

    if (message.toLowerCase().contains('budget') || message.toLowerCase().contains('limit')) {
      final budget = budgetData?['monthly_budget'] ?? 0.0;
      final spent = budgetData?['spent_this_month'] ?? 0.0;
      final remaining = budget - spent;
      final percentage = (spent / budget * 100).round();

      if (percentage > 90) {
        return "$greeting, you're almost out of budget! ⚠️ You've spent ${percentage}% of your monthly budget. Only KSh ${remaining.toStringAsFixed(0)} left. Time to tighten those purse strings! 💸";
      } else if (percentage > 70) {
        return "$greeting, you're spending wisely! 💪 You've used ${percentage}% of your budget. KSh ${remaining.toStringAsFixed(0)} remaining. Keep it up! 👍";
      } else {
        return "$greeting, you're doing great with your budget! 🎉 You've only used ${percentage}% so far. KSh ${remaining.toStringAsFixed(0)} left. You're a budgeting pro! 💪";
      }
    }

    return "$greeting, let's talk about your budget! I'll help you stay on track! 📊";
  }

  static String getFinancialEducationResponse(String message, UserProfile? profile) {
    final greeting = profile?.genderGreeting ?? 'Hey';
    final pronoun = profile?.genderPronoun ?? 'sister';

    final lowerMessage = message.toLowerCase();

    if (lowerMessage.contains('invest') || lowerMessage.contains('investment')) {
      return "$greeting, let's talk investments! 💡 In Kenya, you can start with M-Akiba bonds, SACCO shares, or even local stocks. Start small, $pronoun! 📈";
    }

    if (lowerMessage.contains('emergency') || lowerMessage.contains('fund')) {
      return "$greeting, emergency fund is crucial! 💪 Aim for 3-6 months of expenses. Start with KSh 1,000 per month. You'll thank yourself later! 🛡️";
    }

    if (lowerMessage.contains('debt') || lowerMessage.contains('loan')) {
      return "$greeting, debt can be tricky! 💡 Focus on high-interest debt first (like credit cards). Pay more than minimum to save on interest! 📉";
    }

    if (lowerMessage.contains('sacco') || lowerMessage.contains('chama')) {
      return "$greeting, SACCOs and chamas are great! 🤝 They offer better interest rates than banks. Plus, you get community support! 💪";
    }

    if (lowerMessage.contains('m-pesa') || lowerMessage.contains('mobile money')) {
      return "$greeting, M-Pesa is revolutionary! 📱 But don't keep too much money there. Transfer to bank for better interest rates! 💰";
    }

    return "$greeting, what financial topic do you want to learn about? I'm here to educate you! 📚";
  }

  static String getCelebrationResponse(String achievement, UserProfile? profile) {
    final greeting = profile?.genderGreeting ?? 'Hey';
    final pronoun = profile?.genderPronoun ?? 'sister';

    switch (achievement.toLowerCase()) {
      case 'savings_goal':
        return "🎉 $greeting, you did it! You reached your savings goal! Mali is so proud of you! You're absolutely crushing it! 💪";
      
      case 'budget_streak':
        return "🔥 $greeting, you've been sticking to your budget for days! You're a budgeting legend! Keep it up! 💪";
      
      case 'debt_free':
        return "🎊 $greeting, you're debt-free! That's a huge achievement! You're financially free! 🚀";
      
      case 'investment_started':
        return "📈 $greeting, you started investing! That's thinking long-term! Your future self will thank you! 💪";
      
      case 'emergency_fund':
        return "🛡️ $greeting, you built your emergency fund! You're financially secure! That's adulting done right! 💪";
      
      default:
        return "🎉 $greeting, congratulations on your achievement! You're making Mali proud! 💪";
    }
  }

  static String getRoastingResponse(String spendingCategory, double amount, UserProfile? profile) {
    final greeting = profile?.genderGreeting ?? 'Hey';
    final pronoun = profile?.genderPronoun ?? 'sister';

    switch (spendingCategory.toLowerCase()) {
      case 'coffee':
        return "$greeting, KSh ${amount.toStringAsFixed(0)} on coffee this month? ☕ That's like buying a new phone every 4 months! Maybe try making coffee at home? 💡";
      
      case 'transport':
        return "$greeting, KSh ${amount.toStringAsFixed(0)} on transport? 🚗 Your legs work, right? Consider walking or using matatus! 💪";
      
      case 'food':
        return "$greeting, KSh ${amount.toStringAsFixed(0)} on restaurants? 🍽️ Your kitchen is just for decoration? Time to learn some cooking skills! 👨‍🍳";
      
      case 'shopping':
        return "$greeting, KSh ${amount.toStringAsFixed(0)} on shopping? 🛍️ Your wardrobe is bigger than a boutique! Maybe slow down a bit? 😅";
      
      case 'entertainment':
        return "$greeting, KSh ${amount.toStringAsFixed(0)} on entertainment? 🎬 You're living like a celebrity! Maybe find some free activities? 🎭";
      
      default:
        return "$greeting, you spent KSh ${amount.toStringAsFixed(0)} on $spendingCategory? 💸 That's quite a lot! Let's think about this next time! 💡";
    }
  }

  static String getDefaultResponse(String message, UserProfile? profile) {
    final greeting = profile?.genderGreeting ?? 'Hey';
    final pronoun = profile?.genderPronoun ?? 'sister';

    return "$greeting, that's interesting! 🤔 Tell me more about that. I'm here to help you make smart financial decisions, $pronoun! 💪";
  }
} 