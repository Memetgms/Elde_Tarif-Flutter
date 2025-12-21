import 'package:elde_tarif/apiservice/api_client.dart';

/// Favori ile ilgili API işlemleri
class FavoriApi {
  final ApiClient _client;

  FavoriApi(this._client);

  /// Favoriye ekle
  Future<void> addFavorite(int tarifId) async {
    await _client.post(
      '/api/Favori/add/$tarifId',
      requireAuth: true,
    );
  }

  /// Favoriden çıkar
  Future<void> removeFavorite(int tarifId) async {
    await _client.delete(
      '/api/Favori/remove/$tarifId',
      requireAuth: true,
    );
  }
}



