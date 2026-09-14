import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AudioManager {
  static final AudioManager _instance = AudioManager._internal();
  factory AudioManager() => _instance;

  final AudioPlayer _bgmPlayer = AudioPlayer();
  final List<AudioPlayer> _sfxPlayers = [];
  int _sfxIndex = 0; 
  
  // --- SES SEVİYELERİ ---
  double bgmVolume = 1.0;
  double sfxVolume = 1.0;
  String? _currentBgm;
  bool _isInitialized = false;

  // --- OYUN İÇİ MİKSERİMİZ ---
  final Map<String, double> _soundMixer = {
    'bgm_bunker.mp3': 0.10,
    'ui_click.mp3': 0.85,         
    'ui_end_day.mp3': 1.0,       
    'action_water.mp3': 0.75,     
    'action_soup.mp3': 0.75,
    'action_heal.mp3': 0.75,      
    'action_chat.mp3': 1.0,
    'radio_static.mp3': 1.0,     
    'radio_music.mp3': 0.20,
    'effect_shake.mp3': 1.0,     
    'effect_flicker.mp3': 0.8,   
    'event_bugs.mp3': 1.0,       
    'event_door_bang.mp3': 0.5,  
    'event_leak.mp3': 0.05, 
    'ui_page_turn.mp3': 0.7,     
  };

  AudioManager._internal() {
    final audioContext = AudioContext(
      android: AudioContextAndroid(
        isSpeakerphoneOn: false,
        stayAwake: false,
        contentType: AndroidContentType.music,
        usageType: AndroidUsageType.game,
        audioFocus: AndroidAudioFocus.none, 
      ),
      iOS: AudioContextIOS(
        category: AVAudioSessionCategory.playback,
        options: { 
          AVAudioSessionOptions.mixWithOthers, 
        },
      ),
    );
    
    AudioPlayer.global.setAudioContext(audioContext);

    for (int i = 0; i < 5; i++) {
      _sfxPlayers.add(AudioPlayer()..setReleaseMode(ReleaseMode.stop));
    }
  }

  // --- HAFIZADAN SES AYARLARINI YÜKLE VE PRELOAD YAP ---
  Future<void> init() async {
    if (_isInitialized) return;
    final prefs = await SharedPreferences.getInstance();
    bgmVolume = prefs.getDouble('bgmVolume') ?? 1.0;
    sfxVolume = prefs.getDouble('sfxVolume') ?? 1.0;
    
    try {
      await AudioCache.instance.loadAll(
        _soundMixer.keys.map((fileName) => 'audio/$fileName').toList()
      );
    } catch (e) {
      // Güvenlik önlemi
    }

    _isInitialized = true;
  }

  // --- ARKA PLAN MÜZİĞİ (BGM) ---
  Future<void> playBGM(String fileName) async {
    double fileBaseVol = _soundMixer[fileName] ?? 1.0;
    double finalVol = bgmVolume * fileBaseVol;

    if (_currentBgm == fileName && _bgmPlayer.state == PlayerState.playing) {
      await _bgmPlayer.setVolume(finalVol);
      return;
    }

    _currentBgm = fileName;
    await _bgmPlayer.setReleaseMode(ReleaseMode.loop);
    await _bgmPlayer.setVolume(finalVol);
    
    if (bgmVolume > 0) {
      // KESİN ÇÖZÜM: Sesi play fonksiyonuna parametre olarak veriyoruz ki patlama yapmasın
      await _bgmPlayer.play(AssetSource('audio/$fileName'), volume: finalVol);
    }
  }

  Future<void> stopBGM() async {
    await _bgmPlayer.stop();
  }

  Future<void> pauseBGM() async {
    await _bgmPlayer.pause();
  }

  Future<void> resumeBGM() async {
    await _bgmPlayer.resume();
  }

  // --- MÜZİK SESİNİ DEĞİŞTİR VE HAFIZAYA KAYDET ---
  Future<void> setBgmVolume(double volume) async {
    bgmVolume = volume;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('bgmVolume', volume); 
    
    double fileBaseVol = _soundMixer[_currentBgm] ?? 1.0;
    double finalVol = bgmVolume * fileBaseVol;
    await _bgmPlayer.setVolume(finalVol);
    
    if (bgmVolume == 0.0) {
      await pauseBGM();
    } else if (bgmVolume > 0.0 && _bgmPlayer.state == PlayerState.paused) {
      await resumeBGM();
    } else if (bgmVolume > 0.0 && _bgmPlayer.state != PlayerState.playing && _currentBgm != null) {
      await playBGM(_currentBgm!);
    }
  }

  // --- SES EFEKTLERİ (SFX) ---
  Future<void> playSFX(String fileName) async {
    if (sfxVolume <= 0) return; 
    
    double fileBaseVolume = _soundMixer[fileName] ?? 1.0;
    double finalVolume = sfxVolume * fileBaseVolume;
    
    final player = _sfxPlayers[_sfxIndex];
    _sfxIndex = (_sfxIndex + 1) % _sfxPlayers.length; 
    
    await player.stop();
    await player.setVolume(finalVolume);
    // Patlamaları önlemek için finalVolume parametresi buraya da eklendi
    await player.play(AssetSource('audio/$fileName'), volume: finalVolume);
  }
  
  // --- EFEKT SESİNİ DEĞİŞTİR VE HAFIZAYA KAYDET ---
  Future<void> setSfxVolume(double volume) async {
    sfxVolume = volume;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('sfxVolume', volume); 

    for (var player in _sfxPlayers) {
      await player.setVolume(sfxVolume);
    }
  }

  Future<void> stopAll() async {
    await _bgmPlayer.stop();
    for (var player in _sfxPlayers) {
      await player.stop();
    }
  }
}