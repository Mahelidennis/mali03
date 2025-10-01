import 'package:flutter/material.dart';
import '../services/financial_health_scoring_service.dart';

class FinancialHealthDashboard extends StatefulWidget {
  const FinancialHealthDashboard({super.key});

  @override
  State<FinancialHealthDashboard> createState() => _FinancialHealthDashboardState();
}

class _FinancialHealthDashboardState extends State<FinancialHealthDashboard> {
  HealthScore? _healthScore;
  List<Achievement> _achievements = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHealthData();
  }

  Future<void> _loadHealthData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Calculate fresh health score
      final healthScore = await FinancialHealthScoringService.calculateHealthScore();
      final achievements = await FinancialHealthScoringService.getAchievements();
      
      setState(() {
        _healthScore = healthScore;
        _achievements = achievements;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading health data: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF2F8),
      appBar: AppBar(
        title: const Text('Financial Health'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: const Color(0xFF181114),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadHealthData,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _healthScore == null
              ? _buildEmptyState()
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Overall Score Card
                      _buildOverallScoreCard(),
                      
                      const SizedBox(height: 24),
                      
                      // Metrics Grid
                      _buildMetricsGrid(),
                      
                      const SizedBox(height: 24),
                      
                      // Achievements Section
                      _buildAchievementsSection(),
                      
                      const SizedBox(height: 24),
                      
                      // Insights Section
                      _buildInsightsSection(),
                    ],
                  ),
                ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  const Color(0xFFEE2B8D).withOpacity(0.1),
                  const Color(0xFFEE2B8D).withOpacity(0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: const Icon(
              Icons.analytics,
              size: 60,
              color: Color(0xFFEE2B8D),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'No health data yet',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF181114),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start using Mali to track your financial health',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildOverallScoreCard() {
    final score = _healthScore!.overallScore;
    final level = _healthScore!.level;
    final badge = _healthScore!.badge;
    
    return Card(
      elevation: 12,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: [
              _getScoreColor(score).withOpacity(0.1),
              _getScoreColor(score).withOpacity(0.05),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              // Score Circle
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 120,
                    height: 120,
                    child: CircularProgressIndicator(
                      value: score / 100,
                      strokeWidth: 8,
                      backgroundColor: Colors.grey[300],
                      valueColor: AlwaysStoppedAnimation<Color>(_getScoreColor(score)),
                    ),
                  ),
                  Column(
                    children: [
                      Text(
                        score.toStringAsFixed(0),
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: _getScoreColor(score),
                        ),
                      ),
                      Text(
                        'Health Score',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              
              const SizedBox(height: 24),
              
              // Level and Badge
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: _getScoreColor(score).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          level,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: _getScoreColor(score),
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Level',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEE2B8D).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          badge,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFEE2B8D),
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Badge',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Streak
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.local_fire_department,
                    color: Colors.orange,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${_healthScore!.streakDays} day streak',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF181114),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetricsGrid() {
    final metrics = _healthScore!.metricScores;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Health Metrics',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF181114),
          ),
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 1.5,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: metrics.length,
          itemBuilder: (context, index) {
            final entry = metrics.entries.elementAt(index);
            return _buildMetricCard(entry.key, entry.value);
          },
        ),
      ],
    );
  }

  Widget _buildMetricCard(HealthMetric metric, double score) {
    final displayName = _getMetricDisplayName(metric);
    final icon = _getMetricIcon(metric);
    final color = _getScoreColor(score);
    
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    displayName,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF181114),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: LinearProgressIndicator(
                    value: score / 100,
                    backgroundColor: Colors.grey[300],
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${score.toStringAsFixed(0)}',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAchievementsSection() {
    final recentAchievements = _achievements
        .where((a) => a.isNew)
        .toList();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Achievements',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF181114),
              ),
            ),
            Text(
              '${_achievements.length} total',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        
        if (recentAchievements.isNotEmpty) ...[
          // New achievements
          const Text(
            'New Achievements!',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFFEE2B8D),
            ),
          ),
          const SizedBox(height: 8),
          ...recentAchievements.take(3).map((achievement) => 
            _buildAchievementCard(achievement, isNew: true)
          ),
          const SizedBox(height: 16),
        ],
        
        // All achievements
        if (_achievements.isNotEmpty)
          ..._achievements.take(5).map((achievement) => 
            _buildAchievementCard(achievement, isNew: false)
          )
        else
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: Text(
                'No achievements yet. Keep using Mali to earn your first badge!',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildAchievementCard(Achievement achievement, {required bool isNew}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Card(
        elevation: isNew ? 8 : 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Achievement icon
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isNew ? const Color(0xFFEE2B8D).withOpacity(0.1) : Colors.grey[100],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Center(
                  child: Text(
                    achievement.icon,
                    style: const TextStyle(fontSize: 20),
                  ),
                ),
              ),
              
              const SizedBox(width: 12),
              
              // Achievement details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            achievement.title,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: isNew ? const Color(0xFFEE2B8D) : const Color(0xFF181114),
                            ),
                          ),
                        ),
                        if (isNew)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEE2B8D),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              'NEW',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      achievement.description,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              
              // Points
              Column(
                children: [
                  Text(
                    '${achievement.points}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFEE2B8D),
                    ),
                  ),
                  Text(
                    'pts',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInsightsSection() {
    final strengths = _healthScore!.strengths;
    final improvements = _healthScore!.improvements;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Insights & Recommendations',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF181114),
          ),
        ),
        const SizedBox(height: 16),
        
        // Strengths
        if (strengths.isNotEmpty) ...[
          _buildInsightCard(
            'Your Strengths',
            Icons.star,
            Colors.green,
            strengths,
          ),
          const SizedBox(height: 16),
        ],
        
        // Improvements
        if (improvements.isNotEmpty) ...[
          _buildInsightCard(
            'Areas to Improve',
            Icons.trending_up,
            Colors.orange,
            improvements,
          ),
        ],
      ],
    );
  }

  Widget _buildInsightCard(
    String title,
    IconData icon,
    Color color,
    List<String> items,
  ) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...items.map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 4,
                    height: 4,
                    margin: const EdgeInsets.only(top: 8, right: 8),
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      item,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF181114),
                      ),
                    ),
                  ),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }

  Color _getScoreColor(double score) {
    if (score >= 80) return Colors.green;
    if (score >= 60) return Colors.orange;
    if (score >= 40) return Colors.yellow[700]!;
    return Colors.red;
  }

  String _getMetricDisplayName(HealthMetric metric) {
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

  IconData _getMetricIcon(HealthMetric metric) {
    switch (metric) {
      case HealthMetric.spendingControl:
        return Icons.shopping_cart;
      case HealthMetric.savingHabits:
        return Icons.savings;
      case HealthMetric.goalProgress:
        return Icons.flag;
      case HealthMetric.budgetAdherence:
        return Icons.account_balance_wallet;
      case HealthMetric.emotionalStability:
        return Icons.psychology;
      case HealthMetric.financialLiteracy:
        return Icons.school;
      case HealthMetric.riskManagement:
        return Icons.security;
      case HealthMetric.futurePlanning:
        return Icons.timeline;
    }
  }
}

