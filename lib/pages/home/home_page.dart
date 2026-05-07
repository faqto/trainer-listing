import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../models/client_model.dart';
import '../../routes/app_routes.dart';
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

  List<Client> get _clients => ClientRepository.instance.clients;

  List<HomeActivity> get _recentActivities {
    return _clients.map((client) {
      return HomeActivity(
        name: client.name,
        subtitle: client.goal,
        time: 'Joined ${client.joinDateLabel}',
        icon: Icons.timer,
        color: Colors.blueAccent,
      );
    }).toList();
  }

  void _setIndex(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<void> _openAddClient() async {
    final result = await Navigator.pushNamed(context, AppRoutes.addClient);
    if (result == true) {
      setState(() {});
    }
  }

  Future<void> _openClientDetails(String clientId) async {
    final result = await Navigator.pushNamed(
      context,
      AppRoutes.clientInfo,
      arguments: clientId,
    );
    if (result == true) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final titles = ['Dashboard', 'Plans', 'Clients', 'Settings'];
    final bodies = [
      DashboardTab(
        clients: _clients,
        recentActivity: _recentActivities,
        onAddClient: _openAddClient,
      ),
      PlansTab(clients: _clients, onOpenClient: _openClientDetails),
      ClientsTab(
        clients: _clients,
        onAddClient: _openAddClient,
        onOpenClient: _openClientDetails,
      ),
      SettingsTab(
        onLogout: () =>
            Navigator.pushReplacementNamed(context, AppRoutes.login),
      ),
    ];

    return Scaffold(
      backgroundColor: pageBackgroundColor,
      extendBody: true,
      body: NestedScrollView(
        physics: const BouncingScrollPhysics(),
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              pinned: true,
              expandedHeight: 104,
              stretch: false,
              backgroundColor: const Color(0xFF101827),
              toolbarHeight: 58,
              flexibleSpace: FlexibleSpaceBar(
                titlePadding: const EdgeInsetsDirectional.only(
                  start: space2,
                  bottom: 12,
                ),
                title: Text(
                  titles[_selectedIndex],
                  style: GoogleFonts.bebasNeue(
                    fontSize: 28,
                    letterSpacing: 0,
                    color: Colors.white,
                  ),
                ),
                background: Container(
                  decoration: const BoxDecoration(
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
  }
}
