import 'package:shared_preferences/shared_preferences.dart';

class TokenService {
  // Token'ları kaydet
  Future<void> saveTokens(String token, String refreshToken) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
    await prefs.setString('refreshToken', refreshToken);
  }

  // Token'ları al
  Future<Map<String, String?>> getTokens() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'token': prefs.getString('token'),
      'refreshToken': prefs.getString('refreshToken'),
    };
  }

  // Token'ları sil (çıkış yap)
  Future<void> clearTokens() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('refreshToken');
  }

  // Token kontrolü
  Future<bool> hasValidToken() async {
    final tokens = await getTokens();
    return tokens['token'] != null && tokens['token']!.isNotEmpty;
  }
}

