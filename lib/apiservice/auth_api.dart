import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:elde_tarif/apiservice/api_config.dart';
import 'package:elde_tarif/apiservice/token_service.dart';
import 'package:elde_tarif/excepiton/emailexception.dart';
import 'package:elde_tarif/models/auth_dto.dart';

class AuthApi {
  final TokenService _tokenService;

  AuthApi(this._tokenService);

  // Hata mesajını parse eden helper metod
  String _parseErrorMessage(String responseBody) {
    if (responseBody.isEmpty) {
      return 'Bir hata oluştu. Lütfen tekrar deneyin.';
    }

    try {
      final errorData = jsonDecode(responseBody);
      
      if (errorData is Map<String, dynamic>) {
        // 'message' anahtarı varsa onu kullan
        if (errorData.containsKey('message')) {
          final message = errorData['message'];
          if (message is String && message.isNotEmpty) {
            return message;
          }
        }
        
        // 'error' anahtarı varsa onu kullan
        if (errorData.containsKey('error')) {
          final error = errorData['error'];
          if (error is String && error.isNotEmpty) {
            return error;
          }
        }
        
        // 'errors' anahtarı varsa (validation errors gibi)
        if (errorData.containsKey('errors')) {
          final errors = errorData['errors'];
          if (errors is List && errors.isNotEmpty) {
            return errors.map((e) => e.toString()).join(', ');
          } else if (errors is Map) {
            final errorList = <String>[];
            errors.forEach((key, value) {
              if (value is List) {
                errorList.addAll(value.map((e) => e.toString()));
              } else {
                errorList.add(value.toString());
              }
            });
            if (errorList.isNotEmpty) {
              return errorList.join(', ');
            }
          }
        }
      } else if (errorData is String) {
        // Direkt string ise
        return errorData;
      }
    } catch (e) {
      // JSON parse hatası - response body'yi direkt kullan
      final body = responseBody.trim();
      if (body.startsWith('Format') || body.contains('Unexpected character')) {
        try {
          final jsonStart = body.indexOf('{');
          if (jsonStart != -1) {
            final jsonPart = body.substring(jsonStart);
            final parsed = jsonDecode(jsonPart);
            if (parsed is Map && parsed.containsKey('message')) {
              return parsed['message'].toString();
            }
          }
        } catch (_) {
          return body.replaceAll(RegExp(r'Format.*?:\s*'), '')
                     .replaceAll(RegExp(r'Exception:\s*'), '')
                     .trim();
        }
      }
      return body;
    }

    return 'Bir hata oluştu. Lütfen tekrar deneyin.';
  }

  Future<AuthResponse> login(LoginDto dto) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/api/auth/login');
    final headers = await ApiConfig.getHeaders();
    
    final response = await http.post(
      uri,
      headers: headers,
      body: jsonEncode(dto.toJson()),
    );

    if (response.statusCode == 200) {
      try {
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        final authResponse = AuthResponse.fromJson(body);
        await _tokenService.saveTokens(authResponse.token, authResponse.refreshToken);
        return authResponse;
      } catch (e) {
        throw Exception('Yanıt işlenirken bir hata oluştu.');
      }
    }

    // 🔴 Email doğrulanmamış özel durum
    if (response.statusCode == 401) {
      try {
        final body = jsonDecode(response.body);
        if (body is Map && body['code'] == 'EMAIL_NOT_CONFIRMED') {
          throw EmailNotConfirmedException(
            body['message']?.toString() ?? 'Email doğrulanmamış',
            body['email']?.toString() ?? '',
          );
        }
      } catch (e) {
        if (e is EmailNotConfirmedException) rethrow;
        // JSON parse hatası, normal hata olarak devam et
      }
    }

    throw Exception(_parseErrorMessage(response.body));
  }

  // Kayıt ol
  Future<RegisterResponse> register(RegisterDto dto) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/api/auth/register');
    final headers = await ApiConfig.getHeaders();
    
    final response = await http.post(
      uri,
      headers: headers,
      body: jsonEncode(dto.toJson()),
    );

    if (response.statusCode == 200) {
      try {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return RegisterResponse.fromJson(data);
      } catch (e) {
        throw Exception('Yanıt işlenirken bir hata oluştu.');
      }
    } else {
      throw Exception(_parseErrorMessage(response.body));
    }
  }

  // Email doğrulama
  Future<String> confirmEmail(ConfirmEmailCodeDto dto) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/api/auth/confirm-email');
    final headers = await ApiConfig.getHeaders();
    
    final response = await http.post(
      uri,
      headers: headers,
      body: jsonEncode(dto.toJson()),
    );

    if (response.statusCode == 200) {
      try {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return data['message'] as String? ?? 'Email başarıyla doğrulandı.';
      } catch (e) {
        return 'Email başarıyla doğrulandı.';
      }
    } else {
      throw Exception(_parseErrorMessage(response.body));
    }
  }

  // Kod tekrar gönder
  Future<String> resendCode(ResendCodeDto dto) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/api/auth/resend-code');
    final headers = await ApiConfig.getHeaders();
    
    final response = await http.post(
      uri,
      headers: headers,
      body: jsonEncode(dto.toJson()),
    );

    if (response.statusCode == 200) {
      try {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return data['message'] as String? ?? 'Doğrulama kodu tekrar gönderildi.';
      } catch (e) {
        return 'Doğrulama kodu tekrar gönderildi.';
      }
    } else {
      throw Exception(_parseErrorMessage(response.body));
    }
  }

  // Refresh token ile yeni token al
  Future<AuthResponse> refreshToken(String refreshToken) async {
    // Backend direkt string bekliyor (JSON encode edilmeden)
    final uri = Uri.parse('${ApiConfig.baseUrl}/api/auth/refresh-token');
    final headers = await ApiConfig.getHeaders();
    
    final response = await http.post(
      uri,
      headers: headers,
      body: refreshToken, // Direkt string gönder (jsonEncode yapma)
    );

    if (response.statusCode == 200) {
      try {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final authResponse = AuthResponse.fromJson(data);
        
        // Yeni token'ları sakla
        await _tokenService.saveTokens(authResponse.token, authResponse.refreshToken);
        
        return authResponse;
      } catch (e) {
        throw Exception('Token yenileme yanıtı işlenirken bir hata oluştu.');
      }
    } else {
      throw Exception(_parseErrorMessage(response.body));
    }
  }

  // Çıkış yap
  Future<String> logout() async {
    final tokens = await _tokenService.getTokens();
    final token = tokens['token'];
    
    if (token == null) {
      await _tokenService.clearTokens();
      return 'Çıkış yapıldı.';
    }

    try {
      final uri = Uri.parse('${ApiConfig.baseUrl}/api/auth/logout');
      final headers = await ApiConfig.getHeaders(includeAuth: true);
      
      final response = await http.post(uri, headers: headers);

      // Token'ları temizle (başarılı olsun ya da olmasın)
      await _tokenService.clearTokens();

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return data['message'] as String? ?? 'Çıkış yapıldı.';
      } else {
        return 'Çıkış yapıldı.';
      }
    } catch (_) {
      // Hata olsa bile token'ları temizle
      await _tokenService.clearTokens();
      return 'Çıkış yapıldı.';
    }
  }
}
