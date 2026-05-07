import 'package:flutter/material.dart';

void main() {
  runApp(const TrainerApp());
}

class TrainerApp extends StatelessWidget {
  const TrainerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TrainWith',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: const ColorScheme.dark(
          surface: Color(0xFF0D0D0D),
          primary: Color(0xFFE8FF47),
          secondary: Color(0xFF2A2A2A),
          onSurface: Color(0xFFF5F5F5),
        ),
        fontFamily: 'Georgia',
        useMaterial3: true,
      ),
      home: const TrainerHomePage(),
    );
  }
}

// ─── Data Models ────────────────────────────────────────────────────────────

class Trainer {
  final String name;
  final String specialty;
  final String location;
  final double rating;
  final int reviews;
  final int experience;
  final double price;
  final String tag;
  final Color accentColor;

  const Trainer({
    required this.name,
    required this.specialty,
    required this.location,
    required this.rating,
    required this.reviews,
    required this.experience,
    required this.price,
    required this.tag,
    required this.accentColor,
  });
}

final List<Trainer> trainers = [
  Trainer(
    name: 'Elena Voss',
    specialty: 'Olympic Weightlifting',
    location: 'New York, NY',
    rating: 4.9,
    reviews: 312,
    experience: 8,
    price: 95,
    tag: 'TOP RATED',
    accentColor: const Color(0xFFE8FF47),
  ),
  Trainer(
    name: 'Marcus Reid',
    specialty: 'HIIT & Conditioning',
    location: 'Los Angeles, CA',
    rating: 4.8,
    reviews: 204,
    experience: 6,
    price: 75,
    tag: 'POPULAR',
    accentColor: const Color(0xFFFF6B35),
  ),
  Trainer(
    name: 'Saya Tanaka',
    specialty: 'Yoga & Mobility',
    location: 'Austin, TX',
    rating: 5.0,
    reviews: 189,
    experience: 10,
    price: 80,
    tag: 'PERFECT SCORE',
    accentColor: const Color(0xFF7FFFDB),
  ),
  Trainer(
    name: 'Daniel Osei',
    specialty: 'Powerlifting',
    location: 'Chicago, IL',
    rating: 4.7,
    reviews: 97,
    experience: 5,
    price: 70,
    tag: 'NEW',
    accentColor: const Color(0xFFD4A5FF),
  ),
  Trainer(
    name: 'Camila Torres',
    specialty: 'Pilates & Core',
    location: 'Miami, FL',
    rating: 4.9,
    reviews: 256,
    experience: 7,
    price: 85,
    tag: 'TOP RATED',
    accentColor: const Color(0xFFFFD166),
  ),
];

final List<String> categories = [
  'All',
  'Strength',
  'Cardio',
  'Yoga',
  'Pilates',
  'HIIT',
  'Mobility',
];

// ─── Home Page ───────────────────────────────────────────────────────────────

class TrainerHomePage extends StatefulWidget {
  const TrainerHomePage({super.key});

  @override
  State<TrainerHomePage> createState() => _TrainerHomePageState();
}

class _TrainerHomePageState extends State<TrainerHomePage>
    with TickerProviderStateMixin {
  int _selectedCategory = 0;
  late AnimationController _headerController;
  late Animation<double> _headerFade;

  @override
  void initState() {
    super.initState();
    _headerController = AnimationController(
      duration: const Duration(milliseconds: 900),
      vsync: this,
    )..forward();
    _headerFade = CurvedAnimation(
      parent: _headerController,
      curve: Curves.easeOut,
    );
  }

  @override
  void dispose() {
    _headerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // ── Top Bar ──
            SliverToBoxAdapter(child: _buildTopBar()),

            // ── Hero Header ──
            SliverToBoxAdapter(
              child: FadeTransition(
                opacity: _headerFade,
                child: _buildHeroHeader(),
              ),
            ),

            // ── Search Bar ──
            SliverToBoxAdapter(child: _buildSearchBar()),

            // ── Category Chips ──
            SliverToBoxAdapter(child: _buildCategories()),

            // ── Section Label ──
            SliverToBoxAdapter(child: _buildSectionLabel()),

            // ── Trainer Cards ──
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => _TrainerCard(trainer: trainers[index]),
                  childCount: trainers.length,
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 32)),
          ],
        ),
      ),

      // ── Bottom Nav ──
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  // ── Top Bar ──────────────────────────────────────────────────────────────

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        children: [
          // Logo
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0xFFE8FF47),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Text(
              'TW',
              style: TextStyle(
                color: Color(0xFF0D0D0D),
                fontWeight: FontWeight.w900,
                fontSize: 14,
                letterSpacing: 1,
              ),
            ),
          ),
          const SizedBox(width: 10),
          const Text(
            'TrainWith',
            style: TextStyle(
              color: Color(0xFFF5F5F5),
              fontWeight: FontWeight.w700,
              fontSize: 18,
              letterSpacing: -0.5,
            ),
          ),
          const Spacer(),
          _iconBtn(Icons.notifications_outlined),
          const SizedBox(width: 8),
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF2A2A2A),
              border: Border.all(color: const Color(0xFFE8FF47), width: 1.5),
            ),
            child: const Icon(
              Icons.person_outline,
              color: Color(0xFFE8FF47),
              size: 18,
            ),
          ),
        ],
      ),
    );
  }

  Widget _iconBtn(IconData icon) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(icon, color: const Color(0xFF888888), size: 18),
    );
  }

  // ── Hero Header ──────────────────────────────────────────────────────────

  Widget _buildHeroHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 28, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: RichText(
                  text: const TextSpan(
                    children: [
                      TextSpan(
                        text: 'Find your\n',
                        style: TextStyle(
                          color: Color(0xFFF5F5F5),
                          fontSize: 38,
                          fontWeight: FontWeight.w300,
                          height: 1.1,
                          letterSpacing: -1.5,
                        ),
                      ),
                      TextSpan(
                        text: 'perfect trainer.',
                        style: TextStyle(
                          color: Color(0xFFE8FF47),
                          fontSize: 38,
                          fontWeight: FontWeight.w800,
                          height: 1.1,
                          letterSpacing: -1.5,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Stats pill
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A1A),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFF2E2E2E)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text(
                      '2,400+',
                      style: TextStyle(
                        color: Color(0xFFE8FF47),
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Trainers',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.4),
                        fontSize: 11,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'Elite coaches, personalized programs.',
            style: TextStyle(
              color: Colors.white.withOpacity(0.45),
              fontSize: 14,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }

  // ── Search Bar ───────────────────────────────────────────────────────────

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFF2A2A2A)),
        ),
        child: Row(
          children: [
            const SizedBox(width: 16),
            Icon(Icons.search, color: Colors.white.withOpacity(0.35), size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Search by name, sport, location…',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.3),
                  fontSize: 14,
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFE8FF47),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'Filter',
                style: TextStyle(
                  color: Color(0xFF0D0D0D),
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.3,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Categories ───────────────────────────────────────────────────────────

  Widget _buildCategories() {
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: SizedBox(
        height: 36,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          itemCount: categories.length,
          itemBuilder: (context, index) {
            final selected = _selectedCategory == index;
            return GestureDetector(
              onTap: () => setState(() => _selectedCategory = index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: selected
                      ? const Color(0xFFE8FF47)
                      : const Color(0xFF1A1A1A),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: selected
                        ? const Color(0xFFE8FF47)
                        : const Color(0xFF2A2A2A),
                  ),
                ),
                child: Text(
                  categories[index],
                  style: TextStyle(
                    color: selected
                        ? const Color(0xFF0D0D0D)
                        : Colors.white.withOpacity(0.6),
                    fontSize: 13,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // ── Section Label ────────────────────────────────────────────────────────

  Widget _buildSectionLabel() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 28, 20, 16),
      child: Row(
        children: [
          const Text(
            'Featured Trainers',
            style: TextStyle(
              color: Color(0xFFF5F5F5),
              fontSize: 20,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.5,
            ),
          ),
          const Spacer(),
          Text(
            'See all →',
            style: TextStyle(
              color: const Color(0xFFE8FF47).withOpacity(0.8),
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // ── Bottom Nav ───────────────────────────────────────────────────────────

  Widget _buildBottomNav() {
    return Container(
      height: 72,
      decoration: const BoxDecoration(
        color: Color(0xFF111111),
        border: Border(top: BorderSide(color: Color(0xFF1E1E1E))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _navItem(Icons.home_rounded, 'Home', true),
          _navItem(Icons.search_rounded, 'Explore', false),
          _navItem(Icons.calendar_today_rounded, 'Schedule', false),
          _navItem(Icons.person_outline_rounded, 'Profile', false),
        ],
      ),
    );
  }

  Widget _navItem(IconData icon, String label, bool active) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          icon,
          color: active
              ? const Color(0xFFE8FF47)
              : Colors.white.withOpacity(0.3),
          size: 22,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: active
                ? const Color(0xFFE8FF47)
                : Colors.white.withOpacity(0.3),
            fontSize: 10,
            fontWeight: active ? FontWeight.w700 : FontWeight.w400,
          ),
        ),
      ],
    );
  }
}

// ─── Trainer Card ────────────────────────────────────────────────────────────

class _TrainerCard extends StatelessWidget {
  final Trainer trainer;

  const _TrainerCard({required this.trainer});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF141414),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF202020)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () {},
        splashColor: trainer.accentColor.withOpacity(0.05),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar block
              _buildAvatar(),
              const SizedBox(width: 14),

              // Info block
              Expanded(child: _buildInfo()),

              // Price block
              _buildPriceBlock(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    final initials = trainer.name.split(' ').map((e) => e[0]).take(2).join();

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                trainer.accentColor.withOpacity(0.25),
                trainer.accentColor.withOpacity(0.05),
              ],
            ),
            border: Border.all(
              color: trainer.accentColor.withOpacity(0.3),
              width: 1.5,
            ),
          ),
          child: Center(
            child: Text(
              initials,
              style: TextStyle(
                color: trainer.accentColor,
                fontSize: 20,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
              ),
            ),
          ),
        ),
        // Tag badge
        Positioned(
          top: -6,
          left: -6,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
            decoration: BoxDecoration(
              color: trainer.accentColor,
              borderRadius: BorderRadius.circular(5),
            ),
            child: Text(
              trainer.tag,
              style: const TextStyle(
                color: Color(0xFF0D0D0D),
                fontSize: 7,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          trainer.name,
          style: const TextStyle(
            color: Color(0xFFF5F5F5),
            fontSize: 16,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          trainer.specialty,
          style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 13),
        ),
        const SizedBox(height: 8),
        // Rating + location row
        Row(
          children: [
            Icon(Icons.star_rounded, color: trainer.accentColor, size: 14),
            const SizedBox(width: 3),
            Text(
              trainer.rating.toString(),
              style: TextStyle(
                color: trainer.accentColor,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              '  (${trainer.reviews})',
              style: TextStyle(
                color: Colors.white.withOpacity(0.35),
                fontSize: 12,
              ),
            ),
            const SizedBox(width: 10),
            Icon(
              Icons.location_on_outlined,
              color: Colors.white.withOpacity(0.3),
              size: 12,
            ),
            const SizedBox(width: 2),
            Expanded(
              child: Text(
                trainer.location,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.35),
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        // Exp chip
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E1E),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            '${trainer.experience} yrs exp',
            style: TextStyle(
              color: Colors.white.withOpacity(0.55),
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPriceBlock() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: '\$${trainer.price.toInt()}',
                style: const TextStyle(
                  color: Color(0xFFF5F5F5),
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),
              TextSpan(
                text: '/hr',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.35),
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            color: const Color(0xFFE8FF47),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Text(
            'Book',
            style: TextStyle(
              color: Color(0xFF0D0D0D),
              fontSize: 12,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.3,
            ),
          ),
        ),
      ],
    );
  }
}
