import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'financial_reports.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  List<FinancialReport> _reports = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadReports();
  }

  Future<void> _loadReports() async {
    final reports = await FinancialReportsManager.getReports();
    setState(() {
      _reports = reports;
      _isLoading = false;
    });
  }

  Future<void> _generateMonthlyReport() async {
    setState(() {
      _isLoading = true;
    });

    final currentMonth = DateTime.now();
    final report = await FinancialReportsManager.generateMonthlyReport(currentMonth);
    await FinancialReportsManager.saveReport(report);

    await _loadReports();
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Monthly report generated: ${report.title}'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Future<void> _generateSummaryReport() async {
    setState(() {
      _isLoading = true;
    });

    final report = await FinancialReportsManager.generateSummaryReport();
    await FinancialReportsManager.saveReport(report);

    await _loadReports();
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Summary report generated: ${report.title}'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Future<void> _exportReport(FinancialReport report, String format) async {
    String reportData = '';
    String fileName = '';

    if (format == 'csv') {
      reportData = FinancialReportsManager.generateCSV(report);
      fileName = '${report.title.replaceAll(' ', '_')}.csv';
    } else {
      reportData = FinancialReportsManager.generateTextReport(report);
      fileName = '${report.title.replaceAll(' ', '_')}.txt';
    }

    try {
      await Clipboard.setData(ClipboardData(text: reportData));
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$format report copied to clipboard!'),
            backgroundColor: Colors.green,
            action: SnackBarAction(
              label: 'View',
              onPressed: () => _showReportPreview(report, format),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to export report: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showReportPreview(FinancialReport report, String format) {
    String reportData = '';
    if (format == 'csv') {
      reportData = FinancialReportsManager.generateCSV(report);
    } else {
      reportData = FinancialReportsManager.generateTextReport(report);
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${report.title} ($format)'),
        content: Container(
          width: double.maxFinite,
          height: 400,
          child: SingleChildScrollView(
            child: SelectableText(
              reportData,
              style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Financial Reports',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                _buildGenerateButtons(),
                const SizedBox(height: 16),
                Expanded(
                  child: _reports.isEmpty
                      ? _buildEmptyState()
                      : _buildReportsList(),
                ),
              ],
            ),
    );
  }

  Widget _buildGenerateButtons() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: _generateMonthlyReport,
              icon: const Icon(Icons.calendar_month),
              label: const Text('Monthly Report'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: _generateSummaryReport,
              icon: const Icon(Icons.summarize),
              label: const Text('Summary Report'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.description_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No Reports Generated Yet',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Generate your first financial report to see your data!',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildReportsList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _reports.length,
      itemBuilder: (context, index) {
        final report = _reports[index];
        return _buildReportCard(report);
      },
    );
  }

  Widget _buildReportCard(FinancialReport report) {
    final data = report.data;
    final isMonthly = report.type == 'monthly';
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isMonthly ? Colors.blue[100] : Colors.green[100],
          child: Icon(
            isMonthly ? Icons.calendar_month : Icons.summarize,
            color: isMonthly ? Colors.blue : Colors.green,
          ),
        ),
        title: Text(
          report.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Generated: ${report.generatedDate.toString().split('.')[0]}',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Text(
                  'Income: KSh ${data['total_income']?.toStringAsFixed(0) ?? '0'}',
                  style: const TextStyle(fontSize: 12),
                ),
                const SizedBox(width: 8),
                Text(
                  'Spending: KSh ${data['total_spending']?.toStringAsFixed(0) ?? '0'}',
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (format) => _exportReport(report, format),
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'text',
              child: Row(
                children: [
                  Icon(Icons.text_fields),
                  SizedBox(width: 8),
                  Text('Export as Text'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'csv',
              child: Row(
                children: [
                  Icon(Icons.table_chart),
                  SizedBox(width: 8),
                  Text('Export as CSV'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'preview',
              child: Row(
                children: [
                  Icon(Icons.preview),
                  SizedBox(width: 8),
                  Text('Preview Report'),
                ],
              ),
            ),
          ],
          child: const Icon(Icons.more_vert),
        ),
        onTap: () => _showReportPreview(report, 'text'),
      ),
    );
  }
} 