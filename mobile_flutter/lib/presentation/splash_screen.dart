import 'package:flutter/material.dart'; 
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

import 'package:mobile_flutter/presentation/auth/login_page.dart';
import 'package:mobile_flutter/presentation/chat_dashboard_screen.dart';
import 'package:mobile_flutter/provider/profile_providers.dart';
import 'package:mobile_flutter/services/api_client.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
     _bootstrapSession();
  }

  Future<void> _bootstrapSession() async {
    final profileProv = context.read<ProfileProvider>();

    await Future.delayed(const Duration(seconds: 2));

    final token = await ApiClient().getAccessToken();
    final hasToken = token != null && token.isNotEmpty;

    if (!mounted) return;

    if (hasToken) {
      await profileProv.initLocalData();
      
      if (!mounted) return;
      await profileProv.fetchProfile();
    }
    
        if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => hasToken ? const ChatDashboardScreen() : const LoginPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Lottie.asset(
              'assets/animations/logo_splash.json',
              width: 200, height: 200,
              fit: BoxFit.contain,
              repeat: false,
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}