import 'package:flutter/material.dart';
import 'start_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToStart();
  }

  _navigateToStart() async {
    // Görselin ekranda kalma süresi (2500 milisaniye = 2.5 saniye)
    await Future.delayed(const Duration(milliseconds: 2500));
    if (!mounted) return;
    
    // StartScreen'e yumuşak bir Fade (Kararma/Aydınlanma) efektiyle geçiş
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const StartScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 1000), // Geçiş hızı
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SizedBox.expand(
        child: Image.asset(
          'assets/background.jpg',
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}