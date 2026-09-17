import re

with open('c:\\Projeler\\bunker_60\\lib\\start_screen.dart', 'r', encoding='utf-8') as f:
    content = f.read()

# Add import
content = content.replace("import 'audio_manager.dart';", "import 'audio_manager.dart';\nimport 'localization.dart';")

# Add language toggle widget inside class
toggle_code = '''
  Widget _buildLanguageToggle(GameState gameState) {
    return SafeArea(
      child: Container(
        margin: const EdgeInsets.only(top: 10, right: 10),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.5),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white24, width: 1),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              onTap: () {
                AudioManager().playSFX('ui_click.mp3');
                gameState.setLanguage('tr');
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: gameState.currentLanguage == 'tr' ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Text('TR', style: TextStyle(color: gameState.currentLanguage == 'tr' ? Colors.black : Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
              ),
            ),
            GestureDetector(
              onTap: () {
                AudioManager().playSFX('ui_click.mp3');
                gameState.setLanguage('en');
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: gameState.currentLanguage == 'en' ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Text('EN', style: TextStyle(color: gameState.currentLanguage == 'en' ? Colors.black : Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
              ),
            ),
          ],
        ),
      ),
    );
  }
'''
content = content.replace("Widget _buildStartButton({", toggle_code + "\n  Widget _buildStartButton({")

# Replace texts
content = content.replace('gameState.loadingMessage.isEmpty ? "Lütfen Bekleyin..." : gameState.loadingMessage', 'gameState.loadingMessage.isEmpty ? Localization.t("loading_wait", gameState.currentLanguage) : gameState.loadingMessage')
content = content.replace('"Hayatta kalmak için ne kadar ileri gidebilirsin?"', 'Localization.t("start_subtitle", gameState.currentLanguage)')
content = content.replace('title: "DEVAM ET"', 'title: Localization.t("start_continue", gameState.currentLanguage)')
content = content.replace('subtitle: "Sığınağa geri dön ve kaldığın yerden devam et."', 'subtitle: Localization.t("start_continue_desc", gameState.currentLanguage)')
content = content.replace('title: "YENİ OYUN: GERÇEKÇİ OYNANIŞ"', 'title: Localization.t("start_new_gps", gameState.currentLanguage)')
content = content.replace('subtitle: "Tam konumunu haritalandırır."', 'subtitle: Localization.t("start_new_gps_desc", gameState.currentLanguage)')
content = content.replace('title: "YENİ OYUN: HIZLI OYNANIŞ"', 'title: Localization.t("start_new_ip", gameState.currentLanguage)')
content = content.replace('subtitle: "İzin gerektirmez. Tahmini harita üzerinden ilerler."', 'subtitle: Localization.t("start_new_ip_desc", gameState.currentLanguage)')

# Insert toggle on screen
content = content.replace('SafeArea(', 'Positioned(top: 0, right: 0, child: _buildLanguageToggle(gameState)),\n                SafeArea(')

with open('c:\\Projeler\\bunker_60\\lib\\start_screen.dart', 'w', encoding='utf-8') as f:
    f.write(content)
