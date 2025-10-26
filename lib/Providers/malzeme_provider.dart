import 'package:flutter/foundation.dart';
import 'package:elde_tarif/apiservice.dart';
import 'package:elde_tarif/models/malzeme.dart';

class MalzemeProvider extends ChangeNotifier {
  final ApiService api;
  MalzemeProvider(this.api);

  bool loading = false;
  String? error;

  List<Malzeme> _all = [];
  List<Malzeme> get all => _all;

  String _search = '';
  String get search => _search;

  final Set<String> _selectedTypes = {};
  Set<String> get selectedTypes => _selectedTypes;

  List<String> get allTypes {
    final list = <String>{ for (final m in _all) m.malzemeTur.trim() }.toList();
    list.sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
    return list;
  }

  List<Malzeme> get filtered {
    Iterable<Malzeme> q = _all;

    if (_selectedTypes.isNotEmpty) {
      q = q.where((m) => _selectedTypes.contains(m.malzemeTur));
    }
    if (_search.trim().isNotEmpty) {
      final norm = _normalize(_search);
      q = q.where((m) => _normalize(m.ad).contains(norm));
    }

    final list = q.toList()
      ..sort((a, b) => a.ad.toLowerCase().compareTo(b.ad.toLowerCase()));
    return list;
  }

  Future<void> load() async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      _all = await api.fetchMalzemeler();
    } catch (e) {
      error = e.toString();
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  void setSearch(String v) {
    _search = v;
    notifyListeners();
  }

  void toggleType(String t) {
    _selectedTypes.contains(t) ? _selectedTypes.remove(t) : _selectedTypes.add(t);
    notifyListeners();
  }

  static String _normalize(String s) => s
      .toLowerCase()
      .replaceAll('ı', 'i')
      .replaceAll('İ', 'i')
      .replaceAll('ş', 's')
      .replaceAll('Ş', 's')
      .replaceAll('ğ', 'g')
      .replaceAll('Ğ', 'g')
      .replaceAll('ç', 'c')
      .replaceAll('Ç', 'c')
      .replaceAll('ö', 'o')
      .replaceAll('Ö', 'o')
      .replaceAll('ü', 'u')
      .replaceAll('Ü', 'u')
      .trim();
}
