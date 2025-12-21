import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:elde_tarif/services/client_id_services.dart';
import 'package:elde_tarif/apiservice/token_service.dart';

/// Ortak HTTP isteklerini yöneten merkezi client
/// - Tüm isteklere otomatik headers ekler (Content-Type, X-Client-Id, Authorization)
/// - Hata yönetimi yapar (statusCode 200-299 değilse Exception fırlatır)
/// - 401 geldiğinde otomatik refresh token flow çalıştırır ve request'i retry eder
class ApiClient {
  static const String baseUrl = 'http://10.0.2.2:5262';
  
  final TokenService _tokenService = TokenService();
  bool _isRefreshing = false; // Refresh işlemi devam ediyorsa tekrar refresh yapma


  /// Refresh token ile yeni access token alır
  /// Başarılı olursa yeni token'ları kaydeder
  Future<void> _refreshAccessToken() async {
    if (_isRefreshing) {
      // Zaten refresh işlemi devam ediyorsa bekle (max 5 saniye)
      int waitCount = 0;
      while (_isRefreshing && waitCount < 50) {
        await Future.delayed(const Duration(milliseconds: 100));
        waitCount++;
      }
      return;
    }

    _isRefreshing = true;
    try {
      final tokens = await _tokenService.getTokens();
      final refreshTokenValue = tokens['refreshToken'];
      
      if (refreshTokenValue == null || refreshTokenValue.isEmpty) {
        print('[ApiClient] Refresh token bulunamadı');
        await _tokenService.clearTokens();
        throw Exception('Oturum süresi doldu. Lütfen tekrar giriş yapın.');
      }

      print('[ApiClient] Access token yenileniyor...');
      
      // Refresh token endpoint'ini çağır (auth gerektirmez)
      final uri = Uri.parse('$baseUrl/api/auth/refresh-token');
      
      // Header'ları burada oluştur (refresh token için auth gerekmez)
      final clientId = await ClientIdService.getOrCreate();
      final headers = <String, String>{
        'Content-Type': 'application/json',
        'X-Client-Id': clientId,
      };
      
      // Backend string bekliyor, direkt string gönder (jsonEncode yapma)
      final response = await http.post(
        uri,
        headers: headers,
        body: refreshTokenValue, // Direkt string gönder
      );

      if (response.statusCode == 200) {
        try {
          final data = jsonDecode(response.body) as Map<String, dynamic>;
          final newAccessToken = data['token'] as String?;
          final newRefreshToken = data['refreshToken'] as String?;
          
          if (newAccessToken != null && newRefreshToken != null) {
            await _tokenService.saveTokens(newAccessToken, newRefreshToken);
            print('[ApiClient] Access token başarıyla yenilendi');
          } else {
            throw Exception('Token yenileme yanıtı geçersiz.');
          }
        } catch (e) {
          print('[ApiClient] Token yenileme yanıtı parse edilemedi: $e');
          throw Exception('Token yenileme yanıtı işlenirken bir hata oluştu.');
        }
      } else {
        print('[ApiClient] Token yenileme başarısız: ${response.statusCode}');
        // Refresh token da geçersizse token'ları temizle
        await _tokenService.clearTokens();
        throw Exception('Oturum süresi doldu. Lütfen tekrar giriş yapın.');
      }
    } finally {
      _isRefreshing = false;
    }
  }

  /// Hata kontrolü yapar ve gerekirse Exception fırlatır
  /// 401 durumunda false döner (retry için), diğer hatalarda exception fırlatır
  void _checkResponse(http.Response response, {bool allow401 = false}) {
    if (response.statusCode == 401 && allow401) {
      // 401 durumu, retry mekanizması için false döner (exception fırlatılmaz)
      return;
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      String errorMessage = 'İstek başarısız (${response.statusCode})';
      
      // Response body'den hata mesajını çıkarmaya çalış
      if (response.body.isNotEmpty) {
        try {
          final errorData = jsonDecode(response.body);
          if (errorData is Map<String, dynamic>) {
            if (errorData.containsKey('message')) {
              errorMessage = errorData['message'] as String? ?? errorMessage;
            } else if (errorData.containsKey('error')) {
              errorMessage = errorData['error'] as String? ?? errorMessage;
            }
          } else if (errorData is String) {
            errorMessage = errorData;
          }
        } catch (_) {
          // JSON parse edilemezse, body'nin ilk 200 karakterini kullan
          final body = response.body.trim();
          if (body.isNotEmpty && body.length < 200) {
            errorMessage = body;
          }
        }
      }
      
      throw Exception(errorMessage);
    }
  }

  /// GET isteği
  Future<http.Response> get(String path, {bool requireAuth = false}) async {
    return _executeWithRetry(
      () async {
        final uri = Uri.parse('$baseUrl$path');
        
        // Header'ları burada oluştur
        final clientId = await ClientIdService.getOrCreate();
        final headers = <String, String>{
          'Content-Type': 'application/json',
          'X-Client-Id': clientId,
        };
        
        // Token varsa ekle
        final tokens = await _tokenService.getTokens();
        final token = tokens['token'];
        if (token != null && token.isNotEmpty) {
          headers['Authorization'] = 'Bearer $token';
          print('[ApiClient] GET $path - Authorization header eklendi');
        } else if (requireAuth) {
          throw Exception('Bu işlem için giriş yapmanız gerekiyor.');
        } else {
          print('[ApiClient] GET $path - Authorization header yok');
        }
        
        return await http.get(uri, headers: headers);
      },
      requireAuth: requireAuth,
    );
  }

  /// POST isteği
  Future<http.Response> post(
    String path, {
    Object? body,
    bool requireAuth = false,
  }) async {
    final bodyData = body != null ? jsonEncode(body) : null;
    return _executeWithRetry(
      () async {
        final uri = Uri.parse('$baseUrl$path');
        
        // Header'ları burada oluştur
        final clientId = await ClientIdService.getOrCreate();
        final headers = <String, String>{
          'Content-Type': 'application/json',
          'X-Client-Id': clientId,
        };
        
        // Token varsa ekle
        final tokens = await _tokenService.getTokens();
        final token = tokens['token'];
        if (token != null && token.isNotEmpty) {
          headers['Authorization'] = 'Bearer $token';
          print('[ApiClient] POST $path - Authorization header eklendi');
        } else if (requireAuth) {
          throw Exception('Bu işlem için giriş yapmanız gerekiyor.');
        } else {
          print('[ApiClient] POST $path - Authorization header yok');
        }
        
        return await http.post(
          uri,
          headers: headers,
          body: bodyData,
        );
      },
      requireAuth: requireAuth,
    );
  }

  /// PUT isteği
  Future<http.Response> put(
    String path, {
    Object? body,
    bool requireAuth = false,
  }) async {
    final bodyData = body != null ? jsonEncode(body) : null;
    return _executeWithRetry(
      () async {
        final uri = Uri.parse('$baseUrl$path');
        
        // Header'ları burada oluştur
        final clientId = await ClientIdService.getOrCreate();
        final headers = <String, String>{
          'Content-Type': 'application/json',
          'X-Client-Id': clientId,
        };
        
        // Token varsa ekle
        final tokens = await _tokenService.getTokens();
        final token = tokens['token'];
        if (token != null && token.isNotEmpty) {
          headers['Authorization'] = 'Bearer $token';
          print('[ApiClient] PUT $path - Authorization header eklendi');
        } else if (requireAuth) {
          throw Exception('Bu işlem için giriş yapmanız gerekiyor.');
        } else {
          print('[ApiClient] PUT $path - Authorization header yok');
        }
        
        return await http.put(
          uri,
          headers: headers,
          body: bodyData,
        );
      },
      requireAuth: requireAuth,
    );
  }

  /// DELETE isteği
  Future<http.Response> delete(String path, {bool requireAuth = false}) async {
    return _executeWithRetry(
      () async {
        final uri = Uri.parse('$baseUrl$path');
        
        // Header'ları burada oluştur
        final clientId = await ClientIdService.getOrCreate();
        final headers = <String, String>{
          'Content-Type': 'application/json',
          'X-Client-Id': clientId,
        };
        
        // Token varsa ekle
        final tokens = await _tokenService.getTokens();
        final token = tokens['token'];
        if (token != null && token.isNotEmpty) {
          headers['Authorization'] = 'Bearer $token';
          print('[ApiClient] DELETE $path - Authorization header eklendi');
        } else if (requireAuth) {
          throw Exception('Bu işlem için giriş yapmanız gerekiyor.');
        } else {
          print('[ApiClient] DELETE $path - Authorization header yok');
        }
        
        return await http.delete(uri, headers: headers);
      },
      requireAuth: requireAuth,
    );
  }

  /// Request'i çalıştırır, 401 gelirse refresh token ile yeniden dener
  Future<http.Response> _executeWithRetry(
    Future<http.Response> Function() requestFn, {
    required bool requireAuth,
  }) async {
    // İlk deneme
    var response = await requestFn();
    
    // 401 geldiyse ve requireAuth true ise refresh token dene
    if (response.statusCode == 401 && requireAuth) {
      print('[ApiClient] 401 Unauthorized alındı, refresh token deneniyor...');
      
      try {
        // Refresh token ile yeni access token al
        await _refreshAccessToken();
        
        // Yeni token ile request'i tekrar gönder
        print('[ApiClient] Request retry ediliyor (yeni token ile)...');
        response = await requestFn();
        
        // Hala 401 gelirse (refresh token da geçersizse) exception fırlat
        if (response.statusCode == 401) {
          print('[ApiClient] Retry sonrası hala 401, token geçersiz');
          _checkResponse(response);
        }
      } catch (e) {
        print('[ApiClient] Refresh token başarısız: $e');
        // Refresh token başarısızsa, 401 response'unu hata olarak işle
        _checkResponse(response);
      }
    }
    
    // Response'u kontrol et (401 değilse veya retry sonrası başarılıysa)
    _checkResponse(response);
    return response;
  }

  /// Raw POST (exception fırlatmaz, response'u direkt döndürür)
  /// Özel hata yönetimi gereken durumlar için kullanılır
  /// NOT: Bu metod 401 handling yapmaz, sadece raw response döndürür
  Future<http.Response> postRaw(
    String path, {
    Object? body,
    bool requireAuth = false,
  }) async {
    final uri = Uri.parse('$baseUrl$path');
    
    // Header'ları burada oluştur
    final clientId = await ClientIdService.getOrCreate();
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'X-Client-Id': clientId,
    };
    
    // Token varsa ekle
    final tokens = await _tokenService.getTokens();
    final token = tokens['token'];
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
      print('[ApiClient] POST RAW $path - Authorization header eklendi');
    } else if (requireAuth) {
      throw Exception('Bu işlem için giriş yapmanız gerekiyor.');
    } else {
      print('[ApiClient] POST RAW $path - Authorization header yok');
    }
    
    return await http.post(
      uri,
      headers: headers,
      body: body != null ? jsonEncode(body) : null,
    );
  }

  /// Image URL oluşturur (BaseApiService'ten taşındı)
  String getImageUrl(String imagePath) {
    if (imagePath.isEmpty) return imagePath;
    if (imagePath.startsWith('http://') || imagePath.startsWith('https://')) {
      return imagePath;
    }
    return '$baseUrl$imagePath';
  }
}



