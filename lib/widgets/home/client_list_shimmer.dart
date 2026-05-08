import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../../pages/home/home_constants.dart';

class ClientListShimmer extends StatelessWidget {
  const ClientListShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(space2, 0, space2, 104),
      itemCount: 4,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: const Color(0xFFE2E8F0),
          highlightColor: Colors.white,
          child: Container(
            height: 136,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        );
      },
    );
  }
}
