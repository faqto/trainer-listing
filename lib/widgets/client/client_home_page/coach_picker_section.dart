import 'package:flutter/material.dart';

import '../../../models/app_user_profile.dart';
import 'coach_option_tile.dart';
import 'section_card.dart';

class CoachPickerSection extends StatelessWidget {
  final List<AppUserProfile> coaches;
  final List<AppUserProfile> filteredCoaches;
  final String? selectedCoachId;
  final TextEditingController searchController;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<String> onCoachSelected;

  const CoachPickerSection({
    super.key,
    required this.coaches,
    required this.filteredCoaches,
    required this.selectedCoachId,
    required this.searchController,
    required this.onSearchChanged,
    required this.onCoachSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      title: 'Available Coaches',
      icon: Icons.sports_outlined,
      children: [
        if (coaches.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Text('No coaches are available yet.'),
          )
        else ...[
          TextField(
            controller: searchController,
            onChanged: onSearchChanged,
            decoration: const InputDecoration(
              labelText: 'Search coaches',
              prefixIcon: Icon(Icons.search_rounded),
            ),
          ),
          const SizedBox(height: 12),
          if (filteredCoaches.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Text('No coaches match your search.'),
            )
          else
            ...filteredCoaches.map(
              (coach) => CoachOptionTile(
                coach: coach,
                selected: coach.id == selectedCoachId,
                onTap: () => onCoachSelected(coach.id),
              ),
            ),
        ],
      ],
    );
  }
}
