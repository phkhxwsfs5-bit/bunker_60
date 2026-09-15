import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:purchases_flutter/purchases_flutter.dart'; // EKLENDİ
import 'game_state.dart';
import 'splash_screen.dart';

import 'localization.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Loc.loadLanguage();
  WidgetsFlutterBinding.ensureInitialized();
  
  // AdMob SDK Başlatma
  await MobileAds.instance.initialize();
  
  // --- REVENUECAT BAŞLATMA SİSTEMİ ---
  await Purchases.setLogLevel(LogLevel.debug); // Geliştirme aşamasında hataları terminalde gösterir
  
  // Bunker 06 (Play Store) Public API Anahtarı
  PurchasesConfiguration configuration = PurchasesConfiguration("goog_DImuaWLEZUIKMbyMLlQPOJwzXvQ");
  await Purchases.configure(configuration);
  
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]).then((_) {
    runApp(
      ChangeNotifierProvider(
        create: (context) => GameState(),
        child: const SurviveGameApp(),
      ),
    );
  });
}

class SurviveGameApp extends StatelessWidget {
  const SurviveGameApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Bunker 06',
      theme: ThemeData.dark(),
      home: const SplashScreen(), 
    );
  }
}