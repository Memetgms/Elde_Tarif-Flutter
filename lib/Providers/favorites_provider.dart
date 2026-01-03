import 'package:flutter/material.dart';
import 'package:elde_tarif/apiservice/favori_api.dart';
import 'package:elde_tarif/apiservice/token_service.dart';
import 'package:elde_tarif/widgets/custom_toast.dart';

class FavoritesProvider extends ChangeNotifier {
  final Set<int> _favoriteTarifIds = {};
  final FavoriApi _favoriApi;
  final TokenService _tokenService = TokenService();

  FavoritesProvider()
      : _favoriApi = FavoriApi();

  Set<int> get favoriteTarifIds => Set.unmodifiable(_favoriteTarifIds);

  bool isFavorite(int tarifId) {
    return _favoriteTarifIds.contains(tarifId);
  }

  Future<void> toggleFavorite(int tarifId, BuildContext context) async {
    // Token kontrolü
    final hasToken = await _tokenService.hasValidToken();
    
    if (!hasToken) {
      // Token yoksa sadece uyarı göster
      CustomToast.warning(
        context,
        'Favorilere eklemek için giriş yapmalısın',
      );
      return;
    }

    // Optimistic UI güncellemesi
    final wasFavorite = _favoriteTarifIds.contains(tarifId);
    
    if (wasFavorite) {
      _favoriteTarifIds.remove(tarifId);
    } else {
      _favoriteTarifIds.add(tarifId);
    }
    
    notifyListeners();

    try {
      // API çağrısı
      if (wasFavorite) {
        await _favoriApi.removeFavorite(tarifId);
        CustomToast.success(context, 'Favorilerden kaldırıldı');
      } else {
        await _favoriApi.addFavorite(tarifId);
        CustomToast.success(context, 'Favorilere eklendi');
      }
    } catch (e) {
      // Hata durumunda UI'ı eski haline döndür
      if (wasFavorite) {
        _favoriteTarifIds.add(tarifId);
      } else {
        _favoriteTarifIds.remove(tarifId);
      }
      notifyListeners();

      // Hata mesajı göster
      final errorMessage = e.toString().replaceAll('Exception: ', '');
      CustomToast.error(context, errorMessage);
    }
  }

  // Favori ID'lerini set et (örneğin uygulama başlangıcında backend'den yüklenebilir)
  void setFavoriteIds(Set<int> ids) {
    _favoriteTarifIds.clear();
    _favoriteTarifIds.addAll(ids);
    notifyListeners();
  }

  // Tek bir favori ID ekle (senkron, state yönetimi için)
  void addFavoriteId(int tarifId) {
    _favoriteTarifIds.add(tarifId);
    notifyListeners();
  }

  // Tek bir favori ID çıkar (senkron, state yönetimi için)
  void removeFavoriteId(int tarifId) {
    _favoriteTarifIds.remove(tarifId);
    notifyListeners();
  }
}
