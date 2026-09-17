with open(r'c:\Projeler\bunker_60\lib\game_state.dart', 'r', encoding='utf-8') as f:
    gs_content = f.read()

gs_content = gs_content.replace(
    "Localization.t('ending_heli', currentLanguage, {'char': exploringCharacter})", 
    "Localization.t('ending_heli', currentLanguage, {'char': exploringCharacter ?? ''})"
)
gs_content = gs_content.replace(
    "Localization.t('ending_utopia', currentLanguage, {'char': exploringCharacter})", 
    "Localization.t('ending_utopia', currentLanguage, {'char': exploringCharacter ?? ''})"
)
gs_content = gs_content.replace(
    "Localization.t('ending_utopia_fail', currentLanguage, {'char': exploringCharacter})", 
    "Localization.t('ending_utopia_fail', currentLanguage, {'char': exploringCharacter ?? ''})"
)
gs_content = gs_content.replace(
    "Localization.t('expedition_success_pharmacy', currentLanguage, {'char': exploringCharacter})", 
    "Localization.t('expedition_success_pharmacy', currentLanguage, {'char': exploringCharacter ?? ''})"
)
gs_content = gs_content.replace(
    "Localization.t('expedition_success_hardware', currentLanguage, {'char': exploringCharacter})", 
    "Localization.t('expedition_success_hardware', currentLanguage, {'char': exploringCharacter ?? ''})"
)

with open(r'c:\Projeler\bunker_60\lib\game_state.dart', 'w', encoding='utf-8') as f:
    f.write(gs_content)
