import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:elde_tarif/apiservice/api_client.dart';
import 'package:elde_tarif/apiservice/malzeme_api.dart';
import 'package:elde_tarif/models/tarif_oneri_sonuc.dart';
import 'package:elde_tarif/Providers/favorites_provider.dart';
import 'package:elde_tarif/screens/TarifDetayPage.dart';

class TarifOneriPage extends StatefulWidget {
  final List<int> seciliMalzemeIdleri;

  const TarifOneriPage({
    super.key,
    required this.seciliMalzemeIdleri,
  });

  @override
  State<TarifOneriPage> createState() => _TarifOneriPageState();
}

class _TarifOneriPageState extends State<TarifOneriPage> {
  late Future<List<TarifOneriSonuc>> _future;
  final ApiClient _apiClient = ApiClient();
  final MalzemeApi _malzemeApi = MalzemeApi(ApiClient());

  String getImageUrl(String imagePath) => _apiClient.getImageUrl(imagePath);

  static const _primary = Color(0xFF3B82F6);
  static const _primaryDark = Color(0xFF2563EB);
  static const _surfaceSoft = Color(0xFFF1F5F9);
  static const _textMuted = Color(0xFF64748B);

  @override
  void initState() {
    super.initState();
    _future = _malzemeApi.tarifOneriGetir(widget.seciliMalzemeIdleri);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Tarif Önerileri"),
        backgroundColor: _primary,
        foregroundColor: Colors.white,
      ),
      backgroundColor: Colors.white,
      body: FutureBuilder<List<TarifOneriSonuc>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  "Bir hata oluştu:\n${snapshot.error}",
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          final sonuclar = snapshot.data ?? [];

          if (sonuclar.isEmpty) {
            return const Center(
              child: Text("Seçtiğiniz malzemelere uygun tarif bulunamadı."),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: sonuclar.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final t = sonuclar[index];

              // Backend /resimler/... döndürüyor → baseUrl ile birleştir
              final imageUrl = getImageUrl(t.tarifFoto ?? '');

              return Consumer<FavoritesProvider>(
                builder: (context, favoritesProvider, _) {
                  final isFavorite = favoritesProvider.isFavorite(t.tarifId);
                  return InkWell(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => TarifDetayPage(tarifId: t.tarifId),
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            blurRadius: 8,
                            color: Colors.black.withOpacity(0.03),
                            offset: const Offset(0, 2),
                          ),
                        ],
                        border: Border.all(
                          color: _surfaceSoft,
                        ),
                      ),
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // 👇 Fotoğraf
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.network(
                                  imageUrl,
                                  width: 72,
                                  height: 72,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Container(
                                    width: 72,
                                    height: 72,
                                    color: _surfaceSoft,
                                    child: Icon(
                                      Icons.image_not_supported_outlined,
                                      color: _textMuted,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),

                              // 👇 Başlık + eşleşme bilgisi
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      t.baslik,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      "Eşleşen malzeme: ${t.eslesenMalzemeSayisi}/${t.tarifToplamMalzemeSayisi}",
                                      style: const TextStyle(
                                        fontSize: 13,
                                        color: _textMuted,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // 👇 Sağ üstte küçük yüzde ve kalp ikonu
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      favoritesProvider.toggleFavorite(t.tarifId, context);
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
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
                                        color: isFavorite ? Colors.red : _textMuted,
                                        size: 18,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "${t.skorYuzde.toStringAsFixed(0)}%",
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: _primaryDark,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),

                          const SizedBox(height: 10),

                          // Eşleşen malzemeler chipleri
                          if (t.eslesenMalzemeler.isNotEmpty) ...[
                            const Text(
                              "Eşleşen malzemeler:",
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Wrap(
                              spacing: 6,
                              runSpacing: 4,
                              children: t.eslesenMalzemeler
                                  .map(
                                    (m) => Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _primary.withOpacity(0.08),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    m,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: _primaryDark,
                                    ),
                                  ),
                                ),
                              )
                                  .toList(),
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
