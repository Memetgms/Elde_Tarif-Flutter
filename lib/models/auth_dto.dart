// Auth DTO'ları
class LoginDto {
  final String emailOrUserName;
  final String password;

  LoginDto({required this.emailOrUserName, required this.password});

  Map<String, dynamic> toJson() {
    return {
      'emailOrUserName': emailOrUserName,
      'password': password,
    };
  }
}

class RegisterDto {
  final String email;
  final String? userName;
  final String password;

  RegisterDto({required this.email, this.userName, required this.password});

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'userName': userName,
      'password': password,
    };
  }
}

// Auth Response Model
class AuthResponse {
  final String token;
  final String refreshToken;
  final String? message;

  AuthResponse({required this.token, required this.refreshToken, this.message});

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      token: json['token'] as String,
      refreshToken: json['refreshToken'] as String,
      message: json['message'] as String?,
    );
  }
}

// Register Response (artık token döndürmüyor)
class RegisterResponse {
  final String message;

  RegisterResponse({required this.message});

  factory RegisterResponse.fromJson(Map<String, dynamic> json) {
    return RegisterResponse(
      message: json['message'] as String,
    );
  }
}

// Email Doğrulama DTO
class ConfirmEmailCodeDto {
  final String email;
  final String code;

  ConfirmEmailCodeDto({required this.email, required this.code});

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'code': code,
    };
  }
}

// Kod Tekrar Gönderme DTO
class ResendCodeDto {
  final String email;

  ResendCodeDto({required this.email});

  Map<String, dynamic> toJson() {
    return {
      'email': email,
    };
  }
}


