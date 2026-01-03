import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:elde_tarif/apiservice/api_config.dart';
import 'package:elde_tarif/apiservice/token_service.dart';

class AiChatApi {
  final TokenService _tokenService;

  AiChatApi(this._tokenService);

  Future<String> sendMessage(String message) async {
    if (message.trim().isEmpty) {
      throw Exception('Lütfen bir mesaj gönderin.');
    }

    // Token kontrolü
    final tokens = await _tokenService.getTokens();
    final token = tokens['token'];

    if (token == null || token.isEmpty) {
      throw Exception('Giriş yapmanız gerekiyor. Lütfen önce giriş yapın.');
    }

    final uri = Uri.parse('${ApiConfig.baseUrl}/api/Chat');
    final headers = await ApiConfig.getHeaders(includeAuth: true);
    
    final requestBody = jsonEncode({
      'message': message,
    });

    final response = await http.post(uri, headers: headers, body: requestBody);

    // Debug için response bilgilerini logla
    if (response.statusCode != 200) {
      print('🔴 AI Chat API Hata: ${response.statusCode}');
      print('Response Body: ${response.body}');
    }

    if (response.statusCode == 200) {
      try {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return data['reply'] as String? ?? 'Yanıt alınamadı.';
      } catch (e) {
        throw Exception('Yanıt işlenirken bir hata oluştu.');
      }
    } else if (response.statusCode == 401) {
      // Unauthorized - Token geçersiz veya süresi dolmuş
      throw Exception('Oturum süreniz dolmuş. Lütfen tekrar giriş yapın.');
    } else if (response.statusCode == 400) {
      try {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return data['reply'] as String? ?? 'Lütfen bir mesaj gönderin.';
      } catch (e) {
        return 'Lütfen bir mesaj gönderin.';
      }
    } else if (response.statusCode == 429) {
      // Too Many Requests - Rate limiting
      try {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        if (data.containsKey('reply')) {
          return data['reply'] as String;
        }
        if (data.containsKey('message')) {
          throw Exception(data['message'] as String);
        }
      } catch (e) {
        if (e is Exception) rethrow;
      }
      throw Exception('Çok fazla istek gönderildi. Lütfen birkaç saniye bekleyip tekrar deneyin.');
    } else {
      // 500 veya diğer hatalar
      try {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        
        // Önce 'reply' alanını kontrol et (backend'den gelen mesaj)
        if (data.containsKey('reply')) {
          final reply = data['reply'];
          if (reply != null && reply is String && reply.isNotEmpty) {
            throw Exception(reply);
          }
        }
        
        // 'message' alanını kontrol et
        if (data.containsKey('message')) {
          final message = data['message'];
          if (message != null && message is String && message.isNotEmpty) {
            throw Exception(message);
          }
        }
      } catch (e) {
        // Eğer zaten bir Exception fırlatıldıysa, onu tekrar fırlat
        if (e is Exception) {
          rethrow;
        }
        // JSON parse hatası - response body'yi direkt göster
        final body = response.body.trim();
        if (body.isNotEmpty && body.length < 200) {
          throw Exception('Hata: $body');
        }
      }
      throw Exception('Şu anda bir sorun yaşıyorum, lütfen daha sonra tekrar deneyin. (Hata kodu: ${response.statusCode})');
    }
  }
}
