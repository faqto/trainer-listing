import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:trainer_listing/models/client_model.dart';
import 'package:trainer_listing/widgets/activity_tile.dart';

import '../clients/clients_list_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int currentIndex = 0;

  final List<Widget> pages = [const HomeContent(), const ClientsListPage()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('FitEd Trainer'), centerTitle: true),

      body: pages[currentIndex],

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,

        onTap: (index) {
          setState(() {
            currentIndex = index;
          });
        },

        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),

          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Clients'),
        ],
      ),
    );
  }
}

class HomeContent extends StatelessWidget {
  const HomeContent({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            const Text(
              'Welcome Trainer 👋',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            const Text(
              'Manage your clients and track their fitness progress.',
              style: TextStyle(fontSize: 16),
            ),

            const SizedBox(height: 25),

            const Text(
              'Quick Actions',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                SizedBox(
                  width: 160,
                  height: 100,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // Add client page
                    },
                    icon: const Icon(Icons.person_add),
                    label: const Text('Add Client'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                SizedBox(
                  width: 160,
                  height: 100,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // analytics / progress page
                    },
                    icon: const Icon(Icons.analytics),
                    label: const Text('Progress'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 30),

            // HEADER
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,

              children: [
                const Text(
                  'Recent Activity',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),

                TextButton(
                  onPressed: () {
                    // view all page
                  },

                  child: const Text('See All'),
                ),
              ],
            ),

            const SizedBox(height: 10),

            // LIST
            ListView.builder(
              itemCount: 5,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),

              itemBuilder: (context, index) {
                final client = recentActivities[index];

                return ActivityTile(
                  client: client,

                  onTap: () {
                    // open client information page
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }
}
