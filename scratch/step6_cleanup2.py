with open(r'c:\Projeler\bunker_60\lib\bunker_screen.dart', 'r', encoding='utf-8') as f:
    content = f.read()

content = content.replace("'Hayatta Kalma Paketi (\\$1)'", "Localization.t('ui_survival_pack', context.read<GameState>().currentLanguage)")
content = content.replace("Text(\n                              '${(value * 100).toInt()}%'", "Text(\n                              '${(value * 100).toInt()}%'") # This is just to check

with open(r'c:\Projeler\bunker_60\lib\bunker_screen.dart', 'w', encoding='utf-8') as f:
    f.write(content)
