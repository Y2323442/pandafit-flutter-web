import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'app_controller.dart';
import 'models/trainquest_models.dart';
import 'dart:io';

class GrowPage extends StatefulWidget {
  const GrowPage({super.key});

  @override
  State<GrowPage> createState() => _GrowPageState();
}

class _GrowPageState extends State<GrowPage> {
  static const Color bgColor = Color(0xFFF1F8E9);
  static const Color mainGreen = Color(0xFFD1E683);
  static const Color darkCard = Color(0xFF000000);

  bool _loading = false;
  String? _error;
  final ImagePicker _picker = ImagePicker();
  List<XFile> _images = [];

  int _customStreak = 0;
  int _customSteps = 0;

  AppUser? get user => AppController.instance.user;

  @override
  void initState() {
    super.initState();
    if (user != null) {
      _customStreak = user!.signInDates?.length ?? 0;
    }
  }

  Future<void> _loadData({bool showLoader = true}) async {
    if (user == null) return;
    setState(() => _loading = showLoader);
    await Future.delayed(const Duration(milliseconds: 300));
    setState(() => _loading = false);
  }

  Future<void> _signInToday() async {
    if (user == null) return;
    await AppController.instance.userSignIn();
    setState(() {
      _customStreak = user!.signInDates?.length ?? 0;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Signed in successfully!")),
    );
  }

  Future<void> _pickImage() async {
    if (_images.length >= 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("You can upload up to 5 pictures.")),
      );
      return;
    }
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _images.add(image);
      });
    }
  }

  Future<void> _editStreak() async {
    final TextEditingController controller = TextEditingController(text: _customStreak.toString());
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Streak Days'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              setState(() => _customStreak = int.tryParse(controller.text) ?? _customStreak);
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _editSteps() async {
    final TextEditingController controller = TextEditingController(text: _customSteps.toString());
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Today Steps'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              setState(() => _customSteps = int.tryParse(controller.text) ?? _customSteps);
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (user == null) return const Center(child: CircularProgressIndicator());
    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => _loadData(showLoader: false),
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            children: [
              const SizedBox(height: 20),
              const Text('Grow', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
              const SizedBox(height: 8),
              const Text('Track today, keep your streak alive, and upload workout photos.', style: TextStyle(color: Colors.black54)),
              const SizedBox(height: 25),
              if (_loading)
                const Padding(padding: EdgeInsets.only(top: 80), child: Center(child: CircularProgressIndicator()))
              else if (_error != null)
                _buildErrorCard()
              else ...[
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

  Widget _buildKeepItUpCard() {
    return Container(
      height: 180,
      decoration: BoxDecoration(
        color: darkCard,
        borderRadius: BorderRadius.circular(40),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 15, offset: const Offset(0, 8))],
      ),
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Keep It Up', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  _ScaleTap(
                    onTap: _editStreak,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Streak: $_customStreak days', style: TextStyle(color: mainGreen, fontSize: 16, fontWeight: FontWeight.bold)),
                        Text('Stay consistent today.', style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 13)),
                      ],
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

  // ✅ 还原成你截图里的样子
  Widget _buildImageGallery() {
    return Stack(
      children: <Widget>[
        Container(
          height: 220,
          decoration: BoxDecoration(
            color: mainGreen.withOpacity(0.3),
            borderRadius: BorderRadius.circular(40),
          ),
          child: _images.isEmpty
              ? const Center(child: Icon(Icons.image, size: 50, color: Colors.black26))
              : PageView.builder(
                  itemCount: _images.length,
                  itemBuilder: (context, index) {
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(40),
                      child: Image.file(
                        File(_images[index].path),
                        fit: BoxFit.cover,
                      ),
                    );
                  },
                ),
        ),
        Positioned(
          bottom: 15,
          right: 15,
          child: _ScaleTap(
            onTap: _pickImage,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(30),
              ),
              child: const Row(
                children: <Widget>[
                  Icon(Icons.add_a_photo, color: Colors.white, size: 18),
                  SizedBox(width: 8),
                  Text(
                    'Add Pictures',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
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
    return Column(children: [_buildTaskCard('Today steps', '$_customSteps', 'Keep walking and stay active.', true, onBadgeTap: _editSteps)]);
  }

  Widget _buildTaskCard(String title, String badgeText, String subtitle, bool right, {VoidCallback? onBadgeTap}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: mainGreen, borderRadius: BorderRadius.circular(30)),
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(color: const Color(0xFFF9FFF0), borderRadius: BorderRadius.circular(25)),
        child: Row(
          children: [
            if (!right) _buildBadge(badgeText, onTap: onBadgeTap),
            if (!right) const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 6),
                  Text(subtitle, style: const TextStyle(color: Colors.black54)),
                ],
              ),
            ),
            if (right) const SizedBox(width: 10),
            if (right) _buildBadge(badgeText, onTap: onBadgeTap),
          ],
        ),
      ),
    );
  }

  Widget _buildBadge(String text, {VoidCallback? onTap}) {
    return _ScaleTap(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(20)),
        child: Text(text, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildErrorCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(30)),
      child: Column(
        children: [
          const Icon(Icons.error_outline, size: 42, color: Colors.redAccent),
          const SizedBox(height: 12),
          Text(_error ?? 'Could not load grow data.', textAlign: TextAlign.center, style: const TextStyle(color: Colors.black54)),
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
  const _ScaleTap({required this.child, required this.onTap});
  final Widget child;
  final VoidCallback? onTap;

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