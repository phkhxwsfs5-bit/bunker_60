class Character {
  String name;
  String imagePrefix; // Örn: 'dad' -> 'dad_normal.png' olarak UI'da birleşecek
  bool isAlive;
  bool isExploring;
  int hungerLevel; // 0-5 arası (0 tam tok, 5 açlıktan ölmek üzere)
  int thirstLevel; // 0-4 arası (0 tam suya doymuş, 4 susuzluktan ölmek üzere)
  int moraleLevel; // 0-5 arası (0 çok mutlu, 5 tamamen delirmek üzere/insane)
  String status; // 'normal', 'sick', 'injured', 'insane'
  
  int daysSinceFood;
  int daysSinceWater;
  int daysSinceTalk;

  Character({
    required this.name,
    required this.imagePrefix,
    this.isAlive = true,
    this.isExploring = false,
    this.hungerLevel = 0,
    this.thirstLevel = 0,
    this.moraleLevel = 0,
    this.status = 'normal',
    this.daysSinceFood = 0,
    this.daysSinceWater = 0,
    this.daysSinceTalk = 0,
  });

  // Susuzluk ve açlığı arttıran Tick fonksiyonu
  void ageOneDay() {
    if (!isAlive || isExploring) return;
    
    daysSinceFood++;
    daysSinceWater++;
    daysSinceTalk++;

    // Her 3 günde bir açlık artar
    if (daysSinceFood >= 3) {
      if (hungerLevel < 5) hungerLevel++;
      daysSinceFood = 0; // Sayacı sıfırla ki her gün ardışık artmasın
    }

    // Her 2 günde bir susuzluk artar
    if (daysSinceWater >= 2) {
      if (thirstLevel < 4) thirstLevel++;
      daysSinceWater = 0; 
    }

    // Her 4 günde bir yalnızlıktan/stresten moral bozulur
    if (daysSinceTalk >= 4) {
      if (moraleLevel < 5) moraleLevel++;
      daysSinceTalk = 0;
    }

    // Hastalık tetikleyicisi
    if (hungerLevel >= 4 || thirstLevel >= 3) {
      if (status == 'normal') status = 'sick';
    }

    // Delilik (Insane) tetikleyicisi
    if (moraleLevel >= 5 && status == 'normal') {
      status = 'insane';
    }

    // Ölüm kontrolü (Susuzluk 4'e veya Açlık 5'e ulaşırsa)
    if (thirstLevel >= 4 || hungerLevel >= 5) {
      isAlive = false;
      status = 'dead';
    }
  }

  // Besleme ve İlgi Fonksiyonları
  void feedSoup() {
    hungerLevel = 0;
    daysSinceFood = 0;
  }

  void feedWater() {
    thirstLevel = 0;
    daysSinceWater = 0;
  }

  void heal() {
    if (status == 'sick' || status == 'injured') {
      status = 'normal';
    }
  }

  void talk() {
    moraleLevel = 0;
    daysSinceTalk = 0;
    if (status == 'insane') {
      status = 'normal';
    }
  }

  // UI için anlık resim yolunu veren yardımcı
  String get currentImagePath {
    if (!isAlive) return 'assets/game_over.jpg'; // İleride mezar taşı falan eklenebilir
    return 'assets/${imagePrefix}_$status.png';
  }
}

// Oyuncunun karşısına çıkacak Karar Butonları
class EventChoice {
  final String buttonText;
  final Function() onSelect;
  final bool isEnabled;

  EventChoice({required this.buttonText, required this.onSelect, this.isEnabled = true});
}

// Günlük Kayıtlarında çıkacak Olaylar
class GameEvent {
  final String description;
  final List<EventChoice> choices;

  GameEvent({required this.description, required this.choices});
}

// Gerçek Dünya Mekanları
class Place {
  final String name;
  final double lat;
  final double lng;
  final String type; // pharmacy, supermarket, hardware

  Place({
    required this.name,
    required this.lat,
    required this.lng,
    required this.type,
  });
}
