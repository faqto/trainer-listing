import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'welcome_page.dart';
import 'package:trainer_listing/widgets/register_page/register_field.dart';
import 'package:trainer_listing/widgets/register_page/register_footer.dart';
import 'package:trainer_listing/widgets/register_page/register_header.dart';
import 'package:trainer_listing/widgets/register_page/register_password_field.dart';
import 'package:trainer_listing/widgets/register_page/register_password_hint.dart';
import 'package:trainer_listing/widgets/register_page/register_section_header.dart';
import 'package:trainer_listing/widgets/register_page/register_submit_button.dart';

import '../../routes/app_routes.dart';
import '../../services/auth_repository.dart';
import '../../widgets/confirmation_dialog/confirmation_dialog.dart';

const String _privacyPolicyText = '''
Privacy Policy for FitED

Effective Date: May 16, 2026

1. Scope of Service

FitED is a cloud-hosted utility mobile application designed exclusively for professional fitness trainers to record, track, and monitor the physical progress of their individual clients.

Important: This App is built for operational use by Trainers only. Clients do not hold user accounts, login credentials, or direct interface access to the application or the cloud infrastructure.

2. Data Collection & Sensitive Physical Metrics

The application processes personal fitness and biometric performance metrics entered exclusively by the authenticated Trainer. This data includes:

Progress Metrics: Body weight, body fat percentage, and precise anthropometric physical measurements.

Performance Logs: Comprehensive historical logs of physical workouts, including weights, sets, repetitions, and timestamps.

3. Data Storage & Cloud Infrastructure (Firebase)

All information entered into the application is transmitted to and stored on a secure cloud database managed through Google Firebase.

Data is synchronized in real-time across the Trainer's authenticated devices.

While the data is securely hosted within Firebase cloud architecture (utilizing encryption protocols for data both in transit and at rest), the application developer operates as the Data Controller responsible for the database backend.

4. Mandatory Client Consent Framework

Because physical metrics constitute sensitive health-adjacent information under modern data protection laws (such as GDPR and state-level privacy acts), FitED strictly prohibits unauthorized data logging.

The Consent Gate: Before a Trainer can initialize a new profile or upload a client's physical metrics to the Firebase database, the client must be presented with the in-app disclosure screen.

The client must physically review the terms on the Trainer's device and check the digital authorization box.

The app logs this explicit consent (consentGranted = true) along with a timestamp into Firebase before unlocking the profile data-entry interface.

5. Data Subject Rights (Access & Erasure)

Even though clients do not possess direct login accounts to the FitED platform, they retain full legal rights over their personal data stored in our database:

Right to Deletion (The Right to be Forgotten): A client may demand the permanent removal of their fitness history at any time.

Execution: A client can exercise this right by instructing their Trainer to delete their profile directly inside the application UI, or by emailing the developer support desk at support@fitedapp.com. Upon receiving a request via support, the developer will manually purge all associated document blocks from the Firebase database within standard regulatory timelines.

6. Data Sharing & Security Commitments

We strictly enforce data minimization principles. We do not sell, rent, lease, or share client progress profiles or trainer data with third-party advertising brokers or commercial marketing networks. Data is utilized strictly to render performance progress charts and visualizations for the tracking trainer.

7. Contact Us

For any privacy inquiries, data access requests, or urgent profile deletion requirements, please contact: Email: support@fitedapp.com
''';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _initialController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _acceptedPrivacyPolicy = false;
  bool _showPrivacyPolicyError = false;
  bool _isLoading = false;

  Future<void> _register() async {
    if (!_acceptedPrivacyPolicy) {
      setState(() => _showPrivacyPolicyError = true);
      return;
    }

    if (!_formKey.currentState!.validate()) return;
    final fullName = _buildFullName();
    if (!await ConfirmationDialog.show(
      context: context,
      title: 'Confirm Account Creation',
      content: 'Create a new trainer account for $fullName?',
      confirmText: 'Create Account',
    )) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      await AuthRepository.instance.register(
        name: fullName,
        email: _emailController.text.trim(),
        password: _passwordController.text,
        lastName: _lastNameController.text.trim(),
      );
      if (!mounted) return;
      Navigator.pushReplacementNamed(
        context,
        AppRoutes.welcome,
        arguments: WelcomeType.newUser,
      );
    } on FirebaseAuthException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_authErrorMessage(error)),
          behavior: SnackBarBehavior.floating,
          backgroundColor: const Color(0xFF1E293B),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _buildFullName() {
    final firstName = _capitalize(_firstNameController.text.trim());
    final lastName = _capitalize(_lastNameController.text.trim());
    final initial = _initialController.text.trim().toUpperCase();
    return initial.isNotEmpty
        ? '$lastName, $firstName $initial.'
        : '$lastName, $firstName';
  }

  String _capitalize(String value) {
    if (value.isEmpty) return value;
    return value
        .split(RegExp(r'\s+'))
        .map(
          (word) => word.isEmpty
              ? word
              : word[0].toUpperCase() + word.substring(1).toLowerCase(),
        )
        .join(' ');
  }

  String _authErrorMessage(FirebaseAuthException error) {
    switch (error.code) {
      case 'email-already-in-use':
        return 'An account already exists for this email.';
      case 'invalid-email':
        return 'Enter a valid email address.';
      case 'weak-password':
        return 'Use a password with at least 6 characters.';
      case 'operation-not-allowed':
        return 'Email/password sign-up is not enabled.';
      default:
        return error.message ?? 'Unable to create account. Please try again.';
    }
  }

  Future<void> _showPrivacyPolicy() async {
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('FitED Privacy Policy'),
        content: const SingleChildScrollView(
          child: Text(
            _privacyPolicyText,
            style: TextStyle(height: 1.35),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _initialController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Column(
              children: [
                const RegisterHeader(),
                const SizedBox(height: 24),
                _buildFormCard(),
                const SizedBox(height: 20),
                const RegisterFooter(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFormCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withOpacity(0.06),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const RegisterSectionHeader(
              icon: Icons.person_outline_rounded,
              label: 'Personal information',
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: RegisterField(
                          controller: _firstNameController,
                          label: 'First name',
                          icon: Icons.badge_outlined,
                          validator: (v) =>
                              (v == null || v.isEmpty) ? 'Required' : null,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: RegisterField(
                          controller: _lastNameController,
                          label: 'Last name',
                          icon: Icons.badge_outlined,
                          validator: (v) =>
                              (v == null || v.isEmpty) ? 'Required' : null,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: RegisterField(
                          controller: _initialController,
                          label: 'Middle initial',
                          icon: Icons.short_text_rounded,
                          maxLength: 2,
                        ),
                      ),
                      const Spacer(flex: 3),
                    ],
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: Color(0xFFE2E8F0)),
            const RegisterSectionHeader(
              icon: Icons.lock_outline_rounded,
              label: 'Account credentials',
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
              child: Column(
                children: [
                  RegisterField(
                    controller: _emailController,
                    label: 'Email address',
                    icon: Icons.mail_outline_rounded,
                    keyboardType: TextInputType.emailAddress,
                    validator: (v) {
                      final email = v?.trim() ?? '';
                      if (email.isEmpty) return 'Please enter your email';
                      if (!email.contains('@')) return 'Enter a valid email';
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  RegisterPasswordField(controller: _passwordController),
                  const SizedBox(height: 8),
                  const RegisterPasswordHint(),
                  const SizedBox(height: 18),
                  _buildPrivacyConsent(),
                  const SizedBox(height: 18),
                  RegisterSubmitButton(
                    isLoading: _isLoading,
                    onPressed: _register,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPrivacyConsent() {
    final showError = _showPrivacyPolicyError && !_acceptedPrivacyPolicy;
    final borderColor = showError
        ? const Color(0xFFEF4444)
        : const Color(0xFFE2E8F0);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      decoration: BoxDecoration(
        color: showError ? const Color(0xFFFFF1F2) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor, width: showError ? 1.8 : 1.2),
        boxShadow: showError
            ? [
                BoxShadow(
                  color: const Color(0xFFEF4444).withOpacity(0.28),
                  blurRadius: 16,
                  spreadRadius: 1,
                ),
              ]
            : null,
      ),
      child: CheckboxListTile(
        value: _acceptedPrivacyPolicy,
        onChanged: _isLoading
            ? null
            : (value) {
                setState(() {
                  _acceptedPrivacyPolicy = value ?? false;
                  if (_acceptedPrivacyPolicy) {
                    _showPrivacyPolicyError = false;
                  }
                });
              },
        activeColor: const Color(0xFF1E40AF),
        checkColor: Colors.white,
        controlAffinity: ListTileControlAffinity.leading,
        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        title: const Text(
          'I have read the FitED Privacy Policy and consent to FitED recording '
          'and storing my account information.',
          style: TextStyle(
            fontSize: 13,
            height: 1.35,
            color: Color(0xFF334155),
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextButton(
              onPressed: _showPrivacyPolicy,
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: const Size(0, 32),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                foregroundColor: const Color(0xFF1E40AF),
                textStyle: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
              child: const Text('View Privacy Policy'),
            ),
            if (showError)
              const Padding(
                padding: EdgeInsets.only(bottom: 4),
                child: Text(
                  'Please check this box before creating your account.',
                  style: TextStyle(
                    color: Color(0xFFDC2626),
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
