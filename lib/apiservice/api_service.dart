class BaseApiService {
  static const String baseUrl = 'http://10.0.2.2:5262'; //10.0.2.2:5262

  String getImageUrl(String imagePath) {
    if (imagePath.isEmpty) return imagePath;
    if (imagePath.startsWith('http://') || imagePath.startsWith('https://')) {
      return imagePath;
    }
    return '$baseUrl$imagePath';
  }
}

