import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../helpers/client_page_helpers.dart';
import '../pages/home/home_constants.dart';

class ClientSliverAppBar extends StatelessWidget {
  final String name;
  final String goal;
  final String clientId;
  final VoidCallback onBack;

  const ClientSliverAppBar({
    super.key,
    required this.name,
    required this.goal,
    required this.clientId,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      pinned: true,
      floating: false,
      stretch: false,
      expandedHeight: 150,
      collapsedHeight: 60,
      toolbarHeight: 60,
      leading: BackButton(color: Colors.white, onPressed: onBack),
      leadingWidth: 72,
      titleSpacing: 20,
      backgroundColor: clientPageAppBarColor,
      title: const Text(
        'Client Profile',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      automaticallyImplyLeading: false,
      flexibleSpace: FlexibleSpaceBar(
        expandedTitleScale: 1,
        background: DecoratedBox(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF111827), Color(0xFF0F766E), Color(0xFF1E40AF)],
            ),
          ),
          child: SafeArea(
            top: false,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(space2, 42, space2, 12),
                child: _ClientAppBarCard(
                  name: name,
                  goal: goal,
                  clientId: clientId,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ClientAppBarCard extends StatelessWidget {
  final String name;
  final String goal;
  final String clientId;

  const _ClientAppBarCard({
    required this.name,
    required this.goal,
    required this.clientId,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(space2),
          decoration: BoxDecoration(
            color: Colors.white.withAlpha(42),
            border: Border.all(color: Colors.white.withAlpha(82)),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Hero(
                tag: 'client-avatar-$clientId',
                child: CircleAvatar(
                  radius: 28,
                  backgroundColor: Colors.white,
                  child: Text(
                    name.isEmpty ? '?' : name[0],
                    style: const TextStyle(
                      color: primaryColor,
                      fontWeight: FontWeight.w900,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: space2),
              Expanded(
                child: Hero(
                  tag: 'client-title-$clientId',
                  child: Material(
                    color: Colors.transparent,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: GoogleFonts.bebasNeue(
                            color: Colors.white,
                            fontSize: 24,
                            letterSpacing: 0,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          goal,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
