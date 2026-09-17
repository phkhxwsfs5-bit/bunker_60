import os
import re

files_to_check = [
    r'c:\Projeler\bunker_60\lib\bunker_screen.dart',
    r'c:\Projeler\bunker_60\lib\game_state.dart',
    r'c:\Projeler\bunker_60\lib\start_screen.dart',
    r'c:\Projeler\bunker_60\lib\main.dart',
    r'c:\Projeler\bunker_60\lib\map_screen.dart',
]

def scan_file(filepath):
    if not os.path.exists(filepath):
        return
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()

    # Find all strings in single or double quotes
    strings = re.findall(r'([\"\'])(.*?)\1', content)
    
    suspicious = []
    for quote, text in strings:
        if len(text) < 2: continue
        if text.startswith('assets/'): continue
        if text.startswith('ui_') or text.startswith('bgm_') or text.startswith('sfx_'): continue
        if text.startswith('http'): continue
        if text in ['tr', 'en', 'Roboto', 'BUNKER 06']: continue
        if text.endswith('.json') or text.endswith('.mp3') or text.endswith('.png') or text.endswith('.jpg'): continue
        # Ignore localization keys, typical keys don't have spaces and are snake case
        if re.match(r'^[a-z0-9_]+$', text): continue
        if 'Localization.t' in text: continue
        
        # We are looking for Turkish characters or spaces, indicating a sentence/phrase
        if ' ' in text or any(c in text for c in 'çğıöşüÇĞİÖŞÜ'):
            suspicious.append(text)
            
    if suspicious:
        print(f'--- {os.path.basename(filepath)} ---')
        for s in suspicious:
            print(f'  {s}')

for f in files_to_check:
    scan_file(f)
