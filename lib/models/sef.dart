class Sef {
  final int id;
  final String ad;
  final String fotoUrl;

  const Sef({
    required this.id,
    required this.ad,
    required this.fotoUrl,
  });

  factory Sef.fromJson(Map<String, dynamic> json) {
    return Sef(
      id: json['id'] as int,
      ad: json['ad'] as String,
      fotoUrl: (json['fotoUrl'] ?? '') as String,
    );
  }
}
