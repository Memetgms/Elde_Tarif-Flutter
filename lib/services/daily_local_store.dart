import 'package:shared_preferences/shared_preferences.dart';

class DailyLocalStore {
  static const _kCalGoal = 'daily_goal_cal';
  static const _kProteinGoal = 'daily_goal_protein';
  static const _kCarbGoal = 'daily_goal_carb';
  static const _kFatGoal = 'daily_goal_fat';
  static const _kWaterGoal = 'daily_goal_water_ml';

  static const _kWaterMl = 'daily_water_ml';
  static const _kLastWaterResetEpoch = 'daily_water_last_reset_epoch';

  Future<Map<String, int>> getGoals() async {
    final sp = await SharedPreferences.getInstance();
    return {
      "cal": sp.getInt(_kCalGoal) ?? 2000,
      "protein": sp.getInt(_kProteinGoal) ?? 100,
      "carb": sp.getInt(_kCarbGoal) ?? 200,
      "fat": sp.getInt(_kFatGoal) ?? 60,
      "waterMl": sp.getInt(_kWaterGoal) ?? 2500,
    };
  }

  Future<void> saveGoals({
    required int cal,
    required int protein,
    required int carb,
    required int fat,
    required int waterMl,
  }) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setInt(_kCalGoal, cal);
    await sp.setInt(_kProteinGoal, protein);
    await sp.setInt(_kCarbGoal, carb);
    await sp.setInt(_kFatGoal, fat);
    await sp.setInt(_kWaterGoal, waterMl);
  }

  /// Günlük su reset kontrolü: her gün 05:00
  Future<void> ensureWaterResetIfNeeded() async {
    final sp = await SharedPreferences.getInstance();

    final now = DateTime.now();
    final today5 = DateTime(now.year, now.month, now.day, 5, 0, 0);

    // "Bugünün reset zamanı" geçmiş mi? (yani saat 05:00'i geçtiysek)
    final effectiveResetPoint = now.isAfter(today5) ? today5 : today5.subtract(const Duration(days: 1));

    final lastEpoch = sp.getInt(_kLastWaterResetEpoch);
    final lastReset = lastEpoch != null ? DateTime.fromMillisecondsSinceEpoch(lastEpoch) : null;

    // Hiç reset yoksa veya son reset effective reset noktasından eskiyse -> sıfırla
    if (lastReset == null || lastReset.isBefore(effectiveResetPoint)) {
      await sp.setInt(_kWaterMl, 0);
      await sp.setInt(_kLastWaterResetEpoch, effectiveResetPoint.millisecondsSinceEpoch);
    }
  }

  Future<int> getWaterMl() async {
    final sp = await SharedPreferences.getInstance();
    return sp.getInt(_kWaterMl) ?? 0;
  }

  Future<void> setWaterMl(int ml) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setInt(_kWaterMl, ml);
  }

  Future<int> addWater(int addMl) async {
    final current = await getWaterMl();
    final next = (current + addMl).clamp(0, 1000000);
    await setWaterMl(next);
    return next;
  }

  Future<void> resetWater() async {
    final sp = await SharedPreferences.getInstance();
    await sp.setInt(_kWaterMl, 0);
  }
}
