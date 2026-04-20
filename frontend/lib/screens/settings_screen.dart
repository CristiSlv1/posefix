import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../core/theme.dart';
import '../services/auth_service.dart';
import '../services/theme_service.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Future<void> _sendPasswordReset(BuildContext context) async {
    final auth = context.read<AuthService>();
    final email = auth.currentUser?.email;
    if (email == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No email on account.')),
      );
      return;
    }
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Reset password'),
        content: Text('Send a password reset link to $email?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogCtx, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(dialogCtx, true), child: const Text('Send')),
        ],
      ),
    );
    if (confirm != true) return;
    try {
      await auth.sendPasswordResetEmail(email);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Reset link sent to $email')),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    final themeService = context.watch<ThemeService>();
    final authService = context.watch<AuthService>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            tooltip: 'Log out',
            onPressed: () => authService.signOut(),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _SectionHeader(label: 'Account'),
          _SettingsTile(
            icon: Icons.person_outline_rounded,
            title: 'Profile',
            subtitle: authService.currentUser?.email ?? '',
            onTap: () => context.push('/settings/profile'),
          ),
          _SettingsTile(
            icon: Icons.lock_reset_rounded,
            title: 'Password reset',
            subtitle: 'Send a reset link to your email',
            onTap: () => _sendPasswordReset(context),
          ),
          _SettingsTile(
            icon: Icons.fitness_center_outlined,
            title: 'Personal data',
            subtitle: 'Height, weight, sex',
            onTap: () => context.push('/settings/personal-data'),
          ),
          const SizedBox(height: 24),
          _SectionHeader(label: 'Appearance'),
          Card(
            color: c.card,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: SwitchListTile(
              value: themeService.isDark,
              onChanged: (_) => themeService.toggle(),
              title: const Text('Dark theme'),
              subtitle: Text(
                themeService.isDark ? 'Currently using dark mode' : 'Currently using light mode',
                style: TextStyle(color: c.textMuted),
              ),
              secondary: Icon(
                themeService.isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                color: c.primaryLight,
              ),
              activeThumbColor: c.primary,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String label;
  const _SectionHeader({required this.label});

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 8, 4, 8),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
          color: c.textMuted,
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;
  const _SettingsTile({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    return Card(
      color: c.card,
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        leading: Icon(icon, color: c.primaryLight),
        title: Text(title),
        subtitle: subtitle != null && subtitle!.isNotEmpty
            ? Text(subtitle!, style: TextStyle(color: c.textMuted))
            : null,
        trailing: Icon(Icons.chevron_right, color: c.textDim),
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }
}
