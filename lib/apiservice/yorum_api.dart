import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:elde_tarif/apiservice/api_config.dart';
import 'package:elde_tarif/models/yorum.dart';

/// Yorum ile ilgili API işlemleri
class YorumApi {
  /// Tarifin yorumlarını listele
  /// GET: /api/yorum/tarif/{tarifId}?skip=0&take=20
  Future<List<YorumListItem>> getYorumlarByTarif(
    int tarifId, {
    int skip = 0,
    int take = 20,
  }) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/api/yorum/tarif/$tarifId?skip=$skip&take=$take');
    final headers = await ApiConfig.getHeaders();
    
    final response = await http.get(uri, headers: headers);
    
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Yorumlar yüklenemedi (${response.statusCode})');
    }
    
    final List data = jsonDecode(response.body) as List;
    return data
        .map((e) => YorumListItem.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Yorum ekle (giriş zorunlu)
  /// POST: /api/yorum
  Future<YorumListItem> createYorum(YorumCreateDto dto) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/api/yorum');
    final headers = await ApiConfig.getHeaders(includeAuth: true);
    
    final response = await http.post(
      uri,
      headers: headers,
      body: jsonEncode(dto.toJson()),
    );
    
    if (response.statusCode == 401) {
      throw Exception('Oturum süresi doldu. Lütfen tekrar giriş yapın.');
    }
    
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Yorum eklenemedi (${response.statusCode})');
    }
    
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return YorumListItem.fromJson(data);
  }

  /// Yorum güncelle (giriş zorunlu)
  /// PUT: /api/yorum/{id}
  Future<YorumListItem> updateYorum(int id, YorumUpdateDto dto) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/api/yorum/$id');
    final headers = await ApiConfig.getHeaders(includeAuth: true);
    
    final response = await http.put(
      uri,
      headers: headers,
      body: jsonEncode(dto.toJson()),
    );
    
    if (response.statusCode == 401) {
      throw Exception('Oturum süresi doldu. Lütfen tekrar giriş yapın.');
    }
    
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Yorum güncellenemedi (${response.statusCode})');
    }
    
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return YorumListItem.fromJson(data);
  }

  /// Yorum sil (giriş zorunlu)
  /// DELETE: /api/yorum/{id}
  Future<void> deleteYorum(int id) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/api/yorum/$id');
    final headers = await ApiConfig.getHeaders(includeAuth: true);
    
    final response = await http.delete(uri, headers: headers);
    
    if (response.statusCode == 401) {
      throw Exception('Oturum süresi doldu. Lütfen tekrar giriş yapın.');
    }
    
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Yorum silinemedi (${response.statusCode})');
    }
  }
}
