import re

with open(r'c:\Projeler\bunker_60\lib\game_state.dart', 'r', encoding='utf-8') as f:
    content = f.read()

# 1. Fix exploringCharacter Localization in strings
content = content.replace(
    "'char': exploringCharacter ?? ''",
    "'char': exploringCharacter != null ? Localization.t(exploringCharacter!, currentLanguage) : ''"
)
content = content.replace(
    "'char': characterName",
    "'char': Localization.t(characterName, currentLanguage)"
)

# 2. Fix hardcoded "Baba"
content = content.replace('"Baba"', '"role_father"')
content = content.replace("'Baba'", "'role_father'")

# 3. Fix hardcoded "Anne"
content = content.replace('"Anne"', '"role_mother"')
content = content.replace("'Anne'", "'role_mother'")

# 4. Fix hardcoded Localization.t('role_kid', currentLanguage) in logic comparisons
content = content.replace(
    "char.name == Localization.t('role_kid', currentLanguage)",
    'char.name == "role_kid"'
)
content = content.replace(
    "exploringCharacter == Localization.t('role_kid', currentLanguage)",
    'exploringCharacter == "role_kid"'
)
content = content.replace(
    "getTraitName(Localization.t('role_kid', currentLanguage))",
    'getTraitName("role_kid")'
)

with open(r'c:\Projeler\bunker_60\lib\game_state.dart', 'w', encoding='utf-8') as f:
    f.write(content)
