import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:elde_tarif/services/client_id_services.dart';
import 'package:elde_tarif/apiservice/token_service.dart';

/// API yapılandırması ve ortak yardımcı metodlar
class ApiConfig {
  static const String baseUrl = 'http://10.0.2.2:5262';
  
  // Refresh işlemi sırasında tekrar refresh yapılmasını önlemek için flag
  static bool _isRefreshing = false;

  /// Standart headers oluşturur (auth opsiyonel)
  /// Token expire olduysa otomatik olarak refresh yapar
  static Future<Map<String, String>> getHeaders({bool includeAuth = false}) async {
    final clientId = await ClientIdService.getOrCreate();
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'X-Client-Id': clientId,
    };

    if (includeAuth) {
      final tokenService = TokenService();
      var tokens = await tokenService.getTokens();
      var token = tokens['token'];
      final refreshToken = tokens['refreshToken'];

      // Token varsa ve expire olduysa refresh dene
      if (token != null && token.isNotEmpty) {
        final isExpired = tokenService.isTokenExpired(token);
        
        if (isExpired && refreshToken != null && refreshToken.isNotEmpty && !_isRefreshing) {
          // Token expired, refresh dene
          final newToken = await _refreshAccessToken(refreshToken, tokenService);
          if (newToken != null) {
            token = newToken;
          } else {
            // Refresh başarısız - token'ları temizle (login'e yönlendirilecek)
            await tokenService.clearTokens();
            token = null;
          }
        }
      }

      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
    }

    return headers;
  }

  /// Refresh token kullanarak yeni access token alır
  /// Başarılı olursa yeni token'ı döndürür, başarısız olursa null döner
  static Future<String?> _refreshAccessToken(String refreshToken, TokenService tokenService) async {
    _isRefreshing = true;
    
    try {
      final clientId = await ClientIdService.getOrCreate();
      final uri = Uri.parse('$baseUrl/api/auth/refresh-token');
      
      // Debug log
      print('[ApiConfig] Refresh token isteği gönderiliyor...');
      print('[ApiConfig] RefreshToken uzunluğu: ${refreshToken.length}');
      
      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'X-Client-Id': clientId,
        },
        body: jsonEncode(refreshToken), // Backend [FromBody] string bekliyor - JSON string literal
      );

      print('[ApiConfig] Refresh response status: ${response.statusCode}');
      print('[ApiConfig] Refresh response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final newToken = data['token'] as String?;
        final newRefreshToken = data['refreshToken'] as String?;

        if (newToken != null && newRefreshToken != null) {
          await tokenService.saveTokens(newToken, newRefreshToken);
          print('[ApiConfig] Token başarıyla yenilendi!');
          return newToken;
        }
      }
      
      return null;
    } catch (e) {
      print('[ApiConfig] Refresh token hatası: $e');
      return null;
    } finally {
      _isRefreshing = false;
    }
  }

  /// Image URL oluşturur
  static String getImageUrl(String imagePath) {
    if (imagePath.isEmpty) return imagePath;
    if (imagePath.startsWith('http://') || imagePath.startsWith('https://')) {
      return imagePath;
    }
    return '$baseUrl$imagePath';
  }
}
