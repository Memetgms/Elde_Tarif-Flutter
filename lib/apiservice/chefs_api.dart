import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:elde_tarif/models/sef.dart';
import 'package:elde_tarif/models/sef_detay.dart';
import 'api_service.dart';

class ChefsApi {
  ChefsApi(BaseApiService apiService);

  // Şefler
  Future<List<Sef>> fetchSefler() async {
    final response = await http.get(Uri.parse('${BaseApiService.baseUrl}/api/Sef'));
    if (response.statusCode != 200) {
      throw Exception('Şefler isteği başarısız: ${response.statusCode}');
    }
    final List data = jsonDecode(response.body) as List;
    return data.map((e) => Sef.fromJson(e as Map<String, dynamic>)).toList();
  }

  // Şef Detay
  Future<SefDetay> getSefDetay(int id) async {
    final uri = Uri.parse('${BaseApiService.baseUrl}/api/Sef/$id');
    final res = await http.get(uri);
    if (res.statusCode != 200) {
      throw Exception('Şef detay alınamadı (${res.statusCode})');
    }
    final data = json.decode(res.body) as Map<String, dynamic>;
    return SefDetay.fromJson(data);
  }
}

