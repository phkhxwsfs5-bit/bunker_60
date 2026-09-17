import 'dart:math'; 
import 'dart:ui';
import 'package:flutter/material.dart';
import 'localization.dart';
import 'package:provider/provider.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:purchases_flutter/purchases_flutter.dart'; 
import 'game_state.dart';
import 'models.dart';
import 'start_screen.dart';
import 'audio_manager.dart';

class BunkerScreen extends StatefulWidget {
  const BunkerScreen({super.key});

  @override
  State<BunkerScreen> createState() => _BunkerScreenState();
}

class _BunkerScreenState extends State<BunkerScreen> {
  
  @override
  void initState() {
    super.initState();
    AudioManager().playBGM('bgm_bunker.mp3');
  }

  void _showModernAlert(BuildContext context, String title, String message, Color color, IconData icon) {
    ScaffoldMessenger.of(context).clearSnackBars(); 
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A1D), 
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withOpacity(0.5), width: 1.5),
            boxShadow: [
              BoxShadow(color: color.withOpacity(0.2), blurRadius: 10, spreadRadius: 2, offset: const Offset(0, 4))
            ]
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(title, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 15, letterSpacing: 0.5)),
                    const SizedBox(height: 4),
                    Text(message, style: const TextStyle(color: Colors.white70, fontSize: 13, height: 1.3)),
                  ],
                ),
              ),
            ],
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        behavior: SnackBarBehavior.floating, 
        margin: const EdgeInsets.only(bottom: 30, left: 20, right: 20),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  Future<void> _restorePurchases(BuildContext context, GameState gameState) async {
    try {
      CustomerInfo customerInfo = await Purchases.restorePurchases();
      if (customerInfo.entitlements.all["elite_access"]?.isActive == true) {
        gameState.restoreAdFree(); 
        if (context.mounted) {
          _showModernAlert(context, Localization.t('ui_success', context.read<GameState>().currentLanguage), Localization.t('ui_restore_success', context.read<GameState>().currentLanguage), Colors.greenAccent, Icons.check_circle);
        }
      } else {
        if (context.mounted) {
          _showModernAlert(context, Localization.t('ui_info', context.read<GameState>().currentLanguage), Localization.t('ui_restore_fail', context.read<GameState>().currentLanguage), Colors.orangeAccent, Icons.info_outline);
        }
      }
    } catch (e) {
      if (context.mounted) {
        _showModernAlert(context, Localization.t('ui_conn_error', context.read<GameState>().currentLanguage), Localization.t('ui_conn_error_desc', context.read<GameState>().currentLanguage), Colors.redAccent, Icons.error_outline);
      }
    }
  }

  Widget _buildStrokedText(String text, double fontSize, Color textColor, double strokeWidth, double letterSpacing) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
            letterSpacing: letterSpacing,
            foreground: Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = strokeWidth
              ..strokeJoin = StrokeJoin.round
              ..color = Colors.black,
            shadows: const [
              Shadow(color: Colors.black, blurRadius: 15, offset: Offset(0, 0)),
              Shadow(color: Colors.black87, blurRadius: 8, offset: Offset(0, 4))
            ],
          ),
        ),
        Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
            letterSpacing: letterSpacing,
            color: textColor,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final gameState = context.watch<GameState>();

    if (gameState.isGameOver) {
      AudioManager().stopBGM();
      return Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            Positioned.fill(
              child: Image.asset('assets/game_over.jpg', fit: BoxFit.cover),
            ),
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildStrokedText(Localization.t('ui_signal_lost', context.read<GameState>().currentLanguage), 46, Colors.redAccent, 8.0, 4.0),
                  const SizedBox(height: 16),
                  _buildStrokedText(Localization.t('ui_days_survived', context.read<GameState>().currentLanguage), 20, Colors.white, 6.0, 2.0),
                  _buildStrokedText("${gameState.currentDay}", 84, Colors.white, 14.0, 0.0),
                  const SizedBox(height: 40),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade900,
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 10,
                    ),
                    onPressed: () {
                      AudioManager().playSFX('ui_click.mp3');
                      gameState.resetGame();
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => const StartScreen()),
                      );
                    },
                    child: Text(
                      Localization.t('ui_back_to_menu', context.read<GameState>().currentLanguage),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                      ),
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      );
    }

    if (gameState.isGameWon) {
      AudioManager().stopBGM();
      return Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            Positioned.fill(
              child: Image.asset('assets/game_won.jpg', fit: BoxFit.cover),
            ),
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildStrokedText("KURTARILDIK!", 46, Colors.amber.shade400, 8.0, 4.0),
                  const SizedBox(height: 16),
                  _buildStrokedText(Localization.t('ui_bunker_days', context.read<GameState>().currentLanguage), 20, Colors.white, 6.0, 2.0),
                  _buildStrokedText("${gameState.currentDay}", 84, Colors.white, 14.0, 0.0),
                  const SizedBox(height: 40),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange.shade900,
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 10,
                    ),
                    onPressed: () {
                      AudioManager().playSFX('ui_click.mp3');
                      gameState.resetGame();
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => const StartScreen()),
                      );
                    },
                    child: Text(
                      Localization.t('ui_back_to_menu', context.read<GameState>().currentLanguage),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                      ),
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: ShakeWidget(
        isShaking: gameState.isShaking,
        child: SizedBox.expand(
          child: FittedBox(
            fit: BoxFit.contain, 
            alignment: Alignment.center,
            child: SizedBox(
              width: 900, 
              height: 400, 
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Image.asset('assets/background.jpg', fit: BoxFit.cover),
                  ),

                  if (gameState.isFlickering)
                    Positioned.fill(
                      child: TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0.0, end: 0.7),
                        duration: const Duration(milliseconds: 100),
                        curve: Curves.elasticIn,
                        builder: (context, val, child) {
                          double opacity = (sin(DateTime.now().millisecondsSinceEpoch / 50) * 0.35 + 0.35);
                          return Container(color: Colors.black.withOpacity(opacity));
                        },
                      ),
                    ),

                  _buildCharacterSlot(context, gameState, gameState.characters[0], const Alignment(-0.50, 0.95)),
                  _buildCharacterSlot(context, gameState, gameState.characters[1], const Alignment(-0.15, 0.95)),
                  _buildCharacterSlot(context, gameState, gameState.characters[2], const Alignment(0.12, 0.95)),

                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: _buildTopBar(context, gameState),
                  ),
                  Positioned(
                    top: 90,
                    right: 24,
                    bottom: 24,
                    width: 300,
                    child: _buildRightPanel(context, gameState),
                  ),

                  IgnorePointer(
                    ignoring: !gameState.isDayChanging,
                    child: AnimatedOpacity(
                      opacity: gameState.isDayChanging ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 500),
                      child: Container(
                        color: Colors.black,
                        child: Center(
                          child: gameState.isDayChanging 
                              ? DayChangeAnimation(day: gameState.currentDay) 
                              : const SizedBox.shrink(),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCharacterSlot(BuildContext context, GameState gameState, Character char, Alignment alignment) {
    if (!char.isAlive || char.isExploring) {
      return const SizedBox.shrink(); 
    }

    int breathDuration = char.name == "Baba" ? 1800 : (char.name == "Anne" ? 1600 : 1300);
    double imgHeight = char.name == "Baba" ? 250.0 : (char.name == "Anne" ? 240.0 : 210.0);

    Widget charWidget = GestureDetector(
      onTap: () {
        AudioManager().playSFX('ui_click.mp3');
        _showFeedDialog(context, gameState, char);
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildStatusBars(char),
          const SizedBox(height: 8),
          BreathingWidget(
            durationMillis: breathDuration,
            child: Image.asset(char.currentImagePath, height: imgHeight),
          ),
        ],
      ),
    );

    return Align(
      alignment: alignment,
      child: charWidget,
    );
  }

  Widget _buildStatusBars(Character char) {
    double water = (1.0 - (char.thirstLevel / 4.0)).clamp(0.0, 1.0);
    double hunger = (1.0 - (char.hungerLevel / 5.0)).clamp(0.0, 1.0);
    double morale = (1.0 - (char.moraleLevel / 5.0)).clamp(0.0, 1.0);
    double health = char.status == 'normal' ? 1.0 : (char.status == 'dead' ? 0.0 : 0.4);

    return Container(
      width: 50, 
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4), 
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.8), 
        borderRadius: BorderRadius.circular(6), 
        border: Border.all(color: Colors.white24, width: 0.5), 
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.6), blurRadius: 4, offset: const Offset(0, 2))
        ]
      ),
      child: Column(
        children: [
          _buildIconStatusBar('assets/icon_water.png', Colors.lightBlueAccent, water),
          const SizedBox(height: 2), 
          _buildIconStatusBar('assets/icon_soup.png', Colors.amber, hunger),
          const SizedBox(height: 2),
          _buildIconStatusBar('assets/icon_medkit.png', Colors.redAccent, health),
          const SizedBox(height: 2),
          _buildIconStatusBar('assets/icon_chat.png', Colors.deepPurpleAccent, morale),
        ],
      ),
    );
  }

  Widget _buildIconStatusBar(String imagePath, Color color, double percentage) {
    return Row(
      children: [
        Image.asset(imagePath, width: 8, height: 8), 
        const SizedBox(width: 3), 
        Expanded(
          child: Container(
            height: 3, 
            alignment: Alignment.centerLeft,
            decoration: BoxDecoration(
              color: Colors.black87, 
              borderRadius: BorderRadius.circular(1.5),
              border: Border.all(color: Colors.white24, width: 0.3), 
            ),
            child: FractionallySizedBox(
              widthFactor: percentage,
              child: Container(
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(1.5),
                  boxShadow: [
                    BoxShadow(color: color.withOpacity(0.6), blurRadius: 1.5, spreadRadius: 0.1) 
                  ]
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showFeedDialog(BuildContext ctx, GameState gameState, Character char) {
    String traitName = Localization.t(gameState.getTraitName(char.name), gameState.currentLanguage);
    String traitDesc = Localization.t(gameState.getTraitDesc(char.name), gameState.currentLanguage);

    showDialog(
      context: ctx,
      barrierColor: Colors.black.withValues(alpha: 0.3),
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(16),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Container(
                width: 440,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E1E),
                  image: DecorationImage(
                    image: const AssetImage('assets/dialog_bg.png'),
                    fit: BoxFit.cover,
                    colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.4), BlendMode.darken),
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white24, width: 1.5),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            color: Colors.black54,
                            child: Image.asset(
                              char.currentImagePath,
                              height: 50,
                              width: 50,
                              fit: BoxFit.cover,
                              alignment: Alignment.topCenter,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                Localization.t(char.name, gameState.currentLanguage).toUpperCase(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.2,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Tooltip(
                                message: traitDesc,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.amber.withOpacity(0.2),
                                    border: Border.all(color: Colors.amber.withOpacity(0.5)),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    traitName,
                                    style: const TextStyle(
                                      color: Colors.amber,
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Divider(color: Colors.white24, height: 1),
                    const SizedBox(height: 12),
                    _buildModernActionRow(
                      imagePath: 'assets/icon_water.png',
                      title: Localization.t('ui_give_water', gameState.currentLanguage),
                      subtitle: Localization.t('ui_give_water_desc', gameState.currentLanguage),
                      enabled: gameState.waterCount > 0 && char.thirstLevel > 0,
                      onTap: () {
                        AudioManager().playSFX('action_water.mp3');
                        gameState.feedWater(char);
                        Navigator.pop(context); // HATA DÜZELTİLDİ: ctx yerine context
                      },
                    ),
                    const SizedBox(height: 6),
                    _buildModernActionRow(
                      imagePath: 'assets/icon_soup.png',
                      title: Localization.t('ui_give_soup', gameState.currentLanguage),
                      subtitle: Localization.t('ui_give_soup_desc', gameState.currentLanguage),
                      enabled: gameState.soupCount > 0 && char.hungerLevel > 0,
                      onTap: () {
                        AudioManager().playSFX('action_soup.mp3');
                        gameState.feedSoup(char);
                        Navigator.pop(context); // HATA DÜZELTİLDİ: ctx yerine context
                      },
                    ),
                    const SizedBox(height: 6),
                    _buildModernActionRow(
                      imagePath: 'assets/icon_medkit.png',
                      title: Localization.t('ui_use_medkit', gameState.currentLanguage),
                      subtitle: Localization.t('ui_give_medkit_desc', gameState.currentLanguage),
                      enabled: gameState.medkitCount > 0 && (char.status == 'sick' || char.status == 'injured'),
                      onTap: () {
                        AudioManager().playSFX('action_heal.mp3');
                        gameState.healCharacter(char);
                        Navigator.pop(context); // HATA DÜZELTİLDİ: ctx yerine context
                      },
                    ),
                    const SizedBox(height: 6),
                    _buildModernActionRow(
                      imagePath: 'assets/icon_chat.png',
                      title: Localization.t('ui_chat', gameState.currentLanguage),
                      subtitle: Localization.t('ui_chat_desc', gameState.currentLanguage),
                      enabled: !gameState.hasChattedToday && char.moraleLevel > 0,
                      onTap: () {
                        AudioManager().playSFX('action_chat.mp3');
                        gameState.talkToCharacter(char);
                        Navigator.pop(context); // HATA DÜZELTİLDİ: ctx yerine context
                      },
                    ),
                    const SizedBox(height: 12),
                    _buildActionButton(
                      Localization.t('ui_close', context.read<GameState>().currentLanguage),
                      Icons.close,
                      Colors.white,
                      () {
                        AudioManager().playSFX('ui_click.mp3');
                        Navigator.pop(context); // HATA DÜZELTİLDİ: ctx yerine context
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildVolumeSliderRow({
    required String title,
    required double value,
    required ValueChanged<double> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                title,
                style: TextStyle(
                  color: value > 0 ? Colors.white : Colors.grey, 
                  fontSize: 14, 
                  fontWeight: FontWeight.bold
                ),
              ),
              const Spacer(),
              Text(
                "${(value * 100).toInt()}%",
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              )
            ],
          ),
          SliderTheme(
            data: SliderThemeData(
              activeTrackColor: value > 0 ? Colors.greenAccent : Colors.grey,
              inactiveTrackColor: Colors.white24,
              thumbColor: Colors.white,
              trackHeight: 4.0,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8.0),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 16.0),
            ),
            child: Slider(
              value: value,
              min: 0.0,
              max: 1.0,
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernActionRow({
    IconData? icon,
    String? imagePath,
    Color iconColor = Colors.white,
    required String title,
    required String subtitle,
    required bool enabled,
    required VoidCallback onTap,
    bool isAd = false,
  }) {
    return InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: enabled ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: enabled ? Colors.white24 : Colors.transparent),
        ),
        child: Row(
          children: [
            if (icon != null || imagePath != null) ...[
              imagePath != null
                  ? Opacity(opacity: enabled ? 1.0 : 0.5, child: Image.asset(imagePath, width: 36, height: 36))
                  : Icon(icon, color: enabled ? iconColor : Colors.grey.shade700, size: 36),
              const SizedBox(width: 14),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          title,
                          style: TextStyle(
                            color: enabled ? Colors.white : Colors.grey.shade600,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      if (isAd) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.orange.shade800,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            "AD", 
                            style: TextStyle(
                              color: Colors.white, 
                              fontSize: 9, 
                              fontWeight: FontWeight.bold, 
                              letterSpacing: 0.5
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: enabled ? Colors.white60 : Colors.grey.shade800,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, size: 18, color: enabled ? Colors.white54 : Colors.transparent),
          ],
        ),
      ),
    );
  }

  Widget _buildTopMenuButton({
    required String title,
    required String imagePath,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start, 
          children: [
            Image.asset(imagePath, width: 32, height: 32), 
            const SizedBox(height: 4), 
            Text(
              title,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 10, 
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
                shadows: [
                  Shadow(color: Colors.black, blurRadius: 4, offset: Offset(1, 1))
                ]
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context, GameState gameState) {
    return Container(
      height: 100, 
      padding: const EdgeInsets.only(top: 16, left: 24, right: 24, bottom: 10), 
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black.withOpacity(0.95), 
            Colors.black.withOpacity(0.6),  
            Colors.transparent,             
          ],
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 32,
            child: Center(
              child: Text(
                Localization.t('ui_day_counter', gameState.currentLanguage, {'day': gameState.currentDay.toString()}),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(color: Colors.black, blurRadius: 6, offset: Offset(1, 1))
                  ]
                ),
              ),
            ),
          ),
          const SizedBox(width: 14), 
          
          _buildResourceItem("Su", 'assets/icon_water.png', "${gameState.waterCount}"),
          _buildResourceItem(Localization.t('ui_soup', gameState.currentLanguage), 'assets/icon_soup.png', "${gameState.soupCount}"),
          _buildResourceItem(Localization.t('ui_medkit', gameState.currentLanguage), 'assets/icon_medkit.png', "${gameState.medkitCount}"),
          _buildResourceItem(Localization.t('ui_tool', gameState.currentLanguage), 'assets/icon_tool.png', "${gameState.toolCount}"),
          _buildResourceItem("Cephane", 'assets/icon_ammo.png', "${gameState.ammoCount}"),
          
          const Spacer(),
          
          _buildTopMenuButton(
            title: Localization.t('ui_radio', context.read<GameState>().currentLanguage),
            imagePath: 'assets/icon_radio.png',
            onTap: () {
              AudioManager().playSFX('ui_click.mp3');
              _showRadioDialog(context, gameState);
            },
          ),
          _buildTopMenuButton(
            title: Localization.t('ui_store', gameState.currentLanguage),
            imagePath: 'assets/icon_store.png',
            onTap: () {
              AudioManager().playSFX('ui_click.mp3');
              _showStoreDialog(context, gameState);
            },
          ),
          _buildTopMenuButton(
            title: Localization.t('ui_guide', context.read<GameState>().currentLanguage),
            imagePath: 'assets/icon_logbook.png',
            onTap: () {
              AudioManager().playSFX('ui_click.mp3');
              _showHowToPlayDialog(context);
            },
          ),
          _buildTopMenuButton(
            title: Localization.t('ui_settings', context.read<GameState>().currentLanguage),
            imagePath: 'assets/icon_settings.png',
            onTap: () {
              AudioManager().playSFX('ui_click.mp3');
              _showSettingsDialog(context);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildResourceItem(String tooltip, String imagePath, String amount) {
    return Tooltip(
      message: tooltip, 
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 7), 
        child: SizedBox(
          height: 32,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset(imagePath, width: 32, height: 32), 
              const SizedBox(width: 6),
              Text(
                amount,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 19, 
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(color: Colors.black, blurRadius: 6, offset: Offset(1, 1))
                  ]
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRightPanel(BuildContext context, GameState gameState) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white12, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Image.asset('assets/icon_logbook.png', width: 28, height: 28), 
              const SizedBox(width: 10),
              Text(
                      Localization.t('ui_logs', gameState.currentLanguage),
                style: TextStyle(
                  color: Colors.lightBlueAccent,
                  fontSize: 16, 
                  fontWeight: FontWeight.bold,
                ),
              )
            ],
          ),
          const Divider(color: Colors.white24, height: 24, thickness: 1),
          
          Expanded(
            child: Align(
              alignment: Alignment.topLeft,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.topLeft,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: constraints.maxWidth,
                      ),
                      child: Text(
                        gameState.dailyLog,
                        style: const TextStyle(
                          color: Colors.white70, 
                          fontSize: 13.5, 
                          height: 1.3
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          
          const SizedBox(height: 10),
          if (gameState.currentEvent.choices.isNotEmpty)
            ...gameState.currentEvent.choices.map((choice) => Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: _buildActionButton(
                    choice.buttonText,
                    Icons.arrow_forward, 
                    Colors.lightBlue,
                    choice.isEnabled ? () {
                      AudioManager().playSFX('ui_click.mp3');
                      choice.onSelect();
                    } : null,
                  ),
                )),
          if (gameState.currentEvent.choices.isEmpty)
            Column(
              children: [
                _buildActionImageButton(
                  gameState.exploringCharacter != null ? Localization.t('ui_expedition_ongoing', gameState.currentLanguage) : Localization.t('ui_expedition_start', gameState.currentLanguage),
                  'assets/icon_explore.png',
                  gameState.exploringCharacter != null ? Colors.white38 : Colors.white70,
                  () {
                    if (gameState.exploringCharacter == null) {
                      AudioManager().playSFX('ui_click.mp3');
                      _showExploreDialog(context, gameState);
                    }
                  },
                ),
                const SizedBox(height: 10),
                
                _buildGradientImageButton(
                  Localization.t('ui_end_day', gameState.currentLanguage),
                  'assets/icon_night.png',
                  () {
                    AudioManager().playSFX('ui_end_day.mp3');
                    context.read<GameState>().nextDay();
                  },
                ),
              ],
            )
        ],
      ),
    );
  }

  Widget _buildActionButton(String title, IconData icon, Color color, VoidCallback? onTap) {
    bool isEnabled = onTap != null;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        height: 40,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: const AssetImage('assets/button_bg.png'),
            fit: BoxFit.cover,
            colorFilter: isEnabled ? null : ColorFilter.mode(Colors.black.withOpacity(0.6), BlendMode.darken),
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: isEnabled ? [const BoxShadow(color: Colors.black54, blurRadius: 4, offset: Offset(0, 2))] : [],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: isEnabled ? Colors.white70 : Colors.grey, size: 18), 
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                color: isEnabled ? Colors.white : Colors.grey,
                fontWeight: FontWeight.bold,
                fontSize: 14, 
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionImageButton(String title, String imagePath, Color color, VoidCallback? onTap) {
    bool isEnabled = onTap != null;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        height: 40, 
        decoration: BoxDecoration(
          image: DecorationImage(
            image: const AssetImage('assets/button_bg.png'),
            fit: BoxFit.cover,
            colorFilter: isEnabled ? null : ColorFilter.mode(Colors.black.withOpacity(0.6), BlendMode.darken),
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: isEnabled ? [const BoxShadow(color: Colors.black54, blurRadius: 4, offset: Offset(0, 2))] : [],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Opacity(opacity: isEnabled ? 1.0 : 0.4, child: Image.asset(imagePath, width: 22, height: 22)), 
            const SizedBox(width: 10),
            Text(
              title,
              style: TextStyle(
                color: isEnabled ? Colors.white : Colors.grey,
                fontWeight: FontWeight.bold,
                fontSize: 14, 
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGradientImageButton(String title, String imagePath, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        height: 40, 
        decoration: BoxDecoration(
          image: const DecorationImage(
            image: AssetImage('assets/button_bg.png'),
            fit: BoxFit.cover,
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [BoxShadow(color: Colors.black54, blurRadius: 4, offset: Offset(0, 2))],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(imagePath, width: 22, height: 22), 
            const SizedBox(width: 10),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14, 
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            )
          ],
        ),
      ),
    );
  }

  void _showExploreDialog(BuildContext context, GameState gameState) {
    var availableChars = gameState.characters.where((c) => c.isAlive && !c.isExploring).toList();
    if (availableChars.isEmpty) return; 

    String selectedCharacter = availableChars.first.name;
    Place? selectedPlace;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              backgroundColor: Colors.transparent,
              insetPadding: const EdgeInsets.all(16),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    width: 550,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E1E1E), 
                      image: DecorationImage(
                        image: const AssetImage('assets/dialog_bg.png'),
                        fit: BoxFit.cover,
                        colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.4), BlendMode.darken),
                      ),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white24, width: 1.5),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Image.asset('assets/icon_explore.png', width: 24, height: 24),
                                const SizedBox(width: 8),
                                Text(
                      Localization.t('ui_plan_expedition', context.read<GameState>().currentLanguage),
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                      Localization.t('ui_select_target', context.read<GameState>().currentLanguage),
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            height: 150, 
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: Colors.white24),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: Stack(
                                children: [
                                  FlutterMap(
                                    options: MapOptions(
                                      initialCenter: LatLng(gameState.lat, gameState.lng),
                                      initialZoom: 14.0,
                                      onTap: (_, __) {
                                        AudioManager().playSFX('ui_click.mp3');
                                        setState(() {
                                          selectedPlace = null;
                                        });
                                      },
                                    ),
                                    children: [
                                      TileLayer(
                                        urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                                        userAgentPackageName: 'com.example.bunker_06',
                                      ),
                                      MarkerLayer(
                                        markers: [
                                          Marker(
                                            point: LatLng(gameState.lat, gameState.lng),
                                            width: 40,
                                            height: 40,
                                            child: const Icon(Icons.my_location, color: Colors.blueAccent, size: 30),
                                          ),
                                          ...gameState.nearbyPlaces.map((place) {
                                            bool isSelected = selectedPlace == place;
                                            return Marker(
                                              point: LatLng(place.lat, place.lng),
                                              width: 140,
                                              height: 100, 
                                              alignment: Alignment.center,
                                              child: GestureDetector(
                                                onTap: () {
                                                  AudioManager().playSFX('ui_click.mp3');
                                                  setState(() {
                                                    selectedPlace = place;
                                                  });
                                                },
                                                child: Column(
                                                  mainAxisSize: MainAxisSize.min,
                                                  mainAxisAlignment: MainAxisAlignment.end,
                                                  children: [
                                                    if (isSelected)
                                                      Container(
                                                        margin: const EdgeInsets.only(bottom: 2),
                                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                                                        decoration: BoxDecoration(
                                                          color: Colors.black87,
                                                          borderRadius: BorderRadius.circular(6),
                                                          border: Border.all(color: Colors.greenAccent, width: 1.5),
                                                        ),
                                                        child: Text(
                                                          place.name,
                                                          style: const TextStyle(
                                                            color: Colors.white,
                                                            fontSize: 11,
                                                            fontWeight: FontWeight.bold,
                                                          ),
                                                          textAlign: TextAlign.center,
                                                          maxLines: 2,
                                                          overflow: TextOverflow.ellipsis,
                                                        ),
                                                      ),
                                                    Icon(
                                                      Icons.location_on,
                                                      color: isSelected ? Colors.greenAccent : Colors.redAccent,
                                                      size: isSelected ? 40 : 35,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            );
                                          }).toList(),
                                        ],
                                      ),
                                    ],
                                  ),
                                  if (gameState.isLoadingPlaces)
                                    Container(
                                      color: Colors.black54,
                                      child: Center(
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const CircularProgressIndicator(),
                                            const SizedBox(height: 12),
                                            Text(
                                              gameState.loadingMessage,
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 12,
                                              ),
                                              textAlign: TextAlign.center,
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                      Localization.t('ui_select_char', context.read<GameState>().currentLanguage),
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            height: 38,
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.lightBlueAccent.withOpacity(0.5)),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: selectedCharacter,
                                dropdownColor: Colors.grey.shade900,
                                isExpanded: true,
                                icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white54, size: 20),
                                items: availableChars.map((Character character) {
                                  return DropdownMenuItem<String>(
                                    value: character.name,
                                    child: Row(
                                      children: [
                                        Text(Localization.t(character.name, gameState.currentLanguage), style: const TextStyle(color: Colors.white)),
                                        const SizedBox(width: 10),
                                        Text(
                                          "(${Localization.t(gameState.getTraitName(character.name), gameState.currentLanguage)})",
                                          style: const TextStyle(color: Colors.amber, fontSize: 11),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                                onChanged: (newValue) {
                                  if (newValue != null) {
                                    AudioManager().playSFX('ui_click.mp3');
                                    setState(() {
                                      selectedCharacter = newValue;
                                    });
                                  }
                                },
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: _buildActionButton(
                                  Localization.t('ui_cancel', context.read<GameState>().currentLanguage),
                                  Icons.close,
                                  Colors.white,
                                  () {
                                    AudioManager().playSFX('ui_click.mp3');
                                    Navigator.pop(context);
                                  },
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildActionButton(
                                  Localization.t('ui_confirm', context.read<GameState>().currentLanguage),
                                  Icons.check,
                                  Colors.white,
                                  () {
                                    AudioManager().playSFX('ui_click.mp3');
                                    if (selectedPlace == null) {
                                      _showModernAlert(context, Localization.t('ui_target_not_found', gameState.currentLanguage), Localization.t('ui_please_select_target', context.read<GameState>().currentLanguage), Colors.redAccent, Icons.location_off);
                                      return;
                                    }
                                    Navigator.pop(context);
                                    context.read<GameState>().startExpedition(selectedCharacter, selectedPlace!);
                                  },
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
            );
          },
        );
      },
    );
  }

  void _showRadioDialog(BuildContext context, GameState gameState) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(16),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Container(
                width: 440,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E1E), 
                  image: DecorationImage(
                    image: const AssetImage('assets/dialog_bg.png'),
                    fit: BoxFit.cover,
                    colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.4), BlendMode.darken),
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white24, width: 1.5),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset('assets/icon_radio.png', width: 48, height: 48),
                    const SizedBox(height: 8),
                    Text(
                      Localization.t('ui_radio_title', context.read<GameState>().currentLanguage),
                      style: TextStyle(
                        color: Colors.lightBlue,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      Localization.t('ui_radio_desc', context.read<GameState>().currentLanguage),
                      style: TextStyle(color: Colors.white70, fontSize: 12, height: 1.4),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    _buildModernActionRow(
                      imagePath: 'assets/icon_radar.png',
                      title: Localization.t('ui_scan_signal_btn', context.read<GameState>().currentLanguage),
                      subtitle: Localization.t('ui_scan_signal', context.read<GameState>().currentLanguage),
                      enabled: !gameState.hasUsedRadioToday,
                      onTap: () {
                        AudioManager().playSFX('radio_static.mp3'); 
                        Navigator.pop(context);
                        gameState.useRadio("scan");
                      },
                    ),
                    const SizedBox(height: 8),
                    _buildModernActionRow(
                      imagePath: 'assets/icon_music.png', 
                      title: Localization.t('ui_listen_music', context.read<GameState>().currentLanguage),
                      subtitle: Localization.t('ui_listen_music_desc', context.read<GameState>().currentLanguage),
                      enabled: !gameState.hasUsedRadioToday,
                      onTap: () {
                        AudioManager().playSFX('radio_music.mp3'); 
                        Navigator.pop(context);
                        gameState.useRadio("music");
                      },
                    ),
                    const SizedBox(height: 12),
                    _buildActionButton(
                      Localization.t('ui_close', context.read<GameState>().currentLanguage),
                      Icons.close,
                      Colors.white,
                      () {
                        AudioManager().playSFX('ui_click.mp3');
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _showStoreDialog(BuildContext context, GameState gameState) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(16),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Container(
                width: 440,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E1E), 
                  image: DecorationImage(
                    image: const AssetImage('assets/dialog_bg.png'),
                    fit: BoxFit.cover,
                    colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.4), BlendMode.darken),
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white24, width: 1.5),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset('assets/icon_store.png', width: 48, height: 48),
                    const SizedBox(height: 8),
                    Text(
                      Localization.t('ui_black_market', context.read<GameState>().currentLanguage),
                      style: const TextStyle(
                        color: Colors.amber,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      Localization.t('ui_store_desc', context.read<GameState>().currentLanguage),
                      style: TextStyle(color: Colors.white70, fontSize: 12, height: 1.4),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    
                    Builder(
                      builder: (context) {
                        bool canUseAd = (gameState.currentDay - gameState.lastAdDay) >= 3;
                        int daysLeft = 3 - (gameState.currentDay - gameState.lastAdDay);
                        
                        return _buildModernActionRow(
                          imagePath: 'assets/icon_radio.png', 
                          title: Localization.t('ui_emergency_signal', context.read<GameState>().currentLanguage),
                          subtitle: canUseAd 
                              ? Localization.t('ui_watch_ad_desc', context.read<GameState>().currentLanguage) 
                              : Localization.t('ui_ad_cooldown', context.read<GameState>().currentLanguage, {'days': daysLeft.toString()}),
                          enabled: canUseAd,
                          isAd: true, 
                          onTap: () {
                            AudioManager().playSFX('ui_click.mp3');
                            Navigator.pop(context);
                            
                            gameState.watchAdForResources(
                              onReward: () {
                                _showModernAlert(context, Localization.t('ui_signal_received', context.read<GameState>().currentLanguage), Localization.t('ui_ad_reward', context.read<GameState>().currentLanguage), Colors.greenAccent, Icons.inventory_2);
                              },
                              onFailed: () {
                                _showModernAlert(context, Localization.t('ui_signal_lost', context.read<GameState>().currentLanguage), Localization.t('ui_ad_fail', context.read<GameState>().currentLanguage), Colors.redAccent, Icons.signal_wifi_off);
                              }
                            );
                          },
                        );
                      }
                    ),
                    const SizedBox(height: 6),
                    _buildModernActionRow(
                      imagePath: 'assets/icon_store.png',
                      title: Localization.t('ui_survival_pack', context.read<GameState>().currentLanguage),
                      subtitle: Localization.t('ui_buy_pack_desc', context.read<GameState>().currentLanguage),
                      enabled: true,
                      onTap: () async {
                        AudioManager().playSFX('ui_click.mp3');
                        Navigator.pop(context);
                        try {
                          await Purchases.purchaseProduct('survival_pack_1');
                          gameState.buyResourcePack();
                          if (context.mounted) {
                            _showModernAlert(context, Localization.t('ui_cargo_arrived', context.read<GameState>().currentLanguage), Localization.t('ui_pack_bought', context.read<GameState>().currentLanguage), Colors.greenAccent, Icons.check_circle);
                          }
                        } catch (e) {
                          if (context.mounted) {
                            _showModernAlert(context, Localization.t('ui_transaction_cancel', context.read<GameState>().currentLanguage), Localization.t('ui_transaction_cancel_desc', context.read<GameState>().currentLanguage), Colors.orangeAccent, Icons.cancel);
                          }
                        }
                      },
                    ),
                    const SizedBox(height: 6),
                    _buildModernActionRow(
                      imagePath: 'assets/icon_elite.png',
                      title: gameState.isAdFree ? Localization.t('ui_elite_active', context.read<GameState>().currentLanguage) : Localization.t('ui_elite_buy', context.read<GameState>().currentLanguage),
                      subtitle: gameState.isAdFree
                          ? Localization.t('ui_elite_desc_active', context.read<GameState>().currentLanguage)
                          : Localization.t('ui_elite_desc_buy', context.read<GameState>().currentLanguage),
                      enabled: !gameState.isAdFree,
                      onTap: () async {
                        AudioManager().playSFX('ui_click.mp3');
                        if (gameState.isAdFree) return;
                        Navigator.pop(context);
                        
                        try {
                          PurchaseResult result = await Purchases.purchaseProduct('elite_edition_5');
                          
                          if (result.customerInfo.entitlements.all["elite_access"]?.isActive == true) {
                            gameState.buyAdFree();
                            if (context.mounted) {
                              _showModernAlert(context, Localization.t('ui_elite_success', context.read<GameState>().currentLanguage), Localization.t('ui_elite_success_desc', context.read<GameState>().currentLanguage), Colors.greenAccent, Icons.star);
                            }
                          }
                        } catch (e) {
                          if (context.mounted) {
                            _showModernAlert(context, Localization.t('ui_transaction_cancel', context.read<GameState>().currentLanguage), Localization.t('ui_transaction_cancel_desc', context.read<GameState>().currentLanguage), Colors.orangeAccent, Icons.cancel);
                          }
                        }
                      },
                    ),
                    const SizedBox(height: 12),
                    _buildActionButton(
                      Localization.t('ui_close', context.read<GameState>().currentLanguage),
                      Icons.close,
                      Colors.white,
                      () {
                        AudioManager().playSFX('ui_click.mp3');
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _showHowToPlayDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.7), 
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(16),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Container(
              constraints: BoxConstraints(
                maxWidth: 600,
                maxHeight: MediaQuery.of(context).size.height * 0.9,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E), 
                image: DecorationImage(
                  image: const AssetImage('assets/dialog_bg.png'),
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.4), BlendMode.darken),
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white24, width: 1.5),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    decoration: const BoxDecoration(
                      color: Colors.black38,
                      border: Border(bottom: BorderSide(color: Colors.white12)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset('assets/icon_logbook.png', width: 32, height: 32),
                        const SizedBox(width: 12),
                        Text(
                      Localization.t('ui_guide_title', context.read<GameState>().currentLanguage),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Scrollbar(
                      thumbVisibility: true,
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(28),
                        physics: const BouncingScrollPhysics(),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildGuideSection(
                              imagePath: 'assets/icon_night.png',
                              color: Colors.amber,
                              title: Localization.t('ui_guide_1', context.read<GameState>().currentLanguage),
                              content: Localization.t('ui_guide_1_desc', context.read<GameState>().currentLanguage),
                            ),
                            _buildGuideSection(
                              imagePath: 'assets/icon_explore.png',
                              color: Colors.greenAccent,
                              title: Localization.t('ui_guide_2', context.read<GameState>().currentLanguage),
                              content: Localization.t('ui_guide_2_desc', context.read<GameState>().currentLanguage),
                            ),
                            _buildGuideSection(
                              imagePath: 'assets/icon_chat.png',
                              color: Colors.purpleAccent,
                              title: Localization.t('ui_guide_3', context.read<GameState>().currentLanguage),
                              content: Localization.t('ui_guide_3_desc', context.read<GameState>().currentLanguage),
                            ),
                            _buildGuideSection(
                              imagePath: 'assets/icon_tool.png',
                              color: Colors.orangeAccent,
                              title: Localization.t('ui_guide_4', context.read<GameState>().currentLanguage),
                              content: Localization.t('ui_guide_4_desc', context.read<GameState>().currentLanguage),
                            ),
                            _buildGuideSection(
                              imagePath: 'assets/icon_radio.png',
                              color: Colors.lightBlue,
                              title: Localization.t('ui_guide_5', context.read<GameState>().currentLanguage),
                              content: Localization.t('ui_guide_5_desc', context.read<GameState>().currentLanguage),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: _buildActionButton(
                      Localization.t('ui_guide_ready', context.read<GameState>().currentLanguage),
                      Icons.check,
                      Colors.white,
                      () {
                        AudioManager().playSFX('ui_click.mp3');
                        Navigator.pop(context);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildGuideSection({
    required String imagePath, 
    required Color color, 
    required String title, 
    required String content
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 28.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.only(right: 16),
            child: Image.asset(imagePath, width: 44, height: 44),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: color,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.1,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  content,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                    height: 1.6,
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  void _showSettingsDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.4),
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              backgroundColor: Colors.transparent,
              insetPadding: const EdgeInsets.all(16),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    width: 320, 
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E1E1E), 
                      image: DecorationImage(
                        image: const AssetImage('assets/dialog_bg.png'),
                        fit: BoxFit.cover,
                        colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.4), BlendMode.darken),
                      ),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white24, width: 1.5),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image.asset('assets/icon_settings.png', width: 48, height: 48),
                        const SizedBox(height: 8),
                        Text(
                      Localization.t('ui_settings', context.read<GameState>().currentLanguage),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildVolumeSliderRow(
                          title: Localization.t('ui_music_vol', context.read<GameState>().currentLanguage),
                          value: AudioManager().bgmVolume,
                          onChanged: (val) {
                            setState(() {
                              AudioManager().setBgmVolume(val);
                            });
                          },
                        ),
                        const SizedBox(height: 8),
                        _buildVolumeSliderRow(
                          title: Localization.t('ui_sfx_vol', context.read<GameState>().currentLanguage),
                          value: AudioManager().sfxVolume,
                          onChanged: (val) {
                            setState(() {
                              AudioManager().setSfxVolume(val);
                            });
                          },
                        ),
                        const SizedBox(height: 12),
                        _buildModernActionRow(
                          title: Localization.t('ui_restore_purchases', context.read<GameState>().currentLanguage),
                          subtitle: Localization.t('ui_restore_desc', context.read<GameState>().currentLanguage),
                          enabled: true,
                          onTap: () {
                            AudioManager().playSFX('ui_click.mp3');
                            Navigator.pop(context);
                            _restorePurchases(context, context.read<GameState>());
                          },
                        ),
                        const SizedBox(height: 6),
                        _buildModernActionRow(
                          title: Localization.t('ui_send_feedback', context.read<GameState>().currentLanguage),
                          subtitle: Localization.t('ui_feedback_desc', context.read<GameState>().currentLanguage),
                          enabled: true,
                          onTap: () async {
                            AudioManager().playSFX('ui_click.mp3');
                            final Uri emailLaunchUri = Uri(
                              scheme: "mailto",
                              path: "grcihaner@gmail.com",
                              query: "subject=Bunker 06 Geri Bildirim",
                            );
                            if (await canLaunchUrl(emailLaunchUri)) {
                              await launchUrl(emailLaunchUri);
                            }
                          },
                        ),
                        const SizedBox(height: 20),
                        _buildActionButton(
                          Localization.t('ui_close', context.read<GameState>().currentLanguage),
                          Icons.close,
                          Colors.white,
                          () {
                            AudioManager().playSFX('ui_click.mp3');
                            Navigator.pop(context);
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class DayChangeAnimation extends StatefulWidget {
  final int day;
  const DayChangeAnimation({super.key, required this.day});

  @override
  State<DayChangeAnimation> createState() => _DayChangeAnimationState();
}

class _DayChangeAnimationState extends State<DayChangeAnimation> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
    _scaleAnimation = Tween<double>(begin: 3.5, end: 1.0).animate(CurvedAnimation(parent: _controller, curve: Curves.bounceOut));
    
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const int totalSlots = 35; 
    int currentMarkIndex = (widget.day - 1) % 31;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          Localization.t('ui_day_ended', context.read<GameState>().currentLanguage, {'day': widget.day.toString()}),
          style: const TextStyle(
            color: Colors.white54,
            fontSize: 22,
            letterSpacing: 4.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 40),
        SizedBox(
          width: 300, 
          height: 280, 
          child: Stack(
            children: [
              Positioned.fill(
                child: Image.asset('assets/calendar_blank.png', fit: BoxFit.fill),
              ),
              
              Padding(
                padding: const EdgeInsets.only(
                  top: 72.0,    
                  bottom: 45.0, 
                  left: 32.0,   
                  right: 29.0,  
                ), 
                child: GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 7, 
                    childAspectRatio: 1.15, 
                    crossAxisSpacing: 0.0,
                    mainAxisSpacing: 2.0,
                  ),
                  itemCount: totalSlots,
                  itemBuilder: (context, index) {
                    
                    if (index < currentMarkIndex) {
                      return Center(
                        child: Icon(Icons.close, color: Colors.redAccent.withOpacity(0.7), size: 28),
                      );
                    } 
                    else if (index == currentMarkIndex) {
                      return AnimatedBuilder(
                        animation: _scaleAnimation,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: _scaleAnimation.value,
                            child: Opacity(
                              opacity: _controller.value.clamp(0.0, 1.0),
                              child: child,
                            ),
                          );
                        },
                        child: Center(
                          child: Icon(Icons.close, color: Colors.redAccent.withOpacity(0.7), size: 28),
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class BreathingWidget extends StatefulWidget {
  final Widget child;
  final int durationMillis;
  const BreathingWidget({super.key, required this.child, required this.durationMillis});

  @override
  State<BreathingWidget> createState() => _BreathingWidgetState();
}

class _BreathingWidgetState extends State<BreathingWidget> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: widget.durationMillis),
      vsync: this,
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 1.0, end: 1.025).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.scale(
          scaleY: _animation.value,
          scaleX: 1.0 + (_animation.value - 1.0) / 3,
          alignment: Alignment.bottomCenter,
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

class ShakeWidget extends StatefulWidget {
  final Widget child;
  final bool isShaking;
  const ShakeWidget({super.key, required this.child, required this.isShaking});

  @override
  State<ShakeWidget> createState() => _ShakeWidgetState();
}

class _ShakeWidgetState extends State<ShakeWidget> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
  }

  @override
  void didUpdateWidget(ShakeWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isShaking && !oldWidget.isShaking) {
      _controller.repeat(reverse: true);
    } else if (!widget.isShaking && oldWidget.isShaking) {
      _controller.stop();
      _controller.reset();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final dx = sin(_controller.value * pi * 4) * 3;
        final dy = cos(_controller.value * pi * 4) * 1.5;
        return Transform.translate(
          offset: widget.isShaking ? Offset(dx, dy) : Offset.zero,
          child: child,
        );
      },
      child: widget.child,
    );
  }
}