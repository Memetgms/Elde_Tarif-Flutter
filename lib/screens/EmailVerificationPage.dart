import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:elde_tarif/apiservice/auth_api.dart';
import 'package:elde_tarif/apiservice/api_client.dart';
import 'package:elde_tarif/apiservice/token_service.dart';
import 'package:elde_tarif/models/auth_dto.dart';
import 'package:elde_tarif/widgets/custom_toast.dart';

class EmailVerificationPage extends StatefulWidget {
  final String email;

  const EmailVerificationPage({super.key, required this.email});

  @override
  State<EmailVerificationPage> createState() => _EmailVerificationPageState();
}

class _EmailVerificationPageState extends State<EmailVerificationPage> {
  final AuthApi _authApi = AuthApi(ApiClient(), TokenService());
  final _codeController = TextEditingController();

  bool _loading = false;
  int _secondsLeft = 15 * 60;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _codeController.dispose();
    super.dispose();
  }

  // ================= TIMER =================

  void _startTimer() {
    _timer?.cancel();
    _secondsLeft = 15 * 60;

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsLeft == 0) {
        timer.cancel();
      } else {
        setState(() => _secondsLeft--);
      }
    });
  }

  String get _timeText {
    final m = (_secondsLeft ~/ 60).toString().padLeft(2, '0');
    final s = (_secondsLeft % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  // ================= ACTIONS =================

  Future<void> _confirm() async {
    if (_codeController.text.length != 6) {
      _showError('6 haneli kod giriniz');
      return;
    }

    setState(() => _loading = true);

    try {
      await _authApi.confirmEmail(
        ConfirmEmailCodeDto(
          email: widget.email,
          code: _codeController.text.trim(),
        ),
      );

      if (!mounted) return;

      CustomToast.success(
        context,
        'Email doğrulandı. Giriş yapabilirsiniz.',
      );

      // Toast mesajının görünmesi için kısa bir gecikme
      await Future.delayed(const Duration(milliseconds: 500));
      
      if (mounted) {
        Navigator.pop(context); // Login ekranına geri dön
      }
    } catch (e) {
      _showError(e);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _resend() async {
    setState(() => _loading = true);

    try {
      await _authApi.resendCode(
        ResendCodeDto(email: widget.email),
      );

      _startTimer();

      CustomToast.info(context, 'Yeni doğrulama kodu gönderildi');
    } catch (e) {
      _showError(e);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  // Hata mesajını temizleyen ve gösteren helper
  String _cleanErrorMessage(dynamic error) {
    String message = error.toString();
    
    // Exception: prefix'ini kaldır
    message = message.replaceAll(RegExp(r'Exception:\s*'), '');
    
    // Format hatası gibi teknik mesajları temizle
    message = message.replaceAll(RegExp(r'Format.*?:\s*'), '');
    message = message.replaceAll(RegExp(r'Unexpected character.*'), '');
    
    // Eğer mesaj JSON benzeri bir yapı içeriyorsa, sadece message kısmını al
    if (message.contains('{') && message.contains('message')) {
      try {
        final jsonStart = message.indexOf('{');
        final jsonPart = message.substring(jsonStart);
        final parsed = jsonDecode(jsonPart);
        if (parsed is Map && parsed.containsKey('message')) {
          return parsed['message'].toString();
        }
      } catch (_) {
        // Parse edilemezse devam et
      }
    }
    
    return message.trim();
  }

  void _showError(dynamic error) {
    final cleanMessage = _cleanErrorMessage(error);
    CustomToast.error(context, cleanMessage);
  }

  // ================= UI =================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text(
          'Email Doğrulama',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.grey.shade900,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.mark_email_read,
                    size: 64,
                    color: Colors.blue.shade700,
                  ),
                ),
                const SizedBox(height: 32),

                const Text(
                  'Doğrulama Kodu',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 12),

                Text(
                  '${widget.email} adresine gönderilen',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '6 haneli kodu giriniz',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.grey.shade600,
                  ),
                ),

                const SizedBox(height: 40),

                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextField(
                        controller: _codeController,
                        maxLength: 6,
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          letterSpacing: 16,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade900,
                        ),
                        decoration: InputDecoration(
                          hintText: '______',
                          hintStyle: TextStyle(
                            letterSpacing: 16,
                            color: Colors.grey.shade300,
                          ),
                          counterText: '',
                          filled: true,
                          fillColor: Colors.grey.shade50,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(
                              color: Colors.blue.shade700,
                              width: 2,
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 20,
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: _secondsLeft > 60
                              ? Colors.blue.shade50
                              : _secondsLeft > 0
                                  ? Colors.orange.shade50
                                  : Colors.red.shade50,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              _secondsLeft > 0
                                  ? Icons.access_time
                                  : Icons.error_outline,
                              size: 20,
                              color: _secondsLeft > 60
                                  ? Colors.blue.shade700
                                  : _secondsLeft > 0
                                      ? Colors.orange.shade700
                                      : Colors.red.shade700,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _secondsLeft > 0
                                  ? 'Kalan süre: $_timeText'
                                  : 'Süre doldu',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: _secondsLeft > 60
                                    ? Colors.blue.shade700
                                    : _secondsLeft > 0
                                        ? Colors.orange.shade700
                                        : Colors.red.shade700,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      SizedBox(
                        height: 56,
                        child: ElevatedButton(
                          onPressed: _loading ? null : _confirm,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue.shade700,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: _loading
                              ? const SizedBox(
                                  height: 24,
                                  width: 24,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2.5,
                                  ),
                                )
                              : const Text(
                                  'Doğrula',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      TextButton(
                        onPressed:
                            _secondsLeft == 0 && !_loading ? _resend : null,
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: Text(
                          'Kodu Tekrar Gönder',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: _secondsLeft == 0 && !_loading
                                ? Colors.blue.shade700
                                : Colors.grey.shade400,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}




