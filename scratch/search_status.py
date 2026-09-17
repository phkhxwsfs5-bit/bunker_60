with open('c:\\Projeler\\bunker_60\\lib\\bunker_screen.dart', 'r', encoding='utf-8') as f:
    for i, line in enumerate(f):
        if 'sick' in line or 'Hasta' in line or 'İyi' in line or 'status' in line:
            print(f'{i+1}: {line.strip()}')
