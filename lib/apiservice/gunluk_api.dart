import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:elde_tarif/apiservice/api_config.dart';
import 'package:elde_tarif/models/gunluk_models.dart';

class GunlukApi {
  Future<void> ogunEkle({
    required String ogunTipi,
    required int tarifId,
  }) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/api/gunluk/ogun-ekle');
    final headers = await ApiConfig.getHeaders(includeAuth: true);
    
    final body = jsonEncode({
      "ogunTipi": ogunTipi,
      "tarifId": tarifId,
    });
    
    final response = await http.post(uri, headers: headers, body: body);
    
    if (response.statusCode == 401) {
      throw Exception('Oturum süresi doldu. Lütfen tekrar giriş yapın.');
    }
    
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Öğün eklenemedi (${response.statusCode})');
    }
  }

  Future<List<GunlukOgunItem>> getOgunler() async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/api/gunluk/ogunler');
    final headers = await ApiConfig.getHeaders(includeAuth: true);
    
    final response = await http.get(uri, headers: headers);
    
    if (response.statusCode == 401) {
      throw Exception('Oturum süresi doldu. Lütfen tekrar giriş yapın.');
    }
    
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Öğünler yüklenemedi (${response.statusCode})');
    }
    
    final list = jsonDecode(response.body) as List<dynamic>;
    return list.map((e) => GunlukOgunItem.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<void> ogunSil(int id) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/api/gunluk/ogun-sil/$id');
    final headers = await ApiConfig.getHeaders(includeAuth: true);
    
    final response = await http.delete(uri, headers: headers);
    
    if (response.statusCode == 401) {
      throw Exception('Oturum süresi doldu. Lütfen tekrar giriş yapın.');
    }
    
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Öğün silinemedi (${response.statusCode})');
    }
  }

  Future<GunlukMakroToplam> getMakrolar() async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/api/gunluk/makrolar');
    final headers = await ApiConfig.getHeaders(includeAuth: true);
    
    final response = await http.get(uri, headers: headers);
    
    if (response.statusCode == 401) {
      throw Exception('Oturum süresi doldu. Lütfen tekrar giriş yapın.');
    }
    
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Makrolar yüklenemedi (${response.statusCode})');
    }
    
    final map = jsonDecode(response.body) as Map<String, dynamic>;
    return GunlukMakroToplam.fromJson(map);
  }
}
