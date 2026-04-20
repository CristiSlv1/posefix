import 'package:flutter/material.dart';

import '../core/theme.dart';
import '../models/posture_analysis.dart';
import '../services/api_service.dart';

class PostureDetailScreen extends StatefulWidget {
  final int analysisId;
  const PostureDetailScreen({super.key, required this.analysisId});

  @override
  State<PostureDetailScreen> createState() => _PostureDetailScreenState();
}

class _PostureDetailScreenState extends State<PostureDetailScreen> {
  final ApiService _apiService = ApiService();
  late Future<PostureAnalysis> _future;

  @override
  void initState() {
    super.initState();
    _future = _apiService.getPosture(widget.analysisId);
  }

  Color _scoreColor(BuildContext context, int score) {
    final c = context.appColors;
    if (score >= 80) return c.success;
    if (score >= 60) return c.warning;
    return c.danger;
  }

  Color _severityColor(BuildContext context, String? severity) {
    final c = context.appColors;
    switch ((severity ?? '').toLowerCase()) {
      case 'high':
        return c.danger;
      case 'medium':
        return c.warning;
      case 'low':
        return c.success;
      default:
        return c.primaryLight;
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    return Scaffold(
      appBar: AppBar(title: const Text('Posture Analysis')),
      body: FutureBuilder<PostureAnalysis>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(color: c.primary));
          }
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Error: ${snapshot.error}',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: c.danger),
                ),
              ),
            );
          }
          final a = snapshot.data!;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _summaryCard(context, a),
              const SizedBox(height: 24),
              const Text('Detected mistakes', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              if (a.mistakes.isEmpty)
                Card(
                  color: c.card,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Icon(Icons.check_circle_outline, color: c.success),
                        const SizedBox(width: 12),
                        const Expanded(child: Text('No mistakes detected. Great form!')),
                      ],
                    ),
                  ),
                )
              else
                ...a.mistakes.map((m) => Card(
                      color: c.card,
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: Icon(Icons.error_outline, color: _severityColor(context, m.severity)),
                        title: Text(m.mistake),
                        subtitle: m.severity != null
                            ? Text(
                                'Severity: ${m.severity}',
                                style: TextStyle(color: _severityColor(context, m.severity)),
                              )
                            : null,
                      ),
                    )),
              const SizedBox(height: 24),
              if (a.anglesSummary.isNotEmpty) ...[
                const Text('Angles summary', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Card(
                  color: c.card,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: a.anglesSummary.entries.map((entry) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(entry.key, style: TextStyle(color: c.textSecondary)),
                              Text(
                                entry.value.toString(),
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }

  Widget _summaryCard(BuildContext context, PostureAnalysis a) {
    final c = context.appColors;
    final color = _scoreColor(context, a.score);
    return Card(
      color: c.card,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                shape: BoxShape.circle,
                border: Border.all(color: color, width: 3),
              ),
              alignment: Alignment.center,
              child: Text(
                '${a.score}',
                style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 28),
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    a.exerciseName ?? 'Exercise #${a.exerciseId ?? '-'}',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  const SizedBox(height: 6),
                  if (a.createdAt != null && a.createdAt!.length >= 10)
                    Text(
                      a.createdAt!.substring(0, 10),
                      style: TextStyle(color: c.textMuted, fontSize: 12),
                    ),
                  const SizedBox(height: 8),
                  Text(
                    a.mistakeCount == 0
                        ? 'No mistakes detected'
                        : '${a.mistakeCount} mistake${a.mistakeCount > 1 ? 's' : ''}',
                    style: TextStyle(color: c.textSecondary),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
