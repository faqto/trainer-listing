import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../helpers/client_page_helpers.dart';
import '../../models/app_user_profile.dart';
import '../../models/client_model.dart';
import '../../routes/app_routes.dart';
import '../../services/auth_repository.dart';
import '../../services/user_repository.dart';
import '../../widgets/client/client_information_page/progress_entry_card.dart';
import '../../widgets/client/client_section_card.dart';
import '../../widgets/client/client_section_title.dart';
import 'client_home_page.dart';

class ClientFitnessPage extends StatefulWidget {
  const ClientFitnessPage({super.key});

  @override
  State<ClientFitnessPage> createState() => _ClientFitnessPageState();
}

class _ClientFitnessPageState extends State<ClientFitnessPage> {
  ClientDashboardData? _data;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final data = await UserRepository.instance
          .getCurrentClientDashboardData();
      if (!mounted) return;
      setState(() => _data = data);
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Unable to load your fitness dashboard.';
      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _logout() async {
    await AuthRepository.instance.signOut();
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.login,
      (route) => false,
    );
  }

  Future<void> _editDetails() async {
    await Navigator.pushNamed(context, AppRoutes.clientDetails);
    if (mounted) await _load();
  }

  Future<void> _showMetricsSheet(Client client) async {
    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (sheetContext) => _MetricUpdateSheet(client: client),
    );

    if (saved != true || !mounted) return;
    await _load();
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Body metrics updated.')));
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final data = _data;
    if (data == null || _errorMessage != null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('My Fitness'),
          actions: [
            IconButton(
              tooltip: 'Sign out',
              onPressed: _logout,
              icon: const Icon(Icons.logout_rounded),
            ),
          ],
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.error_outline_rounded,
                  color: Color(0xFFBE123C),
                  size: 42,
                ),
                const SizedBox(height: 12),
                Text(
                  _errorMessage ?? 'Your client profile could not be loaded.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(onPressed: _load, child: const Text('Retry')),
              ],
            ),
          ),
        ),
      );
    }

    if (!data.hasAssignedCoach || data.client == null) {
      return const ClientHomePage();
    }

    final profile = data.profile!;
    final client = data.client!;
    final progressEntries = [...client.progressEntries]
      ..sort((a, b) => b.date.compareTo(a.date));

    return Scaffold(
      backgroundColor: clientPageBackgroundColor,
      appBar: AppBar(
        title: const Text('My Fitness'),
        actions: [
          IconButton(
            tooltip: 'Edit details',
            onPressed: _editDetails,
            icon: const Icon(Icons.edit_outlined),
          ),
          IconButton(
            tooltip: 'Sign out',
            onPressed: _logout,
            icon: const Icon(Icons.logout_rounded),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          children: [
            _FitnessHeader(profile: profile, client: client),
            const SizedBox(height: 16),
            _QuickStats(client: client),
            const SizedBox(height: 16),
            _CoachPlanCard(client: client),
            const SizedBox(height: 16),
            _BodyMetricsCard(
              client: client,
              onUpdate: () => _showMetricsSheet(client),
            ),
            const SizedBox(height: 16),
            _ProgressCard(
              client: client,
              progressEntries: progressEntries,
              onUpdate: () => _showMetricsSheet(client),
            ),
            const SizedBox(height: 16),
            _SuggestionsCard(client: client),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _FitnessHeader extends StatelessWidget {
  final AppUserProfile profile;
  final Client client;

  const _FitnessHeader({required this.profile, required this.client});

  @override
  Widget build(BuildContext context) {
    final coachName = profile.assignedCoachName?.trim().isNotEmpty == true
        ? profile.assignedCoachName!.trim()
        : 'your coach';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF111827),
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Color(0x220F172A),
            blurRadius: 24,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: const Color(0xFF2563EB),
                child: Text(
                  client.name.isEmpty ? '?' : client.name[0].toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      client.name.isEmpty ? 'My Fitness' : client.name,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Connected with $coachName',
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Color(0xFFCBD5E1)),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          _HeaderPill(icon: Icons.flag_outlined, text: client.goal),
          const SizedBox(height: 10),
          _HeaderPill(
            icon: Icons.event_available_outlined,
            text: client.schedule.trim().isEmpty
                ? 'No preferred schedule yet'
                : client.schedule,
          ),
        ],
      ),
    );
  }
}

class _HeaderPill extends StatelessWidget {
  final IconData icon;
  final String text;

  const _HeaderPill({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF93C5FD), size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text.trim().isEmpty ? 'Not set' : text,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickStats extends StatelessWidget {
  final Client client;

  const _QuickStats({required this.client});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      childAspectRatio: 1.55,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      children: [
        _StatTile(
          icon: Icons.monitor_weight_outlined,
          label: 'Weight',
          value: _metricValue(client.weightKg, 'kg'),
        ),
        _StatTile(
          icon: Icons.straighten_outlined,
          label: 'BMI',
          value: client.bmiLabel,
        ),
        _StatTile(
          icon: Icons.percent_outlined,
          label: 'Body Fat',
          value: _metricValue(client.bodyFatPercent, '%'),
        ),
        _StatTile(
          icon: Icons.trending_up_rounded,
          label: 'Trend',
          value: client.weightTrendLabel,
        ),
      ],
    );
  }
}

class _StatTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _StatTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, color: const Color(0xFF1E40AF), size: 22),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(color: Color(0xFF64748B))),
              const SizedBox(height: 2),
              Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Color(0xFF0F172A),
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CoachPlanCard extends StatelessWidget {
  final Client client;

  const _CoachPlanCard({required this.client});

  @override
  Widget build(BuildContext context) {
    return ClientSectionCard(
      children: [
        const ClientSectionTitle('Coach Plan'),
        const SizedBox(height: 14),
        _DetailLine(label: 'Workout', value: client.fitnessRegime),
        _DetailLine(label: 'Cardio', value: client.cardioPlan),
        _DetailLine(label: 'Program', value: client.trainingProgram),
        _DetailLine(label: 'Coach Notes', value: client.notes),
      ],
    );
  }
}

class _BodyMetricsCard extends StatelessWidget {
  final Client client;
  final VoidCallback onUpdate;

  const _BodyMetricsCard({required this.client, required this.onUpdate});

  @override
  Widget build(BuildContext context) {
    return ClientSectionCard(
      children: [
        Row(
          children: [
            const Expanded(child: ClientSectionTitle('Body Metrics')),
            TextButton.icon(
              onPressed: onUpdate,
              icon: const Icon(Icons.add_chart_outlined),
              label: const Text('Update'),
            ),
          ],
        ),
        const SizedBox(height: 10),
        _DetailLine(
          label: 'Weight',
          value: _metricValue(client.weightKg, 'kg'),
        ),
        _DetailLine(
          label: 'Height',
          value: _metricValue(client.heightCm, 'cm'),
        ),
        _DetailLine(label: 'BMI', value: client.bmiLabel),
        _DetailLine(
          label: 'Body Fat',
          value: _metricValue(client.bodyFatPercent, '%'),
        ),
        _DetailLine(label: 'Waist', value: _metricValue(client.waistCm, 'cm')),
        _DetailLine(label: 'Hips', value: _metricValue(client.hipsCm, 'cm')),
        _DetailLine(label: 'Chest', value: _metricValue(client.chestCm, 'cm')),
      ],
    );
  }
}

class _ProgressCard extends StatelessWidget {
  final Client client;
  final List<ProgressEntry> progressEntries;
  final VoidCallback onUpdate;

  const _ProgressCard({
    required this.client,
    required this.progressEntries,
    required this.onUpdate,
  });

  @override
  Widget build(BuildContext context) {
    final visibleEntries = progressEntries.take(4).toList();

    return ClientSectionCard(
      children: [
        Row(
          children: [
            const Expanded(child: ClientSectionTitle('Progress Tracking')),
            TextButton.icon(
              onPressed: onUpdate,
              icon: const Icon(Icons.post_add_outlined),
              label: const Text('Log'),
            ),
          ],
        ),
        const SizedBox(height: 10),
        _DetailLine(label: 'Entries', value: progressEntries.length.toString()),
        _DetailLine(label: 'Weight Trend', value: client.weightTrendLabel),
        const SizedBox(height: 8),
        if (visibleEntries.isEmpty)
          const Text(
            'No progress entries yet.',
            style: TextStyle(color: Color(0xFF64748B)),
          )
        else
          ...visibleEntries.map((entry) => ProgressEntryCard(entry: entry)),
      ],
    );
  }
}

class _SuggestionsCard extends StatelessWidget {
  final Client client;

  const _SuggestionsCard({required this.client});

  @override
  Widget build(BuildContext context) {
    final suggestions = <String>[
      if (client.schedule.trim().isEmpty)
        'Add a preferred schedule so your coach can plan sessions faster.',
      if (client.fitnessRegime.trim().isEmpty &&
          client.cardioPlan.trim().isEmpty)
        'Your coach plan will appear here after your coach adds it.',
      if (client.progressEntries.length < 2)
        'Log body metrics again later to start seeing a trend.',
      if (client.weightKg > 0 && client.heightCm > 0)
        'Keep weight and measurements updated from the same scale and time of day.',
    ];

    return ClientSectionCard(
      children: [
        const ClientSectionTitle('Suggested Next Steps'),
        const SizedBox(height: 12),
        ...suggestions.map(
          (suggestion) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.check_circle_outline,
                  color: Color(0xFF0F766E),
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(child: Text(suggestion)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _DetailLine extends StatelessWidget {
  final String label;
  final String value;

  const _DetailLine({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final displayValue = value.trim().isEmpty ? 'Not set' : value.trim();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 106,
            child: Text(
              label,
              style: const TextStyle(color: Color(0xFF64748B)),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              displayValue,
              style: const TextStyle(
                color: Color(0xFF0F172A),
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricUpdateSheet extends StatefulWidget {
  final Client client;

  const _MetricUpdateSheet({required this.client});

  @override
  State<_MetricUpdateSheet> createState() => _MetricUpdateSheetState();
}

class _MetricUpdateSheetState extends State<_MetricUpdateSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _weightController;
  late final TextEditingController _heightController;
  late final TextEditingController _bodyFatController;
  late final TextEditingController _waistController;
  late final TextEditingController _hipsController;
  late final TextEditingController _chestController;
  late final TextEditingController _noteController;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _weightController = TextEditingController(
      text: _initialMetric(widget.client.weightKg),
    );
    _heightController = TextEditingController(
      text: _initialMetric(widget.client.heightCm),
    );
    _bodyFatController = TextEditingController(
      text: _initialMetric(widget.client.bodyFatPercent),
    );
    _waistController = TextEditingController(
      text: _initialMetric(widget.client.waistCm),
    );
    _hipsController = TextEditingController(
      text: _initialMetric(widget.client.hipsCm),
    );
    _chestController = TextEditingController(
      text: _initialMetric(widget.client.chestCm),
    );
    _noteController = TextEditingController();
  }

  Future<void> _save() async {
    if (_isSaving || !_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    final progressEntry = ProgressEntry(
      weightKg: parseMetric(_weightController.text),
      heightCm: parseMetric(_heightController.text),
      bodyFatPercent: parseMetric(_bodyFatController.text),
      waistCm: parseMetric(_waistController.text),
      hipsCm: parseMetric(_hipsController.text),
      chestCm: parseMetric(_chestController.text),
      note: _noteController.text.trim(),
    );

    try {
      await UserRepository.instance.updateCurrentClientMetrics(progressEntry);
      if (!mounted) return;
      Navigator.pop(context, true);
    } on FirebaseException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.message ?? 'Unable to save metrics.')),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Unable to save metrics: $error')));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  String? _validateMetric(
    String? value,
    String label, {
    bool required = false,
    double? max,
  }) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return required ? 'Enter $label' : null;

    final number = double.tryParse(text.replaceAll(',', '.'));
    if (number == null) return 'Enter a valid $label';
    if (number <= 0) return '$label must be above zero';
    if (max != null && number > max) return '$label looks too high';
    return null;
  }

  Widget _metricField({
    required TextEditingController controller,
    required String label,
    required String validationLabel,
    bool required = false,
    double? max,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(labelText: label),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      validator: (value) =>
          _validateMetric(value, validationLabel, required: required, max: max),
    );
  }

  @override
  void dispose() {
    _weightController.dispose();
    _heightController.dispose();
    _bodyFatController.dispose();
    _waistController.dispose();
    _hipsController.dispose();
    _chestController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.viewInsetsOf(context).bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(16, 16, 16, bottomPadding + 16),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Update Body Metrics',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Close',
                    onPressed: _isSaving ? null : () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _metricField(
                      controller: _weightController,
                      label: 'Weight (kg)',
                      validationLabel: 'weight',
                      required: true,
                      max: 500,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _metricField(
                      controller: _heightController,
                      label: 'Height (cm)',
                      validationLabel: 'height',
                      required: true,
                      max: 300,
                    ),
                  ),
                ],
              ),
              clientFieldGap,
              Row(
                children: [
                  Expanded(
                    child: _metricField(
                      controller: _bodyFatController,
                      label: 'Body Fat (%)',
                      validationLabel: 'body fat',
                      max: 100,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _metricField(
                      controller: _waistController,
                      label: 'Waist (cm)',
                      validationLabel: 'waist',
                      max: 300,
                    ),
                  ),
                ],
              ),
              clientFieldGap,
              Row(
                children: [
                  Expanded(
                    child: _metricField(
                      controller: _hipsController,
                      label: 'Hips (cm)',
                      validationLabel: 'hips',
                      max: 300,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _metricField(
                      controller: _chestController,
                      label: 'Chest (cm)',
                      validationLabel: 'chest',
                      max: 300,
                    ),
                  ),
                ],
              ),
              clientFieldGap,
              TextFormField(
                controller: _noteController,
                decoration: const InputDecoration(
                  labelText: 'Progress note',
                  alignLabelWithHint: true,
                ),
                minLines: 2,
                maxLines: 3,
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isSaving ? null : _save,
                  icon: _isSaving
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.check_circle_outline),
                  label: const Text('Save Metrics'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

String _metricValue(double value, String unit) {
  if (value <= 0) return 'Not set';
  final text = value == value.roundToDouble()
      ? value.toStringAsFixed(0)
      : value.toStringAsFixed(1);
  return unit == '%' ? '$text%' : '$text $unit';
}

String _initialMetric(double value) {
  if (value <= 0) return '';
  return value == value.roundToDouble()
      ? value.toStringAsFixed(0)
      : value.toString();
}
