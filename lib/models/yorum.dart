class YorumListItem {
  final int id;
  final int tarifId;
  final String kullaniciId;
  final String userName;
  final String? icerik;
  final int? puan;
  final DateTime olusturulmaTarihi;

  YorumListItem({
    required this.id,
    required this.tarifId,
    required this.kullaniciId,
    required this.userName,
    this.icerik,
    this.puan,
    required this.olusturulmaTarihi,
  });

  factory YorumListItem.fromJson(Map<String, dynamic> j) => YorumListItem(
        id: j['id'],
        tarifId: j['tarifId'],
        kullaniciId: j['kullaniciId'],
        userName: j['userName'] ?? '',
        icerik: j['icerik'],
        puan: j['puan'],
        olusturulmaTarihi: DateTime.parse(j['olusturulmaTarihi']),
      );
}

class YorumCreateDto {
  final int tarifId;
  final String? icerik;
  final int? puan;

  YorumCreateDto({
    required this.tarifId,
    this.icerik,
    this.puan,
  });

  Map<String, dynamic> toJson() => {
        'tarifId': tarifId,
        if (icerik != null) 'icerik': icerik,
        if (puan != null) 'puan': puan,
      };
}

class YorumUpdateDto {
  final String? icerik;
  final int? puan;

  YorumUpdateDto({
    this.icerik,
    this.puan,
  });

  Map<String, dynamic> toJson() => {
        if (icerik != null) 'icerik': icerik,
        if (puan != null) 'puan': puan,
      };
}


