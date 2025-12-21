import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:convert';

import 'package:elde_tarif/Providers/tarif_detay_provider.dart';
import 'package:elde_tarif/Providers/favorites_provider.dart';
import 'package:elde_tarif/apiservice/api_client.dart';
import 'package:elde_tarif/apiservice/token_service.dart';
import 'package:elde_tarif/models/yorum.dart';
import 'package:elde_tarif/widgets/custom_toast.dart';

class AppTheme {
  static const primary = Color(0xFF3B82F6);
  static const primaryDark = Color(0xFF2563EB);
  static const surfaceSoft = Color(0xFFF1F5F9);
  static const border = Color(0xFFE2E8F0);
  static const textMuted = Color(0xFF64748B);
}

class TarifDetayPage extends StatefulWidget {
  final int tarifId;
  const TarifDetayPage({super.key, required this.tarifId});

  @override
  State<TarifDetayPage> createState() => _TarifDetayPageState();
}

class _TarifDetayPageState extends State<TarifDetayPage>
    with SingleTickerProviderStateMixin {
  late TabController _tab;
  final ApiClient _apiClient = ApiClient();

  String getImageUrl(String imagePath) => _apiClient.getImageUrl(imagePath);
  String? _currentUserId;
  bool _isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 3, vsync: this);
    _checkAuth();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TarifDetayProvider>().yukle(widget.tarifId);
    });
  }

  Future<void> _checkAuth() async {
    final tokens = await TokenService().getTokens();
    final token = tokens['token'];
    _isLoggedIn = token != null && token.isNotEmpty;
    
    if (_isLoggedIn && token != null) {
      // JWT token'dan kullanıcı ID'sini çıkar
      try {
        final parts = token.split('.');
        if (parts.length == 3) {
          final payload = parts[1];
          // Base64 padding ekle
          String normalized = payload.replaceAll('-', '+').replaceAll('_', '/');
          switch (normalized.length % 4) {
            case 1:
              normalized += '===';
              break;
            case 2:
              normalized += '==';
              break;
            case 3:
              normalized += '=';
              break;
          }
          final decoded = utf8.decode(base64Decode(normalized));
          final json = jsonDecode(decoded) as Map<String, dynamic>;
          _currentUserId = json['http://schemas.xmlsoap.org/ws/2005/05/identity/claims/nameidentifier'] as String?;
        }
      } catch (e) {
        // Token decode edilemezse boş bırak
      }
    }
    
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  String normalizeIngredient(String text) {
    text = text.replaceAll("\n", " ");
    text = text.replaceAll(RegExp(r'\s+'), ' ');
    return text.trim();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: Consumer<TarifDetayProvider>(
        builder: (context, provider, child) {
          if (provider.yukleniyor) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.hata != null) {
            return Center(child: Text("Hata: ${provider.hata}"));
          }

          final d = provider.detay;
          if (d == null) {
            return const Center(child: Text("Tarif bulunamadı"));
          }

          final protein = (d.proteinGr ?? 0).toDouble();
          final yag = (d.yagGr ?? 0).toDouble();
          final karbon = (d.karbonhidratGr ?? 0).toDouble();
          final total = protein + yag + karbon;

          final pctProtein = total > 0 ? (protein / total) * 100 : 0;
          final pctYag = total > 0 ? (yag / total) * 100 : 0;
          final pctKarbon = total > 0 ? (karbon / total) * 100 : 0;

          return CustomScrollView(
            slivers: [
              // ======================
              // PINNED SLIVER APPBAR
              // ======================
              SliverAppBar(
                pinned: true,
                floating: false,
                expandedHeight: 260,
                backgroundColor: Colors.white,
                leading: CircleAvatar(
                  backgroundColor: Colors.white70,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.black87),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
                actions: [
                  Consumer<FavoritesProvider>(
                    builder: (context, favoritesProvider, _) {
                      final isFavorite = favoritesProvider.isFavorite(widget.tarifId);
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: CircleAvatar(
                          backgroundColor: Colors.white70,
                          child: IconButton(
                            icon: Icon(
                              isFavorite ? Icons.favorite : Icons.favorite_border,
                              color: isFavorite ? Colors.red : Colors.black87,
                            ),
                            onPressed: () {
                              favoritesProvider.toggleFavorite(widget.tarifId, context);
                            },
                          ),
                        ),
                      );
                    },
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(
                    d.baslik ?? "",
                    style: const TextStyle(
                      color: Colors.black87,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  background: Stack(
                    children: [
                      // Resim
                      Positioned.fill(
                        child: ClipRRect(
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(35),
                            bottomRight: Radius.circular(35),
                          ),
                          child: Image.network(
                            getImageUrl(d.kapakFotoUrl ?? ''),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),

                      // Soft fade geçiş (çok daha şık)
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          height: 120,
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: [
                                Colors.white,
                                Colors.white70,
                                Colors.white38,
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ======================
              // CONTENT
              // ======================
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),

                      // Etiketler
                      Wrap(
                        spacing: 8,
                        children: [
                          if (d.kategoriAd != null)
                            _chip(Icons.restaurant, d.kategoriAd!),
                          if (d.sefAd != null)
                            _chip(Icons.person, d.sefAd!, primary: true),
                        ],
                      ),

                      const SizedBox(height: 18),

                      // Hazırlık - Kalori - Porsiyon
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _info(Icons.timer,
                              "${d.hazirlikSuresiDakika ?? '-'} dk", "Hazırlık"),
                          _info(Icons.local_fire_department,
                              "${d.kaloriKcal ?? '-'} kcal", "Kalori"),
                          _info(Icons.people,
                              "${d.porsiyonSayisi ?? '-'} kişilik", "Porsiyon"),
                        ],
                      ),

                      const SizedBox(height: 25),

                      // Besin Bilgisi Card
                      if (total > 0)
                        Container(
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: AppTheme.surfaceSoft,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppTheme.border),
                          ),
                          child: Row(
                            children: [
                              SizedBox(
                                width: 120,
                                height: 120,
                                child: PieChart(
                                  PieChartData(
                                    centerSpaceRadius: 20,
                                    sectionsSpace: 2,
                                    sections: [
                                      PieChartSectionData(
                                        value: pctProtein.toDouble(),
                                        color: Colors.green,
                                        radius: 50,
                                        showTitle: false,
                                      ),
                                      PieChartSectionData(
                                        value: pctYag.toDouble(),
                                        color: Colors.orange,
                                        radius: 50,
                                        showTitle: false,
                                      ),
                                      PieChartSectionData(
                                        value: pctKarbon.toDouble(),
                                        color: Colors.blue,
                                        radius: 50,
                                        showTitle: false,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 25),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text("Besin bilgisi",
                                        style: TextStyle(
                                            fontSize: 17,
                                            fontWeight: FontWeight.bold)),
                                    const SizedBox(height: 8),
                                    _nut("${protein.toInt()} g Protein",
                                        Colors.green),
                                    _nut("${yag.toInt()} g Yağ",
                                        Colors.orange),
                                    _nut("${karbon.toInt()} g Karbonhidrat",
                                        Colors.blue),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                      const SizedBox(height: 25),

                      // Açıklama
                      if (d.aciklama != null && d.aciklama!.isNotEmpty)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("Açıklama",
                                style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
                            Text(
                              d.aciklama!,
                              style: const TextStyle(
                                  fontSize: 15,
                                  height: 1.5,
                                  color: Colors.black87),
                            ),
                          ],
                        ),

                      const SizedBox(height: 25),

                      // TabBar
                      Container(
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceSoft,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: TabBar(
                          controller: _tab,
                          indicator: BoxDecoration(
                            color: AppTheme.primary,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          indicatorSize: TabBarIndicatorSize.tab,
                          labelColor: Colors.white,
                          unselectedLabelColor: AppTheme.textMuted,
                          tabs: const [
                            Tab(text: "Malzemeler"),
                            Tab(text: "Yapım adımları"),
                            Tab(text: "Yorumlar"),
                          ],
                        ),
                      ),

                      SizedBox(
                        height: 500,
                        child: TabBarView(
                          controller: _tab,
                          children: [
                            _malzemeler(d),
                            _adimlar(d),
                            _yorumlar(provider),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // ---------- Widget Helpers ----------

  Widget _chip(IconData icon, String text, {bool primary = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: primary ? AppTheme.primary.withValues(alpha: 0.12) : AppTheme.surfaceSoft,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: primary ? AppTheme.primary : AppTheme.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon,
              size: 15,
              color: primary ? AppTheme.primary : AppTheme.textMuted),
          const SizedBox(width: 5),
          Text(
            text,
            style: TextStyle(
                color: primary ? AppTheme.primary : Colors.black87,
                fontWeight: FontWeight.w600,
                fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _info(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, size: 26, color: AppTheme.primary),
        const SizedBox(height: 6),
        Text(value,
            style: const TextStyle(
                fontSize: 15, fontWeight: FontWeight.w600)),
        Text(label, style: const TextStyle(color: AppTheme.textMuted)),
      ],
    );
  }

  Widget _nut(String text, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Container(
              width: 10,
              height: 10,
              decoration:
              BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 8),
          Text(text, style: const TextStyle(fontSize: 14)),
        ],
      ),
    );
  }

  Widget _malzemeler(detay) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: detay.malzemeler.length,
      itemBuilder: (context, index) {

        final m = detay.malzemeler[index];
        final raw = (m.aciklama?.isNotEmpty ?? false)
            ? m.aciklama!
            : m.malzemeAd;

        final txt = normalizeIngredient(raw); // 🔥 BÜTÜN OLAY BU

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: AppTheme.primary,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  txt,
                  style: const TextStyle(
                    fontSize: 16,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _adimlar(detay) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: detay.yapimAdimlari.length,
      itemBuilder: (context, i) {
        final a = detay.yapimAdimlari[i];
        final no = a.sira ?? i + 1;

        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppTheme.primary,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Text(
                    "$no",
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 15),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceSoft,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.border),
                  ),
                  child: Text(
                    a.aciklama ?? "",
                    style: const TextStyle(fontSize: 15, height: 1.5),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _yorumlar(TarifDetayProvider provider) {
    return Column(
      children: [
        // Yorum ekleme formu (giriş yapmış kullanıcı için)
        if (_isLoggedIn) _yorumEkleForm(provider),
        
        // Yorum listesi
        Expanded(
          child: provider.yorumlarYukleniyor
              ? const Center(child: CircularProgressIndicator())
              : provider.yorumlarHata != null
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.error_outline,
                              size: 64,
                              color: Colors.red,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              provider.yorumlarHata!,
                              style: TextStyle(
                                fontSize: 14,
                                color: AppTheme.textMuted,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () => provider.yorumlariYukle(),
                              child: const Text("Tekrar Dene"),
                            ),
                          ],
                        ),
                      ),
                    )
              : provider.yorumlar.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.comment_outlined,
                              size: 64,
                              color: AppTheme.textMuted,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              "Henüz yorum yok",
                              style: TextStyle(
                                fontSize: 16,
                                color: AppTheme.textMuted,
                              ),
                            ),
                            if (!_isLoggedIn) ...[
                              const SizedBox(height: 8),
                              Text(
                                "İlk yorumu sen yap!",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: AppTheme.textMuted,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: provider.yorumlar.length,
                      itemBuilder: (context, index) {
                        final yorum = provider.yorumlar[index];
                        final isOwner = _currentUserId != null &&
                            yorum.kullaniciId == _currentUserId;
                        return _yorumItem(yorum, isOwner, provider);
                      },
                    ),
        ),
      ],
    );
  }



  Widget _yorumEkleForm(TarifDetayProvider provider) {
    final TextEditingController icerikController = TextEditingController();
    int? selectedPuan;
    bool isSubmitting = false;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceSoft,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.border),
      ),
      child: StatefulBuilder(
        builder: (context, setFormState) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Yorum Yap",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              
              // Puan seçimi
              Row(
                children: [
                  const Text("Puan: ", style: TextStyle(fontSize: 14)),
                  const SizedBox(width: 8),
                  ...List.generate(5, (index) {
                    final puan = index + 1;
                    return GestureDetector(
                      onTap: () {
                        setFormState(() {
                          selectedPuan = selectedPuan == puan ? null : puan;
                        });
                      },
                      child: Icon(
                        selectedPuan != null && puan <= selectedPuan!
                            ? Icons.star
                            : Icons.star_border,
                        color: selectedPuan != null && puan <= selectedPuan!
                            ? Colors.amber
                            : AppTheme.textMuted,
                        size: 24,
                      ),
                    );
                  }),
                ],
              ),
              const SizedBox(height: 12),
              
              // Yorum metni
              TextField(
                controller: icerikController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: "Yorumunuzu yazın...",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: AppTheme.border),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              
              // Gönder butonu
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isSubmitting
                      ? null
                      : () async {
                          if (icerikController.text.trim().isEmpty &&
                              selectedPuan == null) {
                            CustomToast.error(
                              context,
                              "Lütfen yorum içeriği veya puan girin",
                            );
                            return;
                          }

                          setFormState(() {
                            isSubmitting = true;
                          });

                          final success = await provider.yorumEkle(
                            icerikController.text.trim(),
                            selectedPuan,
                          );

                          setFormState(() {
                            isSubmitting = false;
                          });

                          if (success) {
                            icerikController.clear();
                            setFormState(() {
                              selectedPuan = null;
                            });
                            if (context.mounted) {
                              CustomToast.success(context, "Yorumunuz eklendi");
                            }
                          } else {
                            if (context.mounted) {
                              CustomToast.error(
                                context,
                                provider.yorumlarHata ?? "Yorum eklenemedi",
                              );
                            }
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: isSubmitting
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text("Gönder"),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _yorumItem(YorumListItem yorum, bool isOwner, TarifDetayProvider provider) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Kullanıcı avatarı
              CircleAvatar(
                radius: 20,
                backgroundColor: AppTheme.primary.withValues(alpha: 0.1),
                child: Text(
                  (yorum.userName.isNotEmpty
                          ? yorum.userName[0].toUpperCase()
                          : 'U'),
                  style: TextStyle(
                    color: AppTheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              
              // Kullanıcı adı ve tarih
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      yorum.userName.isNotEmpty ? yorum.userName : "Anonim",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    Text(
                      _formatDate(yorum.olusturulmaTarihi),
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Puan gösterimi
              if (yorum.puan != null)
                Row(
                  children: [
                    ...List.generate(5, (index) {
                      return Icon(
                        index < yorum.puan! ? Icons.star : Icons.star_border,
                        size: 16,
                        color: Colors.amber,
                      );
                    }),
                  ],
                ),
              
              // Düzenle/Sil butonları (sadece sahip için)
              if (isOwner)
                PopupMenuButton<String>(
                  icon: Icon(Icons.more_vert, color: AppTheme.textMuted),
                  onSelected: (value) async {
                    if (value == 'edit') {
                      _showEditYorumDialog(context, yorum, provider);
                    } else if (value == 'delete') {
                      _showDeleteYorumDialog(context, yorum, provider);
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit, size: 18),
                          SizedBox(width: 8),
                          Text("Düzenle"),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, size: 18, color: Colors.red),
                          SizedBox(width: 8),
                          Text("Sil", style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
                ),
            ],
          ),
          
          // Yorum içeriği
          if (yorum.icerik != null && yorum.icerik!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              yorum.icerik!,
              style: const TextStyle(fontSize: 14, height: 1.5),
            ),
          ],
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        if (difference.inMinutes == 0) {
          return "Az önce";
        }
        return "${difference.inMinutes} dakika önce";
      }
      return "${difference.inHours} saat önce";
    } else if (difference.inDays == 1) {
      return "Dün";
    } else if (difference.inDays < 7) {
      return "${difference.inDays} gün önce";
    } else {
      return "${date.day}/${date.month}/${date.year}";
    }
  }

  void _showEditYorumDialog(
    BuildContext context,
    YorumListItem yorum,
    TarifDetayProvider provider,
  ) {
    final TextEditingController icerikController =
        TextEditingController(text: yorum.icerik ?? '');
    int? selectedPuan = yorum.puan;
    bool isSubmitting = false;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text("Yorumu Düzenle"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Puan seçimi
                Row(
                  children: [
                    const Text("Puan: ", style: TextStyle(fontSize: 14)),
                    const SizedBox(width: 8),
                    ...List.generate(5, (index) {
                      final puan = index + 1;
                      return GestureDetector(
                        onTap: () {
                          setDialogState(() {
                            selectedPuan = selectedPuan == puan ? null : puan;
                          });
                        },
                        child: Icon(
                          selectedPuan != null && puan <= selectedPuan!
                              ? Icons.star
                              : Icons.star_border,
                          color: selectedPuan != null && puan <= selectedPuan!
                              ? Colors.amber
                              : AppTheme.textMuted,
                          size: 24,
                        ),
                      );
                    }),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Yorum metni
                TextField(
                  controller: icerikController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: "Yorumunuzu yazın...",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: isSubmitting
                  ? null
                  : () => Navigator.of(dialogContext).pop(),
              child: const Text("İptal"),
            ),
            ElevatedButton(
              onPressed: isSubmitting
                  ? null
                  : () async {
                      if (icerikController.text.trim().isEmpty &&
                          selectedPuan == null) {
                        CustomToast.error(
                          dialogContext,
                          "Lütfen yorum içeriği veya puan girin",
                        );
                        return;
                      }

                      setDialogState(() {
                        isSubmitting = true;
                      });

                      final success = await provider.yorumGuncelle(
                        yorum.id,
                        icerikController.text.trim(),
                        selectedPuan,
                      );

                      setDialogState(() {
                        isSubmitting = false;
                      });

                      if (!dialogContext.mounted) return;
                      
                      if (success) {
                        Navigator.of(dialogContext).pop();
                        CustomToast.success(dialogContext, "Yorumunuz güncellendi");
                      } else {
                        CustomToast.error(
                          dialogContext,
                          provider.yorumlarHata ?? "Yorum güncellenemedi",
                        );
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                foregroundColor: Colors.white,
              ),
              child: isSubmitting
                  ? const SizedBox(
                      height: 16,
                      width: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text("Kaydet"),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteYorumDialog(
    BuildContext context,
    YorumListItem yorum,
    TarifDetayProvider provider,
  ) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text("Yorumu Sil"),
        content: const Text("Bu yorumu silmek istediğinize emin misiniz?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text("İptal"),
          ),
          ElevatedButton(
            onPressed: () async {
              if (!dialogContext.mounted) return;
              Navigator.of(dialogContext).pop();
              final success = await provider.yorumSil(yorum.id);
              if (!dialogContext.mounted) return;
              if (success) {
                CustomToast.success(dialogContext, "Yorumunuz silindi");
              } else {
                CustomToast.error(
                  dialogContext,
                  provider.yorumlarHata ?? "Yorum silinemedi",
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text("Sil"),
          ),
        ],
      ),
    );
  }
}