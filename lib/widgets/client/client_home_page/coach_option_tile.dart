import 'package:flutter/material.dart';

import '../../../models/app_user_profile.dart';

class CoachOptionTile extends StatelessWidget {
  final AppUserProfile coach;
  final bool selected;
  final VoidCallback onTap;

  const CoachOptionTile({
    super.key,
    required this.coach,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: selected ? const Color(0xFFEFF6FF) : const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected
                  ? const Color(0xFF2563EB)
                  : const Color(0xFFE2E8F0),
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: selected
                    ? const Color(0xFF1E40AF)
                    : const Color(0xFFCBD5E1),
                child: Text(
                  coach.name.isEmpty ? '?' : coach.name[0].toUpperCase(),
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      coach.name.isEmpty ? 'Coach' : coach.name,
                      style: const TextStyle(
                        color: Color(0xFF0F172A),
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      coach.email.isEmpty ? 'No email listed' : coach.email,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Color(0xFF64748B)),
                    ),
                  ],
                ),
              ),
              Icon(
                selected
                    ? Icons.radio_button_checked
                    : Icons.radio_button_unchecked,
                color: selected
                    ? const Color(0xFF2563EB)
                    : const Color(0xFF94A3B8),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
