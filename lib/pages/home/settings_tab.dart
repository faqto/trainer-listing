import 'package:flutter/material.dart';

import '../../routes/app_routes.dart';
import '../../widgets/confirmation_dialog/confirmation_dialog.dart';
import 'home_constants.dart';

class SettingsTab extends StatelessWidget {
  final VoidCallback onLogout;

  const SettingsTab({super.key, required this.onLogout});

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.white,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(24, 28, 24, 104),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Column(
                children: [
                  _SettingsMenuTile(
                    icon: Icons.person_outline,
                    title: 'Profile',
                    onTap: () =>
                        Navigator.of(context).pushNamed(AppRoutes.profile),
                  ),
                  _SettingsMenuTile(
                    icon: Icons.notifications_none,
                    title: 'Notifications',
                    onTap: () => _showComingSoon(context, 'Notifications'),
                  ),
                  _SettingsMenuTile(
                    icon: Icons.visibility_outlined,
                    title: 'Appearance',
                    onTap: () => _showComingSoon(context, 'Appearance'),
                  ),
                  _SettingsMenuTile(
                    icon: Icons.lock_outline,
                    title: 'Privacy & Security',
                    onTap: () => Navigator.of(
                      context,
                    ).pushNamed(AppRoutes.privacyPolicy),
                  ),
                  _SettingsMenuTile(
                    icon: Icons.headphones_outlined,
                    title: 'Help and Support',
                    onTap: () =>
                        Navigator.of(context).pushNamed(AppRoutes.terms),
                  ),
                  _SettingsMenuTile(
                    icon: Icons.help_outline,
                    title: 'About',
                    onTap: () =>
                        Navigator.of(context).pushNamed(AppRoutes.aboutUs),
                  ),
                  const _SettingsMenuTile(
                    icon: Icons.verified_outlined,
                    title: 'App Version',
                    trailingText: '1.0.0+1',
                    showChevron: false,
                  ),
                  _SettingsMenuTile(
                    icon: Icons.logout,
                    title: 'Logout',
                    isDangerous: true,
                    showChevron: false,
                    onTap: () async {
                      final shouldLogout = await ConfirmationDialog.show(
                        context: context,
                        title: 'Confirm Logout',
                        content: 'Are you sure you want to sign out?',
                        confirmText: 'Log Out',
                        cancelText: 'Cancel',
                        isDangerous: true,
                      );

                      if (shouldLogout) onLogout();
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showComingSoon(BuildContext context, String label) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('$label settings are coming soon.')));
  }
}

class _SettingsMenuTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback? onTap;
  final bool isDangerous;
  final bool showChevron;
  final String? trailingText;

  const _SettingsMenuTile({
    required this.icon,
    required this.title,
    this.onTap,
    this.isDangerous = false,
    this.showChevron = true,
    this.trailingText,
  });

  @override
  Widget build(BuildContext context) {
    final foregroundColor = isDangerous ? roseColor : Colors.black;
    final textColor = isDangerous ? roseColor : const Color(0xFF525252);

    return Material(
      color: Colors.white,
      child: InkWell(
        onTap: onTap,
        child: DecoratedBox(
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(color: Color(0xFFEDEDED), width: 1),
            ),
          ),
          child: SizedBox(
            height: 57,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: Row(
                children: [
                  SizedBox(
                    width: 32,
                    child: Icon(icon, color: foregroundColor, size: 24),
                  ),
                  const SizedBox(width: 2),
                  Expanded(
                    child: Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: textColor,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0,
                      ),
                    ),
                  ),
                  if (trailingText != null) ...[
                    const SizedBox(width: 10),
                    Text(
                      trailingText!,
                      style: const TextStyle(
                        color: mutedColor,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0,
                      ),
                    ),
                  ],
                  if (showChevron)
                    const Icon(
                      Icons.chevron_right,
                      color: Colors.black,
                      size: 30,
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
