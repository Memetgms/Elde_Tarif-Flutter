import 'package:elde_tarif/apiservice/api_service.dart';
import 'package:elde_tarif/apiservice/auth_api.dart';
import 'package:elde_tarif/apiservice/chefs_api.dart';
import 'package:elde_tarif/apiservice/recipes_api.dart';
import 'package:elde_tarif/apiservice/token_service.dart';
import 'package:elde_tarif/apiservice/aichat_api.dart';
import 'package:elde_tarif/models/auth_dto.dart';
import 'package:elde_tarif/models/kategori.dart';
import 'package:elde_tarif/models/malzeme.dart';
import 'package:elde_tarif/models/sef.dart';
import 'package:elde_tarif/models/sef_detay.dart';
import 'package:elde_tarif/models/tarif_detay.dart';
import 'package:elde_tarif/models/tarif_oneri_sonuc.dart';
import 'package:elde_tarif/models/tarifonizleme.dart';

// Tüm API servislerini birleştiren ana sınıf
class ApiService extends BaseApiService {
  static const String baseUrl = BaseApiService.baseUrl;
  
  late final ChefsApi _chefsApi;
  late final RecipesApi _recipesApi;
  late final TokenService _tokenService;
  late final AuthApi _authApi;
  late final AiChatApi _aiChatApi;

  ApiService() {
    _tokenService = TokenService();
    _authApi = AuthApi(this, _tokenService);
    _chefsApi = ChefsApi(this);
    _recipesApi = RecipesApi(this);
    _aiChatApi = AiChatApi(_tokenService);
  }

  // Base metodlar (getImageUrl BaseApiService'ten geliyor)

  // Şefler API'leri
  Future<List<Sef>> fetchSefler() => _chefsApi.fetchSefler();
  Future<SefDetay> getSefDetay(int id) => _chefsApi.getSefDetay(id);

  // Tarifler API'leri
  Future<List<Kategori>> fetchKategoriler() => _recipesApi.fetchKategoriler();
  Future<List<TarifOnizleme>> fetchTarifOnizleme() => _recipesApi.fetchTarifOnizleme();
  Future<List<Malzeme>> fetchMalzemeler() => _recipesApi.fetchMalzemeler();
  Future<TarifDetay> getTarifDetay(int id) => _recipesApi.getTarifDetay(id);
  Future<List<TarifOneriSonuc>> tarifOneriGetir(List<int> malzemeIdler) => 
      _recipesApi.tarifOneriGetir(malzemeIdler);

  // Token işlemleri
  Future<Map<String, String?>> getTokens() => _tokenService.getTokens();
  Future<void> clearTokens() => _tokenService.clearTokens();
  Future<bool> hasValidToken() => _tokenService.hasValidToken();

  // Auth işlemleri
  Future<AuthResponse> login(LoginDto dto) => _authApi.login(dto);
  Future<RegisterResponse> register(RegisterDto dto) => _authApi.register(dto);
  Future<String> confirmEmail(ConfirmEmailCodeDto dto) => _authApi.confirmEmail(dto);
  Future<String> resendCode(ResendCodeDto dto) => _authApi.resendCode(dto);
  Future<AuthResponse> refreshToken(String refreshToken) => _authApi.refreshToken(refreshToken);
  Future<String> logout() => _authApi.logout();

  // AI Chat işlemleri
  Future<String> sendChatMessage(String message) => _aiChatApi.sendMessage(message);

  // ================= AUTO LOGIN =================
  Future<bool> tryAutoLogin() async {
    final tokens = await _tokenService.getTokens();

    final accessToken = tokens['token'];
    final refreshTokenValue = tokens['refreshToken'];

    // 1️⃣ Access token varsa → giriş var say
    if (accessToken != null && accessToken.isNotEmpty) {
      return true;
    }

    // 2️⃣ Access token yok ama refresh token varsa → yenilemeyi dene
    if (refreshTokenValue != null && refreshTokenValue.isNotEmpty) {
      try {
        final auth = await refreshToken(refreshTokenValue);
        return auth.token.isNotEmpty;
      } catch (_) {
        await _tokenService.clearTokens();
        return false;
      }
    }

    return false;
  }
}

