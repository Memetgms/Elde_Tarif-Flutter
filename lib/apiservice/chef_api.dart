import 'dart:convert';
import 'package:elde_tarif/apiservice/api_client.dart';
import 'package:elde_tarif/models/sef.dart';
import 'package:elde_tarif/models/sef_detay.dart';

/// Şef ile ilgili API işlemleri
class ChefApi {
  final ApiClient _client;

  ChefApi(this._client);

  /// Şef listesi
  Future<List<Sef>> fetchSefler() async {
    final response = await _client.get('/api/Sef');
    final List data = jsonDecode(response.body) as List;
    return data.map((e) => Sef.fromJson(e as Map<String, dynamic>)).toList();
  }

  /// Şef detayı
  Future<SefDetay> getSefDetay(int id) async {
    final response = await _client.get('/api/Sef/$id');
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return SefDetay.fromJson(data);
  }
}



