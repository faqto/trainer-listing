import 'package:flutter/material.dart';

import 'text_asset_page.dart';

class AboutUsPage extends StatelessWidget {
  static const String _assetPath = 'assets/text/about_us.txt';

  const AboutUsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const TextAssetPage(
      title: 'About Us',
      assetPath: _assetPath,
      emptyMessage: 'About Us content is coming soon.',
    );
  }
}
