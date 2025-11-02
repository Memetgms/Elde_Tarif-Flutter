class SefDetay {
  final int id;
  final String ad;
  final String fotoUrl;
  final String? aciklama;
  final List<SefTarif> tarifler;

  SefDetay({
    required this.id,
    required this.ad,
    required this.fotoUrl,
    this.aciklama,
    this.tarifler = const [],
  });

  factory SefDetay.fromJson(Map<String, dynamic> json) {
    return SefDetay(
      id: json['id'] as int,
      ad: json['ad'] as String,
      fotoUrl: (json['fotoUrl'] ?? '') as String,
      aciklama: json['aciklama'] as String?,
      tarifler: (json['tarifler'] as List? ?? [])
          .map((e) => SefTarif.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class SefTarif {
  final int id;
  final String baslik;
  final String kapakFotoUrl;
  final int? kategoriId;
  final String kategoriAdi;
  final int? hazirlikSuresiDakika;
  final int? porsiyonSayisi;

  SefTarif({
    required this.id,
    required this.baslik,
    required this.kapakFotoUrl,
    this.kategoriId,
    required this.kategoriAdi,
    this.hazirlikSuresiDakika,
    this.porsiyonSayisi,
  });

  factory SefTarif.fromJson(Map<String, dynamic> json) {
    return SefTarif(
      id: json['id'] as int,
      baslik: json['baslik'] as String,
      kapakFotoUrl: (json['kapakFotoUrl'] ?? '') as String,
      kategoriId: json['kategoriId'] as int?,
      kategoriAdi: json['kategoriAdi'] as String,
      hazirlikSuresiDakika: json['hazirlikSuresiDakika'] as int?,
      porsiyonSayisi: json['porsiyonSayisi'] as int?,
    );
  }
}

