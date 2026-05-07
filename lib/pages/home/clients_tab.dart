import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../../models/client_model.dart';
import 'home_constants.dart';
import 'home_models.dart';

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
          (_progressFilter == 'Weight loss' && _weightChange(client) < -0.1) ||
          (_progressFilter == 'Weight gain' && _weightChange(client) > 0.1) ||
          (_progressFilter == 'Stable' && _weightChange(client).abs() <= 0.1);

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
                _FilterDropdown(
                  value: _scheduleFilter,
                  defaultValue: 'All schedules',
                  values: scheduleOptions,
                  onChanged: (value) => setState(() => _scheduleFilter = value),
                ),
                _FilterDropdown(
                  value: _statusFilter,
                  defaultValue: 'All statuses',
                  values: const ['All statuses', 'With plan', 'Needs plan'],
                  onChanged: (value) => setState(() => _statusFilter = value),
                ),
                _FilterDropdown(
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
                ? const _ClientListShimmer()
                : filtered.isEmpty
                ? const Center(child: Text('No matching clients.'))
                : ListView.separated(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(space2, 0, space2, 104),
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final client = filtered[index];
                      return _ClientCard(
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

  double _weightChange(Client client) {
    if (client.progressEntries.length < 2) return 0;

    final sorted = [...client.progressEntries]
      ..sort((a, b) => a.date.compareTo(b.date));
    return sorted.last.weightKg - sorted.first.weightKg;
  }
}

class _FilterDropdown extends StatelessWidget {
  final String value;
  final String defaultValue;
  final List<String> values;
  final ValueChanged<String> onChanged;

  const _FilterDropdown({
    required this.value,
    required this.defaultValue,
    required this.values,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final active = value != defaultValue;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      margin: const EdgeInsets.only(right: space1),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: active ? primaryColor : Colors.white.withAlpha(230),
        border: Border.all(color: active ? primaryColor : cardBorderColor),
        borderRadius: BorderRadius.circular(14),
        boxShadow: active ? premiumCardShadows : null,
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: values.contains(value) ? value : values.first,
          dropdownColor: Colors.white,
          icon: Icon(
            Icons.keyboard_arrow_down,
            color: active ? Colors.white : mutedColor,
          ),
          style: TextStyle(
            color: active ? Colors.white : inkColor,
            fontWeight: FontWeight.w700,
          ),
          items: values
              .map(
                (item) => DropdownMenuItem(
                  value: item,
                  child: AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 180),
                    style: TextStyle(
                      color: item == value && active ? primaryColor : inkColor,
                      fontWeight: FontWeight.w700,
                    ),
                    child: Text(item),
                  ),
                ),
              )
              .toList(),
          onChanged: (value) {
            if (value != null) onChanged(value);
          },
        ),
      ),
    );
  }
}

class _ClientCard extends StatelessWidget {
  final Client client;
  final int index;
  final ValueChanged<String> onOpenClient;

  const _ClientCard({
    required this.client,
    required this.index,
    required this.onOpenClient,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 300 + (index * 70).clamp(0, 360)),
      curve: Curves.easeOutCubic,
      tween: Tween(begin: 0, end: 1),
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 26 * (1 - value)),
            child: child,
          ),
        );
      },
      child: PressableScale(
        onTap: () => onOpenClient(client.id),
        borderRadius: BorderRadius.circular(20),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: cardBorderColor),
            borderRadius: BorderRadius.circular(20),
            boxShadow: premiumCardShadows,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Stack(
              children: [
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          primaryColor.withAlpha(28),
                          tealColor.withAlpha(20),
                          Colors.white,
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 0,
                  right: 0,
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(28),
                    ),
                    child: Container(
                      height: 72,
                      width: 116,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            primaryColor.withAlpha(210),
                            tealColor.withAlpha(195),
                          ],
                        ),
                      ),
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.transparent,
                                    Colors.black.withAlpha(54),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const Center(
                            child: Icon(
                              Icons.fitness_center,
                              color: Colors.white70,
                              size: 34,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(space2),
                  child: Row(
                    children: [
                      Hero(
                        tag: 'client-avatar-${client.id}',
                        child: CircleAvatar(
                          radius: 28,
                          backgroundColor: primaryColor,
                          child: Text(
                            client.name.isEmpty ? '?' : client.name[0],
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: space2),
                      Expanded(
                        child: Hero(
                          tag: 'client-title-${client.id}',
                          child: Material(
                            color: Colors.transparent,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  client.name,
                                  style: const TextStyle(
                                    color: inkColor,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 17,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  client.trainingProgram,
                                  style: const TextStyle(color: mutedColor),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Weight ${client.weightKg.toStringAsFixed(1)} kg | BMI ${client.bmiLabel}',
                                  style: const TextStyle(
                                    color: mutedColor,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: space1),
                                Wrap(
                                  spacing: space1,
                                  runSpacing: space1,
                                  children: [
                                    _StatusBadge(
                                      label: client.gender,
                                      color: primaryColor,
                                    ),
                                    _StatusBadge(
                                      label: '${client.age} yrs',
                                      color: amberColor,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const Icon(
                        Icons.arrow_forward_ios,
                        size: 18,
                        color: Colors.black26,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class PressableScale extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;
  final BorderRadius borderRadius;

  const PressableScale({
    super.key,
    required this.child,
    required this.onTap,
    required this.borderRadius,
  });

  @override
  State<PressableScale> createState() => _PressableScaleState();
}

class _PressableScaleState extends State<PressableScale> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: _pressed ? 0.98 : 1,
      duration: const Duration(milliseconds: 110),
      curve: Curves.easeOut,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.onTap,
          onHighlightChanged: (value) => setState(() => _pressed = value),
          borderRadius: widget.borderRadius,
          splashColor: primaryColor.withAlpha(26),
          child: widget.child,
        ),
      ),
    );
  }
}

class _ClientListShimmer extends StatelessWidget {
  const _ClientListShimmer();

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

class _StatusBadge extends StatelessWidget {
  final String label;
  final Color color;

  const _StatusBadge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withAlpha((0.14 * 255).round()),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color.darken(),
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
