import 'dart:convert';
import 'package:elde_tarif/models/tarif_detay.dart';
import 'package:elde_tarif/models/tarif_oneri_sonuc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import 'package:elde_tarif/models/malzeme.dart';
import 'package:elde_tarif/models/kategori.dart';
import 'package:elde_tarif/models/sef.dart';
import 'package:elde_tarif/models/sef_detay.dart';
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

  Future<TarifDetay> getTarifDetay(int id) async {
    final uri = Uri.parse('$baseUrl/api/tarif/$id');
    final res = await http.get(uri);
    if (res.statusCode != 200) {
      throw Exception('Tarif detay alınamadı (${res.statusCode})');
    }
    final data = json.decode(res.body) as Map<String, dynamic>;
    return TarifDetay.fromJson(data);
  }

  // Şef Detay
  Future<SefDetay> getSefDetay(int id) async {
    final uri = Uri.parse('$baseUrl/api/Sef/$id');
    final res = await http.get(uri);
    if (res.statusCode != 200) {
      throw Exception('Şef detay alınamadı (${res.statusCode})');
    }
    final data = json.decode(res.body) as Map<String, dynamic>;
    return SefDetay.fromJson(data);
  }

  // Seçilen malzemeden tarif öneri
  Future<List<TarifOneriSonuc>> tarifOneriGetir(List<int> malzemeIdler) async {
    final uri = Uri.parse('$baseUrl/api/malzemebytarif');

    final body = {
      "malzemeIdler": malzemeIdler,
      "minimumSkorYuzde": 20,
      "minimumEslesenMalzemeSayisi": 1,
      "maksimumSonuc": 5,
      "sadeceEnIyiClusterdanMi": true,
    };

    final response = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode(body),
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final List<dynamic> jsonList = jsonDecode(response.body);
      return jsonList
          .map((e) => TarifOneriSonuc.fromJson(e as Map<String, dynamic>))
          .toList();
    } else {
      throw Exception(
          'Tarif öneri isteği başarısız: ${response.statusCode} - ${response.body}');
    }
  }
}
