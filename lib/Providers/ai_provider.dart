import 'package:elde_tarif/apiservice/aichat_api.dart';
import 'package:elde_tarif/apiservice/api_client.dart';
import 'package:elde_tarif/apiservice/token_service.dart';
import 'package:flutter/foundation.dart';

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });
}

class AiProvider extends ChangeNotifier {
  final AiChatApi _aiChatApi;

  AiProvider() : _aiChatApi = AiChatApi(ApiClient(), TokenService());

  List<ChatMessage> _messages = [];
  bool _isLoading = false;
  String? _error;

  List<ChatMessage> get messages => _messages;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> sendMessage(String message) async {
    if (message.trim().isEmpty) return;

    // Kullanıcı mesajını ekle
    final userMessage = ChatMessage(
      text: message.trim(),
      isUser: true,
      timestamp: DateTime.now(),
    );
    _messages.add(userMessage);
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // API'ye gönder
      final reply = await _aiChatApi.sendMessage(message);

      // AI yanıtını ekle
      final aiMessage = ChatMessage(
        text: reply,
        isUser: false,
        timestamp: DateTime.now(),
      );
      _messages.add(aiMessage);
      _isLoading = false;
      _error = null;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      
      // Exception mesajını temizle (Exception: prefix'ini kaldır)
      String errorText = e.toString();
      if (errorText.startsWith('Exception: ')) {
        errorText = errorText.substring(11);
      }
      
      _error = errorText;
      
      // Hata mesajını da ekle
      final errorMessage = ChatMessage(
        text: errorText,
        isUser: false,
        timestamp: DateTime.now(),
      );
      _messages.add(errorMessage);
      notifyListeners();
    }
  }

  void clearMessages() {
    _messages.clear();
    _error = null;
    notifyListeners();
  }
}


