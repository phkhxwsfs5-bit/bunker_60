import re

def update_file(filepath):
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()

    # 1. "Onayla"
    content = content.replace('"Onayla"', "Localization.t('ui_confirm', context.read<GameState>().currentLanguage)")
    
    # 2. "Kapat"
    content = content.replace('"Kapat"', "Localization.t('ui_close', context.read<GameState>().currentLanguage)")

    # 3. "Hayatta Kalma Paketi (\$1)"
    content = content.replace('"Hayatta Kalma Paketi (\\$1)"', "Localization.t('ui_survival_pack', context.read<GameState>().currentLanguage)")

    # 4. "RADYO"
    content = content.replace('"RADYO"', "Localization.t('ui_radio', context.read<GameState>().currentLanguage)")

    # 5. "REHBER"
    content = content.replace('"REHBER"', "Localization.t('ui_guide', context.read<GameState>().currentLanguage)")

    # 6. Character name in Dropdown
    content = content.replace(
        "Text(character.name, style: const TextStyle(color: Colors.white)),",
        "Text(Localization.t(character.name, gameState.currentLanguage), style: const TextStyle(color: Colors.white)),"
    )

    # 7. Character trait in Dropdown
    content = content.replace(
        '"(${gameState.getTraitName(character.name)})",',
        '"(${Localization.t(gameState.getTraitName(character.name), gameState.currentLanguage)})",'
    )

    # 8. Character name in Dialog
    content = content.replace(
        "char.name.toUpperCase(),",
        "Localization.t(char.name, gameState.currentLanguage).toUpperCase(),"
    )

    with open(filepath, 'w', encoding='utf-8') as f:
        f.write(content)

update_file(r'c:\Projeler\bunker_60\lib\bunker_screen.dart')

def update_loc(filepath):
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()
    
    tr_append = """      'ui_confirm': 'Onayla',
      'ui_close': 'Kapat',
      'ui_radio': 'RADYO',
      'ui_guide': 'REHBER',
"""
    en_append = """      'ui_confirm': 'Confirm',
      'ui_close': 'Close',
      'ui_radio': 'RADIO',
      'ui_guide': 'GUIDE',
"""

    content = content.replace("'ui_survival_pack': 'Hayatta Kalma Paketi (\\$1)',\n", "'ui_survival_pack': 'Hayatta Kalma Paketi (\\$1)',\n" + tr_append, 1)
    content = content.replace("'ui_survival_pack': 'Survival Pack (\\$1)',\n", "'ui_survival_pack': 'Survival Pack (\\$1)',\n" + en_append, 1)
    
    with open(filepath, 'w', encoding='utf-8') as f:
        f.write(content)

update_loc(r'c:\Projeler\bunker_60\lib\localization.dart')
