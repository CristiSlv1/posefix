import 'package:flutter/material.dart';

import '../core/theme.dart';
import '../models/profile.dart';
import '../models/weight_entry.dart';
import '../services/api_service.dart';

class PersonalDataScreen extends StatefulWidget {
  const PersonalDataScreen({super.key});

  @override
  State<PersonalDataScreen> createState() => _PersonalDataScreenState();
}

class _PersonalDataScreenState extends State<PersonalDataScreen> {
  final ApiService _apiService = ApiService();
  final TextEditingController _heightCtrl = TextEditingController();
  final TextEditingController _weightCtrl = TextEditingController();

  Profile? _profile;
  String? _sex;
  bool _loading = true;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _heightCtrl.dispose();
    _weightCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final p = await _apiService.getProfile();
      if (!mounted) return;
      setState(() {
        _profile = p ?? Profile(name: 'User');
        _heightCtrl.text = _profile!.heightCm?.toString() ?? '';
        _weightCtrl.text = _profile!.weightKg?.toString() ?? '';
        _sex = _profile!.sex;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Future<void> _save() async {
    final heightText = _heightCtrl.text.trim();
    final weightText = _weightCtrl.text.trim();

    int? height;
    if (heightText.isNotEmpty) {
      height = int.tryParse(heightText);
      if (height == null || height <= 0) {
        _snack('Enter a valid height in cm.');
        return;
      }
    }

    double? weight;
    if (weightText.isNotEmpty) {
      weight = double.tryParse(weightText);
      if (weight == null || weight <= 0) {
        _snack('Enter a valid weight in kg.');
        return;
      }
    }

    final base = _profile ?? Profile(name: 'User');
    final updated = Profile(
      name: base.name.isNotEmpty ? base.name : 'User',
      birthDate: base.birthDate,
      weightKg: weight ?? base.weightKg,
      heightCm: height ?? base.heightCm,
      sex: _sex ?? base.sex,
    );

    setState(() => _saving = true);

    final weightChanged = weight != null && weight != base.weightKg;
    bool weightOk = true;
    if (weightChanged) {
      weightOk = await _apiService.logWeightToday(weight);
    }

    final ok = await _apiService.updateProfile(updated);

    if (!mounted) return;
    setState(() => _saving = false);
    if (ok && weightOk) {
      if (weightChanged) weightHistoryVersion.value++;
      _snack(weightChanged ? 'Saved. Weight logged for today.' : 'Saved.');
      Navigator.of(context).pop();
    } else {
      _snack('Failed to save.');
    }
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    return Scaffold(
      appBar: AppBar(title: const Text('Personal data')),
      body: _loading
          ? Center(child: CircularProgressIndicator(color: c.primary))
          : _error != null
              ? Center(child: Text('Error: $_error', style: TextStyle(color: c.danger)))
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    Card(
                      color: c.card,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            TextField(
                              controller: _heightCtrl,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(labelText: 'Height (cm)'),
                            ),
                            const SizedBox(height: 12),
                            TextField(
                              controller: _weightCtrl,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              decoration: const InputDecoration(labelText: 'Weight (kg)'),
                            ),
                            const SizedBox(height: 12),
                            DropdownButtonFormField<String>(
                              value: _sex,
                              decoration: const InputDecoration(labelText: 'Sex'),
                              items: const [
                                DropdownMenuItem(value: 'male', child: Text('Male')),
                                DropdownMenuItem(value: 'female', child: Text('Female')),
                              ],
                              onChanged: (val) => setState(() => _sex = val),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: _saving ? null : _save,
                      icon: _saving
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : const Icon(Icons.save),
                      label: const Text('Save'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: c.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ],
                ),
    );
  }
}
