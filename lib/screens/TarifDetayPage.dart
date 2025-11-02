import 'package:flutter/material.dart';
import 'package:elde_tarif/Providers/tarif_detay_provider.dart';
import 'package:elde_tarif/apiservice.dart';
import 'package:provider/provider.dart';

// Tema renkleri
class AppTheme {
  static const primary = Color(0xFF3B82F6); // blue-500
  static const primaryDark = Color(0xFF2563EB); // blue-600
  static const surfaceSoft = Color(0xFFF1F5F9); // slate-50
  static const border = Color(0xFFE2E8F0); // slate-200
  static const textMuted = Color(0xFF64748B); // slate-500
}

class TarifDetayPage extends StatefulWidget {
  final int tarifId;
  const TarifDetayPage({super.key, required this.tarifId});

  @override
  State<TarifDetayPage> createState() => _TarifDetayPageState();
}

class _TarifDetayPageState extends State<TarifDetayPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TarifDetayProvider>().yukle(widget.tarifId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final api = ApiService();
    return Scaffold(
      body: Consumer<TarifDetayProvider>(
        builder: (context, provider, child) {
          if (provider.yukleniyor) {
            return const Center(child: CircularProgressIndicator(color: AppTheme.primary));
          }
          
          if (provider.hata != null) {
            return SafeArea(
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
                        onPressed: () => provider.yukle(widget.tarifId),
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
            );
          }
          
          final detay = provider.detay;
          if (detay == null) {
            return SafeArea(
              child: Center(
                child: Text(
                  'Tarif bulunamadı',
                  style: TextStyle(color: AppTheme.textMuted),
                ),
              ),
            );
          }

          return CustomScrollView(
            slivers: [
              // AppBar with photo
              SliverAppBar(
                expandedHeight: 250,
                pinned: true,
                backgroundColor: Colors.white,
                elevation: 0,
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(
                    detay.baslik ?? 'Tarif',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  background: Image.network(
                    api.getImageUrl(detay.kapakFotoUrl ?? ''),
                    width: 400,
                    height: 400,
                    cacheWidth: 400,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: AppTheme.surfaceSoft,
                      child: Icon(Icons.restaurant, size: 64, color: AppTheme.textMuted),
                    ),
                  ),
                ),
              ),
              
              // Content
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverList.list(
                  children: [
                    // Şef ve kategori
                    if (detay.sefAd != null || detay.kategoriAd != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Wrap(
                          spacing: 12,
                          runSpacing: 8,
                          children: [
                            if (detay.sefAd != null)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  color: AppTheme.primary.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: AppTheme.primary.withOpacity(0.3)),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.person, size: 16, color: AppTheme.primaryDark),
                                    const SizedBox(width: 6),
                                    Text(
                                      detay.sefAd!,
                                      style: TextStyle(
                                        color: AppTheme.primaryDark,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            if (detay.kategoriAd != null)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  color: AppTheme.surfaceSoft,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: AppTheme.border),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.category, size: 16, color: AppTheme.textMuted),
                                    const SizedBox(width: 6),
                                    Text(
                                      detay.kategoriAd!,
                                      style: TextStyle(
                                        color: Colors.black87,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                    
                    // Açıklama
                    if (detay.aciklama != null && detay.aciklama!.isNotEmpty) ...[
                      const Text(
                        'Açıklama',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceSoft,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppTheme.border),
                        ),
                        child: Text(
                          detay.aciklama!,
                          style: const TextStyle(height: 1.6, fontSize: 15),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                    
                    // Bilgiler
                    _buildInfoCard(detay),
                    const SizedBox(height: 24),
                    
                    // Malzemeler
                    if (detay.malzemeler.isNotEmpty) ...[
                      const Text(
                        'Malzemeler',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ...detay.malzemeler.map((malzeme) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              margin: const EdgeInsets.only(top: 6),
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: AppTheme.primary,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Text(
                                (malzeme.aciklama != null && malzeme.aciklama!.isNotEmpty
                                    ? malzeme.aciklama
                                    : malzeme.malzemeAd)!.trim().replaceAll(RegExp(r'\s+'), ' '),
                                style: const TextStyle(fontSize: 15, height: 1.5),
                              ),
                            ),
                          ],
                        ),
                      )),
                      const SizedBox(height: 24),
                    ],
                    
                    // Yapım Adımları
                    if (detay.yapimAdimlari.isNotEmpty) ...[
                      const Text(
                        'Yapım Adımları',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ...detay.yapimAdimlari.map((adim) => Padding(
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
                                  '${adim.sira ?? 1}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: AppTheme.surfaceSoft,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: AppTheme.border),
                                ),
                                child: Text(
                                  adim.aciklama ?? '',
                                  style: const TextStyle(height: 1.6, fontSize: 15),
                                ),
                              ),
                            ),
                          ],
                        ),
                      )),
                      const SizedBox(height: 24),
                    ],
                    
                    // Yorumlar
                    if (detay.sonYorumlar.isNotEmpty) ...[
                      const Text(
                        'Son Yorumlar',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ...detay.sonYorumlar.map((yorum) => Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceSoft,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppTheme.border),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                if (yorum.puan != null)
                                  Row(
                                    children: List.generate(5, (i) => Icon(
                                      i < (yorum.puan ?? 0) ? Icons.star : Icons.star_border,
                                      size: 16,
                                      color: Colors.amber,
                                    )),
                                  ),
                                const SizedBox(width: 8),
                                Text(
                                  yorum.kullaniciAdSoyad ?? 'Anonim',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                ),
                              ],
                            ),
                            if (yorum.icerik != null && yorum.icerik!.isNotEmpty) ...[
                              const SizedBox(height: 10),
                              Text(
                                yorum.icerik!,
                                style: const TextStyle(height: 1.5, fontSize: 14),
                              ),
                            ],
                            const SizedBox(height: 10),
                            Text(
                              _formatDate(yorum.olusturulmaTarihi),
                              style: TextStyle(color: AppTheme.textMuted, fontSize: 12),
                            ),
                          ],
                        ),
                      )),
                    ],
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildInfoCard(detay) {
    final items = <Widget>[];
    
    if (detay.hazirlikSuresiDakika != null) {
      items.add(_buildInfoItem(Icons.schedule, '${detay.hazirlikSuresiDakika} dk', 'Hazırlık'));
    }
    
    if (detay.pismeSuresiDakika != null) {
      items.add(_buildInfoItem(Icons.timer, '${detay.pismeSuresiDakika} dk', 'Pişirme'));
    }
    
    if (detay.porsiyonSayisi != null) {
      items.add(_buildInfoItem(Icons.people, '${detay.porsiyonSayisi} kişilik', 'Porsiyon'));
    }

    if (items.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceSoft,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: items,
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, size: 28, color: AppTheme.primary),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 15,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(color: AppTheme.textMuted, fontSize: 12),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}.${date.month}.${date.year}';
  }
}
