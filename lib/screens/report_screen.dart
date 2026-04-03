import 'package:flutter/material.dart';
import '../models/dog.dart';

class ReportScreen extends StatelessWidget {
  final Dog dog;

  const ReportScreen({super.key, required this.dog});

  Widget _buildStatCard(BuildContext context, String title, int count, IconData icon, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 8),
          )
        ]
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).textTheme.titleLarge?.color,
              ),
            ),
          ),
          Text(
            count.toString(),
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final report = dog.generateMonthlyReport();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Monthly Report', style: TextStyle(fontWeight: FontWeight.w800)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.05),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                children: [
                  Icon(Icons.query_stats, size: 48, color: Theme.of(context).colorScheme.primary.withOpacity(0.5)),
                  const SizedBox(height: 16),
                  Text(
                    '${dog.name}\'s 30-Day Summary',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'History automatically retains metrics for the last 30 days securely.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6),
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            _buildStatCard(context, 'Happy Days', report['Happy Days'] ?? 0, Icons.sentiment_very_satisfied, Colors.orange),
            _buildStatCard(context, 'Lazy Days', report['Lazy Days'] ?? 0, Icons.snooze, Colors.blue),
            _buildStatCard(context, 'Sick Days', report['Sick Days'] ?? 0, Icons.sick_outlined, Colors.indigo),
            _buildStatCard(context, 'Missed Feedings', report['Missed Feedings'] ?? 0, Icons.warning_amber_rounded, Colors.red),
          ],
        ),
      ),
    );
  }
}
