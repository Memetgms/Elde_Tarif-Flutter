import 'package:flutter/material.dart';
import 'package:elde_tarif/services/daily_local_store.dart';

class DailyGoalsSheet extends StatefulWidget {
  final DailyLocalStore store;
  final VoidCallback onSaved;

  const DailyGoalsSheet({
    super.key,
    required this.store,
    required this.onSaved,
  });

  @override
  State<DailyGoalsSheet> createState() => _DailyGoalsSheetState();
}

class _DailyGoalsSheetState extends State<DailyGoalsSheet> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController calC;
  late TextEditingController proteinC;
  late TextEditingController carbC;
  late TextEditingController fatC;
  late TextEditingController waterC;

  bool _loading = true;

  @override
  void initState() {
    super.initState();
    calC = TextEditingController();
    proteinC = TextEditingController();
    carbC = TextEditingController();
    fatC = TextEditingController();
    waterC = TextEditingController();
    _load();
  }

  Future<void> _load() async {
    final g = await widget.store.getGoals();
    calC.text = g["cal"].toString();
    proteinC.text = g["protein"].toString();
    carbC.text = g["carb"].toString();
    fatC.text = g["fat"].toString();
    waterC.text = g["waterMl"].toString();
    if (mounted) setState(() => _loading = false);
  }

  @override
  void dispose() {
    calC.dispose();
    proteinC.dispose();
    carbC.dispose();
    fatC.dispose();
    waterC.dispose();
    super.dispose();
  }

  int _parse(String s, int fallback) {
    final v = int.tryParse(s.trim());
    return v ?? fallback;
  }

  Widget _numField(String label, TextEditingController c, {String suffix = ""}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13, 
            fontWeight: FontWeight.w600,
            color: Colors.black87
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: c,
          keyboardType: TextInputType.number,
          style: const TextStyle(fontWeight: FontWeight.bold),
          decoration: InputDecoration(
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            suffixText: suffix.isEmpty ? null : suffix,
            suffixStyle: TextStyle(color: Colors.grey.shade600, fontSize: 13),
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF3B82F6), width: 1.5),
            ),
          ),
          validator: (v) {
            if (v == null || v.trim().isEmpty) return "Gerekli";
            final n = int.tryParse(v.trim());
            if (n == null || n < 0) return "Geçersiz";
            return null;
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // Klavye açıklığını dikkate al
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(20, 16, 20, bottomInset + 20),
      child: SafeArea(
        child: _loading
            ? const SizedBox(
                height: 200, 
                child: Center(child: CircularProgressIndicator())
              )
            : SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Handle bar
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      
                      const Row(
                        children: [
                          Icon(Icons.flag_rounded, color: Color(0xFF3B82F6)),
                          SizedBox(width: 10),
                          Text(
                            "Günlük Hedefler",
                            style: TextStyle(
                              fontSize: 18, 
                              fontWeight: FontWeight.bold,
                              color: Colors.black87
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
            
                      // Kalori
                      _numField("Günlük Kalori Hedefi", calC, suffix: "kcal"),
                      const SizedBox(height: 16),
            
                      // Makrolar (Yan Yana)
                      Row(
                        children: [
                          Expanded(child: _numField("Protein", proteinC, suffix: "g")),
                          const SizedBox(width: 12),
                          Expanded(child: _numField("Yag", fatC, suffix: "g")),
                          const SizedBox(width: 12),
                          Expanded(child: _numField("Karb", carbC, suffix: "g")),
                        ],
                      ),
                      const SizedBox(height: 16),
            
                      // Su
                      _numField("Günlük Su Hedefi", waterC, suffix: "ml"),
                      
                      const SizedBox(height: 24),
            
                      // Butonlar
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () async {
                            if (!_formKey.currentState!.validate()) return;
            
                            await widget.store.saveGoals(
                              cal: _parse(calC.text, 2000),
                              protein: _parse(proteinC.text, 100),
                              carb: _parse(carbC.text, 200),
                              fat: _parse(fatC.text, 60),
                              waterMl: _parse(waterC.text, 2500),
                            );
            
                            widget.onSaved();
                            if (context.mounted) Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF3B82F6),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            elevation: 0,
                          ),
                          child: const Text(
                            "Kaydet ve Kapat",
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        "Not: Su takibi her gün 05:00'te sıfırlanır.",
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}
