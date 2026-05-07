import 'package:flutter/material.dart';

import 'home_constants.dart';

class SettingsTab extends StatelessWidget {
  final VoidCallback onLogout;

  const SettingsTab({super.key, required this.onLogout});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(space2, space2, space2, 104),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: cardBorderColor),
              borderRadius: BorderRadius.circular(16),
              boxShadow: premiumCardShadows,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Settings',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text('Manage account preferences and sign out from the app.'),
              ],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: onLogout,
            style: ElevatedButton.styleFrom(
              backgroundColor: roseColor,
              foregroundColor: Colors.white,
              minimumSize: const Size.fromHeight(56),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: const Text('Log Out', style: TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );
  }
}
