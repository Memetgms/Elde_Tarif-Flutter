import 'dart:convert';
import 'package:elde_tarif/apiservice/api_client.dart';
import 'package:elde_tarif/models/tarifonizleme.dart';
import 'package:elde_tarif/models/tarif_detay.dart';

/// Tarif ile ilgili API işlemleri
class TarifApi {
  final ApiClient _client;

  TarifApi(this._client);

  /// Tarif önizleme listesi
  Future<List<TarifOnizleme>> fetchTarifOnizleme() async {
    final response = await _client.get('/api/TarifGosterme/tarifonizleme');
    final List data = jsonDecode(response.body) as List;
    return data.map((e) => TarifOnizleme.fromJson(e as Map<String, dynamic>)).toList();
  }

  /// Tarif detayı
  Future<TarifDetay> getTarifDetay(int id) async {
    final response = await _client.get('/api/TarifGosterme/tarif/$id');
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return TarifDetay.fromJson(data);
  }

  /// View kaydı (sessiz - hata olsa bile UI bozulmasın)
  Future<void> addView(int tarifId) async {
    try {
      await _client.post('/api/TarifGosterme/$tarifId/view');
    } catch (_) {
      // Sessizce ignore et - UI bozulmasın
    }
  }

  /// Ana sayfa önerileri
  Future<List<TarifOnizleme>> fetchHomeRecommendations({int count = 5}) async {
    final response = await _client.get('/api/TarifGosterme/oneri/anasayfa?count=$count');
    final List data = jsonDecode(response.body) as List;
    return data.map((e) => TarifOnizleme.fromJson(e as Map<String, dynamic>)).toList();
  }
}



