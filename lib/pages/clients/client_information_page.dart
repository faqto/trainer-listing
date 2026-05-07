import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../models/client_model.dart';
import '../../routes/app_routes.dart';
import '../../services/client_repository.dart';
import '../home/home_constants.dart';
import 'client_page_helpers.dart';

class ClientInformationPage extends StatefulWidget {
  final String clientId;

  const ClientInformationPage({super.key, required this.clientId});

  @override
  State<ClientInformationPage> createState() => _ClientInformationPageState();
}

class _ClientInformationPageState extends State<ClientInformationPage> {
  Client? _client;

  void _loadClient() {
    _client = ClientRepository.instance.getById(widget.clientId);
  }

  Future<void> _refresh() async {
    setState(_loadClient);
  }

  @override
  void initState() {
    super.initState();
    _loadClient();
  }

  @override
  Widget build(BuildContext context) {
    if (_client == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Client Profile')),
        body: const Center(child: Text('Client not found.')),
      );
    }

    final progressEntries = [..._client!.progressEntries]
      ..sort((a, b) => b.date.compareTo(a.date));

    return Scaffold(
      backgroundColor: clientPageBackgroundColor,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            pinned: true,
            floating: false,
            stretch: false,
            expandedHeight: 180,
            backgroundColor: clientPageAppBarColor,
            title: const Text('Client Profile'),
            automaticallyImplyLeading: true,
            flexibleSpace: FlexibleSpaceBar(
              background: DecoratedBox(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF111827),
                      Color(0xFF0F766E),
                      Color(0xFF1E40AF),
                    ],
                  ),
                ),
                child: SafeArea(
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                      padding: const EdgeInsets.all(space2),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(space2),
                            decoration: BoxDecoration(
                              color: Colors.white.withAlpha(42),
                              border: Border.all(
                                color: Colors.white.withAlpha(82),
                              ),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              children: [
                                Hero(
                                  tag: 'client-avatar-${_client!.id}',
                                  child: CircleAvatar(
                                    radius: 28,
                                    backgroundColor: Colors.white,
                                    child: Text(
                                      _client!.name.isEmpty
                                          ? '?'
                                          : _client!.name[0],
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
                                    tag: 'client-title-${_client!.id}',
                                    child: Material(
                                      color: Colors.transparent,
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            _client!.name,
                                            style: GoogleFonts.bebasNeue(
                                              color: Colors.white,
                                              fontSize: 24,
                                              letterSpacing: 0,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            _client!.goal,
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
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(space2, space1, space2, space3),
            sliver: SliverList.list(
              children: [
                ClientSectionCard(
                  children: [
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        _InfoBadge(label: '${_client!.age} yrs'),
                        _InfoBadge(label: _client!.gender),
                        _InfoBadge(label: _client!.schedule),
                      ],
                    ),
                  ],
                ),
                clientSectionGap,
                ClientSectionCard(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const ClientSectionTitle('Fitness Regime'),
                        TextButton(
                          onPressed: () async {
                            final result = await Navigator.pushNamed(
                              context,
                              AppRoutes.editRegime,
                              arguments: _client!.id,
                            );
                            if (result == true) {
                              await _refresh();
                            }
                          },
                          child: const Text('Edit'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _detailBlock('Schedule', _client!.schedule),
                    _detailBlock('Workout', _client!.fitnessRegime),
                    _detailBlock('Cardio', _client!.cardioPlan),
                  ],
                ),
                clientSectionGap,
                ClientSectionCard(
                  children: [
                    const ClientSectionTitle('Body Metrics'),
                    const SizedBox(height: 16),
                    _metricRow(
                      'Weight',
                      '${_client!.weightKg.toStringAsFixed(1)} kg',
                    ),
                    _metricRow(
                      'Height',
                      '${_client!.heightCm.toStringAsFixed(1)} cm',
                    ),
                    _metricRow('BMI', _client!.bmiLabel),
                    _metricRow(
                      'Body Fat',
                      '${_client!.bodyFatPercent.toStringAsFixed(1)}%',
                    ),
                    _metricRow(
                      'Waist',
                      '${_client!.waistCm.toStringAsFixed(1)} cm',
                    ),
                    _metricRow(
                      'Hips',
                      '${_client!.hipsCm.toStringAsFixed(1)} cm',
                    ),
                    _metricRow(
                      'Chest',
                      '${_client!.chestCm.toStringAsFixed(1)} cm',
                    ),
                  ],
                ),
                clientSectionGap,
                ClientSectionCard(
                  children: [
                    const ClientSectionTitle('Progress Summary'),
                    const SizedBox(height: 16),
                    _metricRow(
                      'Progress entries',
                      progressEntries.length.toString(),
                    ),
                    _metricRow('Weight trend', _client!.weightTrendLabel),
                    _metricRow('Current BMI', _client!.bmiLabel),
                  ],
                ),
                clientSectionGap,
                ClientSectionCard(
                  children: [
                    const ClientSectionTitle('Progress History'),
                    const SizedBox(height: 12),
                    if (progressEntries.isEmpty)
                      const Text('No progress entries yet.')
                    else
                      ...progressEntries.map(_progressEntryCard),
                  ],
                ),
                clientSectionGap,
                ClientSectionCard(
                  children: [
                    const ClientSectionTitle('Client Notes'),
                    const SizedBox(height: 12),
                    Text(
                      _client!.notes.isEmpty
                          ? 'No notes available.'
                          : _client!.notes,
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () async {
                    final result = await Navigator.pushNamed(
                      context,
                      AppRoutes.editClient,
                      arguments: _client!.id,
                    );
                    if (result == true) {
                      await _refresh();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF13294B),
                    minimumSize: const Size.fromHeight(56),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text('Edit Client'),
                ),
                const SizedBox(height: 12),
                OutlinedButton(
                  onPressed: () async {
                    final result = await Navigator.pushNamed(
                      context,
                      AppRoutes.bodyDetails,
                      arguments: _client!.id,
                    );
                    if (result == true) {
                      await _refresh();
                    }
                  },
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(56),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text('Update Body Metrics'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _metricRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.black54)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _progressEntryCard(ProgressEntry entry) {
    final bmi = entry.bmi == null ? '--' : entry.bmi!.toStringAsFixed(1);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            entry.dateLabel,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Weight ${entry.weightKg.toStringAsFixed(1)} kg | BMI $bmi | Body fat ${entry.bodyFatPercent.toStringAsFixed(1)}%',
          ),
          if (entry.note.trim().isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(entry.note, style: const TextStyle(color: Colors.black54)),
          ],
        ],
      ),
    );
  }

  Widget _detailBlock(String label, String value) {
    final displayValue = value.trim().isEmpty ? 'Not set' : value;

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.black54,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            displayValue,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

class _InfoBadge extends StatelessWidget {
  final String label;

  const _InfoBadge({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF3FF),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
    );
  }
}
