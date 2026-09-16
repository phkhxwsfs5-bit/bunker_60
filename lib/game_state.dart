import 'dart:io';
import 'dart:math';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart'; 
import 'models.dart';
import 'audio_manager.dart'; 

class GameState extends ChangeNotifier {
  // --- REKLAM DEĞİŞKENLERİ ---
  RewardedAd? _rewardedAd;
  InterstitialAd? _interstitialAd;
  
  // Canlıya Çıkarken Kullanılacak GERÇEK AdMob ID'leri
  final String _testRewardedId = Platform.isIOS ? 'ca-app-pub-3711837388078625/2088644651' : 'ca-app-pub-3711837388078625/8361549166';
  final String _testInterstitialId = Platform.isIOS ? 'ca-app-pub-3711837388078625/1485562314' : 'ca-app-pub-3711837388078625/4418434729';

  int currentDay = 1;
  bool isGameOver = false;
  bool isGameWon = false; 
  bool isAdFree = false;
  bool showAdToday = false;

  int waterCount = 4;
  int soupCount = 4;
  int medkitCount = 1;
  int toolCount = 1;
  int ammoCount = 0;

  int lastAdDay = -3; 

  bool isDayChanging = false;

  String? exploringCharacter;
  int daysUntilReturn = 0;
  String? exploringDestinationName;
  String? exploringDestinationType;
  
  List<Place> nearbyPlaces = [];
  bool isLoadingPlaces = false;
  String loadingMessage = "";
  bool _isFetchingPlaces = false; 

  bool isMilitaryEvacRevealed = false;
  bool isUtopiaRevealed = false;

  bool hasChattedToday = false;
  bool hasUsedRadioToday = false;

  String locationName = "Ankara";
  double lat = 39.9446;
  double lng = 32.8604;
  bool isRealisticMode = false;

  int lastEventId = -1;

  List<Character> characters = [
    Character(name: "Baba", imagePrefix: "dad"),
    Character(name: "Anne", imagePrefix: "mom"),
    Character(name: "Çocuk", imagePrefix: "kid"),
  ];

  late GameEvent currentEvent;
  String get dailyLog => currentEvent.description;

  bool isShaking = false;
  bool isFlickering = false;

  Map<String, Map<String, String>> currentTraits = {};

  final Map<String, List<Map<String, String>>> _allTraits = {
    "Baba": [
      {"name": "Tamirci", "desc": "Alet kullanımlarında %30 ihtimalle alet kırılmaz."},
      {"name": "Demir Mide", "desc": "Açlığa karşı daha dirençlidir, yavaş acıkır."},
      {"name": "Koruyucu", "desc": "Keşiflerde daha fazla eşya bulur ama yaralanma riski artar."},
      {"name": "İri Yarı", "desc": "Morali çok zor düşer ama daha çabuk susar."},
      {"name": "Soğukkanlı", "desc": "Gece yaşanan kötü olaylardan (hırsız, ses) etkilenmez."},
    ],
    "Anne": [
      {"name": "Pratik", "desc": "Dışarıdaki keşif görevlerinden 1 gün erken döner."},
      {"name": "Tutumlu", "desc": "Birine çorba içirdiğinde %25 ihtimalle çorba eksilmez."},
      {"name": "Şifacı", "desc": "Bazen hastalandığında ilaçsız kendiliğinden iyileşebilir."},
      {"name": "Gözlemci", "desc": "Radyo aramalarında askeri frekans bulma şansı daha yüksektir."},
      {"name": "Dirençli", "desc": "Susuzluğa karşı olağanüstü dayanıklıdır."},
    ],
    "Çocuk": [
      {"name": "Çevik", "desc": "Keşif görevlerinde asla yaralanmaz."},
      {"name": "Neşeli", "desc": "Onunla sohbet etmek tüm ailenin moralini artırır."},
      {"name": "Ufaklık", "desc": "Su ve çorbayı çok daha yavaş tüketir."},
      {"name": "Şanslı", "desc": "Sığınağa saldıran böcek, hırsız gibi belaları kazara savuşturabilir."},
      {"name": "Gözü Açık", "desc": "Keşiflerde mutlaka gizli bir ekstra eşya bulur."},
    ]
  };

  GameState() {
    _initAdMobConfig(); 
    _assignRandomTraits();
    _loadEventForDay();
    _loadRewardedAd(); 
    _loadInterstitialAd(); 
  }

  Future<void> _initAdMobConfig() async {
    RequestConfiguration requestConfiguration = RequestConfiguration(
      tagForChildDirectedTreatment: TagForChildDirectedTreatment.yes, 
      maxAdContentRating: MaxAdContentRating.g, 
    );
    await MobileAds.instance.updateRequestConfiguration(requestConfiguration);
  }

  void _loadRewardedAd() {
    RewardedAd.load(
      adUnitId: _testRewardedId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) => _rewardedAd = ad,
        onAdFailedToLoad: (error) => _rewardedAd = null,
      ),
    );
  }

  void _loadInterstitialAd() {
    InterstitialAd.load(
      adUnitId: _testInterstitialId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback( 
        onAdLoaded: (ad) => _interstitialAd = ad,
        onAdFailedToLoad: (error) => _interstitialAd = null,
      ),
    );
  }

  void _assignRandomTraits() {
    final random = Random();
    currentTraits["Baba"] = _allTraits["Baba"]![random.nextInt(5)];
    currentTraits["Anne"] = _allTraits["Anne"]![random.nextInt(5)];
    currentTraits["Çocuk"] = _allTraits["Çocuk"]![random.nextInt(5)];
  }

  String getTraitName(String charName) => currentTraits[charName]?["name"] ?? "";
  String getTraitDesc(String charName) => currentTraits[charName]?["desc"] ?? "";

  Future<void> triggerEffects({bool shake = false, bool flicker = false}) async {
    isShaking = shake;
    isFlickering = flicker;
    notifyListeners();
    
    if (shake) AudioManager().playSFX('effect_shake.mp3');
    if (flicker) AudioManager().playSFX('effect_flicker.mp3');

    await Future.delayed(const Duration(milliseconds: 1200));
    isShaking = false;
    isFlickering = false;
    notifyListeners();
  }

  Future<void> nextDay() async {
    if (isGameOver || isGameWon || isDayChanging) return;

    isDayChanging = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 1500));

    List<String> diedTonight = [];

    for (var char in characters) {
      bool wasAlive = char.isAlive; 
      char.ageOneDay(); 
      _applyEndOfDayTraits(char); 
      
      if (wasAlive && !char.isAlive) {
        diedTonight.add(char.name);
      }
    }

    if (characters.every((c) => !c.isAlive)) {
      isGameOver = true;
      currentEvent = GameEvent(description: "Herkes öldü... Sığınak artık sessiz bir mezar.", choices: []);
      isDayChanging = false;
      notifyListeners();
      deleteSaveData();
      return;
    }

    currentDay++;
    hasChattedToday = false; 
    hasUsedRadioToday = false;
    showAdToday = (!isAdFree && currentDay > 1 && currentDay % 10 == 0);
    
    if (showAdToday && _interstitialAd != null) {
      _interstitialAd!.show();
      _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) {
          ad.dispose();
          _loadInterstitialAd(); 
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          ad.dispose();
          _loadInterstitialAd();
        }
      );
    }
    
    if (exploringCharacter != null) {
      daysUntilReturn--;
      if (daysUntilReturn <= 0) {
        _handleExpeditionReturn();
      } else {
        if (Random().nextInt(100) < 20) {
          _generateExpeditionEvent();
        } else {
          _loadEventForDay();
          currentEvent = GameEvent(
            description: "${currentEvent.description}\n\n$exploringCharacter hala dışarıda, dönmesini bekliyoruz.",
            choices: currentEvent.choices,
          );
        }
      }
    } else {
      _loadEventForDay();
    }

    if (diedTonight.isNotEmpty) {
      String deathMsg = "KÖTÜ HABER! Bu sabah uyandığımızda ${diedTonight.join(' ve ')} nefes almıyordu. Açlık ve susuzluğa daha fazla dayanamadı...\n\n";
      currentEvent = GameEvent(
        description: deathMsg + currentEvent.description, 
        choices: currentEvent.choices,
      );
    }

    isDayChanging = false;
    notifyListeners();
    saveGame(); 
  }

  void _generateExpeditionEvent() {
    int rnd = Random().nextInt(3);
    
    if (rnd == 0) {
      currentEvent = GameEvent(
        description: "TELSİZ: $exploringCharacter terk edilmiş bir dükkanda kilitli bir çelik kasa buldu. Açmayı denesin mi?",
        choices: [
          EventChoice(
            buttonText: "Aletle Zorla (Alet)",
            isEnabled: toolCount > 0,
            onSelect: () {
              bool breakTool = true; 
              if (exploringCharacter == "Baba" && getTraitName("Baba") == "Tamirci" && Random().nextInt(100) < 30) {
                 breakTool = false;
              }
              if (breakTool) toolCount--; 
              
              waterCount += 2; soupCount += 2;
              currentEvent = GameEvent(description: "Kasa açıldı! İçinden 2 Su ve 2 Çorba çıktı. $exploringCharacter yola devam ediyor.", choices: []);
              notifyListeners(); saveGame();
            }
          ),
          EventChoice(
            buttonText: "Sessizce Bırak",
            isEnabled: true,
            onSelect: () {
              currentEvent = GameEvent(description: "Riski göze almadık. $exploringCharacter sessizce keşfe devam ediyor.", choices: []);
              notifyListeners(); saveGame();
            }
          )
        ]
      );
    } else if (rnd == 1) {
      currentEvent = GameEvent(
        description: "TELSİZ: $exploringCharacter yolda yaralı, çaresiz bir yabancıya rastladı. Telsizden 'Ona yardım edeyim mi?' diye soruyor.",
        choices: [
          EventChoice(
            buttonText: "Su Ver (-1 Su)",
            isEnabled: waterCount > 0,
            onSelect: () {
              waterCount--;
              if (!isUtopiaRevealed) {
                isUtopiaRevealed = true;
                _injectSpecialPlaces(); 
                currentEvent = GameEvent(description: "Yabancı suyu içti ve minnettarlıkla bize kendi kendine yetebilen efsanevi 'Ütopya' kolonisinin koordinatlarını verdi! Haritaya eklendi.", choices: []);
              } else {
                medkitCount++;
                currentEvent = GameEvent(description: "Yabancı minnettarlıkla çantasındaki son İlk Yardım Kitini bize verdi.", choices: []);
              }
              notifyListeners(); saveGame();
            }
          ),
          EventChoice(
            buttonText: "Görmezden Gel",
            isEnabled: true,
            onSelect: () {
              currentEvent = GameEvent(description: "Acımasız bir dünyadayız. Yabancıyı ölüme terk edip yola devam ettik. (Herkesin morali düştü)", choices: []);
              for(var c in characters) { if(c.isAlive && !c.isExploring && c.moraleLevel > 0) c.moraleLevel--; }
              notifyListeners(); saveGame();
            }
          )
        ]
      );
    } else {
      currentEvent = GameEvent(
        description: "TELSİZ: $exploringCharacter dost canlısı görünen bir hayatta kalanla karşılaştı. 2 Çorba karşılığında 1 İlk Yardım Kiti takası teklif ediyor.",
        choices: [
          EventChoice(
            buttonText: "Takas Yap (-2 Çorba)",
            isEnabled: soupCount >= 2,
            onSelect: () {
              soupCount -= 2;
              medkitCount++;
              currentEvent = GameEvent(description: "Takas başarılı! İlk Yardım Kiti envantere eklendi.", choices: []);
              notifyListeners(); saveGame();
            }
          ),
          EventChoice(
            buttonText: "Reddet",
            isEnabled: true,
            onSelect: () {
              currentEvent = GameEvent(description: "Teklifi reddettik. Karakterimiz kendi yoluna gitti.", choices: []);
              notifyListeners(); saveGame();
            }
          )
        ]
      );
    }
  }

  void _applyEndOfDayTraits(Character char) {
    if (!char.isAlive || char.isExploring) return;
    
    String trait = getTraitName(char.name);
    final rand = Random();

    if (trait == "Demir Mide" && char.hungerLevel > 0 && rand.nextInt(100) < 15) char.hungerLevel--;
    if (trait == "İri Yarı" && rand.nextInt(100) < 30) char.thirstLevel++;
    if (trait == "Dirençli" && char.thirstLevel > 0 && rand.nextInt(100) < 15) char.thirstLevel--;
    if (trait == "Şifacı" && char.status == 'sick' && rand.nextInt(100) < 10) char.status = 'normal';

    if (trait == "Ufaklık") {
      if (rand.nextInt(100) < 15 && char.hungerLevel > 0) char.hungerLevel--;
      if (rand.nextInt(100) < 15 && char.thirstLevel > 0) char.thirstLevel--;
    }
  }

  void _loadEventForDay() {
    if (currentDay == 1) {
      currentEvent = GameEvent(description: "Sığınağa ulaştık. Şimdilik güvendeyiz. Bombanın sesi kulaklarımızı sağır edecek gibiydi. Dışarı çıkamayız.", choices: []);
    } else if (currentDay == 2) {
      triggerEffects(flicker: true, shake: true);
      currentEvent = GameEvent(description: "İlk gece çok zordu. Yukarıdan garip tıkırtılar duyduk. Ampul sürekli göz kırpıyor.", choices: []);
    } else {
      currentEvent = _getRandomEvent();
    }
  }

  void useRadio(String action) {
    if (hasUsedRadioToday) return;
    hasUsedRadioToday = true;
    
    if (action == "scan") {
      int chance = Random().nextInt(100);
      
      if (getTraitName("Anne") == "Gözlemci" && characters[1].isAlive && !characters[1].isExploring) chance += 20; 

      if (currentDay > 15 && !isMilitaryEvacRevealed && chance < 15) {
        isMilitaryEvacRevealed = true;
        _injectSpecialPlaces();
        currentEvent = GameEvent(description: "RADYODA NET BİR SİNYAL! 'Hayatta kalanlar, yakınlardaki Askeri Tahliye Noktasına gelin. Kurtarma ekipleri hazır.' Haritaya eklendi!", choices: []);
        notifyListeners(); saveGame(); return;
      }

      if (chance < 30) {
        currentEvent = GameEvent(description: "Radyodan parazitli bir ses geliyor... 'Orada kimse var mı? Lütfen yardım edin...' Ses aniden kesildi.", choices: []);
      } else if (chance < 60) {
        currentEvent = GameEvent(description: "Askeri bir frekans yakaladık! 'Sektör 4 temiz. Beklemede kalın.' Bizim için umut olabilir.", choices: []);
      } else if (chance < 80) {
        currentEvent = GameEvent(description: "Sadece parazit ve statik elektrik sesi var. Dışarıda kimse kalmamış gibi...", choices: []);
      } else {
        currentEvent = GameEvent(description: "Garip bir müzik kanalı bulduk. Çalan şarkı savaş öncesi günleri hatırlattı. Herkesin morali biraz olsun yerine geldi.", choices: []);
        for (var c in characters) {
          if (c.isAlive && !c.isExploring && c.moraleLevel > 0) c.moraleLevel -= 1;
        }
      }
    } else if (action == "music") {
      currentEvent = GameEvent(description: "Radyoyu sadece müzik dinlemek için açtık. Klasik müzik sığınağın soğuk duvarlarında yankılandı. Moraller düzeldi.", choices: []);
      for (var c in characters) {
        if (c.isAlive && !c.isExploring && c.moraleLevel > 0) c.moraleLevel -= 1;
      }
    }
    notifyListeners();
    saveGame();
  }

  void watchAdForResources({required VoidCallback onReward, required VoidCallback onFailed}) {
    if (currentDay - lastAdDay < 3) {
      onFailed(); 
      return;
    }

    if (_rewardedAd != null) {
      _rewardedAd!.show(
        onUserEarnedReward: (AdWithoutView ad, RewardItem reward) {
          lastAdDay = currentDay;
          waterCount += 1;
          soupCount += 1;
          notifyListeners();
          saveGame();
          onReward(); 
        }
      );
      _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) {
          ad.dispose();
          _loadRewardedAd(); 
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          ad.dispose();
          _loadRewardedAd();
          onFailed(); 
        }
      );
    } else {
      onFailed();
      _loadRewardedAd(); 
    }
  }

  void buyResourcePack() {
    waterCount += 5; soupCount += 5; medkitCount += 2; ammoCount += 2; notifyListeners(); saveGame();
  }

  void buyAdFree() {
    isAdFree = true; toolCount += 1; notifyListeners(); saveGame();
  }

  void restoreAdFree() {
    isAdFree = true; 
    notifyListeners(); 
    saveGame();
  }

  void triggerSalvation() {
      isGameWon = true;
      currentEvent = GameEvent(description: "Dışarıdan kapı zorlandı! Askerler içeri girdi. Başardık, kurtulduk!", choices: []);
      notifyListeners();
      deleteSaveData();
  }

  GameEvent _getRandomEvent() {
    int chance = Random().nextInt(100);
    int eventId = 0; 

    if(currentDay > 30 && chance > 90) {
        eventId = 99; 
    } else if (chance < 15) { 
        eventId = 1; 
    } else if (chance < 30) { 
        eventId = 2; 
    } else if (chance < 45) { 
        eventId = 3; 
    } else if (chance < 60) { 
        eventId = 4; 
    } else if (chance < 70) { 
        eventId = 5; 
    } else if (chance < 85) { 
        eventId = 6; 
    } else {
        eventId = 0; 
    }

    if (eventId == lastEventId && eventId != 0 && eventId != 99) {
      eventId = 0;
    }
    
    lastEventId = eventId; 

    if (eventId == 99) {
        triggerEffects(shake: true);
        AudioManager().playSFX('event_door_bang.mp3'); 
        return GameEvent(
            description: "Dışarıdan sesler geliyor! Kapağa vuruyorlar. 'Ordu Birlikleri, açın!' Kurtulduk mu?",
            choices: [EventChoice(buttonText: "Kapağı Aç", isEnabled: true, onSelect: () => triggerSalvation())]
        );
    } else if (eventId == 1) {
      triggerEffects(flicker: true);
      AudioManager().playSFX('event_bugs.mp3'); 
      return GameEvent(
        description: "Devasa, parlayan mutant hamamböcekleri çorba kutularımıza saldırıyor!",
        choices: [
          EventChoice(
            buttonText: "Aletle Ez", isEnabled: toolCount > 0,
            onSelect: () {
              if (toolCount > 0) {
                bool breakTool = true; 
                if (getTraitName("Baba") == "Tamirci" && characters[0].isAlive && !characters[0].isExploring && Random().nextInt(100) < 30) breakTool = false;
                if (breakTool) toolCount--; 
                currentEvent = GameEvent(description: "Hepsini ezerek öldürdük. Eşyalarımız güvende.", choices: []);
              }
              notifyListeners();
              saveGame(); 
            },
          ),
          EventChoice(
            buttonText: "Saklan",
            onSelect: () {
              if (getTraitName("Çocuk") == "Şanslı" && characters[2].isAlive && !characters[2].isExploring && Random().nextBool()) {
                 currentEvent = GameEvent(description: "Böcekler konserveleri açamayıp kendi kendilerine gittiler! Şanslıyız.", choices: []);
              } else {
                 soupCount = max(0, soupCount - 2);
                 currentEvent = GameEvent(description: "Böcekler 2 çorbamızı yiyip uzaklaştı...", choices: []);
              }
              notifyListeners();
              saveGame(); 
            },
          ),
        ],
      );
    } else if (eventId == 2) {
      return GameEvent(
        description: "Sığınağın havalandırması bozuldu. İçeriye zehirli hava sızıyor.",
        choices: [
          EventChoice(
            buttonText: "Tamir Et (Alet)", isEnabled: toolCount > 0,
            onSelect: () {
              if (toolCount > 0) {
                toolCount--; 
                currentEvent = GameEvent(description: "Zor oldu ama tamir ettik. Ciğerlerimiz bayram etti.", choices: []);
              }
              notifyListeners();
              saveGame(); 
            },
          ),
          EventChoice(
            buttonText: "Tamir Etme",
            onSelect: () {
              _makeEveryoneSick();
              currentEvent = GameEvent(description: "Hava kalitesi çok kötü, herkes hastalandı.", choices: []);
              notifyListeners();
              saveGame(); 
            },
          ),
        ],
      );
    } else if (eventId == 3) {
      triggerEffects(shake: true, flicker: true);
      AudioManager().playSFX('event_door_bang.mp3'); 
      return GameEvent(
        description: "GÜM! GÜM! Gece vakti sığınak kapağı yumruklanıyor. Seslerden anladığımız kadarıyla yağmacılar!",
        choices: [
          EventChoice(
            buttonText: "Silahla Korkut (Cephane)", isEnabled: ammoCount > 0,
            onSelect: () {
              if(ammoCount > 0) ammoCount--;
              currentEvent = GameEvent(description: "Havaya bir el ateş ettik. Adım sesleri koşarak uzaklaştı.", choices: []);
              notifyListeners();
              saveGame(); 
            }
          ),
          EventChoice(
            buttonText: "Sessizce Bekle",
            onSelect: () {
              waterCount = max(0, waterCount - 2);
              soupCount = max(0, soupCount - 2);
              currentEvent = GameEvent(description: "Kapağı kırıp içeri daldılar! Erzaklarımızın bir kısmını (2 Su, 2 Çorba) çalıp gittiler.", choices: []);
              notifyListeners();
              saveGame(); 
            }
          )
        ]
      );
    } else if (eventId == 4) {
      triggerEffects(flicker: true);
      AudioManager().playSFX('event_leak.mp3'); 
      return GameEvent(
        description: "Duvardaki eski borulardan şiddetli bir tıslama sesi geliyor. Sığınağa boğucu bir gaz sızıyor!",
        choices: [
          EventChoice(
            buttonText: "Bezlerle Tıka", isEnabled: true,
            onSelect: () {
              _makeSomeoneTiredOrSick();
              currentEvent = GameEvent(description: "Bütün gece zehirli gazı soluyarak borudaki çatlağı bezlerle tıkamaya çalıştık. Sızıntı durdu ama çok yorulduk, birimiz hastalandı.", choices: []);
              notifyListeners();
              saveGame(); 
            }
          ),
        ]
      );
    } else if (eventId == 5) {
      return GameEvent(
        description: "Köşedeki kutuların arkasında kapağı şişkin ve etiketi silinmiş iki konserve bulduk. Erzaklarımıza ekleyelim mi?",
        choices: [
          EventChoice(
            buttonText: "Stoğa Ekle", isEnabled: true,
            onSelect: () {
               if (Random().nextBool()) {
                 soupCount += 2;
                 currentEvent = GameEvent(description: "Konserveler hala sağlammış! Gıdamız arttı (+2 Çorba).", choices: []);
               } else {
                 _makeSomeoneTiredOrSick();
                 currentEvent = GameEvent(description: "Kötü fikirdi. Kutular delikmiş, sızan pis koku birimizi hasta etti.", choices: []);
               }
               notifyListeners();
               saveGame(); 
            }
          ),
          EventChoice(
            buttonText: "Çöpe At", isEnabled: true,
            onSelect: () {
              currentEvent = GameEvent(description: "Riske girmeye değmez. Çöpe attık.", choices: []);
              notifyListeners();
              saveGame(); 
            }
          )
        ]
      );
    } else if (eventId == 6) {
      return GameEvent(
        description: "Sığınağın karanlığı ve sessizliği yavaş yavaş akıl sağlığımızı etkiliyor. Biri köşede kendi kendine konuşuyor.",
        choices: [
          EventChoice(
            buttonText: "Uzun Uzun Sohbet Et", isEnabled: true,
            onSelect: () {
              currentEvent = GameEvent(description: "Eski günlerden, güzel anılardan bahsettik. Zor oldu ama toparlandık.", choices: []);
              for(var c in characters) {
                if (c.isAlive && !c.isExploring && c.moraleLevel > 0) c.moraleLevel--; 
              }
              notifyListeners();
              saveGame(); 
            }
          )
        ]
      );
    } else {
      return GameEvent(
        description: "$currentDay. Gün. Sığınakta sessiz bir bekleyiş sürüyor. Kaynakları idareli kullanmalıyız.", 
        choices: []
      );
    }
  }

  void _makeSomeoneTiredOrSick() {
    var aliveChars = characters.where((c) => c.isAlive && !c.isExploring && c.status == 'normal').toList();
    if (aliveChars.isNotEmpty) {
      aliveChars.shuffle();
      aliveChars.first.status = 'sick';
    }
  }
  
  void _makeEveryoneSick() {
    for (var char in characters) {
      if (char.isAlive && !char.isExploring && char.status == 'normal') char.status = 'sick';
    }
  }

  void feedWater(Character char) {
    if (waterCount > 0 && char.isAlive && char.thirstLevel > 0) {
      waterCount--;
      char.feedWater();
      notifyListeners();
      saveGame();
    }
  }

  void feedSoup(Character char) {
    if (soupCount > 0 && char.isAlive && char.hungerLevel > 0) {
      bool decreaseSoup = true;
      if (getTraitName("Anne") == "Tutumlu" && characters[1].isAlive && !characters[1].isExploring && Random().nextInt(100) < 25) decreaseSoup = false;
      
      if (decreaseSoup) soupCount--;
      char.feedSoup();
      notifyListeners();
      saveGame();
    }
  }

  void healCharacter(Character char) {
    if (medkitCount > 0 && char.isAlive && (char.status == 'sick' || char.status == 'injured')) {
      medkitCount--;
      char.heal();
      notifyListeners();
      saveGame();
    }
  }

  void talkToCharacter(Character char) {
    if (!hasChattedToday && char.isAlive && (char.moraleLevel > 0 || char.status == 'insane')) {
      hasChattedToday = true;
      char.talk();
      
      if (char.name == "Çocuk" && getTraitName("Çocuk") == "Neşeli") {
        for (var c in characters) {
           if (c.isAlive && !c.isExploring && c.moraleLevel > 0) c.moraleLevel--;
        }
      }
      
      notifyListeners();
      saveGame();
    }
  }

  void startExpedition(String characterName, Place destination) {
    if (isGameOver || isGameWon) return;
    exploringCharacter = characterName;
    exploringDestinationName = destination.name;
    exploringDestinationType = destination.type;
    
    if (characterName == "Anne" && getTraitName("Anne") == "Pratik") {
      daysUntilReturn = Random().nextInt(2) + 1; 
    } else {
      daysUntilReturn = Random().nextInt(2) + 2;
    }
    
    for (var char in characters) {
      if (char.name == characterName) char.isExploring = true;
    }
    
    currentEvent = GameEvent(description: "$characterName, ${destination.name} bölgesine yola çıktı. Umarım sağ döner.", choices: []);
    notifyListeners();
    saveGame();
  }

  void _handleExpeditionReturn() {
    if (exploringDestinationType == 'military') {
      isGameWon = true;
      currentEvent = GameEvent(description: "İnanamıyorum! Kurtarma helikopteri sığınağın tam üzerine indi! $exploringCharacter yolu açtı. BAŞARDIK, KURTULDUK!", choices: []);
      notifyListeners(); deleteSaveData(); return;
    }

    if (exploringDestinationType == 'utopia') {
      if (waterCount >= 5 && soupCount >= 5) {
        isGameWon = true;
        currentEvent = GameEvent(description: "Erzaklarımızı sırtlandık ve $exploringCharacter rehberliğinde Gizli Yeraltı Kolonisine ulaştık. Burada yeni bir hayat başlıyor. KAZANDINIZ!", choices: []);
        notifyListeners(); deleteSaveData(); return;
      } else {
        String failText = "HAYAL KIRIKLIĞI! $exploringCharacter koloniyi buldu ama içeri kabul edilmemiz için yanımızda en az 5 Su ve 5 Çorba götürmemiz gerektiğini söylediler. Erzak yetersizliğinden geri çevrildik.";
        for (var char in characters) { if (char.name == exploringCharacter) char.isExploring = false; }
        exploringCharacter = null; exploringDestinationName = null; exploringDestinationType = null;
        currentEvent = GameEvent(description: failText, choices: []);
        notifyListeners(); saveGame(); return;
      }
    }

    int chance = Random().nextInt(100);
    String resultText = "";
    
    bool isAgile = (exploringCharacter == "Çocuk" && getTraitName("Çocuk") == "Çevik");
    bool isProtective = (exploringCharacter == "Baba" && getTraitName("Baba") == "Koruyucu");
    bool isScavenger = (exploringCharacter == "Çocuk" && getTraitName("Çocuk") == "Gözü Açık");

    if (chance < 20 && !isAgile) {
      resultText = "KÖTÜ HABER! $exploringCharacter, dönüş yolunda yağmacıların pususuna düştü. Yaralı döndü!";
      for (var char in characters) {
        if (char.name == exploringCharacter) char.status = 'injured';
      }
    } else if (chance < 40 && !isScavenger) {
      resultText = "$exploringCharacter sığınağa döndü. Gittiği bölge ($exploringDestinationName) yağmalanmış, bir şey bulamadı.";
    } else {
      int extra = isProtective || isScavenger ? 1 : 0; 

      if (exploringDestinationType == 'pharmacy') {
        medkitCount += (1 + extra);
        waterCount += 1;
        resultText = "BAŞARI! $exploringCharacter eczaneden İlk Yardım Kiti ve Su buldu!";
      } else if (exploringDestinationType == 'supermarket') {
        int foundWater = Random().nextInt(2) + 2 + extra;
        int foundSoup = Random().nextInt(2) + 2 + extra;
        waterCount += foundWater;
        soupCount += foundSoup;
        resultText = "BAŞARI! $exploringCharacter marketinden $foundWater su ve $foundSoup çorba getirdi!";
      } else if (exploringDestinationType == 'hardware') {
        toolCount += (1 + extra);
        resultText = "BAŞARI! $exploringCharacter nalburdan Alet Çantası buldu!";
      } else {
        int foundWater = Random().nextInt(2) + 1 + extra;
        int foundSoup = Random().nextInt(2) + 1 + extra;
        waterCount += foundWater;
        soupCount += foundSoup;
        resultText = "BAŞARI! $exploringCharacter yanına $foundWater su ve $foundSoup çorba getirdi!";
      }
    }

    for (var char in characters) {
      if (char.name == exploringCharacter) char.isExploring = false;
    }
    exploringCharacter = null;
    exploringDestinationName = null;
    exploringDestinationType = null;
    
    currentEvent = GameEvent(description: resultText, choices: []);
  }

  void _injectSpecialPlaces() {
    if (isMilitaryEvacRevealed && !nearbyPlaces.any((p) => p.type == 'military')) {
      nearbyPlaces.add(Place(name: "Askeri Tahliye Noktası", lat: lat + 0.015, lng: lng - 0.015, type: 'military'));
    }
    if (isUtopiaRevealed && !nearbyPlaces.any((p) => p.type == 'utopia')) {
      nearbyPlaces.add(Place(name: "Gizli Yeraltı Kolonisi (Giriş için 5 Su/5 Çorba)", lat: lat - 0.012, lng: lng + 0.012, type: 'utopia'));
    }
  }

  Future<bool> setLocationWithGPS() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return false;
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return false;
    }
    if (permission == LocationPermission.deniedForever) return false;

    Position position = await Geolocator.getCurrentPosition();
    lat = position.latitude; 
    lng = position.longitude; 
    locationName = "GPS Konumu"; 
    isRealisticMode = true; 
    notifyListeners(); 
    await fetchNearbyPlaces();
    return true;
  }

  Future<bool> setLocationWithIP() async {
    try {
      final response = await http.get(Uri.parse('http://ip-api.com/json/'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        lat = data['lat']; 
        lng = data['lon']; 
        locationName = "${data['city']}, ${data['country']}";
        isRealisticMode = false; 
        notifyListeners(); 
        await fetchNearbyPlaces();
        return true;
      }
    } catch (e) { print("IP Hata: $e"); }
    return false;
  }

  Future<void> fetchNearbyPlaces() async {
    if (_isFetchingPlaces) return; 
    _isFetchingPlaces = true;

    isLoadingPlaces = true;
    loadingMessage = "Radar Açılıyor...";
    notifyListeners();
    
    await Future.delayed(const Duration(milliseconds: 300));

    try {
      final prefs = await SharedPreferences.getInstance();
      double? cachedLat = prefs.getDouble('cachedLat');
      double? cachedLng = prefs.getDouble('cachedLng');
      String? cachedPlacesJson = prefs.getString('cachedPlaces');

      if (cachedLat != null && cachedLng != null && cachedPlacesJson != null) {
        double distance = Geolocator.distanceBetween(lat, lng, cachedLat, cachedLng);
        if (distance < 500) {
          loadingMessage = "Harita Hafızadan Yükleniyor...";
          notifyListeners();
          await Future.delayed(const Duration(milliseconds: 400)); 

          List<dynamic> decodedData = jsonDecode(cachedPlacesJson);
          nearbyPlaces = decodedData.map((e) => Place(
            name: e['name'], lat: e['lat'], lng: e['lng'], type: e['type'],
          )).toList();

          _injectSpecialPlaces(); 

          isLoadingPlaces = false;
          _isFetchingPlaces = false;
          notifyListeners();
          return; 
        }
      }
    } catch (e) { print("Önbellek okuma hatası: $e"); }

    loadingMessage = "Gerçek Dünya Verileri Çekiliyor (API)...";
    notifyListeners();

    try {
      final query = '''
        [out:json][timeout:10];
        (
          node["amenity"="pharmacy"](around:1500, $lat, $lng);
          node["shop"="supermarket"](around:1500, $lat, $lng);
          node["shop"="hardware"](around:1500, $lat, $lng);
        );
        out body;
      ''';

      final url = Uri.parse('https://overpass.openstreetmap.fr/api/interpreter');
      final response = await http.post(
        url, 
        headers: {'Content-Type': 'application/x-www-form-urlencoded', 'User-Agent': 'Bunker06_Game/1.0 (grcihaner@gmail.com)'},
        body: query
      ).timeout(const Duration(seconds: 12));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final elements = data['elements'] as List;

        nearbyPlaces.clear();
        for (var e in elements) {
          if (e['tags'] != null && e['tags']['name'] != null) {
            String type = 'unknown';
            if (e['tags']['amenity'] == 'pharmacy') type = 'pharmacy';
            else if (e['tags']['shop'] == 'supermarket') type = 'supermarket';
            else if (e['tags']['shop'] == 'hardware') type = 'hardware';
            nearbyPlaces.add(Place(name: e['tags']['name'], lat: e['lat'] ?? 0.0, lng: e['lon'] ?? 0.0, type: type));
          }
        }

        if (nearbyPlaces.isNotEmpty) {
          _injectSpecialPlaces(); 
          try {
            final prefs = await SharedPreferences.getInstance();
            List<Map<String, dynamic>> placesToCache = nearbyPlaces.map((p) => {
              'name': p.name, 'lat': p.lat, 'lng': p.lng, 'type': p.type,
            }).toList();
            await prefs.setDouble('cachedLat', lat);
            await prefs.setDouble('cachedLng', lng);
            await prefs.setString('cachedPlaces', jsonEncode(placesToCache));
          } catch(e) {}
          isLoadingPlaces = false; _isFetchingPlaces = false; notifyListeners(); return; 
        }
      }
    } catch (e) {}

    loadingMessage = "Sinyal Zayıf. Tahmini Harita Kullanılıyor...";
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 500));

    try {
      nearbyPlaces.clear();
      final random = Random();
      int pharmacyCount = random.nextInt(4) + 3;
      List<String> pharmacyNames = ["Şifa Eczanesi", "Merkez Eczanesi", "Sağlık Eczanesi", "Umut Eczanesi", "Hayat Eczanesi", "Güneş Eczanesi", "Halk Eczanesi", "Yeni Eczane"];
      for (int i = 0; i < pharmacyCount; i++) {
        nearbyPlaces.add(Place(name: pharmacyNames[random.nextInt(pharmacyNames.length)], lat: lat + (random.nextDouble() - 0.5) * 0.010, lng: lng + (random.nextDouble() - 0.5) * 0.010, type: 'pharmacy'));
      }
      int marketCount = random.nextInt(4) + 4;
      List<String> marketNames = ["Güven Süpermarket", "Büyük Gıda", "Kardeşler Bakkalı", "Ucuza Market", "Bereket Gıda", "Merkez Hipermarket", "Bizim Bakkal", "Köşe Market"];
      for (int i = 0; i < marketCount; i++) {
        nearbyPlaces.add(Place(name: marketNames[random.nextInt(marketNames.length)], lat: lat + (random.nextDouble() - 0.5) * 0.010, lng: lng + (random.nextDouble() - 0.5) * 0.010, type: 'supermarket'));
      }
      int hardwareCount = random.nextInt(3) + 1;
      List<String> hardwareNames = ["Usta Nalburiye", "Yapı Market", "Çınar Hırdavat", "Emin Yapı", "Kardeşler Nalbur"];
      for (int i = 0; i < hardwareCount; i++) {
        nearbyPlaces.add(Place(name: hardwareNames[random.nextInt(hardwareNames.length)], lat: lat + (random.nextDouble() - 0.5) * 0.010, lng: lng + (random.nextDouble() - 0.5) * 0.010, type: 'hardware'));
      }
      
      _injectSpecialPlaces(); 
      
    } catch (e) {
    } finally {
      isLoadingPlaces = false; _isFetchingPlaces = false; notifyListeners();
    }
  }

  Future<void> saveGame() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setInt('currentDay', currentDay);
    prefs.setInt('waterCount', waterCount);
    prefs.setInt('soupCount', soupCount);
    prefs.setInt('medkitCount', medkitCount);
    prefs.setInt('toolCount', toolCount);
    prefs.setString('locationName', locationName);
    prefs.setBool('isGameOver', isGameOver);
    prefs.setBool('isGameWon', isGameWon);
    
    prefs.setInt('lastAdDay', lastAdDay);

    prefs.setBool('isMilitaryEvacRevealed', isMilitaryEvacRevealed);
    prefs.setBool('isUtopiaRevealed', isUtopiaRevealed);

    prefs.setString('exploringCharacter', exploringCharacter ?? "");
    prefs.setString('exploringDestinationName', exploringDestinationName ?? "");
    prefs.setString('exploringDestinationType', exploringDestinationType ?? "");
    prefs.setInt('daysUntilReturn', daysUntilReturn);
    
    prefs.setInt('lastEventId', lastEventId);
    
    for (int i = 0; i < characters.length; i++) {
      prefs.setBool('char_${i}_isAlive', characters[i].isAlive);
      prefs.setBool('char_${i}_isExploring', characters[i].isExploring);
      prefs.setInt('char_${i}_hunger', characters[i].hungerLevel);
      prefs.setInt('char_${i}_thirst', characters[i].thirstLevel);
      prefs.setString('char_${i}_status', characters[i].status);
    }
    
    prefs.setString('currentTraits', jsonEncode(currentTraits));
  }

  Future<void> deleteSaveData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('currentDay'); 
  }

  Future<bool> loadGame() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('currentDay')) return false;

    currentDay = prefs.getInt('currentDay') ?? 1;
    waterCount = prefs.getInt('waterCount') ?? 4;
    soupCount = prefs.getInt('soupCount') ?? 4;
    medkitCount = prefs.getInt('medkitCount') ?? 1;
    toolCount = prefs.getInt('toolCount') ?? 1;
    locationName = prefs.getString('locationName') ?? "Bilinmeyen Bölge";
    isGameOver = prefs.getBool('isGameOver') ?? false;
    isGameWon = prefs.getBool('isGameWon') ?? false;
    
    lastAdDay = prefs.getInt('lastAdDay') ?? -3;

    isMilitaryEvacRevealed = prefs.getBool('isMilitaryEvacRevealed') ?? false;
    isUtopiaRevealed = prefs.getBool('isUtopiaRevealed') ?? false;

    lastEventId = prefs.getInt('lastEventId') ?? -1;
    
    exploringCharacter = prefs.getString('exploringCharacter'); if(exploringCharacter == "") exploringCharacter = null;
    exploringDestinationName = prefs.getString('exploringDestinationName'); if(exploringDestinationName == "") exploringDestinationName = null;
    exploringDestinationType = prefs.getString('exploringDestinationType'); if(exploringDestinationType == "") exploringDestinationType = null;
    daysUntilReturn = prefs.getInt('daysUntilReturn') ?? 0;
    
    for (int i = 0; i < characters.length; i++) {
      characters[i].isAlive = prefs.getBool('char_${i}_isAlive') ?? true;
      characters[i].isExploring = prefs.getBool('char_${i}_isExploring') ?? false;
      characters[i].hungerLevel = prefs.getInt('char_${i}_hunger') ?? 0;
      characters[i].thirstLevel = prefs.getInt('char_${i}_thirst') ?? 0;
      characters[i].status = prefs.getString('char_${i}_status') ?? 'normal';
    }

    String? traitsJson = prefs.getString('currentTraits');
    if (traitsJson != null) {
      Map<String, dynamic> decoded = jsonDecode(traitsJson);
      currentTraits = decoded.map((k, v) => MapEntry(k, Map<String, String>.from(v)));
    } else {
      _assignRandomTraits();
    }
    
    _loadEventForDay(); 
    notifyListeners();
    if (nearbyPlaces.isEmpty) fetchNearbyPlaces();
    return true;
  }

  void resetGame() {
    currentDay = 1; waterCount = 4; soupCount = 4; medkitCount = 1; toolCount = 1; ammoCount = 0;
    isGameOver = false; isGameWon = false; exploringCharacter = null; exploringDestinationName = null; exploringDestinationType = null; daysUntilReturn = 0;
    isMilitaryEvacRevealed = false; isUtopiaRevealed = false;
    lastAdDay = -3; 
    isDayChanging = false; 
    lastEventId = -1; 
    hasChattedToday = false; 
    hasUsedRadioToday = false;
    for (var char in characters) {
      char.isAlive = true; 
      char.isExploring = false; 
      char.hungerLevel = 0; 
      char.thirstLevel = 0; 
      char.status = 'normal';
      char.moraleLevel = 0; 
      char.daysSinceFood = 0;
      char.daysSinceWater = 0;
      char.daysSinceTalk = 0;
    }
    _assignRandomTraits();
    _loadEventForDay();
    notifyListeners();
  }
}
