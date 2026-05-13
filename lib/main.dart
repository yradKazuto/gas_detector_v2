import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'theme.dart';
import 'models/settings.dart';
import 'models/gas_reading.dart';
import 'services/websocket_service.dart';
import 'screens/home_screen.dart';
import 'screens/history_screen.dart';
import 'screens/alerts_screen.dart';
import 'screens/settings_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  final settings = await AppSettings.load();
  runApp(GasDetectorApp(settings: settings));
}

class GasDetectorApp extends StatefulWidget {
  final AppSettings settings;
  const GasDetectorApp({super.key, required this.settings});

  @override
  State<GasDetectorApp> createState() => _GasDetectorAppState();
}

class _GasDetectorAppState extends State<GasDetectorApp> {
  late AppSettings _settings;
  late WebSocketService _wsService;

  @override
  void initState() {
    super.initState();
    _settings = widget.settings;
    _wsService = WebSocketService(_settings);
    _wsService.connect();
    if (_settings.keepScreenOn) WakelockPlus.enable();
  }

  void _onSettingsChanged(AppSettings updated) {
    setState(() => _settings = updated);
    _wsService.updateSettings(updated);
    if (updated.keepScreenOn) {
      WakelockPlus.enable();
    } else {
      WakelockPlus.disable();
    }
  }

  @override
  void dispose() {
    _wsService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _wsService,
      child: MaterialApp(
        title: 'Gas detector',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.dark,
        home: _MainShell(
          settings: _settings,
          onSettingsChanged: _onSettingsChanged,
        ),
      ),
    );
  }
}

class _MainShell extends StatefulWidget {
  final AppSettings settings;
  final ValueChanged<AppSettings> onSettingsChanged;

  const _MainShell({required this.settings, required this.onSettingsChanged});

  @override
  State<_MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<_MainShell> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    final screens = [
      HomeScreen(settings: widget.settings),
      HistoryScreen(settings: widget.settings),
      const AlertsScreen(),
      SettingsScreen(settings: widget.settings, onChanged: widget.onSettingsChanged),
    ];

    return Consumer<WebSocketService>(
      builder: (context, ws, _) {
        final alertCount = ws.alerts.where((a) => a.status != GasStatus.safe).length;

        return Scaffold(
          body: IndexedStack(index: _tab, children: screens),
          bottomNavigationBar: Container(
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: AppColors.border, width: 0.5)),
            ),
            child: BottomNavigationBar(
              currentIndex: _tab,
              onTap: (i) => setState(() => _tab = i),
              items: [
                const BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'Home'),
                const BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'History'),
                BottomNavigationBarItem(
                  icon: alertCount > 0
                      ? Badge(
                          label: Text('$alertCount'),
                          child: const Icon(Icons.notifications_outlined),
                        )
                      : const Icon(Icons.notifications_outlined),
                  label: 'Alerts',
                ),
                const BottomNavigationBarItem(icon: Icon(Icons.settings_outlined), label: 'Settings'),
              ],
            ),
          ),
        );
      },
    );
  }
}
