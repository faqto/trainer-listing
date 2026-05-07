import 'package:flutter/material.dart';

import '../../models/client_model.dart';
import '../../routes/app_routes.dart';
import '../../services/client_repository.dart';

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
        subtitle: 'New session booked',
        time: 'Today • 10:00 AM',
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

  @override
  Widget build(BuildContext context) {
    final titles = ['Dashboard', 'Activity', 'Clients', 'Settings'];
    final bodies = [
      DashboardTab(
        clients: _clients,
        recentActivity: _recentActivities,
        onAddClient: _openAddClient,
        onViewAll: () => _setIndex(2),
      ),
      ActivityTab(activities: _recentActivities),
      ClientsTab(clients: _clients, onAddClient: _openAddClient),
      SettingsTab(onLogout: () => Navigator.pushReplacementNamed(context, AppRoutes.login)),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFEFF5FB),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF13294B),
        title: Text(titles[_selectedIndex]),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none),
            onPressed: () {},
          ),
        ],
      ),
      body: bodies[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _setIndex,
        selectedItemColor: const Color(0xFFFF8C42),
        unselectedItemColor: Colors.black54,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'Activity'),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Clients'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
        ],
      ),
    );
  }
}

class DashboardTab extends StatelessWidget {
  final List<Client> clients;
  final List<HomeActivity> recentActivity;
  final VoidCallback onAddClient;
  final VoidCallback onViewAll;

  const DashboardTab({
    super.key,
    required this.clients,
    required this.recentActivity,
    required this.onAddClient,
    required this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Eddio Fitness', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text('Trainer dashboard overview', style: TextStyle(color: Colors.black54)),
          const SizedBox(height: 24),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _DashboardMetricCard(label: 'Active Clients', value: clients.length.toString(), color: const Color(0xFF1544A2)),
              _DashboardMetricCard(label: 'Sessions Today', value: '8', color: const Color(0xFF1D8F8F)),
              _DashboardMetricCard(label: 'Avg. BMI', value: '24.1', color: const Color(0xFF8939B7)),
              _DashboardMetricCard(label: 'New Client', value: '2', color: const Color(0xFFF37021)),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: onAddClient,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF13294B),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  icon: const Icon(Icons.person_add),
                  label: const Text('Add Client'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onViewAll,
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFF13294B)),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  icon: const Icon(Icons.visibility),
                  label: const Text('View All'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text('Recent Activity', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Text('See all', style: TextStyle(color: Color(0xFF1544A2))),
            ],
          ),
          const SizedBox(height: 12),
          Column(
            children: recentActivity
                .map((activity) => _ActivityCard(activity: activity))
                .toList(),
          ),
        ],
      ),
    );
  }
}

class ActivityTab extends StatelessWidget {
  final List<HomeActivity> activities;

  const ActivityTab({super.key, required this.activities});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: activities.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        return _ActivityCard(activity: activities[index]);
      },
    );
  }
}

class ClientsTab extends StatefulWidget {
  final List<Client> clients;
  final VoidCallback onAddClient;

  const ClientsTab({super.key, required this.clients, required this.onAddClient});

  @override
  State<ClientsTab> createState() => _ClientsTabState();
}

class _ClientsTabState extends State<ClientsTab> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = widget.clients.where((client) {
      final lower = client.name.toLowerCase();
      return lower.contains(_searchQuery.toLowerCase());
    }).toList();

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  onChanged: (value) => setState(() => _searchQuery = value),
                  decoration: InputDecoration(
                    hintText: 'Search clients',
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              InkWell(
                onTap: widget.onAddClient,
                child: Container(
                  height: 56,
                  width: 56,
                  decoration: BoxDecoration(color: const Color(0xFFFF8C42), borderRadius: BorderRadius.circular(16)),
                  child: const Icon(Icons.add, color: Colors.white),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: filtered.isEmpty
                ? const Center(child: Text('No matching clients.'))
                : ListView.separated(
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final client = filtered[index];
                      return _ClientCard(client: client);
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class SettingsTab extends StatelessWidget {
  final VoidCallback onLogout;

  const SettingsTab({super.key, required this.onLogout});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text('Settings', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                SizedBox(height: 8),
                Text('Manage account preferences and sign out from the app.'),
              ],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: onLogout,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF8C42),
              minimumSize: const Size.fromHeight(56),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: const Text('Log Out', style: TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );
  }
}

class _DashboardMetricCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _DashboardMetricCard({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.43,
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(20)),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Colors.white70)),
          const SizedBox(height: 16),
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class _ActivityCard extends StatelessWidget {
  final HomeActivity activity;

  const _ActivityCard({required this.activity});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            height: 52,
            width: 52,
            decoration: BoxDecoration(
              color: activity.color.withAlpha((0.15 * 255).round()),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(activity.icon, color: activity.color),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(activity.name, style: const TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                Text(activity.subtitle, style: const TextStyle(color: Colors.black54)),
              ],
            ),
          ),
          Text(activity.time, style: const TextStyle(color: Colors.black45)),
        ],
      ),
    );
  }
}

class _ClientCard extends StatelessWidget {
  final Client client;

  const _ClientCard({required this.client});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, AppRoutes.clientInfo, arguments: client.id);
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
        child: Row(
          children: [
            CircleAvatar(
              radius: 26,
              backgroundColor: const Color(0xFF13294B),
              child: Text(client.name.isEmpty ? '?' : client.name[0], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(client.name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                  const SizedBox(height: 6),
                  Text(client.trainingProgram, style: const TextStyle(color: Colors.black54)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _StatusBadge(label: client.gender, color: Colors.indigoAccent),
                      const SizedBox(width: 8),
                      _StatusBadge(label: '${client.age} yrs', color: Colors.orangeAccent),
                    ],
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 18, color: Colors.black26),
          ],
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String label;
  final Color color;

  const _StatusBadge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withAlpha((0.14 * 255).round()),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(label, style: TextStyle(color: color.darken(), fontSize: 12, fontWeight: FontWeight.w600)),
    );
  }
}

class HomeActivity {
  final String name;
  final String subtitle;
  final String time;
  final IconData icon;
  final Color color;

  HomeActivity({
    required this.name,
    required this.subtitle,
    required this.time,
    required this.icon,
    required this.color,
  });
}

extension _ColorUtils on Color {
  Color darken([double amount = .2]) {
    final hsl = HSLColor.fromColor(this);
    return hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0)).toColor();
  }
}
