import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:elde_tarif/apiservice/api_config.dart';
import 'package:elde_tarif/models/user_activity.dart';

class UserApi {
  Future<UserDTO> getMe() async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/api/User/me');
    final headers = await ApiConfig.getHeaders(includeAuth: true);
    
    final response = await http.get(uri, headers: headers);
    
    if (response.statusCode == 401) {
      throw Exception('Oturum süresi doldu. Lütfen tekrar giriş yapın.');
    }
    
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Kullanıcı bilgileri alınamadı (${response.statusCode})');
    }
    
    final data = jsonDecode(response.body);
    return UserDTO.fromJson(data);
  }

  Future<List<ActivityDTO>> getMyActivity() async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/api/User/myactivity');
    final headers = await ApiConfig.getHeaders(includeAuth: true);
    
    final response = await http.get(uri, headers: headers);
    
    if (response.statusCode == 401) {
      throw Exception('Oturum süresi doldu. Lütfen tekrar giriş yapın.');
    }
    
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Aktiviteler alınamadı (${response.statusCode})');
    }
    
    final List list = jsonDecode(response.body);
    return list.map((e) => ActivityDTO.fromJson(e)).toList();
  }
}
