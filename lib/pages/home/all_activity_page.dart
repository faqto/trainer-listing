import 'package:flutter/material.dart';

import '../../models/activity_event.dart';
import '../../models/home_activity.dart';
import '../../services/activity_repository.dart';
import '../../widgets/home/activity_card.dart';
import 'home_constants.dart';

class AllActivityPage extends StatefulWidget {
  const AllActivityPage({super.key});

  @override
  State<AllActivityPage> createState() => _AllActivityPageState();
}

class _AllActivityPageState extends State<AllActivityPage> {
  List<ActivityEvent> _events = [];
  bool _isLoading = true;
  ActivityType? _selectedFilter;

  static const _filters = <String, ActivityType?>{
    'All': null,
    'Body Updates': ActivityType.bodyUpdated,
    'Regime Changes': ActivityType.regimeChanged,
    'Sessions Completed': ActivityType.sessionCompleted,
  };

  @override
  void initState() {
    super.initState();
    _loadActivity();
  }

  Future<void> _loadActivity() async {
    setState(() => _isLoading = true);
    final events = await ActivityRepository.instance.getAll(
      filterType: _selectedFilter,
    );
    if (!mounted) return;
    setState(() {
      _events = events;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('All Activity')),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 52,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              children: _filters.entries.map((entry) {
                final isSelected = _selectedFilter == entry.value;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(entry.key),
                    selected: isSelected,
                    onSelected: (_) {
                      setState(() => _selectedFilter = entry.value);
                      _loadActivity();
                    },
                    selectedColor: primaryColor.withAlpha(30),
                    checkmarkColor: primaryColor,
                    labelStyle: TextStyle(
                      color: isSelected ? primaryColor : mutedColor,
                      fontWeight: isSelected
                          ? FontWeight.w700
                          : FontWeight.w500,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _events.isEmpty
                ? Center(
                    child: Text(
                      'No activity found.',
                      style: TextStyle(color: mutedColor),
                    ),
                  )
                : ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                    itemCount: _events.length,
                    itemBuilder: (context, index) {
                      final event = _events[index];
                      final activity = HomeActivity(
                        name: event.clientName,
                        subtitle: event.description,
                        time: event.timeAgoLabel,
                        icon: event.icon,
                        color: event.color,
                        event: event,
                      );
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: ActivityCard(activity: activity, event: event),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
