class TarifOneriSonuc {
  final int tarifId;
  final String baslik;
  final double skorYuzde;
  final double eslesenAgirlik;
  final double toplamAgirlik;
  final int eslesenMalzemeSayisi;
  final int tarifToplamMalzemeSayisi;
  final int? clusterId;
  final String? tarifFoto;
  final List<String> eslesenMalzemeler;

  TarifOneriSonuc({
    required this.tarifId,
    required this.baslik,
    required this.skorYuzde,
    required this.eslesenAgirlik,
    required this.toplamAgirlik,
    required this.eslesenMalzemeSayisi,
    required this.tarifToplamMalzemeSayisi,
    this.clusterId,
    this.tarifFoto,
    required this.eslesenMalzemeler,
  });

  factory TarifOneriSonuc.fromJson(Map<String, dynamic> json) {
    return TarifOneriSonuc(
      tarifId: json['tarifId'] as int,
      baslik: json['baslik'] as String,
      skorYuzde: (json['skorYuzde'] as num).toDouble(),
      eslesenAgirlik: (json['eslesenAgirlik'] as num).toDouble(),
      toplamAgirlik: (json['toplamAgirlik'] as num).toDouble(),
      eslesenMalzemeSayisi: json['eslesenMalzemeSayisi'] as int,
      tarifToplamMalzemeSayisi: json['tarifToplamMalzemeSayisi'] as int,
      clusterId: json['clusterId'] as int?,
      tarifFoto: json['tarifFoto'] as String?,
      eslesenMalzemeler: (json['eslesenMalzemeler'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
    );
  }
}
