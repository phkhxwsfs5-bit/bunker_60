import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'game_state.dart';
import 'bunker_screen.dart';
import 'audio_manager.dart';
import 'localization.dart';

class StartScreen extends StatefulWidget {
  const StartScreen({super.key});

  @override
  State<StartScreen> createState() => _StartScreenState();
}

class _StartScreenState extends State<StartScreen> {
  bool isLoading = false;
  bool hasSave = false;

  @override
  void initState() {
    super.initState();
    _checkSaveGame();
    _initAudioAndPlay(); 
    Future.microtask(() => context.read<GameState>().initLanguage());
  }

  Future<void> _initAudioAndPlay() async {
    await AudioManager().init();
    AudioManager().playBGM('bgm_bunker.mp3');
  }

  Future<void> _checkSaveGame() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      hasSave = prefs.containsKey('currentDay');
    });
  }

  void startNewGame(bool useGPS) async {
    setState(() => isLoading = true);
    
    final gameState = context.read<GameState>();
    gameState.resetGame();

    if (useGPS) {
      await gameState.setLocationWithGPS();
    } else {
      await gameState.setLocationWithIP();
    }

    await gameState.saveGame();

    setState(() => isLoading = false);
    if (mounted) _goToBunker();
  }

  void continueGame() async {
    setState(() => isLoading = true);
    final gameState = context.read<GameState>();
    await gameState.loadGame();
    setState(() => isLoading = false);
    if (mounted) _goToBunker();
  }

  void _goToBunker() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const BunkerScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final gameState = context.watch<GameState>();
    
    return Scaffold(
      backgroundColor: Colors.black,
      body: SizedBox.expand(
        child: FittedBox(
          fit: BoxFit.contain,
          alignment: Alignment.center,
          child: SizedBox(
            width: 900,
            height: 400,
            child: Stack(
              children: [
                Positioned.fill(
                  child: Opacity(
                    opacity: 0.4,
                    child: Image.asset('assets/background.jpg', fit: BoxFit.cover),
                  ),
                ),
                
                Positioned(bottom: 20, right: 20, child: _buildLanguageToggle(gameState)),
                SafeArea(
                  child: Center(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: isLoading
                          ? Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const CircularProgressIndicator(color: Colors.lightBlueAccent),
                                const SizedBox(height: 20),
                                Text(
                                  gameState.loadingMessage.isEmpty ? Localization.t("loading_wait", gameState.currentLanguage) : gameState.loadingMessage,
                                  style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            )
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const SizedBox(height: 10),
                                const Text(
                                  "BUNKER 06",
                                  style: TextStyle(
                                    color: Colors.white, 
                                    fontSize: 36, 
                                    fontWeight: FontWeight.bold, 
                                    letterSpacing: 4
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  Localization.t("start_subtitle", gameState.currentLanguage),
                                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                                ),
                                const SizedBox(height: 25), 
                                
                                if (hasSave) ...[
                                  _buildStartButton(
                                    title: Localization.t("start_continue", gameState.currentLanguage),
                                    subtitle: Localization.t("start_continue_desc", gameState.currentLanguage),
                                    imagePath: 'assets/icon_play.png', 
                                    color: Colors.greenAccent,
                                    onTap: continueGame,
                                  ),
                                  const SizedBox(height: 12),
                                ],
                                
                                _buildStartButton(
                                  title: Localization.t("start_new_gps", gameState.currentLanguage),
                                  subtitle: Localization.t("start_new_gps_desc", gameState.currentLanguage), 
                                  imagePath: 'assets/icon_gps.png', 
                                  color: Colors.lightBlueAccent,
                                  onTap: () => startNewGame(true),
                                ),
                                const SizedBox(height: 12),
                                
                                _buildStartButton(
                                  title: Localization.t("start_new_ip", gameState.currentLanguage),
                                  subtitle: Localization.t("start_new_ip_desc", gameState.currentLanguage),
                                  imagePath: 'assets/icon_lightning.png', 
                                  color: Colors.amber,
                                  onTap: () => startNewGame(false),
                                ),
                                const SizedBox(height: 15), 
                              ],
                            ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  
  Widget _buildLanguageToggle(GameState gameState) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        _buildLangBtn('Türkçe', 'tr', gameState),
        const SizedBox(height: 8),
        _buildLangBtn('English', 'en', gameState),
      ],
    );
  }

  Widget _buildLangBtn(String label, String code, GameState gameState) {
    bool isActive = gameState.currentLanguage == code;
    return GestureDetector(
      onTap: () {
        AudioManager().playSFX('ui_click.mp3');
        gameState.setLanguage(code);
      },
      child: Container(
        width: 100,
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? Colors.white : Colors.black.withOpacity(0.6),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: isActive ? Colors.white : Colors.white54, width: 1),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isActive ? Colors.black : Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildStartButton({
    required String title,
    required String subtitle,
    required String imagePath,
    required Color color, 
    required VoidCallback? onTap,
  }) {
    bool isDisabled = onTap == null;
    
    return InkWell(
      onTap: isDisabled ? null : () {
        AudioManager().playSFX('ui_click.mp3'); 
        onTap();
      },
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: 420, 
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14), 
        decoration: BoxDecoration(
          color: isDisabled ? Colors.black.withOpacity(0.4) : Colors.black.withOpacity(0.7),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start, 
          children: [
            Opacity(
              opacity: isDisabled ? 0.5 : 1.0,
              child: Image.asset(imagePath, width: 44, height: 44),
            ),
            const SizedBox(width: 20), 
            Expanded( 
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start, 
                children: [
                  Text(
                    title, 
                    textAlign: TextAlign.left, 
                    style: TextStyle(
                      color: isDisabled ? Colors.grey : Colors.white, 
                      fontSize: 16, 
                      fontWeight: FontWeight.bold
                    )
                  ),
                  const SizedBox(height: 4), 
                  Text(
                    subtitle, 
                    textAlign: TextAlign.left, 
                    style: TextStyle(
                      color: isDisabled ? Colors.grey.shade700 : Colors.white70, 
                      fontSize: 12 
                    )
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}