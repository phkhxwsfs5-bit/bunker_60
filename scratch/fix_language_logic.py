import re

with open(r'c:\Projeler\bunker_60\lib\game_state.dart', 'r', encoding='utf-8') as f:
    content = f.read()

# 1. Update setLanguage
new_setLanguage = """  void setLanguage(String lang) async {
    if (currentLanguage != lang) {
      currentLanguage = lang;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('currentLanguage', lang);
      notifyListeners();
    }
  }"""

old_setLanguage = """  void setLanguage(String lang) {
    if (currentLanguage != lang) {
      currentLanguage = lang;
      saveGame();
      notifyListeners();
    }
  }"""

content = content.replace(old_setLanguage, new_setLanguage)

# 2. Add initLanguage function
initLanguage_code = """  Future<void> initLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey('currentLanguage')) {
      currentLanguage = prefs.getString('currentLanguage')!;
      notifyListeners();
    }
  }"""

# Insert initLanguage after setLanguage
content = content.replace(new_setLanguage, new_setLanguage + "\n\n" + initLanguage_code)

with open(r'c:\Projeler\bunker_60\lib\game_state.dart', 'w', encoding='utf-8') as f:
    f.write(content)
