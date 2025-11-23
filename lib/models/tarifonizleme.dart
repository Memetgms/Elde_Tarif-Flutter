class TarifOnizleme {
  final int id;
  final String baslik;
  final String kapakFotoUrl;
  final int? porsiyonSayisi;
  final int? toplamSure;
  final int? sefId;
  final int kategoriId;

  const TarifOnizleme({
    required this.id,
    required this.baslik,
    required this.kapakFotoUrl,
    this.porsiyonSayisi,
    this.toplamSure,
    this.sefId,
    required this.kategoriId,
  });

  factory TarifOnizleme.fromJson(Map<String, dynamic> json) {
    return TarifOnizleme(
      id: json['id'] as int,
      baslik: json['baslik'] as String,
      kapakFotoUrl: (json['kapakFotoUrl'] ?? '') as String,
      porsiyonSayisi: json['porsiyonSayisi'] as int?,
      toplamSure: json['toplamSure'] as int?,
      sefId: json['sefId'] as int?,
      kategoriId: json['kategoriId'] as int,
    );
  }
}
