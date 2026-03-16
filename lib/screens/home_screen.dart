import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/streak_service.dart';
import '../services/crisis_service.dart';
import '../widgets/particles_background.dart';

import 'profile_screen.dart';
import 'chat_screen.dart';
import 'checkup_screen.dart';
import 'pomodoro_screen.dart';
import 'breathing_screen.dart';
import 'journal_screen.dart';
import 'mental_support_screen.dart';
import 'emotion_dashboard_screen.dart';
import 'crisis_alert_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;

  bool _isNavigating = false;
  int _streak = 0;

  @override
  void initState() {
    super.initState();

    _loadStreak();

    // 🚨 Run crisis check AFTER first frame (safe navigation)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkCrisis();
    });

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _fadeAnimation =
        CurvedAnimation(parent: _controller, curve: Curves.easeIn);

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -0.2),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _controller.forward();
  }

  /// 🔥 LOAD STREAK
  Future<void> _loadStreak() async {
    final value = await StreakService.getCurrentStreak();
    if (mounted) {
      setState(() => _streak = value);
    }
  }

  /// 🚨 CRISIS CHECK
  Future<void> _checkCrisis() async {
    final isCrisis = await CrisisService.isUserInCrisis();
    if (!mounted || !isCrisis) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const CrisisAlertScreen(),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// 🔐 LOGOUT
  Future<void> _logout() async {
    if (_isNavigating) return;

    setState(() => _isNavigating = true);
    FocusManager.instance.primaryFocus?.unfocus();

    await AuthService.signOut();

    if (mounted) {
      setState(() => _isNavigating = false);
    }
  }

  /// 🔒 SAFE NAVIGATION + STREAK REFRESH
  void _navigateSafely(Widget page) {
    if (_isNavigating) return;

    setState(() => _isNavigating = true);

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => page),
    ).then((_) async {
      await _loadStreak();
      if (mounted) {
        setState(() => _isNavigating = false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final userEmail = AuthService.currentUser?.email ?? "";

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text("MindEaseAI"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () => _navigateSafely(const ProfileScreen()),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: Stack(
        children: [
          const Positioned.fill(child: ParticlesBackground()),

          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xCC0F2027),
                    Color(0xCC203A43),
                    Color(0xCC2C5364),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: Card(
                        color: Colors.white.withOpacity(0.9),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        elevation: 8,
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            children: [
                              const Icon(
                                Icons.self_improvement,
                                size: 60,
                                color: Colors.green,
                              ),
                              const SizedBox(height: 10),
                              const Text(
                                "Welcome Back 🌿",
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                userEmail,
                                style: const TextStyle(color: Colors.grey),
                              ),
                              const SizedBox(height: 8),

                              /// 🔥 STREAK
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.local_fire_department,
                                    color: Colors.orange,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    "$_streak day streak",
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.orange,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  Expanded(
                    child: ListView(
                      children: [
                        _feature(Icons.chat_bubble_outline,
                            "Chat with AI", const ChatScreen()),
                        _feature(Icons.book_outlined,
                            "Personal Journal", const JournalScreen()),
                        _feature(Icons.timer,
                            "Pomodoro Timer", PomodoroScreen()),
                        _feature(Icons.air,
                            "Breathing Exercise", const BreathingScreen()),
                        _feature(Icons.health_and_safety_outlined,
                            "Mental Health Check-up", CheckupScreen()),
                        _feature(Icons.local_hospital,
                            "Find Mental Health Support",
                            const MentalSupportScreen()),
                        _feature(Icons.insights,
                            "Emotional Trends",
                            const EmotionDashboardScreen()),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _feature(IconData icon, String title, Widget page) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      elevation: 4,
      child: ListTile(
        leading: Icon(icon, color: Colors.green),
        title:
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () => _navigateSafely(page),
      ),
    );
  }
}