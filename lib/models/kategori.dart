class Kategori {
  final int id;
  final String ad;
  final String kategoriUrl;

  const Kategori({
    required this.id,
    required this.ad,
    required this.kategoriUrl,
  });

  factory Kategori.fromJson(Map<String, dynamic> json) {
    return Kategori(
      id: json['id'] as int,
      ad: json['ad'] as String,
      kategoriUrl: (json['kategoriUrl'] ?? '') as String,
    );
  }
}
