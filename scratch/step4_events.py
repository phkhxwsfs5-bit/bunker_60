import re

with open(r'c:\Projeler\bunker_60\lib\game_state.dart', 'r', encoding='utf-8') as f:
    gs_content = f.read()

replacements = {
    '"Dışarıdan sesler geliyor! Kapağa vuruyorlar. \'Ordu Birlikleri, açın!\' Kurtulduk mu?"': "Localization.t('event_army_fake', currentLanguage)",
    '"Kapağı Aç"': "Localization.t('action_open_hatch', currentLanguage)",
    '"Devasa, parlayan mutant hamamböcekleri çorba kutularımıza saldırıyor!"': "Localization.t('event_roaches', currentLanguage)",
    '"Hepsini ezerek öldürdük. Eşyalarımız güvende."': "Localization.t('event_roaches_killed', currentLanguage)",
    '"Böcekler konserveleri açamayıp kendi kendilerine gittiler! Şanslıyız."': "Localization.t('event_roaches_left', currentLanguage)",
    '"Böcekler 2 çorbamızı yiyip uzaklaştı..."': "Localization.t('event_roaches_stole', currentLanguage)",
    '"Sığınağın havalandırması bozuldu. İçeriye zehirli hava sızıyor."': "Localization.t('event_vent_broken', currentLanguage)",
    '"Zor oldu ama tamir ettik. Ciğerlerimiz bayram etti."': "Localization.t('event_vent_fixed', currentLanguage)",
    '"Hava kalitesi çok kötü, herkes hastalandı."': "Localization.t('event_vent_sick', currentLanguage)",
    '"GÜM! GÜM! Gece vakti sığınak kapağı yumruklanıyor. Seslerden anladığımız kadarıyla yağmacılar!"': "Localization.t('event_raiders', currentLanguage)",
    '"Havaya bir el ateş ettik. Adım sesleri koşarak uzaklaştı."': "Localization.t('event_raiders_scared', currentLanguage)",
    '"Kapağı kırıp içeri daldılar! Erzaklarımızın bir kısmını (2 Su, 2 Çorba) çalıp gittiler."': "Localization.t('event_raiders_stole', currentLanguage)",
    '"Duvardaki eski borulardan şiddetli bir tıslama sesi geliyor. Sığınağa boğucu bir gaz sızıyor!"': "Localization.t('event_gas_leak', currentLanguage)",
    '"Bezlerle Tıka"': "Localization.t('action_plug_rags', currentLanguage)",
    '"Bütün gece zehirli gazı soluyarak borudaki çatlağı bezlerle tıkamaya çalıştık. Sızıntı durdu ama çok yorulduk, birimiz hastalandı."': "Localization.t('event_gas_tired', currentLanguage)",
    '"Köşedeki kutuların arkasında kapağı şişkin ve etiketi silinmiş iki konserve bulduk. Erzaklarımıza ekleyelim mi?"': "Localization.t('event_sus_cans', currentLanguage)",
    '"Stoğa Ekle"': "Localization.t('action_add_stock', currentLanguage)",
    '"Konserveler hala sağlammış! Gıdamız arttı (+2 Çorba)."': "Localization.t('event_cans_good', currentLanguage)",
    '"Kötü fikirdi. Kutular delikmiş, sızan pis koku birimizi hasta etti."': "Localization.t('event_cans_bad', currentLanguage)",
    '"Çöpe At"': "Localization.t('action_throw_away', currentLanguage)",
    '"Riske girmeye değmez. Çöpe attık."': "Localization.t('event_cans_thrown', currentLanguage)",
    '"Sığınağın karanlığı ve sessizliği yavaş yavaş akıl sağlığımızı etkiliyor. Biri köşede kendi kendine konuşuyor."': "Localization.t('event_madness', currentLanguage)",
    '"Eski günlerden, güzel anılardan bahsettik. Zor oldu ama toparlandık."': "Localization.t('event_madness_cured', currentLanguage)",
    
    '"$currentDay. Gün. Sığınakta sessiz bir bekleyiş sürüyor. Kaynakları idareli kullanmalıyız."': "Localization.t('log_quiet_day', currentLanguage, {'day': currentDay.toString()})",
    '"$characterName, ${destination.name} bölgesine yola çıktı. Umarım sağ döner."': "Localization.t('log_expedition_start', currentLanguage, {'char': characterName, 'dest': destination.name})",
    '"İnanamıyorum! Kurtarma helikopteri sığınağın tam üzerine indi! $exploringCharacter yolu açtı. BAŞARDIK, KURTULDUK!"': "Localization.t('ending_heli', currentLanguage, {'char': exploringCharacter})",
    '"Erzaklarımızı sırtlandık ve $exploringCharacter rehberliğinde Gizli Yeraltı Kolonisine ulaştık. Burada yeni bir hayat başlıyor. KAZANDINIZ!"': "Localization.t('ending_utopia', currentLanguage, {'char': exploringCharacter})",
    '"HAYAL KIRIKLIĞI! $exploringCharacter koloniyi buldu ama içeri kabul edilmemiz için yanımızda en az 5 Su ve 5 Çorba götürmemiz gerektiğini söylediler. Erzak yetersizliğinden geri çevrildik."': "Localization.t('ending_utopia_fail', currentLanguage, {'char': exploringCharacter})",
    '"BAŞARI! $exploringCharacter eczaneden İlk Yardım Kiti ve Su buldu!"': "Localization.t('expedition_success_pharmacy', currentLanguage, {'char': exploringCharacter})",
    '"BAŞARI! $exploringCharacter nalburdan Alet Çantası buldu!"': "Localization.t('expedition_success_hardware', currentLanguage, {'char': exploringCharacter})",
    
    '"Önbellek okuma hatası: $e"': "Localization.t('error_cache_read', currentLanguage, {'e': e.toString()})",
    '"Bilinmeyen Bölge"': "Localization.t('unknown_region', currentLanguage)",
}

for k, v in replacements.items():
    gs_content = gs_content.replace(k, v)

# "Çocuk" replacement
gs_content = gs_content.replace('"Çocuk"', "Localization.t('role_kid', currentLanguage)")
gs_content = gs_content.replace("'Çocuk'", "Localization.t('role_kid', currentLanguage)")

with open(r'c:\Projeler\bunker_60\lib\game_state.dart', 'w', encoding='utf-8') as f:
    f.write(gs_content)
