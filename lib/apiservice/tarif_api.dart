import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:elde_tarif/apiservice/api_config.dart';
import 'package:elde_tarif/models/tarifonizleme.dart';
import 'package:elde_tarif/models/tarif_detay.dart';

/// Tarif ile ilgili API işlemleri
class TarifApi {
  /// Tarif önizleme listesi
  Future<List<TarifOnizleme>> fetchTarifOnizleme() async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/api/TarifGosterme/tarifonizleme');
    final headers = await ApiConfig.getHeaders();
    
    final response = await http.get(uri, headers: headers);
    
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Tarifler yüklenemedi (${response.statusCode})');
    }
    
    final List data = jsonDecode(response.body) as List;
    return data.map((e) => TarifOnizleme.fromJson(e as Map<String, dynamic>)).toList();
  }

  /// Tarif detayı
  Future<TarifDetay> getTarifDetay(int id) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/api/TarifGosterme/tarif/$id');
    final headers = await ApiConfig.getHeaders();
    
    final response = await http.get(uri, headers: headers);
    
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Tarif detayı yüklenemedi (${response.statusCode})');
    }
    
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return TarifDetay.fromJson(data);
  }

  /// View kaydı (sessiz - hata olsa bile UI bozulmasın)
  Future<void> addView(int tarifId) async {
    try {
      final uri = Uri.parse('${ApiConfig.baseUrl}/api/TarifGosterme/$tarifId/view');
      final headers = await ApiConfig.getHeaders(includeAuth: true);
      await http.post(uri, headers: headers);
    } catch (_) {
      // Sessizce ignore et - UI bozulmasın
    }
  }

  /// Ana sayfa önerileri
  Future<List<TarifOnizleme>> fetchHomeRecommendations({int count = 5}) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/api/TarifGosterme/oneri/anasayfa?count=$count');
    final headers = await ApiConfig.getHeaders();
    
    final response = await http.get(uri, headers: headers);
    
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Öneriler yüklenemedi (${response.statusCode})');
    }
    
    final List data = jsonDecode(response.body) as List;
    return data.map((e) => TarifOnizleme.fromJson(e as Map<String, dynamic>)).toList();
  }
}
