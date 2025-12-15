import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';

import 'package:elde_tarif/Providers/tarif_detay_provider.dart';
import 'package:elde_tarif/apiservice.dart';

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
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TarifDetayProvider>().yukle(widget.tarifId);
    });
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
                            _apiService.getImageUrl(d.kapakFotoUrl ?? ''),
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
        color: primary ? AppTheme.primary.withOpacity(0.12) : AppTheme.surfaceSoft,
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
}