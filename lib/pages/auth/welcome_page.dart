import 'package:flutter/material.dart';
import '../../models/user_role.dart';
import '../../routes/app_routes.dart';
import '../../services/auth_repository.dart';

enum WelcomeType { newUser, returningUser }

class WelcomePage extends StatefulWidget {
  final WelcomeType type;

  const WelcomePage({super.key, required this.type});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;
  UserRole? _role;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnim = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.12),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    _controller.forward();

    _routeAfterWelcome();
  }

  Future<void> _routeAfterWelcome() async {
    final role = await AuthRepository.instance.loadCurrentUserRole().catchError(
      (_) => UserRole.coach,
    );
    if (!mounted) return;
    setState(() => _role = role);

    await Future.delayed(const Duration(milliseconds: 2500));
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(
      context,
      role == UserRole.client ? AppRoutes.clientHome : AppRoutes.home,
      (route) => false,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final name = AuthRepository.instance.currentUserName;
    final isNew = widget.type == WelcomeType.newUser;
    final role = _role ?? AuthRepository.instance.currentUserRole;
    final roleLabel = role?.label ?? 'Member';

    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF111827), Color(0xFF164E63), Color(0xFF1E3A8A)],
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnim,
            child: SlideTransition(
              position: _slideAnim,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Icon(
                        isNew
                            ? Icons.celebration_rounded
                            : Icons.waving_hand_rounded,
                        color: Colors.white,
                        size: 40,
                      ),
                    ),
                    const SizedBox(height: 28),
                    Text(
                      isNew ? 'Welcome,' : 'Welcome back,',
                      style: const TextStyle(
                        fontFamily: 'NunitoSans',
                        color: Colors.white60,
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '$roleLabel $name',
                      style: const TextStyle(
                        fontFamily: 'BarlowCondensed',
                        color: Colors.white,
                        fontSize: 48,
                        fontWeight: FontWeight.w700,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      isNew
                          ? role == UserRole.client
                                ? 'Your client profile is ready.\nChoose a coach to get started.'
                                : 'Your coach workspace is ready.\nLet\'s get started!'
                          : role == UserRole.client
                          ? 'Good to see you again.\nYour coach connection is waiting.'
                          : 'Good to see you again.\nYour clients are waiting.',
                      style: const TextStyle(
                        fontFamily: 'NunitoSans',
                        color: Colors.white60,
                        fontSize: 16,
                        height: 1.6,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
