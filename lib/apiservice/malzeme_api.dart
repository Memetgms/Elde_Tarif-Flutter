import 'dart:convert';
import 'package:elde_tarif/apiservice/api_client.dart';
import 'package:elde_tarif/models/malzeme.dart';
import 'package:elde_tarif/models/tarif_oneri_sonuc.dart';
import 'package:elde_tarif/models/kategori.dart';

/// Malzeme ile ilgili API işlemleri
class MalzemeApi {
  final ApiClient _client;

  MalzemeApi(this._client);

  /// Malzeme listesi
  Future<List<Malzeme>> fetchMalzemeler() async {
    final response = await _client.get('/api/malzeme');
    final List data = jsonDecode(response.body) as List;
    return data.map((e) => Malzeme.fromJson(e as Map<String, dynamic>)).toList();
  }

  /// Kategori listesi
  Future<List<Kategori>> fetchKategoriler() async {
    final response = await _client.get('/api/Kategori');
    final List data = jsonDecode(response.body) as List;
    return data.map((e) => Kategori.fromJson(e as Map<String, dynamic>)).toList();
  }

  /// Malzeme bazlı tarif önerisi
  Future<List<TarifOneriSonuc>> tarifOneriGetir(List<int> malzemeIdler) async {
    // Backend TarifOneriIstekDto bekliyor: { "malzemeIdler": [1, 2, 3] }
    final body = {
      'malzemeIdler': malzemeIdler,
    };
    
    final response = await _client.post(
      '/api/MalzemeByTarif',
      body: body,
    );
    final List data = jsonDecode(response.body) as List;
    return data.map((e) => TarifOneriSonuc.fromJson(e as Map<String, dynamic>)).toList();
  }
}




