class TarifOnizleme {
  final int id;
  final String baslik;
  final String kapakFotoUrl;

  const TarifOnizleme({
    required this.id,
    required this.baslik,
    required this.kapakFotoUrl,
  });

  factory TarifOnizleme.fromJson(Map<String, dynamic> json) {
    return TarifOnizleme(
      id: json['id'] as int,
      baslik: json['baslik'] as String,
      kapakFotoUrl: (json['kapakFotoUrl'] ?? '') as String,
    );
  }
}
