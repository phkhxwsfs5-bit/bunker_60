import re

with open('c:\\Projeler\\bunker_60\\lib\\localization.dart', 'r', encoding='utf-8') as f:
    loc_content = f.read()

# 1. Update the t method
t_method_old = """  static String t(String key, String lang) {
    return _strings[lang]?[key] ?? _strings['tr']?[key] ?? key;
  }"""
t_method_new = """  static String t(String key, String lang, [Map<String, String>? args]) {
    String text = _strings[lang]?[key] ?? _strings['tr']?[key] ?? key;
    if (args != null) {
      args.forEach((k, v) {
        text = text.replaceAll('{$k}', v);
      });
    }
    return text;
  }"""
loc_content = loc_content.replace(t_method_old, t_method_new)

# 2. Add new strings for TR
tr_insert = """
      'loading_radar': 'Radar Açılıyor...',
      'loading_map_cache': 'Harita Hafızadan Yükleniyor...',
      'loading_map_api': 'Gerçek Dünya Verileri Çekiliyor (API)...',
      'loading_map_fallback': 'Sinyal Zayıf. Tahmini Harita Kullanılıyor...',
      'place_military': 'Askeri Tahliye Noktası',
      'place_utopia': 'Gizli Yeraltı Kolonisi (Giriş için 5 Su/5 Çorba)',
      'expedition_ambush': 'KÖTÜ HABER! {char}, dönüş yolunda yağmacıların pususuna düştü. Yaralı döndü!',
      'expedition_empty': '{char} sığınağa döndü. Gittiği bölge ({dest}) yağmalanmış, bir şey bulamadı.',
      'expedition_success_market': 'BAŞARI! {char} marketinden {water} su ve {soup} çorba getirdi!',
      'expedition_success': 'BAŞARI! {char} yanına {water} su ve {soup} çorba getirdi!',
      'death_msg': 'KÖTÜ HABER! Bu sabah uyandığımızda {names} nefes almıyordu. Açlık ve susuzluğa daha fazla dayanamadı...\\n\\n',
"""
loc_content = loc_content.replace("'lang_tr': 'TR',", tr_insert + "\n      'lang_tr': 'TR',")

# 3. Add new strings for EN
en_insert = """
      'loading_radar': 'Radar is Booting...',
      'loading_map_cache': 'Loading Map from Cache...',
      'loading_map_api': 'Fetching Real-World Data (API)...',
      'loading_map_fallback': 'Weak Signal. Using Estimated Map...',
      'place_military': 'Military Evacuation Point',
      'place_utopia': 'Secret Underground Colony (Entry: 5 Water/5 Soup)',
      'expedition_ambush': 'BAD NEWS! {char} was ambushed by raiders on the way back. Returned injured!',
      'expedition_empty': '{char} returned to the bunker. The {dest} was already looted, found nothing.',
      'expedition_success_market': 'SUCCESS! {char} brought back {water} water and {soup} soup from the market!',
      'expedition_success': 'SUCCESS! {char} brought back {water} water and {soup} soup!',
      'death_msg': 'BAD NEWS! When we woke up this morning, {names} were not breathing. They couldn\\'t survive the hunger and thirst...\\n\\n',
"""
loc_content = loc_content.replace("'lang_en': 'EN',", en_insert + "\n      'lang_en': 'EN',")

with open('c:\\Projeler\\bunker_60\\lib\\localization.dart', 'w', encoding='utf-8') as f:
    f.write(loc_content)

# Update game_state.dart
with open('c:\\Projeler\\bunker_60\\lib\\game_state.dart', 'r', encoding='utf-8') as f:
    gs_content = f.read()

# Add import if missing
if "import 'localization.dart';" not in gs_content:
    gs_content = gs_content.replace("import 'models.dart';", "import 'models.dart';\nimport 'localization.dart';")

# 1. Replace loadingMessage strings
gs_content = gs_content.replace('loadingMessage = "Radar Açılıyor...";', 'loadingMessage = Localization.t("loading_radar", currentLanguage);')
gs_content = gs_content.replace('loadingMessage = "Harita Hafızadan Yükleniyor...";', 'loadingMessage = Localization.t("loading_map_cache", currentLanguage);')
gs_content = gs_content.replace('loadingMessage = "Gerçek Dünya Verileri Çekiliyor (API)...";', 'loadingMessage = Localization.t("loading_map_api", currentLanguage);')
gs_content = gs_content.replace('loadingMessage = "Sinyal Zayıf. Tahmini Harita Kullanılıyor...";', 'loadingMessage = Localization.t("loading_map_fallback", currentLanguage);')

# 2. Replace places
gs_content = gs_content.replace('Place(name: "Askeri Tahliye Noktası"', 'Place(name: Localization.t("place_military", currentLanguage)')
gs_content = gs_content.replace('Place(name: "Gizli Yeraltı Kolonisi (Giriş için 5 Su/5 Çorba)"', 'Place(name: Localization.t("place_utopia", currentLanguage)')

# 3. Replace expedition messages
gs_content = gs_content.replace(
    'resultText = "KÖTÜ HABER! $exploringCharacter, dönüş yolunda yağmacıların pususuna düştü. Yaralı döndü!";',
    'resultText = Localization.t("expedition_ambush", currentLanguage, {"char": Localization.t(exploringCharacter!, currentLanguage)});'
)
gs_content = gs_content.replace(
    'resultText = "$exploringCharacter sığınağa döndü. Gittiği bölge ($exploringDestinationName) yağmalanmış, bir şey bulamadı.";',
    'resultText = Localization.t("expedition_empty", currentLanguage, {"char": Localization.t(exploringCharacter!, currentLanguage), "dest": exploringDestinationName!});'
)
gs_content = gs_content.replace(
    'resultText = "BAŞARI! $exploringCharacter marketinden $foundWater su ve $foundSoup çorba getirdi!";',
    'resultText = Localization.t("expedition_success_market", currentLanguage, {"char": Localization.t(exploringCharacter!, currentLanguage), "water": foundWater.toString(), "soup": foundSoup.toString()});'
)
gs_content = gs_content.replace(
    'resultText = "BAŞARI! $exploringCharacter yanına $foundWater su ve $foundSoup çorba getirdi!";',
    'resultText = Localization.t("expedition_success", currentLanguage, {"char": Localization.t(exploringCharacter!, currentLanguage), "water": foundWater.toString(), "soup": foundSoup.toString()});'
)

# 4. Replace death message
gs_content = gs_content.replace(
    'String deathMsg = "KÖTÜ HABER! Bu sabah uyandığımızda ${diedTonight.join(\' ve \')} nefes almıyordu. Açlık ve susuzluğa daha fazla dayanamadı...\\n\\n";',
    'String names = diedTonight.map((n) => Localization.t(n, currentLanguage)).join(" & ");\n      String deathMsg = Localization.t("death_msg", currentLanguage, {"names": names});'
)

with open('c:\\Projeler\\bunker_60\\lib\\game_state.dart', 'w', encoding='utf-8') as f:
    f.write(gs_content)

print("Step 3 replacements completed.")
