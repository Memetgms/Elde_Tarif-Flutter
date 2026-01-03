import 'dart:convert';
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

  // Token kontrolü (sadece var mı kontrol eder)
  Future<bool> hasValidToken() async {
    final tokens = await getTokens();
    return tokens['token'] != null && tokens['token']!.isNotEmpty;
  }

  /// JWT token'ı decode eder ve payload'u döndürür
  /// Hata durumunda null döner
  Map<String, dynamic>? decodeJwt(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return null;

      // Payload'u decode et (base64url)
      final payload = parts[1];
      // Base64URL decode (normal base64'ten farklı: - ve _ karakterleri kullanır)
      String normalizedPayload = payload
          .replaceAll('-', '+')
          .replaceAll('_', '/');
      
      // Padding ekle (base64 için gerekli)
      switch (normalizedPayload.length % 4) {
        case 1:
          normalizedPayload += '===';
          break;
        case 2:
          normalizedPayload += '==';
          break;
        case 3:
          normalizedPayload += '=';
          break;
      }

      final decodedBytes = base64Decode(normalizedPayload);
      final decodedString = utf8.decode(decodedBytes);
      return jsonDecode(decodedString) as Map<String, dynamic>;
    } catch (e) {
      return null;
    }
  }

  /// Token'ın expire olup olmadığını kontrol eder
  /// Token yoksa veya geçersizse true döner (expire sayılır)
  /// exp claim'i yoksa false döner (expire kontrolü yapılamaz, geçerli sayılır)
  bool isTokenExpired(String? token) {
    if (token == null || token.isEmpty) return true;
    
    final payload = decodeJwt(token);
    if (payload == null) return true;

    // exp claim'i kontrol et (Unix timestamp - seconds)
    if (!payload.containsKey('exp')) return false; // exp yoksa geçerli say

    final exp = payload['exp'];
    if (exp is! int) return false;

    // Şu anki zaman (seconds)
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    
    // 30 saniye buffer ekle (network gecikmesi için)
    return exp < (now + 30);
  }

  /// Access token'ın expire olup olmadığını kontrol eder
  Future<bool> isAccessTokenExpired() async {
    final tokens = await getTokens();
    return isTokenExpired(tokens['token']);
  }
}

