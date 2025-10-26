import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:elde_tarif/models/malzeme.dart';
import 'package:elde_tarif/models/kategori.dart';
import 'package:elde_tarif/models/sef.dart';
import 'package:elde_tarif/models/tarifonizleme.dart';

class ApiService {
  static const String baseUrl = 'http://10.0.2.2:5262';

  String getImageUrl(String imagePath) {
    if (imagePath.isEmpty) return imagePath;
    if (imagePath.startsWith('http://') || imagePath.startsWith('https://')) {
      return imagePath;
    }
    return '$baseUrl$imagePath';
  }

  // Kategoriler
  Future<List<Kategori>> fetchKategoriler() async {
    final response = await http.get(Uri.parse('$baseUrl/api/Kategori'));
    if (response.statusCode != 200) {
      throw Exception('Kategori isteği başarısız: ${response.statusCode}');
    }
    final List data = jsonDecode(response.body) as List;
    return data.map((e) => Kategori.fromJson(e as Map<String, dynamic>)).toList();
  }

  // Şefler
  Future<List<Sef>> fetchSefler() async {
    final response = await http.get(Uri.parse('$baseUrl/api/Sef'));
    if (response.statusCode != 200) {
      throw Exception('Şefler isteği başarısız: ${response.statusCode}');
    }
    final List data = jsonDecode(response.body) as List;
    return data.map((e) => Sef.fromJson(e as Map<String, dynamic>)).toList();
  }

  // Tarif Önizleme
  Future<List<TarifOnizleme>> fetchTarifOnizleme() async {
    final response = await http.get(Uri.parse('$baseUrl/api/tarifonizleme'));
    if (response.statusCode != 200) {
      throw Exception('Tarif önizleme isteği başarısız: ${response.statusCode}');
    }
    final List data = jsonDecode(response.body) as List;
    return data.map((e) => TarifOnizleme.fromJson(e as Map<String, dynamic>)).toList();
  }

  // Malzemeler
  Future<List<Malzeme>> fetchMalzemeler() async {
    final response = await http.get(Uri.parse('$baseUrl/api/malzeme'));
    if (response.statusCode != 200) {
      throw Exception('Malzeme isteği başarısız: ${response.statusCode}');
    }
    final List data = jsonDecode(response.body) as List;
    return data.map((e) => Malzeme.fromJson(e as Map<String, dynamic>)).toList();
  }
}
