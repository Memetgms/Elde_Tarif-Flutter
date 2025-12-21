class TarifDetay {
  final int id;
  final String? baslik;
  final String? kategoriAd;
  final String? sefAd;
  final String? kapakFotoUrl;
  final String? aciklama;
  final int? hazirlikSuresiDakika;
  final int? pismeSuresiDakika;
  final int? porsiyonSayisi;
  final int? kaloriKcal;
  final int? proteinGr;
  final int? karbonhidratGr;
  final int? yagGr;
  final List<DetayMalzeme> malzemeler;
  final List<DetayYapimAdimi> yapimAdimlari;
  final List<DetayYorum> sonYorumlar;

  TarifDetay({
    required this.id,
    this.baslik,
    this.kategoriAd,
    this.sefAd,
    this.kapakFotoUrl,
    this.aciklama,
    this.hazirlikSuresiDakika,
    this.pismeSuresiDakika,
    this.porsiyonSayisi,
    this.kaloriKcal,
    this.proteinGr,
    this.karbonhidratGr,
    this.yagGr,
    this.malzemeler = const [],
    this.yapimAdimlari = const [],
    this.sonYorumlar = const [],
  });

  factory TarifDetay.fromJson(Map<String, dynamic> j) => TarifDetay(
    id: j['id'],
    baslik: j['baslik'],
    kategoriAd: j['kategoriAd'],
    sefAd: j['sefAd'],
    kapakFotoUrl: j['kapakFotoUrl'],
    aciklama: j['aciklama'],
    hazirlikSuresiDakika: j['hazirlikSuresiDakika'],
    pismeSuresiDakika: j['pismeSuresiDakika'],
    porsiyonSayisi: j['porsiyonSayisi'],
    kaloriKcal: j['kaloriKcal'],
    proteinGr: j['proteinGr'],
    karbonhidratGr: j['karbonhidratGr'],
    yagGr: j['yagGr'],
    malzemeler: (j['malzemeler'] as List? ?? [])
        .map((e) => DetayMalzeme.fromJson(e))
        .toList(),
    yapimAdimlari: (j['yapimAdimlari'] as List? ?? [])
        .map((e) => DetayYapimAdimi.fromJson(e))
        .toList(),
    sonYorumlar: (j['sonYorumlar'] as List? ?? [])
        .map((e) => DetayYorum.fromJson(e))
        .toList(),
  );
}

class DetayMalzeme {
  final int malzemeId;
  final String malzemeAd;
  final String? malzemeTur;
  final String? aciklama;

  DetayMalzeme({
    required this.malzemeId,
    required this.malzemeAd,
    this.malzemeTur,
    this.aciklama,
  });

  factory DetayMalzeme.fromJson(Map<String, dynamic> j) => DetayMalzeme(
    malzemeId: j['malzemeId'],
    malzemeAd: j['malzemeAd'],
    malzemeTur: j['malzemeTur'],
    aciklama: j['aciklama'],
  );
}

class DetayYapimAdimi {
  final int id;
  final int? sira;
  final String? aciklama;

  DetayYapimAdimi({required this.id, this.sira, this.aciklama});

  factory DetayYapimAdimi.fromJson(Map<String, dynamic> j) => DetayYapimAdimi(
    id: j['id'],
    sira: j['sira'],
    aciklama: j['aciklama'],
  );
}

class DetayYorum {
  final int id;
  final String kullaniciId;
  final String? userName;
  final String? kullaniciAdSoyad; // Eski alan, geriye uyumluluk için
  final String? icerik;
  final int? puan;
  final DateTime olusturulmaTarihi;

  DetayYorum({
    required this.id,
    required this.kullaniciId,
    this.userName,
    this.kullaniciAdSoyad,
    this.icerik,
    this.puan,
    required this.olusturulmaTarihi,
  });

  factory DetayYorum.fromJson(Map<String, dynamic> j) => DetayYorum(
    id: j['id'],
    kullaniciId: j['kullaniciId'],
    userName: j['userName'] ?? j['kullaniciAdSoyad'], // Backend userName gönderiyor
    kullaniciAdSoyad: j['kullaniciAdSoyad'] ?? j['userName'], // Geriye uyumluluk
    icerik: j['icerik'],
    puan: j['puan'],
    olusturulmaTarihi: DateTime.parse(j['olusturulmaTarihi']),
  );
}
