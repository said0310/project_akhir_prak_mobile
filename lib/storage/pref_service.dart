import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants/app_constants.dart';

class PrefService {
  late SharedPreferences _prefs;

  Future<PrefService> init() async {
    _prefs = await SharedPreferences.getInstance();
    return this;
  }

  // Login & Sesi
  bool get isLoggedIn => _prefs.getBool(AppConstants.prefIsLoggedIn) ?? false;
  String get userId => _prefs.getString(AppConstants.prefUserId) ?? '';
  String get sessionToken => _prefs.getString(AppConstants.prefSessionToken) ?? '';

  Future<void> saveSession({required String userId, required String token}) async {
    await _prefs.setBool(AppConstants.prefIsLoggedIn, true);
    await _prefs.setString(AppConstants.prefUserId, userId);
    await _prefs.setString(AppConstants.prefSessionToken, token);
  }

  Future<void> clearSession() async {
    await _prefs.setBool(AppConstants.prefIsLoggedIn, false);
    await _prefs.remove(AppConstants.prefUserId);
    await _prefs.remove(AppConstants.prefSessionToken);
  }

  // Tema
  String get themeMode => _prefs.getString(AppConstants.prefThemeMode) ?? 'light';
  Future<void> setThemeMode(String mode) async {
    await _prefs.setString(AppConstants.prefThemeMode, mode);
  }

  // Notifikasi Toggle
  bool get isNotifEnabled => _prefs.getBool(AppConstants.prefNotifEnabled) ?? true;
  Future<void> setNotifEnabled(bool enabled) async {
    await _prefs.setBool(AppConstants.prefNotifEnabled, enabled);
  }
}
