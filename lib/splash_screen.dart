import 'package:flutter/material.dart';
import 'package:elde_tarif/apiservice/auth_api.dart';
import 'package:elde_tarif/apiservice/api_client.dart';
import 'package:elde_tarif/apiservice/token_service.dart';
import 'package:elde_tarif/screens/HomePage.dart';
import 'package:elde_tarif/screens/AuthenticationPage.dart';
import 'package:lottie/lottie.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  final TokenService _tokenService = TokenService();
  final AuthApi _authApi = AuthApi(ApiClient(), TokenService());
  double value=0.0;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    await Future.delayed(const Duration(seconds: 2));

    final tokens = await _tokenService.getTokens();
    final accessToken = tokens['token'];
    final refreshToken = tokens['refreshToken'];

    if (!mounted) return;

    // 1️⃣ Access token varsa ve expire olmamışsa -> Home
    if (accessToken != null && accessToken.isNotEmpty) {
      if (!_tokenService.isTokenExpired(accessToken)) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const Homepage()),
        );
        return;
      }
      
      // Access token expire olmuş ama refresh token varsa -> Token yenile
      if (refreshToken != null && refreshToken.isNotEmpty) {
        try {
          await _authApi.refreshToken(refreshToken);
          if (!mounted) return;
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const Homepage()),
          );
          return;
        } catch (_) {
          await _tokenService.clearTokens();
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const AuthenticationPage()),
          );
          return;
        }
      }
      
      // Access token expire olmuş, refresh token yok -> Login
      await _tokenService.clearTokens();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const AuthenticationPage()),
      );
      return;
    }

    // 2️⃣ Access token yok ama refresh token varsa -> Token yenile
    if (refreshToken != null && refreshToken.isNotEmpty) {
      try {
        await _authApi.refreshToken(refreshToken);
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const Homepage()),
        );
        return;
      } catch (_) {
        await _tokenService.clearTokens();
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const AuthenticationPage()),
        );
        return;
      }
    }

    // 3️⃣ İkisi de yok -> Login
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const AuthenticationPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            LinearProgressIndicator(
              backgroundColor: Colors.blue,
              color: Colors.white70,
              borderRadius: BorderRadius.circular(10),
              value: value,
            ),
            const SizedBox(height: 16),
            const Text(
              'Elde Tarif',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),

            const SizedBox(height: 24),

            const CircularProgressIndicator(color: Colors.white),
          ],
        ),
      ),
    );
  }
}
