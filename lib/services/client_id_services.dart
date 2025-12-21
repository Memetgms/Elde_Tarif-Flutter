import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class ClientIdService {
  static const _key = 'client_id';
  static const _uuid = Uuid();

  static Future<String> getOrCreate() async {
    final sp = await SharedPreferences.getInstance();
    final existing = sp.getString(_key);
    if (existing != null && existing.isNotEmpty) return existing;

    final id = _uuid.v4(); // random guid
    await sp.setString(_key, id);
    return id;
  }
}
