import 'package:flutter/material.dart';
import 'package:elde_tarif/apiservice/auth_api.dart';
import 'package:elde_tarif/apiservice/token_service.dart';
import 'package:elde_tarif/screens/HomePage.dart';
import 'package:elde_tarif/screens/AuthenticationPage.dart';
import 'package:elde_tarif/theme/app_theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  final TokenService _tokenService = TokenService();
  final AuthApi _authApi = AuthApi(TokenService());
  
  late AnimationController _progressController;
  late AnimationController _fadeController;
  late Animation<double> _progressAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    
    // Fade ve scale animasyonu
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOut),
    );
    
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOut),
    );
    
    // Progress bar animasyonu
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );
    
    _progressAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _progressController, curve: Curves.easeInOut),
    );
    
    // Animasyonları başlat
    _fadeController.forward();
    Future.delayed(const Duration(milliseconds: 300), () {
      _progressController.forward();
    });
    
    _init();
  }

  @override
  void dispose() {
    _progressController.dispose();
    _fadeController.dispose();
    super.dispose();
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
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: AnimatedBuilder(
            animation: _fadeAnimation,
            builder: (context, child) {
              return Opacity(
                opacity: _fadeAnimation.value,
                child: Transform.scale(
                  scale: _scaleAnimation.value,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 48.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Logo Icon
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            color: AppTheme.primary,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.primary.withOpacity(0.3),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.restaurant_menu_rounded,
                            size: 50,
                            color: Colors.white,
                          ),
                        ),
                        
                        const SizedBox(height: 32),
                        
                        // Uygulama Adı
                        Text(
                          'Elde Tarif',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimary,
                            letterSpacing: 0.5,
                          ),
                        ),
                        
                        const SizedBox(height: 8),
                        
                        Text(
                          'Lezzetli tarifler bir tık uzağınızda',
                          style: TextStyle(
                            fontSize: 15,
                            color: AppTheme.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        
                        const SizedBox(height: 56),
                        
                        // Progress Bar
                        AnimatedBuilder(
                          animation: _progressAnimation,
                          builder: (context, child) {
                            return Column(
                              children: [
                                Container(
                                  height: 6,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(3),
                                    color: AppTheme.border,
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(3),
                                    child: Align(
                                      alignment: Alignment.centerLeft,
                                      child: FractionallySizedBox(
                                        widthFactor: _progressAnimation.value,
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: AppTheme.primary,
                                            borderRadius: BorderRadius.circular(3),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Yükleniyor...',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: AppTheme.textMuted,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
