import re
import sys

def find_turkish(filepath):
    print(f'\n--- {filepath} ---')
    with open(filepath, 'r', encoding='utf-8') as f:
        lines = f.readlines()
    
    for i, line in enumerate(lines):
        matches = re.finditer(r'\"([^\"]*?[şğüöçıİĞÜŞÖÇ][^\"]*?)\"|\'([^\']*?[şğüöçıİĞÜŞÖÇ][^\']*?)\'', line)
        for m in matches:
            print(f"Line {i+1}: {m.group(0)}")

find_turkish(r'c:\Projeler\bunker_60\lib\game_state.dart')
find_turkish(r'c:\Projeler\bunker_60\lib\bunker_screen.dart')
