import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:elde_tarif/Providers/sef_detay_provider.dart';
import 'package:elde_tarif/apiservice/api_config.dart';
import 'package:elde_tarif/screens/TarifDetayPage.dart';
import 'package:elde_tarif/theme/app_theme.dart';



class SefDetayPage extends StatefulWidget {
  final int sefId;

  const SefDetayPage({super.key, required this.sefId});

  @override
  State<SefDetayPage> createState() => _SefDetayPageState();
}

class _SefDetayPageState extends State<SefDetayPage> {
  late final SefDetayProvider _provider;

  @override
  void initState() {
    super.initState();
    _provider = SefDetayProvider(widget.sefId);
    Future.microtask(() => _provider.veriyiYukle());
  }

  String getImageUrl(String imagePath) {
    if (imagePath.isEmpty) return imagePath;
    if (imagePath.startsWith('http://') || imagePath.startsWith('https://')) {
      return imagePath;
    }
    return '${ApiConfig.baseUrl}$imagePath';
  }

  @override
  Widget build(BuildContext context) {

    return ChangeNotifierProvider.value(
      value: _provider,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Consumer<SefDetayProvider>(
          builder: (context, provider, child) {
            if (provider.yukleniyor) {
              return const SafeArea(
                child: Center(child: CircularProgressIndicator(color: AppTheme.primary)),
              );
            }

            if (provider.hata != null) {
              return SafeArea(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, size: 64, color: AppTheme.textMuted),
                      const SizedBox(height: 16),
                      Text(
                        'Hata: ${provider.hata}',
                        style: const TextStyle(color: AppTheme.textMuted),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: provider.yenile,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primary,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Tekrar Dene'),
                      ),
                    ],
                  ),
                ),
              );
            }

            final sef = provider.sefDetay;
            if (sef == null) {
              return const SafeArea(
                child: Center(child: Text('Şef bilgisi bulunamadı')),
              );
            }

            return CustomScrollView(
              slivers: [
                // AppBar - şefin adı başlıkta
                SliverAppBar(
                  pinned: true,
                  backgroundColor: Colors.white,
                  elevation: 0,
                  leading: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.black87),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  title: Text(
                    sef.ad,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  centerTitle: false,
                ),

                // İçerik
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Şef fotoğrafı - küçük avatar tarzı
                        Container(
                          width: 128,
                          height: 128,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppTheme.border,
                              width: 3,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ClipOval(
                            child: sef.fotoUrl.isNotEmpty
                                ? Image.network(
                                    getImageUrl(sef.fotoUrl),
                                    width: 128,
                                    height: 128,
                                    cacheWidth: 256,
                                    cacheHeight: 256,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => Container(
                                      color: AppTheme.surfaceSoft,
                                      child: const Icon(Icons.person, size: 64, color: AppTheme.textMuted),
                                    ),
                                  )
                                : Container(
                                    color: AppTheme.surfaceSoft,
                                    child: const Icon(Icons.person, size: 64, color: AppTheme.textMuted),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Açıklama
                        if (sef.aciklama != null && sef.aciklama!.isNotEmpty) ...[
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppTheme.surfaceSoft,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppTheme.border),
                            ),
                            child: Text(
                              sef.aciklama!,
                              style: const TextStyle(
                                fontSize: 15,
                                height: 1.5,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],

                        // Tarifler başlığı
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Tarifler',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            if (sef.tarifler.isNotEmpty)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: AppTheme.primary.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: AppTheme.primary.withOpacity(0.2)),
                                ),
                                child: Text(
                                  '${provider.filtrelenmisTarifler.length} tarif',
                                  style: const TextStyle(
                                    color: AppTheme.primaryDark,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        // Kategori filtresi
                        if (provider.tumKategoriler.length > 1)
                          SizedBox(
                            height: 40,
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              itemCount: provider.tumKategoriler.length,
                              separatorBuilder: (_, __) => const SizedBox(width: 8),
                              itemBuilder: (_, i) {
                                final kategori = provider.tumKategoriler[i];
                                final aktif = provider.seciliKategori == kategori || 
                                              (provider.seciliKategori == null && i == 0);
                                return ChoiceChip(
                                  label: Text(
                                    kategori,
                                    style: TextStyle(
                                      fontWeight: aktif ? FontWeight.w600 : FontWeight.w500,
                                      color: aktif ? AppTheme.primaryDark : Colors.black87,
                                      fontSize: 13,
                                    ),
                                  ),
                                  selected: aktif,
                                  backgroundColor: AppTheme.surfaceSoft,
                                  selectedColor: AppTheme.primary.withOpacity(0.15),
                                  shape: StadiumBorder(
                                    side: BorderSide(
                                      color: aktif ? AppTheme.primary : AppTheme.border,
                                      width: 1.2,
                                    ),
                                  ),
                                  onSelected: (_) => provider.kategoriFiltrele(kategori),
                                );
                              },
                            ),
                          ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),

                // Tarifler listesi
                if (provider.filtrelenmisTarifler.isEmpty)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(40),
                      child: Center(
                        child: Text(
                          sef.tarifler.isEmpty
                              ? 'Bu şefin henüz tarifi yok'
                              : 'Bu kategoride tarif bulunamadı',
                          style: const TextStyle(color: AppTheme.textMuted),
                        ),
                      ),
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    sliver: SliverGrid(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 16,
                        crossAxisSpacing: 16,
                        childAspectRatio: 0.85,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final tarif = provider.filtrelenmisTarifler[index];
                          return InkWell(
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => TarifDetayPage(tarifId: tarif.id),
                                ),
                              );
                            },
                            borderRadius: BorderRadius.circular(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Tarif görseli
                                Expanded(
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(16),
                                    child: Stack(
                                      children: [
                                        Image.network(
                                          getImageUrl(tarif.kapakFotoUrl),
                                          width: 200,
                                          height: 200,
                                          cacheWidth: 200,
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, __, ___) => Container(
                                            color: AppTheme.surfaceSoft,
                                            child: const Icon(
                                              Icons.restaurant,
                                              size: 40,
                                              color: AppTheme.textMuted,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                // Tarif başlığı
                                Text(
                                  tarif.baslik,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                // Bilgiler
                                Row(
                                  children: [
                                    if (tarif.hazirlikSuresiDakika != null) ...[
                                      Icon(Icons.access_time, size: 14, color: AppTheme.textMuted),
                                      const SizedBox(width: 4),
                                      Text(
                                        '${tarif.hazirlikSuresiDakika} dk',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: AppTheme.textMuted,
                                        ),
                                      ),
                                    ],
                                    if (tarif.hazirlikSuresiDakika != null && tarif.porsiyonSayisi != null)
                                      const SizedBox(width: 12),
                                    if (tarif.porsiyonSayisi != null) ...[
                                      Icon(Icons.people_outline, size: 14, color: AppTheme.textMuted),
                                      const SizedBox(width: 4),
                                      Text(
                                        '${tarif.porsiyonSayisi} porsiyon',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: AppTheme.textMuted,
                                        ),
                                      ),
                                    ],
                                    if (tarif.hazirlikSuresiDakika == null && tarif.porsiyonSayisi == null)
                                      Text(
                                        tarif.kategoriAdi,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: AppTheme.textMuted,
                                        ),
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                        childCount: provider.filtrelenmisTarifler.length,
                      ),
                    ),
                  ),

                const SliverToBoxAdapter(child: SizedBox(height: 20)),
              ],
            );
          },
        ),
      ),
    );
  }
}

