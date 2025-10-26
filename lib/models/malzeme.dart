class Malzeme {
  final int id;
  final String ad;
  final String malzemeTur;

  const Malzeme({
    required this.id,
    required this.ad,
    required this.malzemeTur,
  });

  factory Malzeme.fromJson(Map<String, dynamic> json) {
    return Malzeme(
      id: json['id'] as int,
      ad: json['ad'] as String,
      malzemeTur: json['malzemeTur'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'ad': ad,
    'malzemeTur': malzemeTur,
  };
}
