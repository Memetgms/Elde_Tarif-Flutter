import 'package:http/http.dart' as http;
import 'package:elde_tarif/apiservice/api_config.dart';

/// Favori ile ilgili API işlemleri
class FavoriApi {
  /// Favoriye ekle
  Future<void> addFavorite(int tarifId) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/api/Favori/add/$tarifId');
    final headers = await ApiConfig.getHeaders(includeAuth: true);
    
    final response = await http.post(uri, headers: headers);
    
    if (response.statusCode == 401) {
      throw Exception('Oturum süresi doldu. Lütfen tekrar giriş yapın.');
    }
    
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Favoriye eklenemedi (${response.statusCode})');
    }
  }

  /// Favoriden çıkar
  Future<void> removeFavorite(int tarifId) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/api/Favori/remove/$tarifId');
    final headers = await ApiConfig.getHeaders(includeAuth: true);
    
    final response = await http.delete(uri, headers: headers);
    
    if (response.statusCode == 401) {
      throw Exception('Oturum süresi doldu. Lütfen tekrar giriş yapın.');
    }
    
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Favoriden çıkarılamadı (${response.statusCode})');
    }
  }
}
