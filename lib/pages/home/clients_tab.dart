import 'dart:async';

import 'package:flutter/material.dart';

import '../../helpers/client_metrics.dart';
import '../../models/client_model.dart';
import '../../widgets/home/client_card.dart';
import '../../widgets/home/client_list_shimmer.dart';
import '../../widgets/home/filter_dropdown.dart';
import '../../widgets/home/pressable_scale.dart';
import 'home_constants.dart';

class ClientsTab extends StatefulWidget {
  final List<Client> clients;
  final VoidCallback onAddClient;
  final ValueChanged<String> onOpenClient;

  const ClientsTab({
    super.key,
    required this.clients,
    required this.onAddClient,
    required this.onOpenClient,
  });

  @override
  State<ClientsTab> createState() => _ClientsTabState();
}

class _ClientsTabState extends State<ClientsTab> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  String _scheduleFilter = 'All schedules';
  String _statusFilter = 'All statuses';
  String _progressFilter = 'All progress';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    Timer(const Duration(milliseconds: 520), () {
      if (mounted) setState(() => _isLoading = false);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheduleOptions = [
      'All schedules',
      ...widget.clients
          .map((client) => client.schedule.trim())
          .where((schedule) => schedule.isNotEmpty)
          .toSet(),
    ];

    final filtered = widget.clients.where((client) {
      final query = _searchQuery.toLowerCase();
      final matchesSearch =
          client.name.toLowerCase().contains(query) ||
          client.schedule.toLowerCase().contains(query);
      final matchesSchedule =
          _scheduleFilter == 'All schedules' ||
          client.schedule == _scheduleFilter;
      final matchesStatus =
          _statusFilter == 'All statuses' ||
          (_statusFilter == 'With plan' && client.fitnessRegime.isNotEmpty) ||
          (_statusFilter == 'Needs plan' && client.fitnessRegime.isEmpty);
      final matchesProgress =
          _progressFilter == 'All progress' ||
          (_progressFilter == 'Weight loss' && weightChange(client) < -0.1) ||
          (_progressFilter == 'Weight gain' && weightChange(client) > 0.1) ||
          (_progressFilter == 'Stable' && weightChange(client).abs() <= 0.1);

      return matchesSearch &&
          matchesSchedule &&
          matchesStatus &&
          matchesProgress;
    }).toList();

    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFF8FAFC), pageBackgroundColor],
        ),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(space2, space2, space2, 0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    onChanged: (value) => setState(() => _searchQuery = value),
                    decoration: InputDecoration(
                      hintText: 'Search clients',
                      prefixIcon: const Icon(Icons.search, color: mutedColor),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                PressableScale(
                  onTap: widget.onAddClient,
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    height: 56,
                    width: 56,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [primaryColor, Color(0xFF14B8A6)],
                      ),
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: premiumCardShadows,
                    ),
                    child: const Icon(Icons.add, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: space1),
          SizedBox(
            height: 48,
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: space2),
              physics: const BouncingScrollPhysics(),
              scrollDirection: Axis.horizontal,
              children: [
                FilterDropdown(
                  value: _scheduleFilter,
                  defaultValue: 'All schedules',
                  values: scheduleOptions,
                  onChanged: (value) => setState(() => _scheduleFilter = value),
                ),
                FilterDropdown(
                  value: _statusFilter,
                  defaultValue: 'All statuses',
                  values: const ['All statuses', 'With plan', 'Needs plan'],
                  onChanged: (value) => setState(() => _statusFilter = value),
                ),
                FilterDropdown(
                  value: _progressFilter,
                  defaultValue: 'All progress',
                  values: const [
                    'All progress',
                    'Weight loss',
                    'Weight gain',
                    'Stable',
                  ],
                  onChanged: (value) => setState(() => _progressFilter = value),
                ),
              ],
            ),
          ),
          const SizedBox(height: space2),
          Expanded(
            child: _isLoading
                ? const ClientListShimmer()
                : filtered.isEmpty
                ? const Center(child: Text('No matching clients.'))
                : ListView.separated(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(space2, 0, space2, 104),
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final client = filtered[index];
                      return ClientCard(
                        client: client,
                        index: index,
                        onOpenClient: widget.onOpenClient,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
