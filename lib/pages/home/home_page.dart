import 'dart:ui';

import 'package:flutter/material.dart';

import '../../helpers/firebase_error_messages.dart';
import '../../models/activity_event.dart';
import '../../models/client_model.dart';
import '../../models/home_activity.dart';
import '../../routes/app_routes.dart';
import '../../services/activity_repository.dart';
import '../../services/auth_repository.dart';
import '../../services/client_repository.dart';
import '../../widgets/home/home_load_error.dart';
import 'clients_tab.dart';
import 'dashboard_tab.dart';
import 'home_constants.dart';
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
  late Future<List<ActivityEvent>> _activityFuture;

  @override
  void initState() {
    super.initState();
    _loadClients();
  }

  Future<void> _loadClients() async {
    setState(() {
      _clientsFuture = ClientRepository.instance.clients;
      _activityFuture = ActivityRepository.instance.getRecent();
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
    return FutureBuilder<(List<Client>, List<ActivityEvent>)>(
      future: Future.wait([_clientsFuture, _activityFuture]).then(
        (results) =>
            (results[0] as List<Client>, results[1] as List<ActivityEvent>),
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasError) {
          return Scaffold(
            body: HomeLoadError(
              message: clientLoadErrorMessage(snapshot.error),
              onRetry: _loadClients,
              onLogout: _logout,
            ),
          );
        }
        final clients = snapshot.data?.$1 ?? [];
        final activityEvents = snapshot.data?.$2 ?? [];

        // Check for missed sessions after data loads
        WidgetsBinding.instance.addPostFrameCallback((_) async {
          await ActivityRepository.instance.checkAndLogMissedSessions(clients);
        });

        final recentActivities = activityEvents.map((event) {
          return HomeActivity(
            name: event.clientName,
            subtitle: event.description,
            time: event.timeAgoLabel,
            icon: event.icon,
            color: event.color,
            event: event,
          );
        }).toList();

        final titles = ['Dashboard', 'Plans', 'Clients', 'Settings'];
        final bodies = [
          DashboardTab(
            clients: clients,
            recentActivity: recentActivities,
            trainerName: AuthRepository.instance.currentUserName,
            onAddClient: _openAddClient,
            onActivityResolved: _loadClients,
            onOpenClient: (id) => _openClientDetails(id),
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
                  floating: true,
                  snap: true,
                  automaticallyImplyLeading: false,
                  expandedHeight: 86,
                  stretch: false,
                  backgroundColor: const Color(0xFF101827),
                  toolbarHeight: 56,
                  titleSpacing: space2,
                  title: Text(
                    titles[_selectedIndex],
                    style: const TextStyle(
                      fontFamily: 'BarlowCondensed',
                      fontSize: 28,
                      letterSpacing: 0,
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
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
}
