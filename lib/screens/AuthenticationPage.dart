import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:elde_tarif/apiservice.dart';
import 'package:elde_tarif/models/auth_dto.dart';
import 'package:elde_tarif/screens/HomePage.dart';
import 'package:elde_tarif/screens/EmailVerificationPage.dart';
import 'package:elde_tarif/excepiton/emailexception.dart';
import 'package:elde_tarif/widgets/custom_toast.dart';

class AuthenticationPage extends StatefulWidget {
  const AuthenticationPage({super.key});

  @override
  State<AuthenticationPage> createState() => _AuthenticationPageState();
}

class _AuthenticationPageState extends State<AuthenticationPage> {
  final ApiService _api = ApiService();
  final _formKey = GlobalKey<FormState>();

  bool _isLogin = true;
  bool _loading = false;

  final _usernameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _pass2Ctrl = TextEditingController();

  @override
  void dispose() {
    _usernameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _pass2Ctrl.dispose();
    super.dispose();
  }

  // ================= UI HELPERS =================

  InputDecoration _input(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: Colors.blue.shade700),
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
        borderSide: BorderSide(color: Colors.blue.shade700, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Colors.red),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Colors.red, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
    );
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

  // ================= AUTH =================

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    try {
      if (_isLogin) {
        await _login();
      } else {
        await _register();
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _login() async {
    try {
      await _api.login(
        LoginDto(
          emailOrUserName: _emailCtrl.text.trim(),
          password: _passCtrl.text,
        ),
      );

      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const Homepage()),
            (_) => false,
      );
    } on EmailNotConfirmedException catch (e) {
      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => EmailVerificationPage(email: e.email),
        ),
      );
    } catch (e) {
      if (mounted) _showError(e);
    }
  }

  Future<void> _register() async {
    try {
      await _api.register(
        RegisterDto(
          userName: _usernameCtrl.text.trim(),
          email: _emailCtrl.text.trim(),
          password: _passCtrl.text,
        ),
      );

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) =>
              EmailVerificationPage(email: _emailCtrl.text.trim()),
        ),
      );
    } catch (e) {
      if (mounted) _showError(e);
    }
  }

  // ================= BUILD =================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.restaurant_menu,
                      size: 64,
                      color: Colors.blue.shade700,
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Elde Tarif',
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _isLogin
                        ? 'Hesabınıza giriş yapın'
                        : 'Yeni hesap oluşturun',
                    style: TextStyle(
                      fontSize: 16,
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
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          _isLogin ? 'Giriş Yap' : 'Kayıt Ol',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade900,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 32),

                        // USERNAME (SADECE REGISTER)
                        if (!_isLogin)
                          TextFormField(
                            controller: _usernameCtrl,
                            decoration:
                                _input('Kullanıcı Adı', Icons.person_outline),
                            validator: (v) {
                              if (v == null || v.isEmpty) {
                                return 'Kullanıcı adı gerekli';
                              }
                              if (v.length < 3) {
                                return 'En az 3 karakter';
                              }
                              return null;
                            },
                          ),

                        if (!_isLogin) const SizedBox(height: 20),

                        // EMAIL
                        TextFormField(
                          controller: _emailCtrl,
                          decoration: _input('Email', Icons.email_outlined),
                          keyboardType: TextInputType.emailAddress,
                          validator: (v) {
                            if (v == null || v.isEmpty) return 'Email gerekli';
                            if (!v.contains('@')) return 'Geçerli email gir';
                            return null;
                          },
                        ),

                        const SizedBox(height: 20),

                        // PASSWORD
                        TextFormField(
                          controller: _passCtrl,
                          obscureText: true,
                          decoration: _input('Şifre', Icons.lock_outline),
                          validator: (v) {
                            if (v == null || v.length < 6) {
                              return 'En az 6 karakter';
                            }
                            if (!_isLogin) {
                              if (!RegExp(r'[A-Z]').hasMatch(v)) {
                                return 'En az 1 büyük harf';
                              }
                              if (!RegExp(r'[0-9]').hasMatch(v)) {
                                return 'En az 1 rakam';
                              }
                            }
                            return null;
                          },
                        ),

                        if (!_isLogin) const SizedBox(height: 20),

                        // PASSWORD CONFIRM
                        if (!_isLogin)
                          TextFormField(
                            controller: _pass2Ctrl,
                            obscureText: true,
                            decoration:
                                _input('Şifre Tekrar', Icons.lock_outline),
                            validator: (v) =>
                                v != _passCtrl.text ? 'Şifreler eşleşmiyor' : null,
                          ),

                        const SizedBox(height: 28),

                        SizedBox(
                          height: 56,
                          child: ElevatedButton(
                            onPressed: _loading ? null : _submit,
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
                                : Text(
                                    _isLogin ? 'Giriş Yap' : 'Kayıt Ol',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              _isLogin
                                  ? 'Hesabın yok mu? '
                                  : 'Zaten hesabın var mı? ',
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 14,
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  _isLogin = !_isLogin;
                                  _formKey.currentState?.reset();
                                });
                              },
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: Text(
                                _isLogin ? 'Kayıt Ol' : 'Giriş Yap',
                                style: TextStyle(
                                  color: Colors.blue.shade700,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
