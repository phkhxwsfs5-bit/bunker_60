import re

with open('c:\\Projeler\\bunker_60\\lib\\bunker_screen.dart', 'r', encoding='utf-8') as f:
    content = f.read()

content = content.replace('${char.name}', '${Localization.t(char.name, gameState.currentLanguage)}')
content = content.replace('gameState.getTraitName(char.name)', 'Localization.t(gameState.getTraitName(char.name), gameState.currentLanguage)')
content = content.replace('gameState.getTraitDesc(char.name)', 'Localization.t(gameState.getTraitDesc(char.name), gameState.currentLanguage)')
content = content.replace('Text(char.name', 'Text(Localization.t(char.name, gameState.currentLanguage)')
content = content.replace('Text("${char.name}', 'Text("${Localization.t(char.name, gameState.currentLanguage)}')

# We might also have string checks in startExpedition dialogs, let's see. 

with open('c:\\Projeler\\bunker_60\\lib\\bunker_screen.dart', 'w', encoding='utf-8') as f:
    f.write(content)

with open('c:\\Projeler\\bunker_60\\lib\\localization.dart', 'r', encoding='utf-8') as f:
    loc = f.read()

tr_insert = """      'role_father': 'Baba',
      'role_mother': 'Anne',
      'role_kid': 'Çocuk',
      'trait_mechanic': 'Tamirci',
      'trait_mechanic_desc': 'Alet kullanımlarında %30 ihtimalle alet kırılmaz.',
      'trait_iron_stomach': 'Demir Mide',
      'trait_iron_stomach_desc': 'Açlığa karşı daha dirençlidir, yavaş acıkır.',
      'trait_protector': 'Koruyucu',
      'trait_protector_desc': 'Keşiflerde daha fazla eşya bulur ama yaralanma riski artar.',
      'trait_big_guy': 'İri Yarı',
      'trait_big_guy_desc': 'Morali çok zor düşer ama daha çabuk susar.',
      'trait_cold_blooded': 'Soğukkanlı',
      'trait_cold_blooded_desc': 'Gece yaşanan kötü olaylardan (hırsız, ses) etkilenmez.',
      'trait_practical': 'Pratik',
      'trait_practical_desc': 'Dışarıdaki keşif görevlerinden 1 gün erken döner.',
      'trait_frugal': 'Tutumlu',
      'trait_frugal_desc': 'Birine çorba içirdiğinde %25 ihtimalle çorba eksilmez.',
      'trait_healer': 'Şifacı',
      'trait_healer_desc': 'Bazen hastalandığında ilaçsız kendiliğinden iyileşebilir.',
      'trait_observer': 'Gözlemci',
      'trait_observer_desc': 'Radyo aramalarında askeri frekans bulma şansı daha yüksektir.',
      'trait_resilient': 'Dirençli',
      'trait_resilient_desc': 'Susuzluğa karşı olağanüstü dayanıklıdır.',
      'trait_agile': 'Çevik',
      'trait_agile_desc': 'Keşif görevlerinde asla yaralanmaz.',
      'trait_cheerful': 'Neşeli',
      'trait_cheerful_desc': 'Onunla sohbet etmek tüm ailenin moralini artırır.',
      'trait_little': 'Ufaklık',
      'trait_little_desc': 'Su ve çorbayı çok daha yavaş tüketir.',
      'trait_lucky': 'Şanslı',
      'trait_lucky_desc': 'Sığınağa saldıran böcek, hırsız gibi belaları kazara savuşturabilir.',
      'trait_sharp_eyed': 'Gözü Açık',
      'trait_sharp_eyed_desc': 'Keşiflerde mutlaka gizli bir ekstra eşya bulur.',
"""

en_insert = """      'role_father': 'Father',
      'role_mother': 'Mother',
      'role_kid': 'Kid',
      'trait_mechanic': 'Mechanic',
      'trait_mechanic_desc': '30% chance tools won\\'t break when used.',
      'trait_iron_stomach': 'Iron Stomach',
      'trait_iron_stomach_desc': 'More resistant to hunger, gets hungry slower.',
      'trait_protector': 'Protector',
      'trait_protector_desc': 'Finds more items on expeditions but injury risk increases.',
      'trait_big_guy': 'Big Guy',
      'trait_big_guy_desc': 'Morale drops very slowly but gets thirsty faster.',
      'trait_cold_blooded': 'Cold Blooded',
      'trait_cold_blooded_desc': 'Not affected by bad night events (thief, noise).',
      'trait_practical': 'Practical',
      'trait_practical_desc': 'Returns 1 day early from outside expeditions.',
      'trait_frugal': 'Frugal',
      'trait_frugal_desc': '25% chance soup won\\'t be consumed when feeding someone.',
      'trait_healer': 'Healer',
      'trait_healer_desc': 'Sometimes heals naturally without medicine when sick.',
      'trait_observer': 'Observer',
      'trait_observer_desc': 'Higher chance to find military frequencies on radio.',
      'trait_resilient': 'Resilient',
      'trait_resilient_desc': 'Extraordinarily resistant to thirst.',
      'trait_agile': 'Agile',
      'trait_agile_desc': 'Never gets injured on expeditions.',
      'trait_cheerful': 'Cheerful',
      'trait_cheerful_desc': 'Talking with them increases the whole family\\'s morale.',
      'trait_little': 'Little One',
      'trait_little_desc': 'Consumes water and soup much slower.',
      'trait_lucky': 'Lucky',
      'trait_lucky_desc': 'Can accidentally fend off threats like bugs or thieves.',
      'trait_sharp_eyed': 'Sharp-eyed',
      'trait_sharp_eyed_desc': 'Always finds a hidden extra item on expeditions.',
"""

loc = loc.replace("'tr': {", "'tr': {\n" + tr_insert)
loc = loc.replace("'en': {", "'en': {\n" + en_insert)

with open('c:\\Projeler\\bunker_60\\lib\\localization.dart', 'w', encoding='utf-8') as f:
    f.write(loc)
