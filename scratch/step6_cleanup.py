import re

def update_file(filepath, replacements, localization_calls=True):
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()

    for k, v in replacements.items():
        # find the exact string and replace it
        if localization_calls:
            content = content.replace(f'"{k}"', v)
            content = content.replace(f"'{k}'", v)
        else:
            # use regex to replace multiline strings like guide descriptions
            # this is for bunker_screen where we might have missed some
            escaped_k = re.escape(k)
            # handle cases where there are newlines or different spaces in the code
            # Actually, instead of regex, let's just do partial string replace
            content = content.replace(k, v)

    with open(filepath, 'w', encoding='utf-8') as f:
        f.write(content)


# --- game_state.dart replacements ---
gs_replacements = {
    'Herkes öldü... Sığınak artık sessiz bir mezar.': "Localization.t('event_all_dead', currentLanguage)",
    "${currentEvent.description}\\n\\n$exploringCharacter hala dışarıda, dönmesini bekliyoruz.": "Localization.t('event_char_outside', currentLanguage, {'desc': currentEvent!.description, 'char': exploringCharacter ?? ''})",
    "TELSİZ: $exploringCharacter terk edilmiş bir dükkanda kilitli bir çelik kasa buldu. Açmayı denesin mi?": "Localization.t('event_radio_safe', currentLanguage, {'char': exploringCharacter ?? ''})",
    "Aletle Zorla (Alet)": "Localization.t('action_force_tool', currentLanguage)",
    "Kasa açıldı! İçinden 2 Su ve 2 Çorba çıktı. $exploringCharacter yola devam ediyor.": "Localization.t('event_safe_opened', currentLanguage, {'char': exploringCharacter ?? ''})",
    "Sessizce Bırak": "Localization.t('action_leave_silently', currentLanguage)",
    "Riski göze almadık. $exploringCharacter sessizce keşfe devam ediyor.": "Localization.t('event_safe_left', currentLanguage, {'char': exploringCharacter ?? ''})",
    "TELSİZ: $exploringCharacter yolda yaralı, çaresiz bir yabancıya rastladı. Telsizden 'Ona yardım edeyim mi?' diye soruyor.": "Localization.t('event_radio_stranger', currentLanguage, {'char': exploringCharacter ?? ''})",
    "Su Ver (-1 Su)": "Localization.t('action_give_water', currentLanguage)",
    "Yabancı suyu içti ve minnettarlıkla bize kendi kendine yetebilen efsanevi 'Ütopya' kolonisinin koordinatlarını verdi! Haritaya eklendi.": "Localization.t('event_stranger_utopia', currentLanguage)",
    "Yabancı minnettarlıkla çantasındaki son İlk Yardım Kitini bize verdi.": "Localization.t('event_stranger_medkit', currentLanguage)",
    "Görmezden Gel": "Localization.t('action_ignore', currentLanguage)",
    "Acımasız bir dünyadayız. Yabancıyı ölüme terk edip yola devam ettik. (Herkesin morali düştü)": "Localization.t('event_stranger_ignored', currentLanguage)",
    "TELSİZ: $exploringCharacter dost canlısı görünen bir hayatta kalanla karşılaştı. 2 Çorba karşılığında 1 İlk Yardım Kiti takası teklif ediyor.": "Localization.t('event_radio_trader', currentLanguage, {'char': exploringCharacter ?? ''})",
    "Takas Yap (-2 Çorba)": "Localization.t('action_trade', currentLanguage)",
    "Takas başarılı! İlk Yardım Kiti envantere eklendi.": "Localization.t('event_trade_success', currentLanguage)",
    "Teklifi reddettik. Karakterimiz kendi yoluna gitti.": "Localization.t('event_trade_rejected', currentLanguage)",
    "Sığınağa ulaştık. Şimdilik güvendeyiz. Bombanın sesi kulaklarımızı sağır edecek gibiydi. Dışarı çıkamayız.": "Localization.t('log_first_day', currentLanguage)",
    "İlk gece çok zordu. Yukarıdan garip tıkırtılar duyduk. Ampul sürekli göz kırpıyor.": "Localization.t('log_first_night', currentLanguage)",
    "RADYODA NET BİR SİNYAL! 'Hayatta kalanlar, yakınlardaki Askeri Tahliye Noktasına gelin. Kurtarma ekipleri hazır.' Haritaya eklendi!": "Localization.t('radio_military_found', currentLanguage)",
    "Radyodan parazitli bir ses geliyor... 'Orada kimse var mı? Lütfen yardım edin...' Ses aniden kesildi.": "Localization.t('radio_signal_lost', currentLanguage)",
    "Askeri bir frekans yakaladık! 'Sektör 4 temiz. Beklemede kalın.' Bizim için umut olabilir.": "Localization.t('radio_military_hope', currentLanguage)",
    "Sadece parazit ve statik elektrik sesi var. Dışarıda kimse kalmamış gibi...": "Localization.t('radio_static', currentLanguage)",
    "Garip bir müzik kanalı bulduk. Çalan şarkı savaş öncesi günleri hatırlattı. Herkesin morali biraz olsun yerine geldi.": "Localization.t('radio_music_good', currentLanguage)",
    "Radyoyu sadece müzik dinlemek için açtık. Klasik müzik sığınağın soğuk duvarlarında yankılandı. Moraller düzeldi.": "Localization.t('radio_music_classic', currentLanguage)",
    "Dışarıdan kapı zorlandı! Askerler içeri girdi. Başardık, kurtulduk!": "Localization.t('ending_army', currentLanguage)",
    "Aletle Ez": "Localization.t('action_crush_tool', currentLanguage)",
    "Tamir Et (Alet)": "Localization.t('action_fix_tool', currentLanguage)",
    "Tamir Etme": "Localization.t('action_dont_fix', currentLanguage)",
    "Silahla Korkut (Cephane)": "Localization.t('action_scare_gun', currentLanguage)",
    "Sessizce Bekle": "Localization.t('action_wait_silently', currentLanguage)",
    "Uzun Uzun Sohbet Et": "Localization.t('action_chat_long', currentLanguage)",
    "GPS Konumu": "Localization.t('gps_location', currentLanguage)",
    "IP Hata: $e": "Localization.t('ip_error', currentLanguage, {'e': e.toString()})",
}

update_file(r'c:\Projeler\bunker_60\lib\game_state.dart', gs_replacements)


# --- bunker_screen.dart replacements ---
bs_replacements = {
    'Medkit Kullan (-1 Medkit)': "Localization.t('ui_use_medkit', gameState.currentLanguage)",
    'Sohbet Et': "Localization.t('ui_chat', gameState.currentLanguage)",
    'HEDEF BULUNAMADI': "Localization.t('ui_target_not_found', gameState.currentLanguage)",
    'Sinyal Tara': "Localization.t('ui_scan_signal_btn', context.read<GameState>().currentLanguage)",
    'KARABORSA / DESTEK': "Localization.t('ui_black_market', context.read<GameState>().currentLanguage)",
    'Acil Durum Sinyali': "Localization.t('ui_emergency_signal', context.read<GameState>().currentLanguage)",
    'Hayatta Kalma Paketi ($1)': "Localization.t('ui_survival_pack', context.read<GameState>().currentLanguage)",
}

update_file(r'c:\Projeler\bunker_60\lib\bunker_screen.dart', bs_replacements)

# For the guide strings, they were probably split on multiple lines. Let's fix them with regex or partial replace
with open(r'c:\Projeler\bunker_60\lib\bunker_screen.dart', 'r', encoding='utf-8') as f:
    bs_content = f.read()

guide_text_1 = "Sığınakta ailenizle birlikte olabildiğince uzun süre hayatta kalmak."
guide_text_2 = "Ailenin her üyesi oyuna tamamen rastgele yeteneklerle"
bs_content = re.sub(r'\"Sığınakta ailenizle birlikte.*oyun biter\.\"', 
                   r'Localization.t(\'ui_guide_1_desc\', dialogContext.read<GameState>().currentLanguage)', bs_content, flags=re.DOTALL)
bs_content = re.sub(r'\"Oyun, cihazınızın konumunu kullanarak.*dikkatli olun!\"', 
                   r'Localization.t(\'ui_guide_2_desc\', dialogContext.read<GameState>().currentLanguage)', bs_content, flags=re.DOTALL)
bs_content = re.sub(r'\"Ailenin her üyesi oyuna tamamen.*yüksek tutun\.\"', 
                   r'Localization.t(\'ui_guide_3_desc\', dialogContext.read<GameState>().currentLanguage)', bs_content, flags=re.DOTALL)
bs_content = re.sub(r'\"• Su & Çorba: Temel.*için şarttır\.\"', 
                   r'Localization.t(\'ui_guide_4_desc\', dialogContext.read<GameState>().currentLanguage)', bs_content, flags=re.DOTALL)
bs_content = re.sub(r'\"Kurtuluş için tek yol.*ailenizi kurtarın\.\"', 
                   r'Localization.t(\'ui_guide_5_desc\', dialogContext.read<GameState>().currentLanguage)', bs_content, flags=re.DOTALL)

with open(r'c:\Projeler\bunker_60\lib\bunker_screen.dart', 'w', encoding='utf-8') as f:
    f.write(bs_content)

