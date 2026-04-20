import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/theme.dart';
import '../models/posture_analysis.dart';
import '../models/weight_entry.dart';
import '../services/api_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ApiService _apiService = ApiService();
  late Future<List<WeightEntry>> _weightFuture;
  late Future<List<PostureAnalysis>> _postureFuture;

  @override
  void initState() {
    super.initState();
    _refresh();
    weightHistoryVersion.addListener(_refresh);
    postureListVersion.addListener(_refresh);
  }

  @override
  void dispose() {
    weightHistoryVersion.removeListener(_refresh);
    postureListVersion.removeListener(_refresh);
    super.dispose();
  }

  void _refresh() {
    if (!mounted) return;
    setState(() {
      _weightFuture = _apiService.getWeightHistory();
      _postureFuture = _apiService.getPostures();
    });
  }

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: RefreshIndicator(
        onRefresh: () async => _refresh(),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              'Weight history',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: c.textPrimary),
            ),
            const SizedBox(height: 12),
            FutureBuilder<List<WeightEntry>>(
              future: _weightFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return _loadingBox(c);
                }
                if (snapshot.hasError) {
                  return _errorCard(c, snapshot.error.toString());
                }
                final data = snapshot.data ?? [];
                if (data.isEmpty) return _emptyWeightCard(context);
                return _WeightChartCard(entries: data);
              },
            ),
            const SizedBox(height: 28),
            Text(
              'Posture score',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: c.textPrimary),
            ),
            const SizedBox(height: 12),
            FutureBuilder<List<PostureAnalysis>>(
              future: _postureFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return _loadingBox(c);
                }
                if (snapshot.hasError) {
                  return _errorCard(c, snapshot.error.toString());
                }
                final data = (snapshot.data ?? [])
                    .where((p) => p.createdAt != null && p.createdAt!.isNotEmpty)
                    .toList();
                if (data.isEmpty) return _emptyPostureCard(context);
                return _PostureChartCard(entries: data);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _loadingBox(AppColors c) {
    return SizedBox(
      height: 280,
      child: Center(child: CircularProgressIndicator(color: c.primary)),
    );
  }

  Widget _errorCard(AppColors c, String error) {
    return Card(
      color: c.card,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Text('Could not load data.\n$error', style: TextStyle(color: c.danger)),
      ),
    );
  }

  Widget _emptyWeightCard(BuildContext context) {
    final c = context.appColors;
    return Card(
      color: c.card,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Icon(Icons.monitor_weight_outlined, size: 64, color: c.textDim),
            const SizedBox(height: 12),
            Text('No weight logged yet.', style: TextStyle(color: c.textMuted, fontSize: 16)),
            const SizedBox(height: 4),
            Text(
              'Log your weight in Personal data to start tracking.',
              textAlign: TextAlign.center,
              style: TextStyle(color: c.textDim, fontSize: 13),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => context.push('/settings/personal-data'),
              icon: const Icon(Icons.add),
              label: const Text('Log weight'),
              style: ElevatedButton.styleFrom(
                backgroundColor: c.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _emptyPostureCard(BuildContext context) {
    final c = context.appColors;
    return Card(
      color: c.card,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Icon(Icons.accessibility_new_rounded, size: 64, color: c.textDim),
            const SizedBox(height: 12),
            Text('No posture analyses yet.', style: TextStyle(color: c.textMuted, fontSize: 16)),
            const SizedBox(height: 4),
            Text(
              'Analyze a video to see your score trend here.',
              textAlign: TextAlign.center,
              style: TextStyle(color: c.textDim, fontSize: 13),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => context.push('/analyze-select'),
              icon: const Icon(Icons.videocam_outlined),
              label: const Text('Analyze posture'),
              style: ElevatedButton.styleFrom(
                backgroundColor: c.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String _formatDate(DateTime d) {
  final day = d.day.toString().padLeft(2, '0');
  final month = d.month.toString().padLeft(2, '0');
  return '$day/$month/${d.year}';
}

class _WeightChartCard extends StatelessWidget {
  final List<WeightEntry> entries;
  const _WeightChartCard({required this.entries});

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;

    final sorted = [...entries]..sort((a, b) => a.measuredOn.compareTo(b.measuredOn));
    final latest = sorted.last;
    final first = sorted.first;
    final change = latest.weightKg - first.weightKg;
    final changeColor = change > 0 ? c.warning : (change < 0 ? c.success : c.textMuted);
    final changeSign = change > 0 ? '+' : '';

    double minY = sorted.first.weightKg;
    double maxY = sorted.first.weightKg;
    for (final e in sorted) {
      if (e.weightKg < minY) minY = e.weightKg;
      if (e.weightKg > maxY) maxY = e.weightKg;
    }
    final pad = ((maxY - minY) * 0.2).clamp(0.5, 5.0);
    minY = minY - pad;
    maxY = maxY + pad;

    final firstDate = sorted.first.measuredOn;
    final spots = <FlSpot>[
      for (final e in sorted)
        FlSpot(e.measuredOn.difference(firstDate).inDays.toDouble(), e.weightKg),
    ];
    final maxX = spots.last.x == 0 ? 1.0 : spots.last.x;

    return Card(
      color: c.card,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${latest.weightKg.toStringAsFixed(1)} kg',
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: c.textPrimary),
                ),
                const SizedBox(width: 10),
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Text(
                    sorted.length > 1 ? '$changeSign${change.toStringAsFixed(1)} kg' : 'first entry',
                    style: TextStyle(color: changeColor, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            Text(
              '${sorted.length} ${sorted.length == 1 ? 'entry' : 'entries'} • last ${_formatDate(latest.measuredOn)}',
              style: TextStyle(color: c.textMuted, fontSize: 12),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 220,
              child: LineChart(
                LineChartData(
                  minY: minY,
                  maxY: maxY,
                  minX: 0,
                  maxX: maxX,
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    getDrawingHorizontalLine: (_) => FlLine(
                      color: c.border.withOpacity(0.4),
                      strokeWidth: 1,
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, _) => Padding(
                          padding: const EdgeInsets.only(right: 4),
                          child: Text(
                            value.toStringAsFixed(0),
                            style: TextStyle(color: c.textMuted, fontSize: 11),
                          ),
                        ),
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 28,
                        interval: (maxX / 3).clamp(1, double.infinity),
                        getTitlesWidget: (value, _) {
                          final date = firstDate.add(Duration(days: value.round()));
                          return Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Text(
                              '${date.day}/${date.month}',
                              style: TextStyle(color: c.textMuted, fontSize: 11),
                            ),
                          );
                        },
                      ),
                    ),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  lineTouchData: LineTouchData(
                    touchTooltipData: LineTouchTooltipData(
                      getTooltipColor: (_) => c.cardAlt,
                      getTooltipItems: (touched) => touched.map((spot) {
                        final date = firstDate.add(Duration(days: spot.x.round()));
                        return LineTooltipItem(
                          '${spot.y.toStringAsFixed(1)} kg\n${_formatDate(date)}',
                          TextStyle(color: c.textPrimary, fontSize: 12, fontWeight: FontWeight.w600),
                        );
                      }).toList(),
                    ),
                  ),
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      curveSmoothness: 0.25,
                      barWidth: 3,
                      color: c.primary,
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (spot, _, __, ___) => FlDotCirclePainter(
                          radius: 3.5,
                          color: c.primary,
                          strokeWidth: 2,
                          strokeColor: c.card,
                        ),
                      ),
                      belowBarData: BarAreaData(
                        show: true,
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            c.primary.withOpacity(0.25),
                            c.primary.withOpacity(0.0),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PostureChartCard extends StatelessWidget {
  final List<PostureAnalysis> entries;
  const _PostureChartCard({required this.entries});

  Color _scoreColor(AppColors c, double score) {
    if (score >= 80) return c.success;
    if (score >= 60) return c.warning;
    return c.danger;
  }

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;

    final dated = <_ScoredEntry>[];
    for (final e in entries) {
      final dt = DateTime.tryParse(e.createdAt!);
      if (dt != null) dated.add(_ScoredEntry(dt, e.score));
    }
    dated.sort((a, b) => a.at.compareTo(b.at));

    final latest = dated.last;
    final avg = dated.map((e) => e.score).reduce((a, b) => a + b) / dated.length;
    final scoreColor = _scoreColor(c, latest.score.toDouble());

    final firstDate = DateTime(dated.first.at.year, dated.first.at.month, dated.first.at.day);
    final spots = <FlSpot>[
      for (int i = 0; i < dated.length; i++)
        FlSpot(
          dated[i].at.difference(firstDate).inDays.toDouble() + i * 0.001, // tiny offset in case of same-day
          dated[i].score.toDouble(),
        ),
    ];
    final maxX = spots.last.x == 0 ? 1.0 : spots.last.x;

    return Card(
      color: c.card,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${latest.score}',
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: scoreColor),
                ),
                const SizedBox(width: 6),
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text('latest', style: TextStyle(color: c.textMuted, fontSize: 13)),
                ),
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    'avg ${avg.toStringAsFixed(0)}',
                    style: TextStyle(color: c.textSecondary, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            Text(
              '${dated.length} ${dated.length == 1 ? 'analysis' : 'analyses'} • last ${_formatDate(latest.at)}',
              style: TextStyle(color: c.textMuted, fontSize: 12),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 220,
              child: LineChart(
                LineChartData(
                  minY: 0,
                  maxY: 100,
                  minX: 0,
                  maxX: maxX,
                  gridData: FlGridData(
                    show: true,
                    horizontalInterval: 20,
                    drawVerticalLine: false,
                    getDrawingHorizontalLine: (_) => FlLine(
                      color: c.border.withOpacity(0.4),
                      strokeWidth: 1,
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 36,
                        interval: 20,
                        getTitlesWidget: (value, _) => Padding(
                          padding: const EdgeInsets.only(right: 4),
                          child: Text(
                            value.toStringAsFixed(0),
                            style: TextStyle(color: c.textMuted, fontSize: 11),
                          ),
                        ),
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 28,
                        interval: (maxX / 3).clamp(1, double.infinity),
                        getTitlesWidget: (value, _) {
                          final date = firstDate.add(Duration(days: value.round()));
                          return Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Text(
                              '${date.day}/${date.month}',
                              style: TextStyle(color: c.textMuted, fontSize: 11),
                            ),
                          );
                        },
                      ),
                    ),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  lineTouchData: LineTouchData(
                    touchTooltipData: LineTouchTooltipData(
                      getTooltipColor: (_) => c.cardAlt,
                      getTooltipItems: (touched) => touched.map((spot) {
                        final date = firstDate.add(Duration(days: spot.x.round()));
                        return LineTooltipItem(
                          'Score ${spot.y.toStringAsFixed(0)}\n${_formatDate(date)}',
                          TextStyle(color: c.textPrimary, fontSize: 12, fontWeight: FontWeight.w600),
                        );
                      }).toList(),
                    ),
                  ),
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      curveSmoothness: 0.25,
                      barWidth: 3,
                      color: c.primary,
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (spot, _, __, ___) => FlDotCirclePainter(
                          radius: 4,
                          color: _scoreColor(c, spot.y),
                          strokeWidth: 2,
                          strokeColor: c.card,
                        ),
                      ),
                      belowBarData: BarAreaData(
                        show: true,
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            c.primary.withOpacity(0.25),
                            c.primary.withOpacity(0.0),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ScoredEntry {
  final DateTime at;
  final int score;
  _ScoredEntry(this.at, this.score);
}
