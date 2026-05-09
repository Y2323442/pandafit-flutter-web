import 'package:flutter/material.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  static const Color bgColor = Color(0xFFF1F8E9);
  static const Color mainGreen = Color(0xFFD1E683);
  static const Color darkCard = Color(0xFF1A1C1E);

  final bool isMasterSwitchOn = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: _buildIconButton(Icons.arrow_back_ios_new, () => Navigator.pop(context)),
        title: const Text(
          "Notifications",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w900,
            fontSize: 22,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            const SizedBox(height: 20),
            _buildNotificationHero(),
            const SizedBox(height: 30),
            _buildMasterSwitchCard(),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationHero() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: mainGreen,
        borderRadius: BorderRadius.circular(45),
        boxShadow: [
          BoxShadow(
            color: mainGreen.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: Colors.black,
              shape: BoxShape.circle,
            ),
            child: Icon(
              isMasterSwitchOn
                  ? Icons.notifications_active
                  : Icons.notifications_off,
              color: mainGreen,
              size: 40,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            isMasterSwitchOn
                ? "Focus Mode Active"
                : "Notifications Muted",
            style: const TextStyle(
              color: Colors.black,
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "7 notifications filtered today",
            style: TextStyle(
              color: Colors.black54,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMasterSwitchCard() {
    return Container(
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: isMasterSwitchOn ? darkCard : Colors.white,
        borderRadius: BorderRadius.circular(35),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Allow Notifications",
                  style: TextStyle(
                    color: isMasterSwitchOn ? Colors.white : Colors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  isMasterSwitchOn
                      ? "System is delivering alerts"
                      : "All alerts are paused",
                  style: TextStyle(
                    color: isMasterSwitchOn ? Colors.white54 : Colors.black38,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: isMasterSwitchOn,
            onChanged: null,
            activeColor: mainGreen,
          ),
        ],
      ),
    );
  }

  Widget _buildIconButton(IconData icon, VoidCallback onTap) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.black, size: 20),
      ),
    );
  }
}
