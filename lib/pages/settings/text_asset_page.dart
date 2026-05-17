import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../home/home_constants.dart';

class TextAssetPage extends StatelessWidget {
  final String title;
  final String assetPath;
  final String emptyMessage;

  const TextAssetPage({
    super.key,
    required this.title,
    required this.assetPath,
    required this.emptyMessage,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: FutureBuilder<String>(
        future: rootBundle.loadString(assetPath),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(space2),
                child: Text('$title content could not be loaded.'),
              ),
            );
          }

          final content = snapshot.data?.trim();

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(space2, space2, space2, space4),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: cardBorderColor),
                borderRadius: BorderRadius.circular(16),
                boxShadow: premiumCardShadows,
              ),
              child: Text(
                content == null || content.isEmpty ? emptyMessage : content,
                style: const TextStyle(
                  color: inkColor,
                  fontSize: 16,
                  height: 1.5,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
