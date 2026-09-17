with open('c:\\Projeler\\bunker_60\\lib\\localization.dart', 'r', encoding='utf-8') as f:
    loc_content = f.read()

tr_places = '''      'pharmacy_1': 'Şifa Eczanesi',
      'pharmacy_2': 'Merkez Eczanesi',
      'pharmacy_3': 'Sağlık Eczanesi',
      'pharmacy_4': 'Umut Eczanesi',
      'pharmacy_5': 'Hayat Eczanesi',
      'pharmacy_6': 'Güneş Eczanesi',
      'pharmacy_7': 'Halk Eczanesi',
      'pharmacy_8': 'Yeni Eczane',
      'market_1': 'Güven Süpermarket',
      'market_2': 'Büyük Gıda',
      'market_3': 'Kardeşler Bakkalı',
      'market_4': 'Ucuza Market',
      'market_5': 'Bereket Gıda',
      'market_6': 'Merkez Hipermarket',
      'market_7': 'Bizim Bakkal',
      'market_8': 'Köşe Market',
      'hardware_1': 'Usta Nalburiye',
      'hardware_2': 'Yapı Market',
      'hardware_3': 'Çınar Hırdavat',
      'hardware_4': 'Emin Yapı',
      'hardware_5': 'Kardeşler Nalbur',
'''

en_places = '''      'pharmacy_1': 'Healing Pharmacy',
      'pharmacy_2': 'Central Pharmacy',
      'pharmacy_3': 'Health Pharmacy',
      'pharmacy_4': 'Hope Pharmacy',
      'pharmacy_5': 'Life Pharmacy',
      'pharmacy_6': 'Sun Pharmacy',
      'pharmacy_7': 'Public Pharmacy',
      'pharmacy_8': 'New Pharmacy',
      'market_1': 'Trust Supermarket',
      'market_2': 'Big Grocery',
      'market_3': 'Brothers Grocery',
      'market_4': 'Cheap Market',
      'market_5': 'Blessing Grocery',
      'market_6': 'Central Hypermarket',
      'market_7': 'Our Grocery',
      'market_8': 'Corner Market',
      'hardware_1': 'Master Hardware',
      'hardware_2': 'Build Market',
      'hardware_3': 'Plane Hardware',
      'hardware_4': 'Sure Build',
      'hardware_5': 'Brothers Hardware',
'''

loc_content = loc_content.replace("'place_military':", tr_places + "      'place_military':", 1)
loc_content = loc_content.replace("'place_military':", en_places + "      'place_military':") # second occurrence

with open('c:\\Projeler\\bunker_60\\lib\\localization.dart', 'w', encoding='utf-8') as f:
    f.write(loc_content)

with open('c:\\Projeler\\bunker_60\\lib\\game_state.dart', 'r', encoding='utf-8') as f:
    gs_content = f.read()

gs_content = gs_content.replace(
    'List<String> pharmacyNames = ["Şifa Eczanesi", "Merkez Eczanesi", "Sağlık Eczanesi", "Umut Eczanesi", "Hayat Eczanesi", "Güneş Eczanesi", "Halk Eczanesi", "Yeni Eczane"];',
    'List<String> pharmacyNames = ["pharmacy_1", "pharmacy_2", "pharmacy_3", "pharmacy_4", "pharmacy_5", "pharmacy_6", "pharmacy_7", "pharmacy_8"];'
)

gs_content = gs_content.replace(
    'List<String> marketNames = ["Güven Süpermarket", "Büyük Gıda", "Kardeşler Bakkalı", "Ucuza Market", "Bereket Gıda", "Merkez Hipermarket", "Bizim Bakkal", "Köşe Market"];',
    'List<String> marketNames = ["market_1", "market_2", "market_3", "market_4", "market_5", "market_6", "market_7", "market_8"];'
)

gs_content = gs_content.replace(
    'List<String> hardwareNames = ["Usta Nalburiye", "Yapı Market", "Çınar Hırdavat", "Emin Yapı", "Kardeşler Nalbur"];',
    'List<String> hardwareNames = ["hardware_1", "hardware_2", "hardware_3", "hardware_4", "hardware_5"];'
)

gs_content = gs_content.replace(
    'nearbyPlaces.add(Place(name: pharmacyNames[random.nextInt(pharmacyNames.length)], lat:',
    'nearbyPlaces.add(Place(name: Localization.t(pharmacyNames[random.nextInt(pharmacyNames.length)], currentLanguage), lat:'
)
gs_content = gs_content.replace(
    'nearbyPlaces.add(Place(name: marketNames[random.nextInt(marketNames.length)], lat:',
    'nearbyPlaces.add(Place(name: Localization.t(marketNames[random.nextInt(marketNames.length)], currentLanguage), lat:'
)
gs_content = gs_content.replace(
    'nearbyPlaces.add(Place(name: hardwareNames[random.nextInt(hardwareNames.length)], lat:',
    'nearbyPlaces.add(Place(name: Localization.t(hardwareNames[random.nextInt(hardwareNames.length)], currentLanguage), lat:'
)

with open('c:\\Projeler\\bunker_60\\lib\\game_state.dart', 'w', encoding='utf-8') as f:
    f.write(gs_content)
