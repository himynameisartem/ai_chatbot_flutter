import 'package:shared_preferences/shared_preferences.dart';

class SettingsService {
  static const _providerKey = 'selected_provider';
  static const _apiKeyKey = 'api_key';

  Future<void> saveSettings({
    required String provider,
    required String apiKey,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_providerKey, provider);
    await prefs.setString(_apiKeyKey, apiKey);
  }

  Future<String?> getProvider() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_providerKey);
  }

  Future<String?> getApiKey() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_apiKeyKey);
  }

  Future<bool> hasSettings() async {
    final provider = await getProvider();
    final apiKey = await getApiKey();

    return provider != null &&
        provider.isNotEmpty &&
        apiKey != null &&
        apiKey.isNotEmpty;
  }
}
