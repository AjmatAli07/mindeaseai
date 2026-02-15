import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../widgets/particles_background.dart';
import 'auth_screen.dart';
import 'profile_screen.dart';
import 'chat_screen.dart';
import 'checkup_screen.dart';
import 'pomodoro_screen.dart';
import 'breathing_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {

  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation =
        CurvedAnimation(parent: _controller, curve: Curves.easeIn);

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -0.25),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _logout(BuildContext context) async {
    await AuthService.signOut();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const AuthScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final userEmail = AuthService.currentUser?.email ?? "";

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.black, // IMPORTANT
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text("MindEaseAI"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfileScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _logout(context),
          ),
        ],
      ),
      body: Stack(
        children: [

          /// 🌟 PARTICLES (BOTTOM LAYER)
          const Positioned.fill(
            child: ParticlesBackground(),
          ),

          /// 🌌 SEMI-TRANSPARENT GRADIENT (NOT SOLID!)
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xCC0F2027), // 80% opacity
                    Color(0xCC203A43),
                    Color(0xCC2C5364),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),

          /// 📦 CONTENT
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [

                  /// Animated Welcome Card
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
                                style: const TextStyle(
                                  color: Colors.grey,
                                ),
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
                        _feature(context, Icons.chat_bubble_outline,
                            "Chat with AI", ChatScreen()),
                        _feature(context, Icons.timer,
                            "Pomodoro Timer", PomodoroScreen()),
                        _feature(context, Icons.air,
                            "Breathing Exercise", const BreathingScreen()),
                        _feature(context,
                            Icons.health_and_safety_outlined,
                            "Mental Health Check-up", CheckupScreen()),
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

  Widget _feature(BuildContext context,
      IconData icon, String title, Widget page) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      elevation: 4,
      child: ListTile(
        leading: Icon(icon, color: Colors.green),
        title: Text(title,
            style: const TextStyle(fontWeight: FontWeight.bold)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => page),
        ),
      ),
    );
  }
}
