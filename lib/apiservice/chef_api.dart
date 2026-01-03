import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:elde_tarif/apiservice/api_config.dart';
import 'package:elde_tarif/models/sef.dart';
import 'package:elde_tarif/models/sef_detay.dart';

/// Şef ile ilgili API işlemleri
class ChefApi {
  /// Şef listesi
  Future<List<Sef>> fetchSefler() async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/api/Sef');
    final headers = await ApiConfig.getHeaders();
    
    final response = await http.get(uri, headers: headers);
    
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Şefler yüklenemedi (${response.statusCode})');
    }
    
    final List data = jsonDecode(response.body) as List;
    return data.map((e) => Sef.fromJson(e as Map<String, dynamic>)).toList();
  }

  /// Şef detayı
  Future<SefDetay> getSefDetay(int id) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/api/Sef/$id');
    final headers = await ApiConfig.getHeaders();
    
    final response = await http.get(uri, headers: headers);
    
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Şef detayı yüklenemedi (${response.statusCode})');
    }
    
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return SefDetay.fromJson(data);
  }
}
