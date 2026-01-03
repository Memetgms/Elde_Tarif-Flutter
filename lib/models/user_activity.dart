class UserDTO {
  final String id;
  final String email;
  final String? userName;

  UserDTO({required this.id, required this.email, this.userName});

  factory UserDTO.fromJson(Map<String, dynamic> json) {
    return UserDTO(
      id: json['id'],
      email: json['email'],
      userName: json['userName'],
    );
  }
}

class ActivityDTO {
  final DateTime? tarih;
  final String tip;
  final String mesaj;
  final int tarifId;

  ActivityDTO({
    this.tarih,
    required this.tip,
    required this.mesaj,
    required this.tarifId,
  });

  factory ActivityDTO.fromJson(Map<String, dynamic> json) {
    return ActivityDTO(
      tarih: json['tarih'] != null ? DateTime.parse(json['tarih']) : null,
      tip: json['tip'],
      mesaj: json['mesaj'],
      tarifId: json['tarifId'],
    );
  }
}
