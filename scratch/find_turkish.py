import re

def find_turkish(filepath):
    print(f'\n--- {filepath} ---')
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()
    
    matches = re.finditer(r'\"([^\"]*?[şğüöçıİĞÜŞÖÇ][^\"]*?)\"|\'([^\']*?[şğüöçıİĞÜŞÖÇ][^\']*?)\'', content)
    for m in matches:
        print(m.group(0))

find_turkish(r'c:\Projeler\bunker_60\lib\bunker_screen.dart')
find_turkish(r'c:\Projeler\bunker_60\lib\start_screen.dart')
