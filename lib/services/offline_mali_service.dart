import 'dart:math';

/// Offline Mali AI service that provides intelligent financial advice without external API calls
class OfflineMaliService {
  static final Random _random = Random();

  /// Get Mali's response based on user message and financial context
  static String getMaliResponse({
    required String userMessage,
    required Map<String, dynamic> financialContext,
    required String selectedVibe,
    List<Map<String, String>>? conversationHistory,
  }) {
    final message = userMessage.toLowerCase();
    
    // Financial context analysis
    final totalExpenses = financialContext['totalExpenses'] ?? 0.0;
    final totalIncome = financialContext['totalIncome'] ?? 0.0;
    final activeGoals = financialContext['activeGoals'] ?? 0;
    final budgetStatus = totalIncome > totalExpenses ? 'Under Budget' : 'Over Budget';
    
    // Calculate financial health score
    final financialHealth = _calculateFinancialHealth(totalIncome, totalExpenses);
    
    // Determine response based on message content
    if (message.contains('hello') || message.contains('hi') || message.contains('hey')) {
      return _getGreetingResponse(selectedVibe, financialHealth);
    } else if (message.contains('budget') || message.contains('spending')) {
      return _getBudgetAdvice(selectedVibe, totalIncome, totalExpenses, budgetStatus);
    } else if (message.contains('save') || message.contains('saving')) {
      return _getSavingAdvice(selectedVibe, totalIncome, totalExpenses);
    } else if (message.contains('goal') || message.contains('target')) {
      return _getGoalAdvice(selectedVibe, activeGoals);
    } else if (message.contains('expense') || message.contains('cost')) {
      return _getExpenseAdvice(selectedVibe, totalExpenses);
    } else if (message.contains('income') || message.contains('earn')) {
      return _getIncomeAdvice(selectedVibe, totalIncome);
    } else if (message.contains('debt') || message.contains('loan')) {
      return _getDebtAdvice(selectedVibe);
    } else if (message.contains('invest') || message.contains('investment')) {
      return _getInvestmentAdvice(selectedVibe);
    } else if (message.contains('emergency') || message.contains('fund')) {
      return _getEmergencyFundAdvice(selectedVibe, totalIncome);
    } else if (message.contains('help') || message.contains('advice')) {
      return _getGeneralHelp(selectedVibe, financialHealth);
    } else {
      return _getGeneralResponse(selectedVibe, financialHealth, userMessage);
    }
  }

  static String _getGreetingResponse(String vibe, String financialHealth) {
    final responses = {
      'Sassy & Bold': [
        "Hey there, future boss! 💅 Ready to achieve your financial goals? I'm here to help you become the money queen you were meant to be!",
        "What's up, financial warrior? 💪 Let's make your money work harder than you do!",
        "Hey gorgeous! 💖 Ready to turn your financial dreams into reality? I've got your back!",
        "Hello there, money maker! 🔥 Let's get your finances looking absolutely fabulous today!",
      ],
      'Encouraging & Gentle': [
        "Hello! 🌸 I'm here to gently guide you on your financial journey. Let's take this step by step together.",
        "Hi there! 💙 I'm Mali, your supportive financial companion. How can I help you today?",
        "Welcome! 🌺 I'm here to help you build a brighter financial future with kindness and understanding.",
        "Hello beautiful! 💕 I'm so glad you're here. Let's work on your financial wellness together.",
      ],
      'Professional & Direct': [
        "Good day! I'm Mali, your financial AI assistant. I'm here to provide expert guidance on your financial matters.",
        "Hello! I'm ready to help you optimize your financial strategy and achieve your goals efficiently.",
        "Welcome! I'm Mali, your dedicated financial advisor. Let's work together to improve your financial health.",
        "Greetings! I'm here to provide you with professional financial guidance and support.",
      ],
    };

    final vibeResponses = responses[vibe] ?? responses['Sassy & Bold']!;
    final greeting = vibeResponses[_random.nextInt(vibeResponses.length)];
    
    return "$greeting\n\nI can see your financial health is $financialHealth. What would you like to work on today?";
  }

  static String _getBudgetAdvice(String vibe, double income, double expenses, String budgetStatus) {
    final savingsRate = income > 0 ? ((income - expenses) / income * 100) : 0;
    
    if (vibe == 'Sassy & Bold') {
      if (budgetStatus == 'Over Budget') {
        return "Honey, we need to talk! 💅 You're spending more than you're earning, and that's not how queens handle their money. Let's get you back on track!\n\nHere's what I suggest:\n• Track every single expense for a week\n• Cut back on non-essentials by 20%\n• Set up automatic savings transfers\n\nYou've got this! 💪";
      } else if (savingsRate >= 20) {
        return "Now THIS is how you do it! 🔥 You're saving ${savingsRate.toStringAsFixed(0)}% of your income - that's absolutely fantastic!\n\nKeep up the amazing work and maybe even bump it up to 25% if you can. You're building real wealth here! 💎";
      } else {
        return "Okay, you're on the right track but we can do better! 💅 You're saving ${savingsRate.toStringAsFixed(0)}% of your income.\n\nLet's aim for 20% savings rate:\n• Review your biggest expenses\n• Find 3 areas to cut costs\n• Set up a monthly budget review\n\nYou're going to crush this! 💪";
      }
    } else if (vibe == 'Encouraging & Gentle') {
      if (budgetStatus == 'Over Budget') {
        return "I understand this might feel overwhelming, but we can work through this together. 🌸 Being over budget is common and fixable!\n\nLet's start small:\n• Write down all your expenses for one week\n• Identify 2-3 areas where you can save\n• Create a simple weekly budget\n\nYou're taking the first step by asking for help! 💙";
      } else {
        return "You're doing great with your budgeting! 🌺 You're saving ${savingsRate.toStringAsFixed(0)}% of your income.\n\nTo improve further:\n• Review your budget monthly\n• Look for ways to save on recurring expenses\n• Celebrate your progress\n\nEvery step forward counts! 💕";
      }
    } else {
      return "Based on your financial data, you're currently $budgetStatus with a ${savingsRate.toStringAsFixed(0)}% savings rate.\n\nRecommendations:\n• Implement the 50/30/20 rule (needs/wants/savings)\n• Use the envelope method for variable expenses\n• Review and adjust your budget monthly\n\nWould you like specific strategies for any particular expense category?";
    }
  }

  static String _getSavingAdvice(String vibe, double income, double expenses) {
    final monthlySurplus = income - expenses;
    
    if (vibe == 'Sassy & Bold') {
      if (monthlySurplus > 0) {
        return "Yes! You're already saving Ksh ${monthlySurplus.toStringAsFixed(0)} monthly! 🔥 Now let's make that money work for you!\n\nHere's your saving strategy:\n• Emergency fund: 3-6 months expenses\n• High-yield savings account for short-term goals\n• Consider investment options for long-term wealth\n\nYou're building real financial power! 💎";
      } else {
        return "Okay, we need to get you saving ASAP! 💅 Right now you're spending everything you earn.\n\nLet's start small:\n• Save Ksh 1,000 from your next paycheck\n• Set up automatic transfers\n• Track every expense to find savings\n\nSmall steps lead to big changes! 💪";
      }
    } else if (vibe == 'Encouraging & Gentle') {
      return "Saving money is one of the most empowering things you can do for yourself! 🌸\n\nLet's start with baby steps:\n• Begin with 5% of your income\n• Set up automatic transfers\n• Build an emergency fund first\n• Celebrate small wins along the way\n\nYou're investing in your future self! 💙";
    } else {
      return "Effective saving requires a systematic approach:\n\n• Pay yourself first (automated savings)\n• Build emergency fund (3-6 months expenses)\n• Use high-yield savings accounts\n• Consider tax-advantaged accounts\n• Set specific, measurable savings goals\n\nWhat type of savings goal are you working toward?";
    }
  }

  static String _getGoalAdvice(String vibe, int activeGoals) {
    if (vibe == 'Sassy & Bold') {
      if (activeGoals == 0) {
        return "Girl, we need to get you some goals! 💅 Having financial goals is like having a GPS for your money journey!\n\nLet's set some up:\n• Emergency fund (3-6 months expenses)\n• Vacation fund\n• Home down payment\n• Retirement savings\n\nPick one and let's crush it! 🔥";
      } else {
        return "Love that you have $activeGoals goals! 💪 That's how you build real wealth!\n\nTo make them even more powerful:\n• Make them SMART (Specific, Measurable, Achievable, Relevant, Time-bound)\n• Break big goals into smaller milestones\n• Celebrate each achievement\n• Review and adjust quarterly\n\nYou're building the future you want! 💎";
      }
    } else if (vibe == 'Encouraging & Gentle') {
      return "Having financial goals gives you direction and motivation! 🌺\n\nYour goals should be:\n• Personal and meaningful to you\n• Realistic and achievable\n• Broken into smaller steps\n• Regularly reviewed and adjusted\n\nI'm here to help you achieve whatever you're working toward! 💕";
    } else {
      return "Financial goals provide structure and motivation for your money management:\n\n• Set SMART goals (Specific, Measurable, Achievable, Relevant, Time-bound)\n• Prioritize goals by importance and timeline\n• Automate savings toward each goal\n• Track progress monthly\n• Adjust goals as your situation changes\n\nWhat financial goals are you currently working on?";
    }
  }

  static String _getExpenseAdvice(String vibe, double totalExpenses) {
    if (vibe == 'Sassy & Bold') {
      return "Let's talk about your spending, honey! 💅 You've spent Ksh ${totalExpenses.toStringAsFixed(0)} - that's real money we're talking about!\n\nHere's how to take control:\n• Track every expense for 2 weeks\n• Categorize: needs vs wants\n• Set spending limits for each category\n• Use cash for variable expenses\n\nKnowledge is power - let's make every shilling count! 💪";
    } else if (vibe == 'Encouraging & Gentle') {
      return "Understanding your expenses is the first step to better money management! 🌸\n\nLet's work on this together:\n• Track your spending for one week\n• Identify your biggest expense categories\n• Look for opportunities to save\n• Be kind to yourself - change takes time\n\nYou're already taking the right steps! 💙";
    } else {
      return "Effective expense management involves:\n\n• Detailed expense tracking\n• Budget allocation by category\n• Regular spending reviews\n• Identification of cost-saving opportunities\n• Distinction between needs and wants\n\nWould you like help analyzing your current spending patterns?";
    }
  }

  static String _getIncomeAdvice(String vibe, double totalIncome) {
    if (vibe == 'Sassy & Bold') {
      return "Now we're talking about the good stuff! 💎 Your income of Ksh ${totalIncome.toStringAsFixed(0)} is your foundation for building wealth!\n\nLet's maximize it:\n• Negotiate your salary/rates annually\n• Develop new skills for higher-paying roles\n• Consider side hustles or passive income\n• Invest in yourself through education\n\nYou deserve to be paid what you're worth! 🔥";
    } else if (vibe == 'Encouraging & Gentle') {
      return "Your income is your tool for building the life you want! 🌺\n\nWays to grow your income:\n• Ask for raises or better rates\n• Learn new skills\n• Explore side income opportunities\n• Network and build relationships\n\nYou have so much potential! 💕";
    } else {
      return "Income optimization strategies include:\n\n• Regular salary/rate reviews\n• Skill development and certification\n• Side business or freelance opportunities\n• Investment in income-generating assets\n• Networking and professional development\n\nWhat are your current income goals?";
    }
  }

  static String _getDebtAdvice(String vibe) {
    if (vibe == 'Sassy & Bold') {
      return "Debt can feel overwhelming, but we're going to tackle this together! 💪\n\nHere's your debt-busting strategy:\n• List all debts with interest rates\n• Pay minimums on all, extra on highest rate\n• Consider debt consolidation if it makes sense\n• Stop using credit cards until debt-free\n\nYou're stronger than your debt! 🔥";
    } else if (vibe == 'Encouraging & Gentle') {
      return "Debt doesn't define you, and it's absolutely manageable! 🌸\n\nLet's approach this gently:\n• Make a list of all your debts\n• Focus on one debt at a time\n• Celebrate every payment made\n• Seek help if you need it\n\nYou're taking control of your financial future! 💙";
    } else {
      return "Debt management strategies:\n\n• Debt snowball method (smallest balance first)\n• Debt avalanche method (highest interest first)\n• Debt consolidation options\n• Credit counseling services\n• Budget adjustments to accelerate payments\n\nWhat type of debt are you dealing with?";
    }
  }

  static String _getInvestmentAdvice(String vibe) {
    if (vibe == 'Sassy & Bold') {
      return "Now THIS is how you build real wealth! 💎 Investing is like planting money trees!\n\nStart here:\n• Emergency fund first (3-6 months expenses)\n• Employer retirement matching (free money!)\n• Low-cost index funds\n• Start small and increase over time\n• Learn about compound interest\n\nYour future self will thank you! 🔥";
    } else if (vibe == 'Encouraging & Gentle') {
      return "Investing can feel scary, but it's how you build long-term wealth! 🌺\n\nBegin gently:\n• Start with what you can afford\n• Focus on low-risk options initially\n• Learn as you go\n• Consider professional advice\n• Remember: time is your friend\n\nYou're building security for your future! 💕";
    } else {
      return "Investment fundamentals:\n\n• Diversification across asset classes\n• Low-cost index funds for beginners\n• Dollar-cost averaging\n• Long-term perspective\n• Risk tolerance assessment\n• Professional advice when needed\n\nWhat's your investment timeline and risk tolerance?";
    }
  }

  static String _getEmergencyFundAdvice(String vibe, double monthlyIncome) {
    final targetAmount = monthlyIncome * 6; // 6 months of expenses
    
    if (vibe == 'Sassy & Bold') {
      return "Emergency funds are your financial superhero cape! 💪 Life happens, and you need to be ready!\n\nYour target: Ksh ${targetAmount.toStringAsFixed(0)} (6 months expenses)\n\nBuild it by:\n• Save Ksh ${(monthlyIncome * 0.1).toStringAsFixed(0)} monthly\n• Use high-yield savings account\n• Don't touch it unless it's a real emergency\n• Automate the savings\n\nPeace of mind is priceless! 💎";
    } else if (vibe == 'Encouraging & Gentle') {
      return "An emergency fund is like a warm hug for your finances! 🌸\n\nAim for 3-6 months of expenses: Ksh ${targetAmount.toStringAsFixed(0)}\n\nBuild it step by step:\n• Start with one month's expenses\n• Save consistently each month\n• Keep it in a separate account\n• Use it only for true emergencies\n\nYou're creating security for yourself! 💙";
    } else {
      return "Emergency fund guidelines:\n\n• Target: 3-6 months of essential expenses\n• Your target amount: Ksh ${targetAmount.toStringAsFixed(0)}\n• High-yield savings account\n• Liquid and easily accessible\n• Separate from other savings\n• Replenish after use\n\nHow close are you to your emergency fund goal?";
    }
  }

  static String _getGeneralHelp(String vibe, String financialHealth) {
    if (vibe == 'Sassy & Bold') {
      return "I'm here to help you become the financial boss you were meant to be! 💅\n\nI can help with:\n• Budgeting and expense tracking\n• Saving strategies and goals\n• Debt management\n• Investment basics\n• Emergency fund planning\n• Income optimization\n\nWhat's your biggest financial challenge right now? Let's tackle it together! 💪";
    } else if (vibe == 'Encouraging & Gentle') {
      return "I'm here to support you on your financial journey! 🌸\n\nI can help you with:\n• Creating and sticking to budgets\n• Building savings habits\n• Managing debt\n• Setting financial goals\n• Understanding investments\n• Planning for emergencies\n\nWhat would you like to work on today? 💙";
    } else {
      return "I'm your comprehensive financial assistant. I can help with:\n\n• Budget creation and management\n• Expense tracking and analysis\n• Savings strategies and goal setting\n• Debt reduction planning\n• Investment education and planning\n• Emergency fund development\n• Income optimization\n\nWhat specific area would you like to focus on?";
    }
  }

  static String _getGeneralResponse(String vibe, String financialHealth, String userMessage) {
    final responses = {
      'Sassy & Bold': [
        "That's a great question! 💅 Let me break it down for you...",
        "I love where your head's at! 💖 Here's what I think...",
        "You're asking all the right questions! 🔥 Let me help you out...",
        "I've got you covered! 💪 Here's the insight...",
      ],
      'Encouraging & Gentle': [
        "That's a wonderful question! 🌸 Let me help you understand...",
        "I'm so glad you asked! 💙 Here's what I can tell you...",
        "That's a great way to think about it! 🌺 Let me explain...",
        "I'm here to help! 💕 Here's my perspective...",
      ],
      'Professional & Direct': [
        "Excellent question. Let me provide you with a comprehensive answer...",
        "I understand your concern. Here's my analysis...",
        "That's an important consideration. Let me explain...",
        "I'll help you with that. Here's what you need to know...",
      ],
    };

    final responseTemplates = responses[vibe] ?? responses['Sassy & Bold']!;
    final randomResponse = responseTemplates[_random.nextInt(responseTemplates.length)];

    return "$randomResponse\n\nBased on your financial data, I can see you have some great opportunities to optimize your money management. Would you like me to analyze your spending patterns or help you set up a budget?";
  }

  static String _calculateFinancialHealth(double income, double expenses) {
    if (income == 0) return "needs assessment";
    
    final savingsRate = (income - expenses) / income * 100;
    
    if (savingsRate >= 20) return "excellent";
    if (savingsRate >= 10) return "good";
    if (savingsRate >= 0) return "fair";
    return "needs improvement";
  }
}
