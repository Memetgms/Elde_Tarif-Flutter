import 'dart:async';
import 'package:elde_tarif/screens/MalzemePage.dart';
import 'package:elde_tarif/screens/SearchPage.dart';
import 'package:elde_tarif/screens/TarifDetayPage.dart';
import 'package:elde_tarif/screens/SefDetayPage.dart';
import 'package:elde_tarif/screens/AIPage.dart';
import 'package:elde_tarif/Providers/home_provider.dart';
import 'package:elde_tarif/Providers/favorites_provider.dart';
import 'package:elde_tarif/screens/daily_tracker_page.dart';
import 'package:flutter/material.dart';
import 'package:elde_tarif/apiservice/api_config.dart';
import 'package:elde_tarif/apiservice/token_service.dart';
import 'package:elde_tarif/apiservice/auth_api.dart';
import 'package:provider/provider.dart';
import 'package:elde_tarif/screens/AuthenticationPage.dart';
import 'package:elde_tarif/screens/ProfilePage.dart';
import 'package:elde_tarif/theme/app_theme.dart';


class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  int _currentIndex = 0;
  
  final List<Widget> _pages = [
    const _HomeTab(),
    const MalzemelerPage(),
    const AIPage(),
    const DailyTrackerPage(),
    const ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppTheme.cardBackground,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 15,
              offset: const Offset(0, -5),
            ),
          ],
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          child: BottomNavigationBar(
            enableFeedback: false,
            selectedItemColor: AppTheme.primary,
            unselectedItemColor: AppTheme.textMuted,
            backgroundColor: Colors.transparent,
            elevation: 0,
            currentIndex: _currentIndex,
            type: BottomNavigationBarType.fixed,
            selectedFontSize: 12,
            unselectedFontSize: 12,
            selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
            unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500),
            onTap: (index) => setState(() => _currentIndex = index),
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined),
                activeIcon: Icon(Icons.home_rounded),
                label: 'Ana Sayfa',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.kitchen_outlined),
                activeIcon: Icon(Icons.kitchen_rounded),
                label: 'Malzeme',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.smart_toy_outlined),
                activeIcon: Icon(Icons.smart_toy_rounded),
                label: 'AI',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.event_note_outlined),
                activeIcon: Icon(Icons.event_note_rounded),
                label: 'Günlük',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person_outline),
                activeIcon: Icon(Icons.person_rounded),
                label: 'Profil',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HomeTab extends StatefulWidget {
  const _HomeTab();

  @override
  State<_HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<_HomeTab> {
  final TokenService _tokenService = TokenService();
  late final AuthApi _authApi;
  String? _token;
  Timer? _tokenCheckTimer;

  String getImageUrl(String imagePath) => ApiConfig.getImageUrl(imagePath);

  @override
  void initState() {
    super.initState();
    _authApi = AuthApi(_tokenService);
    _loadToken();
    Future.microtask(() => context.read<HomeProvider>().verileriYukle());
    _startTokenCheckTimer();
  }

  @override
  void dispose() {
    _tokenCheckTimer?.cancel();
    super.dispose();
  }

  /// Periyodik token kontrolü (her 5 dakikada bir)
  void _startTokenCheckTimer() {
    _tokenCheckTimer = Timer.periodic(const Duration(minutes: 5), (timer) async {
      if (!mounted) {
        timer.cancel();
        return;
      }

      try {
        final isExpired = await _tokenService.isAccessTokenExpired();
        
        if (isExpired) {
          print('[HomePage] Token expire olmuş, yenileniyor...');
          final tokens = await _tokenService.getTokens();
          final refreshToken = tokens['refreshToken'];
          
          if (refreshToken != null && refreshToken.isNotEmpty) {
            await _authApi.refreshToken(refreshToken);
            await _loadToken(); // Token'ı yeniden yükle
            print('[HomePage] Token başarıyla yenilendi');
          } else {
            print('[HomePage] Refresh token yok');
            timer.cancel();
          }
        }
      } catch (e) {
        print('[HomePage] Token yenileme hatası: $e');
      }
    });
  }

  Future<void> _loadToken() async {
    final tokens = await _tokenService.getTokens();
    setState(() {
      _token = tokens['token'];
    });
    print("🏁 Home TOKEN: ${tokens['token']}");
    print("🏁 Home REFRESH_TOKEN: ${tokens['refreshToken']}");
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeProvider>(
      builder: (context, provider, child) {
        return Scaffold(
          backgroundColor: AppTheme.background,
          body: provider.yukleniyor
              ? const Center(child: CircularProgressIndicator())
              : provider.hata != null
              ? SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 64, color: AppTheme.textMuted),
                    const SizedBox(height: 16),
                    Text(
                      'Hata: ${provider.hata}',
                      style: TextStyle(color: AppTheme.textMuted),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: provider.yenile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Tekrar Dene',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
              : RefreshIndicator(
            color: AppTheme.primary,
            backgroundColor: AppTheme.cardBackground,
            onRefresh: provider.yenile,
            child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            // ======= ÜST HEADER: Logo + Arama Pill =======
            SliverToBoxAdapter(
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Üst bar: Hoşgeldiniz + Login Butonu
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Hoşgeldiniz 👋',
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Bugün ne pişireceğiz?',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: AppTheme.textSecondary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          // Login butonu
                          if (_token == null || _token!.isEmpty)
                            ElevatedButton(
                            onPressed: () {
                              Navigator.of(context).pushNamed('/auth');
                            },
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text('Giriş Yap'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // ARAMA
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const SearchPage()),
                          );
                        },
                        child: Container(
                          height: 50,
                          decoration: BoxDecoration(
                            color: AppTheme.cardBackground,
                            borderRadius: BorderRadius.circular(25),
                            border: Border.all(color: AppTheme.border),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          alignment: Alignment.centerLeft,
                          child: Row(
                            children: [
                              Icon(Icons.search, size: 22, color: AppTheme.accent),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Tarif ara...',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: AppTheme.textMuted,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ),
                              Icon(Icons.tune, size: 20, color: AppTheme.textMuted),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),


            // ======= ASIL İÇERİK =======
            SliverPadding(
              padding: const EdgeInsets.symmetric(vertical: 5,horizontal: 10),
              sliver: SliverList.list(
                children: [
                  // Şefler
                  Container(
                    decoration: BoxDecoration(
                      color: AppTheme.cardBackground,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.03),
                          blurRadius: 15,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(15),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              'Ünlü Şefler',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                            if (provider.sefler.isNotEmpty)
                              TextButton(
                                onPressed: () {},
                                style: TextButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                  minimumSize: Size.zero,
                                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                ),
                                child: Text(
                                  'Tümünü Gör',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: AppTheme.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        // Şefler listesi
                        SizedBox(
                          height: 130,
                          child: provider.sefler.isEmpty
                              ? Center(
                                  child: Text(
                                    'Şef bulunamadı',
                                    style: TextStyle(color: AppTheme.textMuted),
                                  ),
                                )
                              : ListView.separated(
                            scrollDirection: Axis.horizontal,
                            padding: EdgeInsets.zero,
                            itemCount: provider.sefler.length,
                            separatorBuilder: (_, __) => const SizedBox(width: 16),
                            itemBuilder: (context, index) {
                              final sef = provider.sefler[index];
                              return InkWell(
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => SefDetayPage(sefId: sef.id),
                                    ),
                                  );
                                },
                                borderRadius: BorderRadius.circular(16),
                                child: SizedBox(
                                  width: 110,
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: AppTheme.border,
                                            width: 2,
                                          ),
                                        ),
                                        child: sef.fotoUrl.isNotEmpty
                                            ? ClipOval(
                                                child: Image.network(
                                                  getImageUrl(sef.fotoUrl),
                                                  width: 72,
                                                  height: 72,
                                                  cacheWidth: 150,
                                                  fit: BoxFit.cover,
                                                  errorBuilder: (_, __, ___) => CircleAvatar(
                                                    radius: 36,
                                                    backgroundColor: AppTheme.surfaceSoft,
                                                    child: Icon(Icons.person, size: 36, color: AppTheme.textMuted),
                                                  ),
                                                ),
                                              )
                                            : CircleAvatar(
                                                radius: 36,
                                                backgroundColor: AppTheme.surfaceSoft,
                                                child: Icon(Icons.person, size: 36, color: AppTheme.textMuted),
                                              ),
                                      ),
                                      const SizedBox(height: 10),
                                      Flexible(
                                        child: Text(
                                          sef.ad,
                                          textAlign: TextAlign.center,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontSize: 13,
                                            height: 1.2,
                                            fontWeight: FontWeight.w600,
                                            color: AppTheme.textPrimary,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),


                  const SizedBox(height: 10),

                  // Kategoriler
                  Container(
                    decoration: BoxDecoration(
                      color: AppTheme.cardBackground,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.03),
                          blurRadius: 15,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(15),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Popüler Kategoriler',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          height: 150,
                          child: provider.kategoriler.isEmpty
                              ? Center(
                                  child: Text(
                                    'Kategori bulunamadı',
                                    style: TextStyle(color: AppTheme.textMuted),
                                  ),
                                )
                              : ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: provider.kategoriler.length,
                            separatorBuilder: (_, __) => const SizedBox(width: 16),
                            itemBuilder: (context, index) {
                              final kategori = provider.kategoriler[index];
                              return InkWell(
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => SearchPage(
                                        initialKategoriId: kategori.id,  // tıklanan kategori
                                      ),
                                    ),
                                  );
                                },
                                borderRadius: BorderRadius.circular(16),
                                child: Column(
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(color: AppTheme.border),
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(16),
                                        child: Image.network(
                                          getImageUrl(kategori.kategoriUrl),
                                          width: 90,
                                          height: 90,
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, __, ___) => Container(
                                            width: 90,
                                            height: 90,
                                            decoration: BoxDecoration(
                                              color: AppTheme.surfaceSoft,
                                              borderRadius: BorderRadius.circular(16),
                                            ),
                                            child: Icon(
                                              Icons.restaurant,
                                              size: 32,
                                              color: AppTheme.textMuted,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    SizedBox(
                                      width: 90,
                                      child: Text(
                                        kategori.ad,
                                        textAlign: TextAlign.center,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: AppTheme.textPrimary,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Sana Özel Öneriler
                  if (provider.sanaOzelOneriler.isNotEmpty)
                    Container(
                      decoration: BoxDecoration(
                        color: AppTheme.cardBackground,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.03),
                            blurRadius: 15,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(15),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    'Sana Özel',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    '✨',
                                    style: TextStyle(fontSize: 20),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          SizedBox(
                            height: 200,
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              padding: EdgeInsets.zero,
                              itemCount: provider.sanaOzelOneriler.length,
                              separatorBuilder: (_, __) => const SizedBox(width: 16),
                              itemBuilder: (context, index) {
                                final tarif = provider.sanaOzelOneriler[index];
                                return Consumer<FavoritesProvider>(
                                  builder: (context, favoritesProvider, _) {
                                    final isFavorite = favoritesProvider.isFavorite(tarif.id);
                                    return InkWell(
                                      onTap: () {
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (_) => TarifDetayPage(tarifId: tarif.id),
                                          ),
                                        );
                                      },
                                      borderRadius: BorderRadius.circular(16),
                                      child: SizedBox(
                                        width: 160,
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Expanded(
                                              child: Stack(
                                                children: [
                                                  Container(
                                                    decoration: BoxDecoration(
                                                      borderRadius: BorderRadius.circular(16),
                                                      border: Border.all(color: AppTheme.border),
                                                    ),
                                                    child: ClipRRect(
                                                      borderRadius: BorderRadius.circular(16),
                                                      child: Image.network(
                                                        getImageUrl(tarif.kapakFotoUrl),
                                                        width: 160,
                                                        height: 200,
                                                        cacheWidth: 320,
                                                        fit: BoxFit.cover,
                                                        errorBuilder: (_, __, ___) => Container(
                                                          width: double.infinity,
                                                          height: double.infinity,
                                                          decoration: BoxDecoration(
                                                            color: AppTheme.surfaceSoft,
                                                            borderRadius: BorderRadius.circular(16),
                                                          ),
                                                          child: Icon(
                                                            Icons.restaurant,
                                                            size: 40,
                                                            color: AppTheme.textMuted,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  // Kalp ikonu
                                                  Positioned(
                                                    top: 8,
                                                    right: 8,
                                                    child: GestureDetector(
                                                      onTap: () {
                                                        favoritesProvider.toggleFavorite(tarif.id, context);
                                                      },
                                                      child: Container(
                                                        padding: const EdgeInsets.all(6),
                                                        decoration: BoxDecoration(
                                                          color: Colors.white.withOpacity(0.9),
                                                          shape: BoxShape.circle,
                                                          boxShadow: [
                                                            BoxShadow(
                                                              color: Colors.black.withOpacity(0.1),
                                                              blurRadius: 4,
                                                              offset: const Offset(0, 2),
                                                            ),
                                                          ],
                                                        ),
                                                        child: Icon(
                                                          isFavorite ? Icons.favorite : Icons.favorite_border,
                                                          color: isFavorite ? Colors.red : AppTheme.textMuted,
                                                          size: 20,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              tarif.baslik,
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600,
                                                color: AppTheme.textPrimary,
                                                height: 1.3,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),

                  if (provider.sanaOzelOneriler.isNotEmpty) const SizedBox(height: 10),

                ],
              ),
            ),
          ],
        ),
        ),
          );
      },
    );
  }
}


