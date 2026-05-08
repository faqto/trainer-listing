import 'dart:ui';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../models/client_model.dart';
import '../../routes/app_routes.dart';
import '../../services/auth_repository.dart';
import '../../services/client_repository.dart';
import 'clients_tab.dart';
import 'dashboard_tab.dart';
import 'home_constants.dart';
import 'home_models.dart';
import 'plans_tab.dart';
import 'settings_tab.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  late Future<List<Client>> _clientsFuture;

  @override
  void initState() {
    super.initState();
    _loadClients();
  }

  Future<void> _loadClients() async {
    setState(() {
      _clientsFuture = ClientRepository.instance.clients;
    });
  }

  void _setIndex(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<void> _openAddClient() async {
    final result = await Navigator.pushNamed(context, AppRoutes.addClient);
    if (result == true) {
      _loadClients();
    }
  }

  Future<void> _openClientDetails(String clientId) async {
    final result = await Navigator.pushNamed(
      context,
      AppRoutes.clientInfo,
      arguments: clientId,
    );
    if (result == true) {
      _loadClients();
    }
  }

  Future<void> _logout() async {
    await AuthRepository.instance.signOut();
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, AppRoutes.login);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Client>>(
      future: _clientsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasError) {
          return Scaffold(
            body: _HomeLoadError(
              message: _clientLoadErrorMessage(snapshot.error),
              onRetry: _loadClients,
              onLogout: _logout,
            ),
          );
        }
        final clients = snapshot.data ?? [];
        final recentActivities = clients.map((client) {
          return HomeActivity(
            name: client.name,
            subtitle: client.goal,
            time: 'Joined ${client.joinDateLabel}',
            icon: Icons.timer,
            color: Colors.blueAccent,
          );
        }).toList();

        final titles = ['Dashboard', 'Plans', 'Clients', 'Settings'];
        final bodies = [
          DashboardTab(
            clients: clients,
            recentActivity: recentActivities,
            trainerName: AuthRepository.instance.currentUserName,
            onAddClient: _openAddClient,
          ),
          PlansTab(clients: clients, onOpenClient: _openClientDetails),
          ClientsTab(
            clients: clients,
            onAddClient: _openAddClient,
            onOpenClient: _openClientDetails,
          ),
          SettingsTab(onLogout: _logout),
        ];

        return Scaffold(
          backgroundColor: pageBackgroundColor,
          extendBody: false,
          body: NestedScrollView(
            physics: const BouncingScrollPhysics(),
            headerSliverBuilder: (context, innerBoxIsScrolled) {
              return [
                SliverAppBar(
                  pinned: true,
                  automaticallyImplyLeading: false,
                  expandedHeight: 86,
                  stretch: false,
                  backgroundColor: const Color(0xFF101827),
                  toolbarHeight: 56,
                  titleSpacing: space2,
                  title: Text(
                    titles[_selectedIndex],
                    style: GoogleFonts.bebasNeue(
                      fontSize: 28,
                      letterSpacing: 0,
                      color: Colors.white,
                    ),
                  ),
                  flexibleSpace: const FlexibleSpaceBar(
                    background: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color(0xFF111827),
                            Color(0xFF164E63),
                            Color(0xFF1E3A8A),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ];
            },
            body: AnimatedSwitcher(
              duration: const Duration(milliseconds: 260),
              switchInCurve: Curves.easeOutCubic,
              switchOutCurve: Curves.easeInCubic,
              child: KeyedSubtree(
                key: ValueKey(_selectedIndex),
                child: bodies[_selectedIndex],
              ),
            ),
          ),
          bottomNavigationBar: SafeArea(
            minimum: const EdgeInsets.fromLTRB(space2, 0, space2, space2),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(22),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha((0.78 * 255).round()),
                    border: Border.all(color: Colors.white.withAlpha(150)),
                    boxShadow: premiumCardShadows,
                  ),
                  child: BottomNavigationBar(
                    type: BottomNavigationBarType.fixed,
                    elevation: 0,
                    backgroundColor: Colors.transparent,
                    currentIndex: _selectedIndex,
                    onTap: _setIndex,
                    selectedItemColor: primaryColor,
                    unselectedItemColor: mutedColor,
                    items: const [
                      BottomNavigationBarItem(
                        icon: Icon(Icons.home),
                        label: 'Home',
                      ),
                      BottomNavigationBarItem(
                        icon: Icon(Icons.assignment),
                        label: 'Plans',
                      ),
                      BottomNavigationBarItem(
                        icon: Icon(Icons.people),
                        label: 'Clients',
                      ),
                      BottomNavigationBarItem(
                        icon: Icon(Icons.settings),
                        label: 'Settings',
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  String _clientLoadErrorMessage(Object? error) {
    if (error is FirebaseException) {
      switch (error.code) {
        case 'permission-denied':
          return 'Firestore blocked client access. Update your Firestore rules for signed-in users.';
        case 'unauthenticated':
          return 'Please sign in again before loading clients.';
        case 'not-found':
          return 'Firestore database was not found for this Firebase project.';
        default:
          return error.message ?? 'Unable to load clients.';
      }
    }

    return 'Unable to load clients: $error';
  }
}

class _HomeLoadError extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  final VoidCallback onLogout;

  const _HomeLoadError({
    required this.message,
    required this.onRetry,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 460),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.lock_outline_rounded,
                color: primaryColor,
                size: 44,
              ),
              const SizedBox(height: 16),
              const Text(
                'Client access is blocked',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: inkColor,
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(color: mutedColor, height: 1.4),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: onLogout,
                      child: const Text('Sign Out'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: onRetry,
                      child: const Text('Retry'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
