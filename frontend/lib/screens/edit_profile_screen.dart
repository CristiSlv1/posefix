import 'package:flutter/material.dart';

import '../core/theme.dart';
import '../models/profile.dart';
import '../services/api_service.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final ApiService _apiService = ApiService();
  final TextEditingController _nameCtrl = TextEditingController();

  Profile? _profile;
  DateTime? _birthDate;
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
    _nameCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final p = await _apiService.getProfile();
      if (!mounted) return;
      setState(() {
        _profile = p ?? Profile(name: '');
        _nameCtrl.text = _profile!.name;
        _birthDate = _parseDate(_profile!.birthDate);
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

  DateTime? _parseDate(String? s) {
    if (s == null || s.isEmpty) return null;
    try {
      return DateTime.parse(s.length > 10 ? s.substring(0, 10) : s);
    } catch (_) {
      return null;
    }
  }

  String _formatDate(DateTime d) {
    final y = d.year.toString().padLeft(4, '0');
    final m = d.month.toString().padLeft(2, '0');
    final day = d.day.toString().padLeft(2, '0');
    return '$y-$m-$day';
  }

  Future<void> _pickBirthday() async {
    final now = DateTime.now();
    final initial = _birthDate ?? DateTime(now.year - 25, now.month, now.day);
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(1900),
      lastDate: now,
      helpText: 'Select your birthday',
    );
    if (picked != null) {
      setState(() => _birthDate = picked);
    }
  }

  Future<void> _save() async {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Username cannot be empty.')),
      );
      return;
    }
    final base = _profile ?? Profile(name: name);
    final updated = Profile(
      name: name,
      birthDate: _birthDate != null ? _formatDate(_birthDate!) : null,
      weightKg: base.weightKg,
      heightCm: base.heightCm,
      sex: base.sex,
    );
    setState(() => _saving = true);
    final ok = await _apiService.updateProfile(updated);
    if (!mounted) return;
    setState(() => _saving = false);
    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated.')),
      );
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update profile.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: _loading
          ? Center(child: CircularProgressIndicator(color: c.primary))
          : _error != null
              ? Center(child: Text('Error: $_error', style: TextStyle(color: c.danger)))
              : Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Card(
                        color: c.card,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: TextField(
                            controller: _nameCtrl,
                            decoration: const InputDecoration(labelText: 'Username'),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Card(
                        color: c.card,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        child: ListTile(
                          leading: Icon(Icons.cake_outlined, color: c.primaryLight),
                          title: const Text('Birthday'),
                          subtitle: Text(
                            _birthDate != null ? _formatDate(_birthDate!) : 'Not set',
                            style: TextStyle(color: c.textMuted),
                          ),
                          trailing: Icon(Icons.edit_calendar_outlined, color: c.textDim),
                          onTap: _pickBirthday,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
                ),
    );
  }
}
