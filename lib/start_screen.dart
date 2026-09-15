import 'localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'game_state.dart';
import 'bunker_screen.dart';
import 'audio_manager.dart';

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
                                  gameState.loadingMessage.isEmpty ? Loc.get("loading_please_wait") : gameState.loadingMessage,
                                  style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            )
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const SizedBox(height: 10),
                                Text(Loc.get("app_name"),
                                  style: TextStyle(
                                    color: Colors.white, 
                                    fontSize: 36, 
                                    fontWeight: FontWeight.bold, 
                                    letterSpacing: 4
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(Loc.get("subtitle_tagline"),
                                  style: TextStyle(color: Colors.white70, fontSize: 14),
                                ),
                                const SizedBox(height: 25), 
                                
                                if (hasSave) ...[
                                  _buildStartButton(
                                    title: Loc.get("btn_continue"),
                                    subtitle: Loc.get("btn_continue_sub"),
                                    imagePath: 'assets/icon_play.png', 
                                    color: Colors.greenAccent,
                                    onTap: continueGame,
                                  ),
                                  const SizedBox(height: 12),
                                ],
                                
                                _buildStartButton(
                                  title: Loc.get("btn_new_real"),
                                  subtitle: Loc.get("btn_new_real_sub"), 
                                  imagePath: 'assets/icon_gps.png', 
                                  color: Colors.lightBlueAccent,
                                  onTap: () => startNewGame(true),
                                ),
                                const SizedBox(height: 12),
                                
                                _buildStartButton(
                                  title: Loc.get("btn_new_fast"),
                                  subtitle: Loc.get("btn_new_fast_sub"),
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