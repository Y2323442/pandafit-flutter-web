import 'package:flutter/material.dart';

class GrowPage extends StatefulWidget {
  const GrowPage({super.key});

  @override
  State<GrowPage> createState() => _GrowPageState();
}

class _GrowPageState extends State<GrowPage> {
  static const Color bgColor = Color(0xFFF1F8E9);
  static const Color mainGreen = Color(0xFFD1E683);
  static const Color darkCard = Color(0xFF000000);

  String _selectedTab = 'Daily';
  final List<String> _tabs = <String>['Daily', 'Weekly', 'Monthly', 'Quarterly'];
  final PageController _galleryController = PageController();

  bool _loading = false;
  String? _error;
  int _galleryIndex = 0;

  // 纯前端假数据
  final Map<String, dynamic> userData = {
    "streakDays": 7,
    "xp": 120,
    "level": 5,
    "totalSignInDays": 30,
  };

  final Map<String, dynamic> weeklySummary = {
    "totalMinutes": 180,
    "totalDistance": 12.5,
    "signedDays": 6,
    "completionRate": 85.0,
  };

  final Map<String, dynamic> todayProgress = {
    "steps": 8500,
    "workoutMinutes": 45,
    "calories": 320,
    "distanceKm": 6.2,
  };

  @override
  void dispose() {
    _galleryController.dispose();
    super.dispose();
  }

  Future<void> _loadData({bool showLoader = true}) async {
    setState(() => _loading = showLoader);
    await Future.delayed(const Duration(milliseconds: 300));
    setState(() => _loading = false);
  }

  Future<void> _updateTodayProgress() async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Progress saved (offline demo)")),
    );
  }

  Future<void> _signInToday() async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Signed in successfully (offline demo)")),
    );
  }

  Future<void> _pickImage() async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Photo uploaded (offline demo)")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => _loadData(showLoader: false),
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            children: <Widget>[
              const SizedBox(height: 20),
              const Text(
                'Grow',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Track today, keep your streak alive, and upload workout photos.',
                style: TextStyle(color: Colors.black54),
              ),
              const SizedBox(height: 25),
              _buildTimeTabs(),
              const SizedBox(height: 25),
              if (_loading)
                const Padding(
                  padding: EdgeInsets.only(top: 80),
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (_error != null)
                _buildErrorCard()
              else ...<Widget>[
                _buildKeepItUpCard(),
                const SizedBox(height: 20),
                _buildImageGallery(),
                const SizedBox(height: 20),
                _buildMetricsSection(),
                const SizedBox(height: 20),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimeTabs() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: _tabs.map((tab) {
        final isSelected = _selectedTab == tab;
        return _ScaleTap(
          onTap: () => setState(() => _selectedTab = tab),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            decoration: BoxDecoration(
              color: isSelected ? mainGreen : Colors.white,
              shape: BoxShape.circle,
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Text(
              tab,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildKeepItUpCard() {
    final messages = <String>[
      'Streak: 7 days\nStay consistent today.',
      'This week: 180 minutes\nKeep your momentum strong.',
      'XP: 120\nYour progress is saved locally.',
      'Level: 5\nGreat job!',
    ];

    return Container(
      height: 180,
      decoration: BoxDecoration(
        color: darkCard,
        borderRadius: BorderRadius.circular(40),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const Text(
                    'Keep It Up',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    messages[_tabMessageIndex],
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.emoji_events, color: Colors.amber, size: 70),
          ],
        ),
      ),
    );
  }

  int get _tabMessageIndex {
    switch (_selectedTab) {
      case 'Weekly':
        return 1;
      case 'Monthly':
        return 2;
      case 'Quarterly':
        return 3;
      default:
        return 0;
    }
  }

  Widget _buildImageGallery() {
    return Stack(
      children: <Widget>[
        SizedBox(
          height: 220,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(40),
            child: PageView.builder(
              controller: _galleryController,
              onPageChanged: (index) => setState(() => _galleryIndex = index),
              itemCount: 1,
              itemBuilder: (context, index) {
                return Container(
                  color: mainGreen.withOpacity(0.3),
                  child: const Icon(Icons.image, size: 50, color: Colors.black26),
                );
              },
            ),
          ),
        ),
        Positioned(
          top: 20,
          left: 20,
          child: Row(
            children: List<Widget>.generate(1, (index) {
              final isCurrent = index == _galleryIndex;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.only(right: 8),
                width: isCurrent ? 12 : 8,
                height: isCurrent ? 12 : 8,
                decoration: BoxDecoration(
                  color: isCurrent
                      ? Colors.white
                      : Colors.white.withOpacity(0.4),
                  shape: BoxShape.circle,
                ),
              );
            }),
          ),
        ),
        Positioned(
          bottom: 15,
          right: 15,
          child: _ScaleTap(
            onTap: _pickImage,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(15),
              ),
              child: const Row(
                children: <Widget>[
                  Icon(Icons.add_a_photo, color: Colors.white, size: 14),
                  SizedBox(width: 5),
                  Text(
                    'Add Pictures',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMetricsSection() {
    if (_selectedTab == 'Daily') {
      return Column(
        children: <Widget>[
          _buildTaskCard(
            'Today steps',
            '${todayProgress["steps"]}',
            'Keep walking and stay active.',
            true,
          ),
          const SizedBox(height: 20),
          _buildTaskCard(
            'Workout minutes',
            '${todayProgress["workoutMinutes"]} min',
            'Calories: ${todayProgress["calories"]}',
            false,
          ),
        ],
      );
    }

    if (_selectedTab == 'Weekly') {
      return Column(
        children: <Widget>[
          _buildTaskCard(
            'Weekly distance',
            '${weeklySummary["totalDistance"].toStringAsFixed(1)} KM',
            'Signed days: ${weeklySummary["signedDays"]}',
            true,
          ),
          const SizedBox(height: 20),
          _buildTaskCard(
            'Task completion',
            '${weeklySummary["completionRate"].toStringAsFixed(0)}%',
            'Minutes trained: ${weeklySummary["totalMinutes"]}',
            false,
          ),
        ],
      );
    }

    return Column(
      children: <Widget>[
        _buildTaskCard(
          'Current level',
          'Lv.${userData["level"]}',
          'XP collected: ${userData["xp"]}',
          true,
        ),
        const SizedBox(height: 20),
        _buildTaskCard(
          'Total sign-ins',
          '${userData["totalSignInDays"]}',
          'Current streak: ${userData["streakDays"]} days',
          false,
        ),
      ],
    );
  }

  Widget _buildTaskCard(
    String title,
    String badgeText,
    String subtitle,
    bool right,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: mainGreen,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: const Color(0xFFF9FFF0),
          borderRadius: BorderRadius.circular(25),
        ),
        child: Row(
          children: <Widget>[
            if (!right) _buildBadge(badgeText),
            if (!right) const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    subtitle,
                    style: const TextStyle(color: Colors.black54),
                  ),
                ],
              ),
            ),
            if (right) const SizedBox(width: 10),
            if (right) _buildBadge(badgeText),
          ],
        ),
      ),
    );
  }

  Widget _buildBadge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildErrorCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Column(
        children: <Widget>[
          const Icon(Icons.error_outline, size: 42, color: Colors.redAccent),
          const SizedBox(height: 12),
          Text(
            _error ?? 'Could not load grow data.',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.black54),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
            onPressed: () => _loadData(),
            child: const Text('Retry', style: TextStyle(color: mainGreen)),
          ),
        ],
      ),
    );
  }
}

class _ScaleTap extends StatefulWidget {
  const _ScaleTap({
    required this.child,
    required this.onTap,
  });

  final Widget child;
  final VoidCallback onTap;

  @override
  State<_ScaleTap> createState() => _ScaleTapState();
}

class _ScaleTapState extends State<_ScaleTap> {
  double _scale = 1.0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _scale = 0.92),
      onTapUp: (_) => setState(() => _scale = 1.0),
      onTapCancel: () => setState(() => _scale = 1.0),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeOutCubic,
        child: widget.child,
      ),
    );
  }
}