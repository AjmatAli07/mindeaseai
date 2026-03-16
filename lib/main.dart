import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'screens/home_screen.dart';
import 'screens/auth_screen.dart';

import '../services/crisis_service.dart';
import 'screens/crisis_alert_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://mjzdrxqdsltqvlexjntq.supabase.co',
    anonKey: 'sb_publishable_uJieMYonAqmRv3iwQ03jIg_vZIwB2fF',
  );

  runApp(const MindEaseAI());
}

class MindEaseAI extends StatelessWidget {
  const MindEaseAI({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'MindEaseAI',
      themeMode: ThemeMode.system,

      theme: ThemeData(
        brightness: Brightness.light,
        primaryColor: const Color(0xFF4CAF50),
        scaffoldBackgroundColor: const Color(0xFFF5F7FA),
      ),

      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: const Color(0xFF81C784),
        scaffoldBackgroundColor: const Color(0xFF121212),
      ),

      home: const AuthGate(),
    );
  }
}

/// 🔐 SINGLE SOURCE OF TRUTH FOR AUTH
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      stream: Supabase.instance.client.auth.onAuthStateChange,
      builder: (context, snapshot) {
        // 🔄 Always show loader until auth state is known
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final session =
            Supabase.instance.client.auth.currentSession;

        // ❌ NOT LOGGED IN
        if (session == null) {
          return const AuthScreen();
        }

        // ✅ LOGGED IN
        return const HomeScreen();
      },
    );
  }
}
