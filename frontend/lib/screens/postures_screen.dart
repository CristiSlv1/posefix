import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/theme.dart';
import '../models/posture_analysis.dart';
import '../services/api_service.dart';

class PosturesScreen extends StatefulWidget {
  const PosturesScreen({super.key});

  @override
  State<PosturesScreen> createState() => _PosturesScreenState();
}

class _PosturesScreenState extends State<PosturesScreen> {
  final ApiService _apiService = ApiService();
  late Future<List<PostureAnalysis>> _future;

  @override
  void initState() {
    super.initState();
    _refresh();
    postureListVersion.addListener(_refresh);
  }

  @override
  void dispose() {
    postureListVersion.removeListener(_refresh);
    super.dispose();
  }

  void _refresh() {
    if (!mounted) return;
    setState(() {
      _future = _apiService.getPostures();
    });
  }

  Future<void> _openAnalyzeFlow() async {
    final result = await context.push('/analyze-select');
    if (result == true) _refresh();
  }

  Color _scoreColor(BuildContext context, int score) {
    final c = context.appColors;
    if (score >= 80) return c.success;
    if (score >= 60) return c.warning;
    return c.danger;
  }

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Postures', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: FutureBuilder<List<PostureAnalysis>>(
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
                  'Error loading postures:\n${snapshot.error}',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: c.danger),
                ),
              ),
            );
          }
          final items = snapshot.data ?? [];
          if (items.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.accessibility_new_rounded, size: 80, color: c.textDim),
                  const SizedBox(height: 16),
                  Text(
                    'No posture analyses yet.',
                    style: TextStyle(color: c.textMuted, fontSize: 16),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: _openAnalyzeFlow,
                    icon: const Icon(Icons.videocam_outlined),
                    label: const Text('Analyze your posture'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: c.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                  ),
                ],
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: () async => _refresh(),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: items.length,
              itemBuilder: (context, i) {
                final a = items[i];
                final color = _scoreColor(context, a.score);
                return Card(
                  color: c.card,
                  margin: const EdgeInsets.only(bottom: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: () async {
                      await context.push('/postures/${a.id}');
                      _refresh();
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              color: color.withOpacity(0.15),
                              shape: BoxShape.circle,
                              border: Border.all(color: color, width: 2),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              '${a.score}',
                              style: TextStyle(
                                color: color,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  a.exerciseName ?? 'Exercise #${a.exerciseId ?? '-'}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: c.textPrimary,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  a.createdAt != null && a.createdAt!.length >= 10
                                      ? a.createdAt!.substring(0, 10)
                                      : '',
                                  style: TextStyle(color: c.textMuted, fontSize: 12),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  a.mistakeCount == 0
                                      ? 'No mistakes detected'
                                      : '${a.mistakeCount} mistake${a.mistakeCount > 1 ? 's' : ''}',
                                  style: TextStyle(color: c.textSecondary, fontSize: 13),
                                ),
                              ],
                            ),
                          ),
                          Icon(Icons.chevron_right, color: c.textDim),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openAnalyzeFlow,
        backgroundColor: c.primary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        icon: const Icon(Icons.videocam_outlined, color: Colors.white),
        label: const Text('Analyze your posture', style: TextStyle(color: Colors.white)),
      ),
    );
  }
}
