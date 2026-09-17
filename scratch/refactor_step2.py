import re

with open('c:\\Projeler\\bunker_60\\lib\\game_state.dart', 'r', encoding='utf-8') as f:
    content = f.read()

# 1. Update Characters initialization
content = content.replace('Character(name: "Baba", imagePrefix: "dad"),', 'Character(name: "role_father", imagePrefix: "dad"),')
content = content.replace('Character(name: "Anne", imagePrefix: "mom"),', 'Character(name: "role_mother", imagePrefix: "mom"),')
content = content.replace('Character(name: "Çocuk", imagePrefix: "kid"),', 'Character(name: "role_kid", imagePrefix: "kid"),')

# 2. Update _allTraits Map definition
content = content.replace('"Baba": [', '"role_father": [')
content = content.replace('"Anne": [', '"role_mother": [')
content = content.replace('"Çocuk": [', '"role_kid": [')

content = content.replace('"Tamirci"', '"trait_mechanic"')
content = content.replace('"Alet kullanımlarında %30 ihtimalle alet kırılmaz."', '"trait_mechanic_desc"')

content = content.replace('"Demir Mide"', '"trait_iron_stomach"')
content = content.replace('"Açlığa karşı daha dirençlidir, yavaş acıkır."', '"trait_iron_stomach_desc"')

content = content.replace('"Koruyucu"', '"trait_protector"')
content = content.replace('"Keşiflerde daha fazla eşya bulur ama yaralanma riski artar."', '"trait_protector_desc"')

content = content.replace('"İri Yarı"', '"trait_big_guy"')
content = content.replace('"Morali çok zor düşer ama daha çabuk susar."', '"trait_big_guy_desc"')

content = content.replace('"Soğukkanlı"', '"trait_cold_blooded"')
content = content.replace('"Gece yaşanan kötü olaylardan (hırsız, ses) etkilenmez."', '"trait_cold_blooded_desc"')

content = content.replace('"Pratik"', '"trait_practical"')
content = content.replace('"Dışarıdaki keşif görevlerinden 1 gün erken döner."', '"trait_practical_desc"')

content = content.replace('"Tutumlu"', '"trait_frugal"')
content = content.replace('"Birine çorba içirdiğinde %25 ihtimalle çorba eksilmez."', '"trait_frugal_desc"')

content = content.replace('"Şifacı"', '"trait_healer"')
content = content.replace('"Bazen hastalandığında ilaçsız kendiliğinden iyileşebilir."', '"trait_healer_desc"')

content = content.replace('"Gözlemci"', '"trait_observer"')
content = content.replace('"Radyo aramalarında askeri frekans bulma şansı daha yüksektir."', '"trait_observer_desc"')

content = content.replace('"Dirençli"', '"trait_resilient"')
content = content.replace('"Susuzluğa karşı olağanüstü dayanıklıdır."', '"trait_resilient_desc"')

content = content.replace('"Çevik"', '"trait_agile"')
content = content.replace('"Keşif görevlerinde asla yaralanmaz."', '"trait_agile_desc"')

content = content.replace('"Neşeli"', '"trait_cheerful"')
content = content.replace('"Onunla sohbet etmek tüm ailenin moralini artırır."', '"trait_cheerful_desc"')

content = content.replace('"Ufaklık"', '"trait_little"')
content = content.replace('"Su ve çorbayı çok daha yavaş tüketir."', '"trait_little_desc"')

content = content.replace('"Şanslı"', '"trait_lucky"')
content = content.replace('"Sığınağa saldıran böcek, hırsız gibi belaları kazara savuşturabilir."', '"trait_lucky_desc"')

content = content.replace('"Gözü Açık"', '"trait_sharp_eyed"')
content = content.replace('"Keşiflerde mutlaka gizli bir ekstra eşya bulur."', '"trait_sharp_eyed_desc"')

# 3. Update random trait assignment
content = content.replace('_allTraits["Baba"]![random.nextInt(5)];', '_allTraits["role_father"]![random.nextInt(5)];')
content = content.replace('_allTraits["Anne"]![random.nextInt(5)];', '_allTraits["role_mother"]![random.nextInt(5)];')
content = content.replace('_allTraits["Çocuk"]![random.nextInt(5)];', '_allTraits["role_kid"]![random.nextInt(5)];')
content = content.replace('currentTraits["Baba"]', 'currentTraits["role_father"]')
content = content.replace('currentTraits["Anne"]', 'currentTraits["role_mother"]')
content = content.replace('currentTraits["Çocuk"]', 'currentTraits["role_kid"]')

with open('c:\\Projeler\\bunker_60\\lib\\game_state.dart', 'w', encoding='utf-8') as f:
    f.write(content)

print("Replaced logic keys in game_state.dart")
