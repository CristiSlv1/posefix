import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../core/theme.dart';
import '../models/exercise.dart';
import '../models/posture_analysis.dart';
import '../services/api_service.dart';

class AnalyzeVideoScreen extends StatefulWidget {
  final Exercise exercise;
  const AnalyzeVideoScreen({super.key, required this.exercise});

  @override
  State<AnalyzeVideoScreen> createState() => _AnalyzeVideoScreenState();
}

class _AnalyzeVideoScreenState extends State<AnalyzeVideoScreen> {
  final ApiService _apiService = ApiService();
  final ImagePicker _picker = ImagePicker();

  File? _videoFile;
  bool _analyzing = false;
  String? _error;

  Future<void> _pickVideo(ImageSource source) async {
    setState(() => _error = null);
    try {
      final picked = await _picker.pickVideo(source: source);
      if (picked == null) return;
      setState(() => _videoFile = File(picked.path));
    } catch (e) {
      setState(() => _error = 'Could not pick video: $e');
    }
  }

  Future<void> _runAnalysis() async {
    final file = _videoFile;
    if (file == null) return;
    setState(() {
      _analyzing = true;
      _error = null;
    });
    try {
      final PostureAnalysis result = await _apiService.analyzePosture(
        widget.exercise.id,
        file.path,
      );
      postureListVersion.value++;
      if (!mounted) return;
      context.go('/postures/${result.id}');
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _analyzing = false;
        _error = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Analyze: ${widget.exercise.name}')),
      body: _analyzing ? _buildAnalyzing() : _buildPicker(),
    );
  }

  Widget _buildAnalyzing() {
    final c = context.appColors;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 80,
              height: 80,
              child: CircularProgressIndicator(
                color: c.primary,
                strokeWidth: 5,
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'Analyzing your posture...',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Running pose estimation on your ${widget.exercise.name.toLowerCase()} video. This usually takes a few seconds.',
              textAlign: TextAlign.center,
              style: TextStyle(color: c.textSecondary, height: 1.4),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPicker() {
    final c = context.appColors;
    final file = _videoFile;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Expanded(
              child: Card(
                color: c.card,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: file == null ? _emptyPreview(c) : _filePreview(c, file),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _pickVideo(ImageSource.gallery),
                    icon: Icon(Icons.photo_library_outlined, color: c.primaryLight),
                    label: Text('Gallery', style: TextStyle(color: c.primaryLight)),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: c.primaryLight),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _pickVideo(ImageSource.camera),
                    icon: Icon(Icons.videocam_outlined, color: c.primaryLight),
                    label: Text('Record', style: TextStyle(color: c.primaryLight)),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: c.primaryLight),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
              ],
            ),
            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(_error!, style: TextStyle(color: c.danger)),
            ],
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: file == null ? null : _runAnalysis,
                icon: const Icon(Icons.auto_graph_outlined),
                label: const Text('Analyze'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: c.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _emptyPreview(AppColors c) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.video_file_outlined, size: 80, color: c.textDim),
            const SizedBox(height: 12),
            Text(
              'Pick or record a short video of the exercise.',
              textAlign: TextAlign.center,
              style: TextStyle(color: c.textMuted),
            ),
          ],
        ),
      ),
    );
  }

  Widget _filePreview(AppColors c, File file) {
    final name = file.path.split(Platform.pathSeparator).last;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle_outline, size: 64, color: c.success),
            const SizedBox(height: 12),
            const Text('Video ready', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Text(
              name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(color: c.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}
