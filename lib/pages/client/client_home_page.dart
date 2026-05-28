import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../helpers/client_page_helpers.dart';
import '../../models/app_user_profile.dart';
import '../../models/client_model.dart';
import '../../routes/app_routes.dart';
import '../../services/auth_repository.dart';
import '../../services/user_repository.dart';
import '../../widgets/client/client_home_page/assigned_coach_banner.dart';
import '../../widgets/client/client_home_page/body_metrics_section.dart';
import '../../widgets/client/client_home_page/choose_coach_button.dart';
import '../../widgets/client/client_home_page/client_details_section.dart';
import '../../widgets/client/client_home_page/coach_picker_section.dart';
import '../../widgets/client/client_home_page/error_banner.dart';
import '../../widgets/client/client_home_page/section_card.dart';
import '../../widgets/clients/client_schedule_picker.dart';

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
  final _coachSearchController = TextEditingController();

  List<AppUserProfile> _coaches = [];
  String _coachSearchQuery = '';
  String? _selectedCoachId;
  String? _assignedCoachId;
  String? _assignedCoachName;
  String _selectedSex = ClientDetailsSection.sexOptions.first;
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
        _selectedSex = ClientDetailsSection.sexOptions.contains(profile?.sex)
            ? profile!.sex
            : ClientDetailsSection.sexOptions.first;
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
      setState(
        () => _errorMessage = 'Unable to load coaches. Please try again.',
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
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
      final goal = _selectedGoal == ClientDetailsSection.customGoalOption
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

  List<AppUserProfile> get _filteredCoaches {
    final query = _coachSearchQuery.trim().toLowerCase();
    if (query.isEmpty) return _coaches;
    return _coaches.where((coach) {
      return coach.name.toLowerCase().contains(query) ||
          coach.email.toLowerCase().contains(query);
    }).toList();
  }

  void _setSelectedGoal(String goal) {
    final trimmed = goal.trim();
    if (trimmed.isEmpty) {
      _selectedGoal = null;
      _goalController.clear();
      return;
    }
    if (trimmed.startsWith('Others:')) {
      _selectedGoal = ClientDetailsSection.customGoalOption;
      _goalController.text = trimmed.replaceFirst('Others:', '').trim();
      return;
    }
    if (ClientDetailsSection.goalOptions.contains(trimmed)) {
      _selectedGoal = trimmed;
      _goalController.clear();
      return;
    }
    _selectedGoal = ClientDetailsSection.customGoalOption;
    _goalController.text = trimmed;
  }

  void _setSelectedSchedule(String schedule) {
    _selectedDays
      ..clear()
      ..addAll(parseScheduleDays(schedule));
    _scheduleTime = parseScheduleTime(schedule);
    _scheduleError = null;
    final totalMinutes = parseScheduleDurationMinutes(schedule);
    _durationHours = (totalMinutes ~/ 60).clamp(0, 4).toInt();
    final minutes = totalMinutes % 60;
    _durationMinutes = const [0, 15, 30, 45].contains(minutes) ? minutes : 0;
  }

  void _setMetricText(TextEditingController controller, double value) {
    controller.text = value > 0
        ? (value == value.roundToDouble()
              ? value.toStringAsFixed(0)
              : value.toString())
        : '';
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
    _coachSearchController.dispose();
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
                  AssignedCoachBanner(coachName: _assignedCoachName!),
                if (_errorMessage != null) ...[
                  ErrorBanner(message: _errorMessage!, onRetry: _load),
                  const SizedBox(height: 16),
                ],
                ClientDetailsSection(
                  nameController: _nameController,
                  emailController: _emailController,
                  phoneController: _phoneController,
                  ageController: _ageController,
                  goalController: _goalController,
                  selectedSex: _selectedSex,
                  selectedGoal: _selectedGoal,
                  onSexChanged: (value) => setState(
                    () => _selectedSex =
                        value ?? ClientDetailsSection.sexOptions.first,
                  ),
                  onGoalChanged: (value) => setState(() {
                    _selectedGoal = value;
                    if (value != ClientDetailsSection.customGoalOption) {
                      _goalController.clear();
                    }
                  }),
                ),
                const SizedBox(height: 16),
                SectionCard(
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
                BodyMetricsSection(
                  weightController: _weightController,
                  heightController: _heightController,
                  bodyFatController: _bodyFatController,
                  waistController: _waistController,
                  hipsController: _hipsController,
                  chestController: _chestController,
                ),
                const SizedBox(height: 16),
                CoachPickerSection(
                  coaches: _coaches,
                  filteredCoaches: _filteredCoaches,
                  selectedCoachId: _selectedCoachId,
                  searchController: _coachSearchController,
                  onSearchChanged: (value) =>
                      setState(() => _coachSearchQuery = value),
                  onCoachSelected: (id) =>
                      setState(() => _selectedCoachId = id),
                ),
                const SizedBox(height: 24),
                ChooseCoachButton(
                  isSaving: _isSaving,
                  hasCoaches: _coaches.isNotEmpty,
                  isUpdating: _assignedCoachId == _selectedCoachId,
                  onPressed: _chooseCoach,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
