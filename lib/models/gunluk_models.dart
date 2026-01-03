class GunlukOgunItem {
  final int id;
  final String ogunTipi;
  final int tarifId;
  final String tarifBaslik;
  final int kalori;
  final int protein;
  final int karbonhidrat;
  final int yag;

  GunlukOgunItem({
    required this.id,
    required this.ogunTipi,
    required this.tarifId,
    required this.tarifBaslik,
    required this.kalori,
    required this.protein,
    required this.karbonhidrat,
    required this.yag,
  });

  factory GunlukOgunItem.fromJson(Map<String, dynamic> json) {
    return GunlukOgunItem(
      id: (json['id'] as num).toInt(),
      ogunTipi: (json['ogunTipi'] ?? '') as String,
      tarifId: (json['tarifId'] as num).toInt(),
      tarifBaslik: (json['tarifBaslik'] ?? '') as String,
      kalori: ((json['kalori'] ?? 0) as num).toInt(),
      protein: ((json['protein'] ?? 0) as num).toInt(),
      karbonhidrat: ((json['karbonhidrat'] ?? 0) as num).toInt(),
      yag: ((json['yag'] ?? 0) as num).toInt(),
    );
  }
}

class GunlukMakroToplam {
  final int kalori;
  final int protein;
  final int karbonhidrat;
  final int yag;

  GunlukMakroToplam({
    required this.kalori,
    required this.protein,
    required this.karbonhidrat,
    required this.yag,
  });

  factory GunlukMakroToplam.fromJson(Map<String, dynamic> json) {
    return GunlukMakroToplam(
      kalori: ((json['kalori'] ?? 0) as num).toInt(),
      protein: ((json['protein'] ?? 0) as num).toInt(),
      karbonhidrat: ((json['karbonhidrat'] ?? 0) as num).toInt(),
      yag: ((json['yag'] ?? 0) as num).toInt(),
    );
  }
}
