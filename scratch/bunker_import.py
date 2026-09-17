with open('c:\\Projeler\\bunker_60\\lib\\bunker_screen.dart', 'r', encoding='utf-8') as f:
    content = f.read()

if 'localization.dart' not in content:
    content = content.replace("import 'package:flutter/material.dart';", "import 'package:flutter/material.dart';\nimport 'localization.dart';")
    with open('c:\\Projeler\\bunker_60\\lib\\bunker_screen.dart', 'w', encoding='utf-8') as f:
        f.write(content)
    print('Added import to bunker_screen.dart')
else:
    print('Import already exists')
