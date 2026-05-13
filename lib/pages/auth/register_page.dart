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
  bool _isLoading = false;

  Future<void> _register() async {
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
                  const SizedBox(height: 24),
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
}
