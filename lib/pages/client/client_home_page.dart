import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../helpers/client_page_helpers.dart';
import '../../models/app_user_profile.dart';
import '../../models/client_model.dart';
import '../../routes/app_routes.dart';
import '../../services/auth_repository.dart';
import '../../services/user_repository.dart';
import '../../widgets/client/client_schedule_picker.dart';

class ClientHomePage extends StatefulWidget {
  const ClientHomePage({super.key});

  @override
  State<ClientHomePage> createState() => _ClientHomePageState();
}

class _ClientHomePageState extends State<ClientHomePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _ageController = TextEditingController();
  final _goalController = TextEditingController();
  final _weightController = TextEditingController();
  final _heightController = TextEditingController();
  final _bodyFatController = TextEditingController();
  final _waistController = TextEditingController();
  final _hipsController = TextEditingController();
  final _chestController = TextEditingController();

  static const _sexOptions = [
    'Not specified',
    'Female',
    'Male',
    'Nonbinary',
    'Other',
  ];
  static const _customGoalOption = 'Customize';
  static const _goalOptions = [
    'Weight loss',
    'Weight gain',
    'Muscle gain',
    'Muscle loss',
    _customGoalOption,
  ];

  List<AppUserProfile> _coaches = [];
  String? _selectedCoachId;
  String? _assignedCoachId;
  String? _assignedCoachName;
  String _selectedSex = _sexOptions.first;
  String? _selectedGoal;
  final List<String> _selectedDays = [];
  TimeOfDay? _scheduleTime;
  String? _scheduleError;
  int _durationHours = 0;
  int _durationMinutes = 0;
  bool _isLoading = true;
  bool _isSaving = false;
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
      final results = await Future.wait([
        UserRepository.instance.getCurrentProfile(),
        UserRepository.instance.getCoaches(),
      ]);
      final profile = results[0] as AppUserProfile?;
      final coaches = results[1] as List<AppUserProfile>;

      if (!mounted) return;
      setState(() {
        _coaches = coaches;
        _assignedCoachId = profile?.assignedCoachId;
        _assignedCoachName = profile?.assignedCoachName;
        _selectedCoachId =
            _assignedCoachId ?? (coaches.isNotEmpty ? coaches.first.id : null);
        _nameController.text = profile?.name.isNotEmpty == true
            ? profile!.name
            : AuthRepository.instance.currentUserName;
        _emailController.text = profile?.email.isNotEmpty == true
            ? profile!.email
            : AuthRepository.instance.currentUserEmail ?? '';
        _phoneController.text = profile?.phone ?? '';
        _ageController.text = (profile?.age ?? 0) > 0
            ? profile!.age.toString()
            : '';
        _selectedSex = _sexOptions.contains(profile?.sex)
            ? profile!.sex
            : _sexOptions.first;
        _setSelectedGoal(profile?.goal ?? '');
        _setSelectedSchedule(profile?.schedule ?? '');
        _setMetricText(_weightController, profile?.weightKg ?? 0);
        _setMetricText(_heightController, profile?.heightCm ?? 0);
        _setMetricText(_bodyFatController, profile?.bodyFatPercent ?? 0);
        _setMetricText(_waistController, profile?.waistCm ?? 0);
        _setMetricText(_hipsController, profile?.hipsCm ?? 0);
        _setMetricText(_chestController, profile?.chestCm ?? 0);
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Unable to load coaches. Please try again.';
      });
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _chooseCoach() async {
    if (_isSaving) return;
    if (!_formKey.currentState!.validate()) return;

    if (_selectedDays.isNotEmpty && _scheduleTime == null) {
      setState(() => _scheduleError = 'Please select a time');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a schedule time.')),
      );
      return;
    }

    final selectedCoach = _selectedCoach;
    if (selectedCoach == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please choose a coach first.')),
      );
      return;
    }

    final userId = AuthRepository.instance.currentUserId;
    if (userId == null) {
      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.login,
        (route) => false,
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final goal = _selectedGoal == _customGoalOption
          ? 'Others: ${_goalController.text.trim()}'
          : _selectedGoal!;
      final schedule = formatScheduleDays(
        _selectedDays,
        _scheduleTime,
        context,
        durationHours: _durationHours,
        durationMinutes: _durationMinutes,
      );

      final client = Client(
        id: userId,
        clientUserId: userId,
        coachId: selectedCoach.id,
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
        age: int.parse(_ageController.text.trim()),
        sex: _selectedSex,
        goal: goal,
        schedule: schedule,
        weightKg: parseMetric(_weightController.text),
        heightCm: parseMetric(_heightController.text),
        bodyFatPercent: parseMetric(_bodyFatController.text),
        waistCm: parseMetric(_waistController.text),
        hipsCm: parseMetric(_hipsController.text),
        chestCm: parseMetric(_chestController.text),
        notes: 'Added from client account.',
      );

      await UserRepository.instance.assignCurrentClientToCoach(
        coach: selectedCoach,
        client: client,
      );

      if (!mounted) return;
      setState(() {
        _assignedCoachId = selectedCoach.id;
        _assignedCoachName = selectedCoach.name;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('You are now connected with ${selectedCoach.name}.'),
        ),
      );
      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.clientHome,
        (route) => false,
      );
    } on FirebaseException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.message ?? 'Unable to choose coach.')),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Unable to choose coach: $error')));
    } finally {
      if (mounted) setState(() => _isSaving = false);
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

  AppUserProfile? get _selectedCoach {
    for (final coach in _coaches) {
      if (coach.id == _selectedCoachId) return coach;
    }
    return null;
  }

  String? _validateRequired(String? value, String message) {
    return value == null || value.trim().isEmpty ? message : null;
  }

  String? _validateEmail(String? value) {
    final email = value?.trim() ?? '';
    if (email.isEmpty) return 'Please enter your email';
    if (!email.contains('@')) return 'Enter a valid email';
    return null;
  }

  String? _validateAge(String? value) {
    final age = int.tryParse(value?.trim() ?? '');
    if (age == null) return 'Please enter your age';
    if (age < 16) return 'Minimum age is 16';
    if (age > 75) return 'Maximum age is 75';
    return null;
  }

  String? _validateMetric(
    String? value,
    String label, {
    bool required = false,
    double? max,
  }) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) {
      return required ? 'Please enter your $label' : null;
    }

    final metric = double.tryParse(text.replaceAll(',', '.'));
    if (metric == null) return 'Enter a valid $label';
    if (metric <= 0) return '$label must be greater than zero';
    if (max != null && metric > max) return '$label looks too high';
    return null;
  }

  void _setSelectedGoal(String goal) {
    final trimmedGoal = goal.trim();
    if (trimmedGoal.isEmpty) {
      _selectedGoal = null;
      _goalController.clear();
      return;
    }

    if (trimmedGoal.startsWith('Others:')) {
      _selectedGoal = _customGoalOption;
      _goalController.text = trimmedGoal.replaceFirst('Others:', '').trim();
      return;
    }

    if (_goalOptions.contains(trimmedGoal)) {
      _selectedGoal = trimmedGoal;
      _goalController.clear();
      return;
    }

    _selectedGoal = _customGoalOption;
    _goalController.text = trimmedGoal;
  }

  void _setSelectedSchedule(String schedule) {
    _selectedDays
      ..clear()
      ..addAll(parseScheduleDays(schedule));
    _scheduleTime = parseScheduleTime(schedule);
    _scheduleError = null;

    final totalMinutes = parseScheduleDurationMinutes(schedule);
    final hours = totalMinutes ~/ 60;
    final minutes = totalMinutes % 60;
    _durationHours = hours.clamp(0, 4).toInt();
    _durationMinutes = const [0, 15, 30, 45].contains(minutes) ? minutes : 0;
  }

  void _setMetricText(TextEditingController controller, double value) {
    controller.text = value > 0 ? _formatMetric(value) : '';
  }

  String _formatMetric(double value) {
    return value == value.roundToDouble()
        ? value.toStringAsFixed(0)
        : value.toString();
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
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _ageController.dispose();
    _goalController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    _bodyFatController.dispose();
    _waistController.dispose();
    _hipsController.dispose();
    _chestController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        title: Text(
          _assignedCoachId == null ? 'Choose Coach' : 'Update Details',
        ),
        actions: [
          IconButton(
            tooltip: 'Sign out',
            onPressed: _logout,
            icon: const Icon(Icons.logout_rounded),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_assignedCoachName != null &&
                    _assignedCoachName!.isNotEmpty)
                  _AssignedCoachBanner(coachName: _assignedCoachName!),
                if (_errorMessage != null) ...[
                  _ErrorBanner(message: _errorMessage!, onRetry: _load),
                  const SizedBox(height: 16),
                ],
                _SectionCard(
                  title: 'Your Details',
                  icon: Icons.assignment_ind_outlined,
                  children: [
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(labelText: 'Full Name'),
                      validator: (value) =>
                          _validateRequired(value, 'Please enter your name'),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(labelText: 'Email'),
                      keyboardType: TextInputType.emailAddress,
                      validator: _validateEmail,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _phoneController,
                      decoration: const InputDecoration(labelText: 'Phone'),
                      keyboardType: TextInputType.phone,
                      validator: (value) => _validateRequired(
                        value,
                        'Please enter your phone number',
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _ageController,
                            decoration: const InputDecoration(labelText: 'Age'),
                            keyboardType: TextInputType.number,
                            validator: _validateAge,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            initialValue: _selectedSex,
                            decoration: const InputDecoration(
                              labelText: 'Gender',
                            ),
                            items: _sexOptions
                                .map(
                                  (sex) => DropdownMenuItem(
                                    value: sex,
                                    child: Text(sex),
                                  ),
                                )
                                .toList(),
                            onChanged: (value) => setState(
                              () => _selectedSex = value ?? _sexOptions.first,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: _selectedGoal,
                      decoration: const InputDecoration(
                        labelText: 'Fitness Goal',
                      ),
                      items: _goalOptions
                          .map(
                            (goal) => DropdownMenuItem(
                              value: goal,
                              child: Text(goal),
                            ),
                          )
                          .toList(),
                      onChanged: (value) => setState(() {
                        _selectedGoal = value;
                        if (value != _customGoalOption) {
                          _goalController.clear();
                        }
                      }),
                      validator: (value) => value == null
                          ? 'Please select your fitness goal'
                          : null,
                    ),
                    if (_selectedGoal == _customGoalOption) ...[
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _goalController,
                        decoration: const InputDecoration(
                          labelText: 'Custom Fitness Goal',
                        ),
                        validator: (value) => _validateRequired(
                          value,
                          'Please enter your fitness goal',
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 16),
                _SectionCard(
                  title: 'Preferred Schedule',
                  icon: Icons.event_available_outlined,
                  children: [
                    ClientSchedulePicker(
                      selectedDays: _selectedDays,
                      selectedTime: _scheduleTime,
                      errorText: _scheduleError,
                      durationHours: _durationHours,
                      durationMinutes: _durationMinutes,
                      onDaysChanged: (days) => setState(() {
                        _selectedDays
                          ..clear()
                          ..addAll(days);
                      }),
                      onTimeChanged: (time) =>
                          setState(() => _scheduleTime = time),
                      onErrorChanged: (error) =>
                          setState(() => _scheduleError = error),
                      onDurationHoursChanged: (hours) =>
                          setState(() => _durationHours = hours),
                      onDurationMinutesChanged: (minutes) =>
                          setState(() => _durationMinutes = minutes),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _SectionCard(
                  title: 'Body Metrics',
                  icon: Icons.monitor_weight_outlined,
                  children: [
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
                    const SizedBox(height: 12),
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
                    const SizedBox(height: 12),
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
                  ],
                ),
                const SizedBox(height: 16),
                _SectionCard(
                  title: 'Available Coaches',
                  icon: Icons.sports_outlined,
                  children: [
                    if (_coaches.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: Text('No coaches are available yet.'),
                      )
                    else
                      ..._coaches.map(_buildCoachOption),
                  ],
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _isSaving || _coaches.isEmpty
                        ? null
                        : _chooseCoach,
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
                    label: Text(
                      _assignedCoachId == _selectedCoachId
                          ? 'Update Details'
                          : 'Choose Coach',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCoachOption(AppUserProfile coach) {
    final selected = coach.id == _selectedCoachId;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => setState(() => _selectedCoachId = coach.id),
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

class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;

  const _SectionCard({
    required this.title,
    required this.icon,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE2E8F0)),
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F0F172A),
            blurRadius: 24,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: const Color(0xFF1E40AF)),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  color: Color(0xFF0F172A),
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }
}

class _AssignedCoachBanner extends StatelessWidget {
  final String coachName;

  const _AssignedCoachBanner({required this.coachName});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFECFDF5),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFA7F3D0)),
      ),
      child: Row(
        children: [
          const Icon(Icons.verified_outlined, color: Color(0xFF047857)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Connected with $coachName',
              style: const TextStyle(
                color: Color(0xFF065F46),
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorBanner({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF1F2),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFFDA4AF)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Color(0xFFBE123C)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(color: Color(0xFF9F1239)),
            ),
          ),
          TextButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}
