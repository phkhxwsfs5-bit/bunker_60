import re

with open(r'c:\Projeler\bunker_60\lib\bunker_screen.dart', 'r', encoding='utf-8') as f:
    content = f.read()

replacements = {
    '"BAŞARILI"': "Localization.t('ui_success', context.read<GameState>().currentLanguage)",
    '"Satın alımlarınız başarıyla geri yüklendi! Reklamlar kaldırıldı."': "Localization.t('ui_restore_success', context.read<GameState>().currentLanguage)",
    '"BİLGİ"': "Localization.t('ui_info', context.read<GameState>().currentLanguage)",
    '"Geri yüklenecek aktif bir satın alım bulunamadı."': "Localization.t('ui_restore_fail', context.read<GameState>().currentLanguage)",
    '"BAĞLANTI HATASI"': "Localization.t('ui_conn_error', context.read<GameState>().currentLanguage)",
    '"Sunucuyla iletişim kurulamadı. İnternetinizi kontrol edin."': "Localization.t('ui_conn_error_desc', context.read<GameState>().currentLanguage)",
    '"SİNYAL KESİLDİ"': "Localization.t('ui_signal_lost', context.read<GameState>().currentLanguage)",
    '"HAYATTA KALINAN GÜN"': "Localization.t('ui_days_survived', context.read<GameState>().currentLanguage)",
    '"ANA MENÜYE DÖN"': "Localization.t('ui_back_to_menu', context.read<GameState>().currentLanguage)",
    '"SIĞINAKTA GEÇEN GÜN"': "Localization.t('ui_bunker_days', context.read<GameState>().currentLanguage)",
    '"Su İçir (-1 Su)"': "Localization.t('ui_give_water', gameState.currentLanguage)",
    '"Susuzluğunu giderir."': "Localization.t('ui_give_water_desc', gameState.currentLanguage)",
    '"Çorba Yedir (-1 Çorba)"': "Localization.t('ui_give_soup', gameState.currentLanguage)",
    '"Açlığını giderir."': "Localization.t('ui_give_soup_desc', gameState.currentLanguage)",
    '"Hastalığı/Yarayı iyileştirir."': "Localization.t('ui_give_medkit_desc', gameState.currentLanguage)",
    '"Moralini yükseltir. (Günde 1 kez)"': "Localization.t('ui_chat_desc', gameState.currentLanguage)",
    '"GÜN ${gameState.currentDay}"': "Localization.t('ui_day_counter', gameState.currentLanguage, {'day': gameState.currentDay.toString()})",
    '"Çorba"': "Localization.t('ui_soup', gameState.currentLanguage)",
    '"İlk Yardım Kiti"': "Localization.t('ui_medkit', gameState.currentLanguage)",
    '"Alet Çantası"': "Localization.t('ui_tool', gameState.currentLanguage)",
    '"MAĞAZA"': "Localization.t('ui_store', gameState.currentLanguage)",
    '"GÜNLÜK KAYITLARI"': "Localization.t('ui_logs', gameState.currentLanguage)",
    '"KEŞİF SÜRÜYOR"': "Localization.t('ui_expedition_ongoing', gameState.currentLanguage)",
    '"KEŞFE ÇIK"': "Localization.t('ui_expedition_start', gameState.currentLanguage)",
    '"GÜNÜ BİTİR"': "Localization.t('ui_end_day', gameState.currentLanguage)",
    '"Keşif Görevi Planla"': "Localization.t('ui_plan_expedition', context.read<GameState>().currentLanguage)",
    '"Hedef Seçimi"': "Localization.t('ui_select_target', context.read<GameState>().currentLanguage)",
    '"Gönderilecek Karakter"': "Localization.t('ui_select_char', context.read<GameState>().currentLanguage)",
    '"İptal"': "Localization.t('ui_cancel', context.read<GameState>().currentLanguage)",
    '"Lütfen haritadan göndermek istediğiniz mekanı seçin."': "Localization.t('ui_please_select_target', context.read<GameState>().currentLanguage)",
    '"AMATÖR RADYO K6JFD"': "Localization.t('ui_radio_title', context.read<GameState>().currentLanguage)",
    '"Dış dünyadan bir ses duymak veya sadece biraz müzik dinlemek, sığınaktaki herkesin ruh halini etkileyebilir. Günde sadece bir kez kullanabiliriz."': "Localization.t('ui_radio_desc', context.read<GameState>().currentLanguage)",
    '"Askeri veya sivil yayınları ara."': "Localization.t('ui_scan_signal', context.read<GameState>().currentLanguage)",
    '"Müzik Dinle"': "Localization.t('ui_listen_music', context.read<GameState>().currentLanguage)",
    '"Eski şarkılar moralleri yükseltir."': "Localization.t('ui_listen_music_desc', context.read<GameState>().currentLanguage)",
    '"Dışarıdan veya havadan gelen destek paketleriyle sığınaktaki ömrünü uzat. Telsizle sipariş veriyoruz."': "Localization.t('ui_store_desc', context.read<GameState>().currentLanguage)",
    '"Kısa bir video izle. Ödül: +1 Su, +1 Çorba."': "Localization.t('ui_watch_ad_desc', context.read<GameState>().currentLanguage)",
    '"Sinyal şarj oluyor. $daysLeft gün sonra tekrar kullanılabilir."': "Localization.t('ui_ad_cooldown', context.read<GameState>().currentLanguage, {'days': daysLeft.toString()})",
    '"SİNYAL ALINDI"': "Localization.t('ui_signal_received', context.read<GameState>().currentLanguage)",
    '"Destek ulaştı! +1 Su, +1 Çorba kazanıldı."': "Localization.t('ui_ad_reward', context.read<GameState>().currentLanguage)",
    '"SİNYAL KOPTU"': "Localization.t('ui_signal_lost', context.read<GameState>().currentLanguage)",
    '"Bağlantı kurulamadı veya reklam yüklenemedi. Lütfen internetinizi kontrol edin."': "Localization.t('ui_ad_fail', context.read<GameState>().currentLanguage)",
    '"+5 Su, +5 Çorba, +2 İlk Yardım, +2 Cephane."': "Localization.t('ui_buy_pack_desc', context.read<GameState>().currentLanguage)",
    '"KARGO ULAŞTI"': "Localization.t('ui_cargo_arrived', context.read<GameState>().currentLanguage)",
    '"Paket Satın Alındı! Tüm kaynaklar sığınağa eklendi."': "Localization.t('ui_pack_bought', context.read<GameState>().currentLanguage)",
    '"İŞLEM İPTAL"': "Localization.t('ui_transaction_cancel', context.read<GameState>().currentLanguage)",
    '"Satın alma işlemi tamamlanamadı veya iptal edildi."': "Localization.t('ui_transaction_cancel_desc', context.read<GameState>().currentLanguage)",
    '"Elit Sığınak (Aktif)"': "Localization.t('ui_elite_active', context.read<GameState>().currentLanguage)",
    '"Elit Sürüm (\\$5)"': "Localization.t('ui_elite_buy', context.read<GameState>().currentLanguage)",
    '"Zorunlu reklamlar kaldırıldı."': "Localization.t('ui_elite_desc_active', context.read<GameState>().currentLanguage)",
    '"Zorunlu reklamları kalıcı olarak kaldır. Bonus: +1 Alet."': "Localization.t('ui_elite_desc_buy', context.read<GameState>().currentLanguage)",
    '"ELİT SÜRÜM AKTİF"': "Localization.t('ui_elite_success', context.read<GameState>().currentLanguage)",
    '"Tebrikler! Reklamlar kaldırıldı ve +1 Alet eklendi."': "Localization.t('ui_elite_success_desc', context.read<GameState>().currentLanguage)",
    '"HAYATTA KALMA REHBERİ"': "Localization.t('ui_guide_title', dialogContext.read<GameState>().currentLanguage)",
    '"1. TEMEL AMACINIZ"': "Localization.t('ui_guide_1', dialogContext.read<GameState>().currentLanguage)",
    '"Sığınakta ailenizle birlikte olabildiğince uzun süre hayatta kalmak. Su ve çorba stoklarınızı akıllıca yönetin. Günleri atlatmak için sağ alttaki \'Günü Bitir\' butonunu kullanın. Açlık ve susuzluk karakterleri hastalandırır, yalnızlık delirtir. Herkes ölürse oyun biter."': "Localization.t('ui_guide_1_desc', dialogContext.read<GameState>().currentLanguage)",
    '"2. KEŞİF SİSTEMİ (GERÇEK DÜNYA HARİTASI)"': "Localization.t('ui_guide_2', dialogContext.read<GameState>().currentLanguage)",
    '"Oyun, cihazınızın konumunu kullanarak etrafınızdaki gerçek dünyayı haritalandırır. \'Keşfe Çık\' diyerek karakterlerinizi Eczane, Market veya Nalbur gibi yakınınızdaki noktalara erzak toplamaya gönderebilirsiniz. Dışarıdaki tehlikeli olaylara ve yağmacılara karşı dikkatli olun!"': "Localization.t('ui_guide_2_desc', dialogContext.read<GameState>().currentLanguage)",
    '"3. KARAKTER YETENEK (TRAIT) SİSTEMİ"': "Localization.t('ui_guide_3', dialogContext.read<GameState>().currentLanguage)",
    '"Ailenin her üyesi oyuna tamamen rastgele yeteneklerle (örn: Demir Mide, Şifacı, Çevik) başlar. Karakterlerinizin portresine tıklayarak durumlarını görün, yemek/su verin, medkit kullanın veya sohbet ederek morallerini yüksek tutun."': "Localization.t('ui_guide_3_desc', dialogContext.read<GameState>().currentLanguage)",
    '"4. KAYNAK VE ENVANTER YÖNETİMİ"': "Localization.t('ui_guide_4', dialogContext.read<GameState>().currentLanguage)",
    '"• Su & Çorba: Temel yaşam kaynağıdır.\\n• İlk Yardım Kiti (Medkit): Hastalık ve yaralanmaları anında iyileştirir.\\n• Alet Çantası (Tool): Havalandırma gibi sığınak arızalarını tamir etmenizi veya keşiflerdeki kilitli kasaları açmanızı sağlar.\\n• Cephane: Gece sığınağa saldıran yağmacıları veya yaratıkları savuşturmak için şarttır."': "Localization.t('ui_guide_4_desc', dialogContext.read<GameState>().currentLanguage)",
    '"5. RADYO VE GİZLİ SONLAR"': "Localization.t('ui_guide_5', dialogContext.read<GameState>().currentLanguage)",
    '"Kurtuluş için tek yol sığınakta çürümek değil! Günde bir kez radyoyu kullanarak askeri frekansları arayabilir (Sinyal Tara) veya müzik dinleyerek moralleri düzeltebilirsiniz. Askeri tahliye noktalarını bularak veya gizemli \'Ütopya\' kolonisine giden yolu açarak ailenizi kurtarın."': "Localization.t('ui_guide_5_desc', dialogContext.read<GameState>().currentLanguage)",
    '"Anladım, Hayatta Kalmaya Hazırım"': "Localization.t('ui_guide_ready', dialogContext.read<GameState>().currentLanguage)",
    '"AYARLAR"': "Localization.t('ui_settings', dialogContext.read<GameState>().currentLanguage)",
    '"Müzik Sesi"': "Localization.t('ui_music_vol', dialogContext.read<GameState>().currentLanguage)",
    '"Efekt Sesi"': "Localization.t('ui_sfx_vol', dialogContext.read<GameState>().currentLanguage)",
    '"Satın Alımları Geri Yükle"': "Localization.t('ui_restore_purchases', dialogContext.read<GameState>().currentLanguage)",
    '"Elit Sürüm lisansını kurtarır."': "Localization.t('ui_restore_desc', dialogContext.read<GameState>().currentLanguage)",
    '"Geri Bildirim Gönder"': "Localization.t('ui_send_feedback', dialogContext.read<GameState>().currentLanguage)",
    '"Bize düşüncelerinizi iletin."': "Localization.t('ui_feedback_desc', dialogContext.read<GameState>().currentLanguage)",
}

for k, v in replacements.items():
    content = content.replace(k, v)

# Special cases
# Day change animation
content = content.replace('"GÜN ${widget.day} BİTTİ"', "Localization.t('ui_day_ended', context.read<GameState>().currentLanguage, {'day': widget.day.toString()})")

with open(r'c:\Projeler\bunker_60\lib\bunker_screen.dart', 'w', encoding='utf-8') as f:
    f.write(content)
