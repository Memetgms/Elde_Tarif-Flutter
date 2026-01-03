import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:elde_tarif/apiservice/api_config.dart';
import 'package:elde_tarif/models/malzeme.dart';
import 'package:elde_tarif/models/tarif_oneri_sonuc.dart';
import 'package:elde_tarif/models/kategori.dart';

/// Malzeme ile ilgili API işlemleri
class MalzemeApi {
  /// Malzeme listesi
  Future<List<Malzeme>> fetchMalzemeler() async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/api/malzeme');
    final headers = await ApiConfig.getHeaders();
    
    final response = await http.get(uri, headers: headers);
    
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Malzemeler yüklenemedi (${response.statusCode})');
    }
    
    final List data = jsonDecode(response.body) as List;
    return data.map((e) => Malzeme.fromJson(e as Map<String, dynamic>)).toList();
  }

  /// Kategori listesi
  Future<List<Kategori>> fetchKategoriler() async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/api/Kategori');
    final headers = await ApiConfig.getHeaders();
    
    final response = await http.get(uri, headers: headers);
    
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Kategoriler yüklenemedi (${response.statusCode})');
    }
    
    final List data = jsonDecode(response.body) as List;
    return data.map((e) => Kategori.fromJson(e as Map<String, dynamic>)).toList();
  }

  /// Malzeme bazlı tarif önerisi
  Future<List<TarifOneriSonuc>> tarifOneriGetir(List<int> malzemeIdler) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/api/MalzemeByTarif');
    final headers = await ApiConfig.getHeaders();
    
    final body = jsonEncode({
      'malzemeIdler': malzemeIdler,
    });
    
    final response = await http.post(uri, headers: headers, body: body);
    
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Tarif önerileri alınamadı (${response.statusCode})');
    }
    
    final List data = jsonDecode(response.body) as List;
    return data.map((e) => TarifOneriSonuc.fromJson(e as Map<String, dynamic>)).toList();
  }
}
