import 'package:shared_preferences/shared_preferences.dart';
import '../theme.dart';

class AppSettings {
  String ipAddress;
  int port;
  int warningThreshold;
  int dangerThreshold;
  bool soundEnabled;
  bool vibrationEnabled;
  bool pushEnabled;
  bool keepScreenOn;
  int intervalMs;

  AppSettings({
    this.ipAddress = AppConstants.defaultIp,
    this.port = AppConstants.defaultPort,
    this.warningThreshold = AppConstants.defaultWarningThreshold,
    this.dangerThreshold = AppConstants.defaultDangerThreshold,
    this.soundEnabled = true,
    this.vibrationEnabled = false,
    this.pushEnabled = true,
    this.keepScreenOn = true,
    this.intervalMs = AppConstants.defaultIntervalMs,
  });

  String get wsUrl => 'ws://$ipAddress:$port';

  static Future<AppSettings> load() async {
    final prefs = await SharedPreferences.getInstance();
    return AppSettings(
      ipAddress: prefs.getString('ip') ?? AppConstants.defaultIp,
      port: prefs.getInt('port') ?? AppConstants.defaultPort,
      warningThreshold: prefs.getInt('warningThreshold') ?? AppConstants.defaultWarningThreshold,
      dangerThreshold: prefs.getInt('dangerThreshold') ?? AppConstants.defaultDangerThreshold,
      soundEnabled: prefs.getBool('sound') ?? true,
      vibrationEnabled: prefs.getBool('vibration') ?? false,
      pushEnabled: prefs.getBool('push') ?? true,
      keepScreenOn: prefs.getBool('keepScreen') ?? true,
      intervalMs: prefs.getInt('interval') ?? AppConstants.defaultIntervalMs,
    );
  }

  Future<void> save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('ip', ipAddress);
    await prefs.setInt('port', port);
    await prefs.setInt('warningThreshold', warningThreshold);
    await prefs.setInt('dangerThreshold', dangerThreshold);
    await prefs.setBool('sound', soundEnabled);
    await prefs.setBool('vibration', vibrationEnabled);
    await prefs.setBool('push', pushEnabled);
    await prefs.setBool('keepScreen', keepScreenOn);
    await prefs.setInt('interval', intervalMs);
  }
}
