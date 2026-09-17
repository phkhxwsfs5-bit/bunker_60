import 'dart:io';
import 'dart:math';

import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:geolocator/geolocator.dart';

import 'package:http/http.dart' as http;

import 'package:shared_preferences/shared_preferences.dart';

import 'package:google_mobile_ads/google_mobile_ads.dart'; 

import 'models.dart';
import 'localization.dart';

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
  String currentLanguage = 'tr';



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

    Character(name: "role_father", imagePrefix: "dad"),

    Character(name: "role_mother", imagePrefix: "mom"),

    Character(name: "role_kid", imagePrefix: "kid"),

  ];



  late GameEvent currentEvent;

  String get dailyLog => currentEvent.description;



  bool isShaking = false;

  bool isFlickering = false;



  Map<String, Map<String, String>> currentTraits = {};



  final Map<String, List<Map<String, String>>> _allTraits = {

    "role_father": [

      {"name": "trait_mechanic", "desc": "trait_mechanic_desc"},

      {"name": "trait_iron_stomach", "desc": "trait_iron_stomach_desc"},

      {"name": "trait_protector", "desc": "trait_protector_desc"},

      {"name": "trait_big_guy", "desc": "trait_big_guy_desc"},

      {"name": "trait_cold_blooded", "desc": "trait_cold_blooded_desc"},

    ],

    "role_mother": [

      {"name": "trait_practical", "desc": "trait_practical_desc"},

      {"name": "trait_frugal", "desc": "trait_frugal_desc"},

      {"name": "trait_healer", "desc": "trait_healer_desc"},

      {"name": "trait_observer", "desc": "trait_observer_desc"},

      {"name": "trait_resilient", "desc": "trait_resilient_desc"},

    ],

    "role_kid": [

      {"name": "trait_agile", "desc": "trait_agile_desc"},

      {"name": "trait_cheerful", "desc": "trait_cheerful_desc"},

      {"name": "trait_little", "desc": "trait_little_desc"},

      {"name": "trait_lucky", "desc": "trait_lucky_desc"},

      {"name": "trait_sharp_eyed", "desc": "trait_sharp_eyed_desc"},

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



  void setLanguage(String lang) {
    if (currentLanguage != lang) {
      currentLanguage = lang;
      saveGame();
      notifyListeners();
    }
  }

  void _assignRandomTraits() {

    final random = Random();

    currentTraits["role_father"] = _allTraits["role_father"]![random.nextInt(5)];

    currentTraits["role_mother"] = _allTraits["role_mother"]![random.nextInt(5)];

    currentTraits["role_kid"] = _allTraits["role_kid"]![random.nextInt(5)];

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

      currentEvent = GameEvent(description: Localization.t('event_all_dead', currentLanguage), choices: []);

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

            description: Localization.t('event_char_outside', currentLanguage, {'desc': currentEvent!.description, 'char': exploringCharacter != null ? Localization.t(exploringCharacter!, currentLanguage) : ''}),

            choices: currentEvent.choices,

          );

        }

      }

    } else {

      _loadEventForDay();

    }



    if (diedTonight.isNotEmpty) {

      String names = diedTonight.map((n) => Localization.t(n, currentLanguage)).join(" & ");
      String deathMsg = Localization.t("death_msg", currentLanguage, {"names": names});

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

        description: Localization.t('event_radio_safe', currentLanguage, {'char': exploringCharacter != null ? Localization.t(exploringCharacter!, currentLanguage) : ''}),

        choices: [

          EventChoice(

            buttonText: Localization.t('action_force_tool', currentLanguage),

            isEnabled: toolCount > 0,

            onSelect: () {

              bool breakTool = true; 

              if (exploringCharacter == "role_father" && getTraitName("role_father") == "trait_mechanic" && Random().nextInt(100) < 30) {

                 breakTool = false;

              }

              if (breakTool) toolCount--; 

              

              waterCount += 2; soupCount += 2;

              currentEvent = GameEvent(description: Localization.t('event_safe_opened', currentLanguage, {'char': exploringCharacter != null ? Localization.t(exploringCharacter!, currentLanguage) : ''}), choices: []);

              notifyListeners(); saveGame();

            }

          ),

          EventChoice(

            buttonText: Localization.t('action_leave_silently', currentLanguage),

            isEnabled: true,

            onSelect: () {

              currentEvent = GameEvent(description: Localization.t('event_safe_left', currentLanguage, {'char': exploringCharacter != null ? Localization.t(exploringCharacter!, currentLanguage) : ''}), choices: []);

              notifyListeners(); saveGame();

            }

          )

        ]

      );

    } else if (rnd == 1) {

      currentEvent = GameEvent(

        description: Localization.t('event_radio_stranger', currentLanguage, {'char': exploringCharacter != null ? Localization.t(exploringCharacter!, currentLanguage) : ''}),

        choices: [

          EventChoice(

            buttonText: Localization.t('action_give_water', currentLanguage),

            isEnabled: waterCount > 0,

            onSelect: () {

              waterCount--;

              if (!isUtopiaRevealed) {

                isUtopiaRevealed = true;

                _injectSpecialPlaces(); 

                currentEvent = GameEvent(description: Localization.t('event_stranger_utopia', currentLanguage), choices: []);

              } else {

                medkitCount++;

                currentEvent = GameEvent(description: Localization.t('event_stranger_medkit', currentLanguage), choices: []);

              }

              notifyListeners(); saveGame();

            }

          ),

          EventChoice(

            buttonText: Localization.t('action_ignore', currentLanguage),

            isEnabled: true,

            onSelect: () {

              currentEvent = GameEvent(description: Localization.t('event_stranger_ignored', currentLanguage), choices: []);

              for(var c in characters) { if(c.isAlive && !c.isExploring && c.moraleLevel > 0) c.moraleLevel--; }

              notifyListeners(); saveGame();

            }

          )

        ]

      );

    } else {

      currentEvent = GameEvent(

        description: Localization.t('event_radio_trader', currentLanguage, {'char': exploringCharacter != null ? Localization.t(exploringCharacter!, currentLanguage) : ''}),

        choices: [

          EventChoice(

            buttonText: Localization.t('action_trade', currentLanguage),

            isEnabled: soupCount >= 2,

            onSelect: () {

              soupCount -= 2;

              medkitCount++;

              currentEvent = GameEvent(description: Localization.t('event_trade_success', currentLanguage), choices: []);

              notifyListeners(); saveGame();

            }

          ),

          EventChoice(

            buttonText: "Reddet",

            isEnabled: true,

            onSelect: () {

              currentEvent = GameEvent(description: Localization.t('event_trade_rejected', currentLanguage), choices: []);

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



    if (trait == "trait_iron_stomach" && char.hungerLevel > 0 && rand.nextInt(100) < 15) char.hungerLevel--;

    if (trait == "trait_big_guy" && rand.nextInt(100) < 30) char.thirstLevel++;

    if (trait == "trait_resilient" && char.thirstLevel > 0 && rand.nextInt(100) < 15) char.thirstLevel--;

    if (trait == "trait_healer" && char.status == 'sick' && rand.nextInt(100) < 10) char.status = 'normal';



    if (trait == "trait_little") {

      if (rand.nextInt(100) < 15 && char.hungerLevel > 0) char.hungerLevel--;

      if (rand.nextInt(100) < 15 && char.thirstLevel > 0) char.thirstLevel--;

    }

  }



  void _loadEventForDay() {

    if (currentDay == 1) {

      currentEvent = GameEvent(description: Localization.t('log_first_day', currentLanguage), choices: []);

    } else if (currentDay == 2) {

      triggerEffects(flicker: true, shake: true);

      currentEvent = GameEvent(description: Localization.t('log_first_night', currentLanguage), choices: []);

    } else {

      currentEvent = _getRandomEvent();

    }

  }



  void useRadio(String action) {

    if (hasUsedRadioToday) return;

    hasUsedRadioToday = true;

    

    if (action == "scan") {

      int chance = Random().nextInt(100);

      

      if (getTraitName("role_mother") == "trait_observer" && characters[1].isAlive && !characters[1].isExploring) chance += 20; 



      if (currentDay > 15 && !isMilitaryEvacRevealed && chance < 15) {

        isMilitaryEvacRevealed = true;

        _injectSpecialPlaces();

        currentEvent = GameEvent(description: Localization.t('radio_military_found', currentLanguage), choices: []);

        notifyListeners(); saveGame(); return;

      }



      if (chance < 30) {

        currentEvent = GameEvent(description: Localization.t('radio_signal_lost', currentLanguage), choices: []);

      } else if (chance < 60) {

        currentEvent = GameEvent(description: Localization.t('radio_military_hope', currentLanguage), choices: []);

      } else if (chance < 80) {

        currentEvent = GameEvent(description: Localization.t('radio_static', currentLanguage), choices: []);

      } else {

        currentEvent = GameEvent(description: Localization.t('radio_music_good', currentLanguage), choices: []);

        for (var c in characters) {

          if (c.isAlive && !c.isExploring && c.moraleLevel > 0) c.moraleLevel -= 1;

        }

      }

    } else if (action == "music") {

      currentEvent = GameEvent(description: Localization.t('radio_music_classic', currentLanguage), choices: []);

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

      currentEvent = GameEvent(description: Localization.t('ending_army', currentLanguage), choices: []);

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

            description: Localization.t('event_army_fake', currentLanguage),

            choices: [EventChoice(buttonText: Localization.t('action_open_hatch', currentLanguage), isEnabled: true, onSelect: () => triggerSalvation())]

        );

    } else if (eventId == 1) {

      triggerEffects(flicker: true);

      AudioManager().playSFX('event_bugs.mp3'); 

      return GameEvent(

        description: Localization.t('event_roaches', currentLanguage),

        choices: [

          EventChoice(

            buttonText: Localization.t('action_crush_tool', currentLanguage), isEnabled: toolCount > 0,

            onSelect: () {

              if (toolCount > 0) {

                bool breakTool = true; 

                if (getTraitName("role_father") == "trait_mechanic" && characters[0].isAlive && !characters[0].isExploring && Random().nextInt(100) < 30) breakTool = false;

                if (breakTool) toolCount--; 

                currentEvent = GameEvent(description: Localization.t('event_roaches_killed', currentLanguage), choices: []);

              }

              notifyListeners();

              saveGame(); 

            },

          ),

          EventChoice(

            buttonText: "Saklan",

            onSelect: () {

              if (getTraitName("role_kid") == "trait_lucky" && characters[2].isAlive && !characters[2].isExploring && Random().nextBool()) {

                 currentEvent = GameEvent(description: Localization.t('event_roaches_left', currentLanguage), choices: []);

              } else {

                 soupCount = max(0, soupCount - 2);

                 currentEvent = GameEvent(description: Localization.t('event_roaches_stole', currentLanguage), choices: []);

              }

              notifyListeners();

              saveGame(); 

            },

          ),

        ],

      );

    } else if (eventId == 2) {

      return GameEvent(

        description: Localization.t('event_vent_broken', currentLanguage),

        choices: [

          EventChoice(

            buttonText: Localization.t('action_fix_tool', currentLanguage), isEnabled: toolCount > 0,

            onSelect: () {

              if (toolCount > 0) {

                toolCount--; 

                currentEvent = GameEvent(description: Localization.t('event_vent_fixed', currentLanguage), choices: []);

              }

              notifyListeners();

              saveGame(); 

            },

          ),

          EventChoice(

            buttonText: Localization.t('action_dont_fix', currentLanguage),

            onSelect: () {

              _makeEveryoneSick();

              currentEvent = GameEvent(description: Localization.t('event_vent_sick', currentLanguage), choices: []);

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

        description: Localization.t('event_raiders', currentLanguage),

        choices: [

          EventChoice(

            buttonText: Localization.t('action_scare_gun', currentLanguage), isEnabled: ammoCount > 0,

            onSelect: () {

              if(ammoCount > 0) ammoCount--;

              currentEvent = GameEvent(description: Localization.t('event_raiders_scared', currentLanguage), choices: []);

              notifyListeners();

              saveGame(); 

            }

          ),

          EventChoice(

            buttonText: Localization.t('action_wait_silently', currentLanguage),

            onSelect: () {

              waterCount = max(0, waterCount - 2);

              soupCount = max(0, soupCount - 2);

              currentEvent = GameEvent(description: Localization.t('event_raiders_stole', currentLanguage), choices: []);

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

        description: Localization.t('event_gas_leak', currentLanguage),

        choices: [

          EventChoice(

            buttonText: Localization.t('action_plug_rags', currentLanguage), isEnabled: true,

            onSelect: () {

              _makeSomeoneTiredOrSick();

              currentEvent = GameEvent(description: Localization.t('event_gas_tired', currentLanguage), choices: []);

              notifyListeners();

              saveGame(); 

            }

          ),

        ]

      );

    } else if (eventId == 5) {

      return GameEvent(

        description: Localization.t('event_sus_cans', currentLanguage),

        choices: [

          EventChoice(

            buttonText: Localization.t('action_add_stock', currentLanguage), isEnabled: true,

            onSelect: () {

               if (Random().nextBool()) {

                 soupCount += 2;

                 currentEvent = GameEvent(description: Localization.t('event_cans_good', currentLanguage), choices: []);

               } else {

                 _makeSomeoneTiredOrSick();

                 currentEvent = GameEvent(description: Localization.t('event_cans_bad', currentLanguage), choices: []);

               }

               notifyListeners();

               saveGame(); 

            }

          ),

          EventChoice(

            buttonText: Localization.t('action_throw_away', currentLanguage), isEnabled: true,

            onSelect: () {

              currentEvent = GameEvent(description: Localization.t('event_cans_thrown', currentLanguage), choices: []);

              notifyListeners();

              saveGame(); 

            }

          )

        ]

      );

    } else if (eventId == 6) {

      return GameEvent(

        description: Localization.t('event_madness', currentLanguage),

        choices: [

          EventChoice(

            buttonText: Localization.t('action_chat_long', currentLanguage), isEnabled: true,

            onSelect: () {

              currentEvent = GameEvent(description: Localization.t('event_madness_cured', currentLanguage), choices: []);

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

        description: Localization.t('log_quiet_day', currentLanguage, {'day': currentDay.toString()}), 

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

      if (getTraitName("role_mother") == "trait_frugal" && characters[1].isAlive && !characters[1].isExploring && Random().nextInt(100) < 25) decreaseSoup = false;

      

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

      

      if (char.name == "role_kid" && getTraitName("role_kid") == "trait_cheerful") {

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

    

    if (characterName == "role_mother" && getTraitName("role_mother") == "trait_practical") {

      daysUntilReturn = Random().nextInt(2) + 1; 

    } else {

      daysUntilReturn = Random().nextInt(2) + 2;

    }

    

    for (var char in characters) {

      if (char.name == characterName) char.isExploring = true;

    }

    

    currentEvent = GameEvent(description: Localization.t('log_expedition_start', currentLanguage, {'char': Localization.t(characterName, currentLanguage), 'dest': destination.name}), choices: []);

    notifyListeners();

    saveGame();

  }



  void _handleExpeditionReturn() {

    if (exploringDestinationType == 'military') {

      isGameWon = true;

      currentEvent = GameEvent(description: Localization.t('ending_heli', currentLanguage, {'char': exploringCharacter != null ? Localization.t(exploringCharacter!, currentLanguage) : ''}), choices: []);

      notifyListeners(); deleteSaveData(); return;

    }



    if (exploringDestinationType == 'utopia') {

      if (waterCount >= 5 && soupCount >= 5) {

        isGameWon = true;

        currentEvent = GameEvent(description: Localization.t('ending_utopia', currentLanguage, {'char': exploringCharacter != null ? Localization.t(exploringCharacter!, currentLanguage) : ''}), choices: []);

        notifyListeners(); deleteSaveData(); return;

      } else {

        String failText = Localization.t('ending_utopia_fail', currentLanguage, {'char': exploringCharacter != null ? Localization.t(exploringCharacter!, currentLanguage) : ''});

        for (var char in characters) { if (char.name == exploringCharacter) char.isExploring = false; }

        exploringCharacter = null; exploringDestinationName = null; exploringDestinationType = null;

        currentEvent = GameEvent(description: failText, choices: []);

        notifyListeners(); saveGame(); return;

      }

    }



    int chance = Random().nextInt(100);

    String resultText = "";

    

    bool isAgile = (exploringCharacter == "role_kid" && getTraitName("role_kid") == "trait_agile");

    bool isProtective = (exploringCharacter == "role_father" && getTraitName("role_father") == "trait_protector");

    bool isScavenger = (exploringCharacter == "role_kid" && getTraitName("role_kid") == "trait_sharp_eyed");



    if (chance < 20 && !isAgile) {

      resultText = Localization.t("expedition_ambush", currentLanguage, {"char": Localization.t(exploringCharacter!, currentLanguage)});

      for (var char in characters) {

        if (char.name == exploringCharacter) char.status = 'injured';

      }

    } else if (chance < 40 && !isScavenger) {

      resultText = Localization.t("expedition_empty", currentLanguage, {"char": Localization.t(exploringCharacter!, currentLanguage), "dest": exploringDestinationName!});

    } else {

      int extra = isProtective || isScavenger ? 1 : 0; 



      if (exploringDestinationType == 'pharmacy') {

        medkitCount += (1 + extra);

        waterCount += 1;

        resultText = Localization.t('expedition_success_pharmacy', currentLanguage, {'char': exploringCharacter != null ? Localization.t(exploringCharacter!, currentLanguage) : ''});

      } else if (exploringDestinationType == 'supermarket') {

        int foundWater = Random().nextInt(2) + 2 + extra;

        int foundSoup = Random().nextInt(2) + 2 + extra;

        waterCount += foundWater;

        soupCount += foundSoup;

        resultText = Localization.t("expedition_success_market", currentLanguage, {"char": Localization.t(exploringCharacter!, currentLanguage), "water": foundWater.toString(), "soup": foundSoup.toString()});

      } else if (exploringDestinationType == 'hardware') {

        toolCount += (1 + extra);

        resultText = Localization.t('expedition_success_hardware', currentLanguage, {'char': exploringCharacter != null ? Localization.t(exploringCharacter!, currentLanguage) : ''});

      } else {

        int foundWater = Random().nextInt(2) + 1 + extra;

        int foundSoup = Random().nextInt(2) + 1 + extra;

        waterCount += foundWater;

        soupCount += foundSoup;

        resultText = Localization.t("expedition_success", currentLanguage, {"char": Localization.t(exploringCharacter!, currentLanguage), "water": foundWater.toString(), "soup": foundSoup.toString()});

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

      nearbyPlaces.add(Place(name: Localization.t("place_military", currentLanguage), lat: lat + 0.015, lng: lng - 0.015, type: 'military'));

    }

    if (isUtopiaRevealed && !nearbyPlaces.any((p) => p.type == 'utopia')) {

      nearbyPlaces.add(Place(name: Localization.t("place_utopia", currentLanguage), lat: lat - 0.012, lng: lng + 0.012, type: 'utopia'));

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

    locationName = Localization.t('gps_location', currentLanguage); 

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

    } catch (e) { print(Localization.t('ip_error', currentLanguage, {'e': e.toString()})); }

    return false;

  }



  Future<void> fetchNearbyPlaces() async {

    if (_isFetchingPlaces) return; 

    _isFetchingPlaces = true;



    isLoadingPlaces = true;

    loadingMessage = Localization.t("loading_radar", currentLanguage);

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

          loadingMessage = Localization.t("loading_map_cache", currentLanguage);

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

    } catch (e) { print(Localization.t('error_cache_read', currentLanguage, {'e': e.toString()})); }



    loadingMessage = Localization.t("loading_map_api", currentLanguage);

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



    loadingMessage = Localization.t("loading_map_fallback", currentLanguage);

    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 500));



    try {

      nearbyPlaces.clear();

      final random = Random();

      int pharmacyCount = random.nextInt(4) + 3;

      List<String> pharmacyNames = ["pharmacy_1", "pharmacy_2", "pharmacy_3", "pharmacy_4", "pharmacy_5", "pharmacy_6", "pharmacy_7", "pharmacy_8"];

      for (int i = 0; i < pharmacyCount; i++) {

        nearbyPlaces.add(Place(name: Localization.t(pharmacyNames[random.nextInt(pharmacyNames.length)], currentLanguage), lat: lat + (random.nextDouble() - 0.5) * 0.010, lng: lng + (random.nextDouble() - 0.5) * 0.010, type: 'pharmacy'));

      }

      int marketCount = random.nextInt(4) + 4;

      List<String> marketNames = ["market_1", "market_2", "market_3", "market_4", "market_5", "market_6", "market_7", "market_8"];

      for (int i = 0; i < marketCount; i++) {

        nearbyPlaces.add(Place(name: Localization.t(marketNames[random.nextInt(marketNames.length)], currentLanguage), lat: lat + (random.nextDouble() - 0.5) * 0.010, lng: lng + (random.nextDouble() - 0.5) * 0.010, type: 'supermarket'));

      }

      int hardwareCount = random.nextInt(3) + 1;

      List<String> hardwareNames = ["hardware_1", "hardware_2", "hardware_3", "hardware_4", "hardware_5"];

      for (int i = 0; i < hardwareCount; i++) {

        nearbyPlaces.add(Place(name: Localization.t(hardwareNames[random.nextInt(hardwareNames.length)], currentLanguage), lat: lat + (random.nextDouble() - 0.5) * 0.010, lng: lng + (random.nextDouble() - 0.5) * 0.010, type: 'hardware'));

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
    prefs.setString('currentLanguage', currentLanguage);

    

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

    locationName = prefs.getString('locationName') ?? Localization.t('unknown_region', currentLanguage);

    isGameOver = prefs.getBool('isGameOver') ?? false;

    isGameWon = prefs.getBool('isGameWon') ?? false;
    currentLanguage = prefs.getString('currentLanguage') ?? 'tr';

    

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

