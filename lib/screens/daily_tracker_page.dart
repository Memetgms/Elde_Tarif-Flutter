import 'package:elde_tarif/screens/SearchPage.dart';
import 'package:flutter/material.dart';


import 'package:elde_tarif/apiservice/gunluk_api.dart';
import 'package:elde_tarif/models/gunluk_models.dart';
import 'package:elde_tarif/services/daily_local_store.dart';
import 'package:elde_tarif/widgets/daily_goals_sheet.dart';

class DailyTrackerPage extends StatefulWidget {
  const DailyTrackerPage({super.key});

  @override
  State<DailyTrackerPage> createState() => _DailyTrackerPageState();
}

class _DailyTrackerPageState extends State<DailyTrackerPage> {
  late final GunlukApi _api;
  final DailyLocalStore _store = DailyLocalStore();

  bool _loading = true;

  // Data
  List<GunlukOgunItem> _ogunler = [];
  GunlukMakroToplam _makro =
      GunlukMakroToplam(kalori: 0, protein: 0, karbonhidrat: 0, yag: 0);

  // Local Goals
  Map<String, int> _goals = {
    "cal": 2000,
    "protein": 100,
    "carb": 200,
    "fat": 60,
    "waterMl": 2500
  };
  int _waterMl = 0;

  @override
  void initState() {
    super.initState();
    _api = GunlukApi();
    _init();
  }

  Future<void> _init() async {
    setState(() => _loading = true);

    // Su reset kontrol (local)
    await _store.ensureWaterResetIfNeeded();

    // Load goals + water + api
    final goals = await _store.getGoals();
    final water = await _store.getWaterMl();

    try {
      final ogunler = await _api.getOgunler();
      final makro = await _api.getMakrolar();

      if (mounted) {
        setState(() {
          _goals = goals;
          _waterMl = water;
          _ogunler = ogunler;
          _makro = makro;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _goals = goals;
          _waterMl = water;
          _loading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Hata: $e")),
        );
      }
    }
  }

  List<GunlukOgunItem> _filter(String ogunTipi) => _ogunler
      .where((x) => x.ogunTipi.toLowerCase() == ogunTipi.toLowerCase())
      .toList();

  int _sumCal(List<GunlukOgunItem> list) =>
      list.fold(0, (p, e) => p + e.kalori);

  Future<void> _deleteMeal(int id) async {
    try {
      await _api.ogunSil(id);
      await _init();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Silme hatası: $e")),
      );
    }
  }

  Future<void> _goTarifler() async {
    final refreshed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const SearchPage()),
    );

    if (refreshed == true) {
      await _init();
    }
  }

  Future<void> _openGoals() async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DailyGoalsSheet(
        store: _store,
        onSaved: () async {
          final goals = await _store.getGoals();
          setState(() => _goals = goals);
        },
      ),
    );
  }

  Future<void> _addWater(int ml) async {
    final next = await _store.addWater(ml);
    setState(() => _waterMl = next);
  }

  @override
  Widget build(BuildContext context) {
    // Tarih formatı (Örn: 24 Ekim)
    final now = DateTime.now();
    final months = [
      "",
      "Ocak",
      "Şubat",
      "Mart",
      "Nisan",
      "Mayıs",
      "Haziran",
      "Temmuz",
      "Ağustos",
      "Eylül",
      "Ekim",
      "Kasım",
      "Aralık"
    ];
    final dateStr = "${now.day} ${months[now.month]}";

    final calGoal = _goals["cal"] ?? 2000;
    final calProgress =
        (calGoal <= 0) ? 0.0 : (_makro.kalori / calGoal).clamp(0.0, 1.0);
    final waterGoal = _goals["waterMl"] ?? 2500;
    final waterProgress =
        (waterGoal <= 0) ? 0.0 : (_waterMl / waterGoal).clamp(0.0, 1.0);

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA), // Screenshot-like background
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: _init,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // --- Header ---
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                )
                              ],
                            ),
                            child: const Icon(Icons.calendar_today_outlined,
                                color: Color(0xFF3B82F6), size: 24),
                          ),
                          const SizedBox(width: 16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Bugün, $dateStr",
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 2),
                              const Text(
                                "Harika gidiyorsun! 🔥",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          const Spacer(),
                          IconButton(
                            onPressed: _openGoals,
                            icon: const Icon(Icons.settings, color: Colors.black87),
                          ),
                        ],
                      ),
                      const SizedBox(height: 30),

                      // --- Meals Section ---
                      const Text(
                        "Öğünler",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 16),
                      GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: 2,
                        mainAxisSpacing: 16,
                        crossAxisSpacing: 16,
                        childAspectRatio: 0.85,
                        children: [
                          _buildMealCard(
                            title: "Kahvaltı",
                            mealType: "Kahvaltı",
                            imageAsset: "https://images.unsplash.com/photo-1494390248081-4e521a5940db?auto=format&fit=crop&w=400&q=80",
                            onAdd: _goTarifler,
                          ),
                          _buildMealCard(
                            title: "Öğle",
                            mealType: "Öğle",
                            imageAsset: "https://images.unsplash.com/photo-1546069901-ba9599a7e63c?auto=format&fit=crop&w=400&q=80",
                            onAdd: _goTarifler,
                          ),
                          _buildMealCard(
                            title: "Ara Öğün",
                            mealType: "Ara Öğün",
                            imageAsset: "https://images.unsplash.com/photo-1512621776951-a57141f2eefd?auto=format&fit=crop&w=400&q=80",
                            onAdd: _goTarifler,
                          ),
                          _buildMealCard(
                            title: "Akşam",
                            mealType: "Akşam",
                            imageAsset: "https://images.unsplash.com/photo-1547592180-85f173990554?auto=format&fit=crop&w=400&q=80",
                            onAdd: _goTarifler,
                          ),
                        ],
                      ),

                      const SizedBox(height: 30),

                      // --- Macros Section ---
                      const Text(
                        "Günlük Değerler",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.03),
                              blurRadius: 15,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            // Kalori Header
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.orange.shade50,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.local_fire_department,
                                    color: Colors.orange,
                                    size: 24,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                const Text(
                                  "Kalori",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  "${_makro.kalori} / $calGoal kcal",
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            // Kalori Bar
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: LinearProgressIndicator(
                                value: calProgress,
                                minHeight: 12,
                                backgroundColor: const Color(0xFFF1F5F9),
                                valueColor:
                                    const AlwaysStoppedAnimation(Color(0xFF3B82F6)),
                              ),
                            ),
                            const SizedBox(height: 24),
                            // Alt Makrolar (Protein, Carb, Fat)
                            Row(
                              children: [
                                Expanded(
                                  child: _buildMacroColumn(
                                    "Protein",
                                    _makro.protein,
                                    _goals["protein"] ?? 100,
                                    const Color(0xFF3B82F6),
                                  ),
                                ),
                                Expanded(
                                  child: _buildMacroColumn(
                                    "Karb",
                                    _makro.karbonhidrat,
                                    _goals["carb"] ?? 200,
                                    const Color(0xFFFFC107),
                                  ),
                                ),
                                Expanded(
                                  child: _buildMacroColumn(
                                    "Yağ",
                                    _makro.yag,
                                    _goals["fat"] ?? 60,
                                    const Color(0xFFEF4444),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 30),

                      // --- Hydration Section ---
                      const Text(
                        "Su Takibi 💧",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Color(0xFF0EA5E9),
                              Color(0xFF3B82F6),
                              Color(0xFF6366F1),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(28),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF3B82F6).withOpacity(0.3),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            children: [
                              // Header Row
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.water_drop,
                                            color: Colors.white,
                                            size: 28,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            "$_waterMl",
                                            style: const TextStyle(
                                              fontSize: 36,
                                              fontWeight: FontWeight.w800,
                                              color: Colors.white,
                                            ),
                                          ),
                                          const Text(
                                            " ml",
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.w500,
                                              color: Colors.white70,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        "Hedef: $waterGoal ml",
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.white.withOpacity(0.8),
                                        ),
                                      ),
                                    ],
                                  ),
                                  // Circular Progress
                                  Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      SizedBox(
                                        width: 80,
                                        height: 80,
                                        child: CircularProgressIndicator(
                                          value: waterProgress,
                                          strokeWidth: 8,
                                          backgroundColor: Colors.white.withOpacity(0.2),
                                          valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                                          strokeCap: StrokeCap.round,
                                        ),
                                      ),
                                      Text(
                                        "%${(waterProgress * 100).toInt()}",
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),

                              const SizedBox(height: 20),

                              // Progress Bar
                              Container(
                                height: 12,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Stack(
                                  children: [
                                    FractionallySizedBox(
                                      widthFactor: waterProgress.clamp(0.0, 1.0),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(10),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.white.withOpacity(0.5),
                                              blurRadius: 8,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 20),

                              // Motivational Text
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  waterProgress >= 1.0
                                      ? "🎉 Harika! Günlük hedefe ulaştın!"
                                      : waterProgress >= 0.7
                                          ? "💪 Çok iyi gidiyorsun, devam et!"
                                          : waterProgress >= 0.4
                                              ? "👍 İyi ilerleme, daha fazla su iç!"
                                              : "🌊 Hadi başlayalım, su içmeyi unutma!",
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ),

                              const SizedBox(height: 24),

                              // Quick Add Buttons
                              Row(
                                children: [
                                  _buildWaterButton("100", 100),
                                  const SizedBox(width: 10),
                                  _buildWaterButton("250", 250),
                                  const SizedBox(width: 10),
                                  _buildWaterButton("500", 500),
                                ],
                              ),

                              const SizedBox(height: 16),

                              // Main Action Row
                              Row(
                                children: [
                                  // Decrease Button
                                  Expanded(
                                    child: InkWell(
                                      onTap: () => _addWater(-250),
                                      borderRadius: BorderRadius.circular(16),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(vertical: 14),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.15),
                                          borderRadius: BorderRadius.circular(16),
                                          border: Border.all(
                                            color: Colors.white.withOpacity(0.3),
                                            width: 1,
                                          ),
                                        ),
                                        child: const Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Icon(Icons.remove, color: Colors.white, size: 22),
                                            SizedBox(width: 4),
                                            Text(
                                              "Azalt",
                                              style: TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  // Reset Button
                                  InkWell(
                                    onTap: () async {
                                      await _store.resetWater();
                                      setState(() => _waterMl = 0);
                                    },
                                    borderRadius: BorderRadius.circular(16),
                                    child: Container(
                                      padding: const EdgeInsets.all(14),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.15),
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(
                                          color: Colors.white.withOpacity(0.3),
                                          width: 1,
                                        ),
                                      ),
                                      child: const Icon(
                                        Icons.refresh,
                                        color: Colors.white,
                                        size: 22,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildMealCard({
    required String title,
    required String mealType,
    required String imageAsset,
    required VoidCallback onAdd,
  }) {
    // Toplam kalori ve öğün sayısı
    final items = _filter(mealType);
    final totalCal = _sumCal(items);
    final count = items.length;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        image: DecorationImage(
          image: NetworkImage(imageAsset),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(
            Colors.white.withOpacity(0.85), // Soft white overlay for readability
            BlendMode.lighten,
          ),
        ),
      ),
      child: Stack(
        children: [
          // Content
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Kcal Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 4,
                      )
                    ],
                  ),
                  child: Text(
                    "$totalCal kcal",
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
                
                const Spacer(),
                
                // Meal Title
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 4),
                // Subtitle (Öğün Ekle or Listed Meals)
                InkWell(
                  onTap: items.isNotEmpty ? () => _showMealDetails(title, items) : null,
                  child: Text(
                    items.isEmpty 
                        ? "Öğün ekle" 
                        : "$count tarif eklendi >",
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: items.isEmpty ? Colors.grey.shade600 : const Color(0xFF3B82F6),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),

          // Add Button (Bottom Right)
          Positioned(
            bottom: 12,
            right: 12,
            child: Material(
              color: const Color(0xFF2563EB),
              shape: const CircleBorder(),
              elevation: 4,
              child: InkWell(
                onTap: onAdd,
                borderRadius: BorderRadius.circular(30),
                child: const Padding(
                  padding: EdgeInsets.all(10),
                  child: Icon(
                    Icons.add,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Ufak pop-up ile o öğündeki yemekleri gösterip silme imkanı
  void _showMealDetails(String title, List<GunlukOgunItem> items) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("$title - Detaylar", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              ...items.map((item) => ListTile(
                title: Text(item.tarifBaslik, style: const TextStyle(fontWeight: FontWeight.w600)),
                subtitle: Text("${item.kalori} kcal"),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  onPressed: () async {
                    Navigator.pop(ctx);
                    await _deleteMeal(item.id);
                  },
                ),
              )),
              const SizedBox(height: 20),
            ],
          ),
        );
      }
    );
  }

  Widget _buildMacroColumn(String label, int val, int goal, Color color) {
    final progress = (goal <= 0) ? 0.0 : (val / goal).clamp(0.0, 1.0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey.shade500,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 6,
            backgroundColor: color.withOpacity(0.15),
            valueColor: AlwaysStoppedAnimation(color),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          "$val / $goal g",
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildWaterButton(String label, int ml) {
    return Expanded(
      child: InkWell(
        onTap: () => _addWater(ml),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 4,
              ),
            ],
          ),
          child: Column(
            children: [
              const Icon(
                Icons.water_drop_outlined,
                color: Color(0xFF3B82F6),
                size: 20,
              ),
              const SizedBox(height: 4),
              Text(
                "+$label",
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
              Text(
                "ml",
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
