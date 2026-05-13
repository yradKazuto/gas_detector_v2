import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;
import '../models/gas_reading.dart';
import '../models/settings.dart';
import '../theme.dart';

enum WsConnectionState { disconnected, connecting, connected, error }

class WebSocketService extends ChangeNotifier {
  WebSocketChannel? _channel;
  StreamSubscription? _subscription;
  Timer? _reconnectTimer;

  WsConnectionState _connectionState = WsConnectionState.disconnected;
  GasReading? _latestReading;
  String? _errorMessage;

  final List<GasReading> _history = [];
  final List<GasAlert> _alerts = [];

  AppSettings _settings;

  WebSocketService(this._settings);

  WsConnectionState get connectionState => _connectionState;
  GasReading? get latestReading => _latestReading;
  String? get errorMessage => _errorMessage;
  List<GasReading> get history => List.unmodifiable(_history);
  List<GasAlert> get alerts => List.unmodifiable(_alerts);
  bool get isConnected => _connectionState == WsConnectionState.connected;

  void updateSettings(AppSettings settings) {
    _settings = settings;
    if (isConnected) {
      disconnect();
      connect();
    }
  }

  void connect() {
    if (_connectionState == WsConnectionState.connecting ||
        _connectionState == WsConnectionState.connected) return;

    _setConnectionState(WsConnectionState.connecting);
    _errorMessage = null;

    try {
      _channel = WebSocketChannel.connect(Uri.parse(_settings.wsUrl));
      _subscription = _channel!.stream.listen(
        _onMessage,
        onError: _onError,
        onDone: _onDone,
      );
      _setConnectionState(WsConnectionState.connected);
    } catch (e) {
      _errorMessage = e.toString();
      _setConnectionState(WsConnectionState.error);
      _scheduleReconnect();
    }
  }

  void disconnect() {
    _reconnectTimer?.cancel();
    _subscription?.cancel();
    _channel?.sink.close(status.goingAway);
    _channel = null;
    _setConnectionState(WsConnectionState.disconnected);
  }

  void _onMessage(dynamic raw) {
    try {
      final data = jsonDecode(raw as String) as Map<String, dynamic>;
      final reading = GasReading.fromJson(
        data,
        warningThreshold: _settings.warningThreshold,
        dangerThreshold: _settings.dangerThreshold,
      );

      _latestReading = reading;

      _history.add(reading);
      if (_history.length > AppConstants.historyMaxPoints) {
        _history.removeAt(0);
      }

      // Generate alert on state change to warning or danger
      final prev = _history.length > 1 ? _history[_history.length - 2] : null;
      if (prev != null && prev.status != reading.status) {
        if (reading.status == GasStatus.danger) {
          _alerts.insert(
            0,
            GasAlert(
              status: GasStatus.danger,
              value: reading.value,
              timestamp: reading.timestamp,
              message: 'Gas level critical — value ${reading.value} exceeded danger threshold',
            ),
          );
        } else if (reading.status == GasStatus.warning) {
          _alerts.insert(
            0,
            GasAlert(
              status: GasStatus.warning,
              value: reading.value,
              timestamp: reading.timestamp,
              message: 'Warning — gas level rising (${reading.value})',
            ),
          );
        } else if (reading.status == GasStatus.safe && prev.status != GasStatus.safe) {
          _alerts.insert(
            0,
            GasAlert(
              status: GasStatus.safe,
              value: reading.value,
              timestamp: reading.timestamp,
              message: 'Air cleared — back to safe levels',
            ),
          );
        }
      }

      if (_connectionState != WsConnectionState.connected) {
        _setConnectionState(WsConnectionState.connected);
      }

      notifyListeners();
    } catch (e) {
      debugPrint('Parse error: $e');
    }
  }

  void _onError(Object error) {
    _errorMessage = error.toString();
    _setConnectionState(WsConnectionState.error);
    _scheduleReconnect();
  }

  void _onDone() {
    if (_connectionState != WsConnectionState.disconnected) {
      _setConnectionState(WsConnectionState.error);
      _scheduleReconnect();
    }
  }

  void _scheduleReconnect() {
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(const Duration(seconds: 3), connect);
  }

  void _setConnectionState(WsConnectionState state) {
    _connectionState = state;
    notifyListeners();
  }

  void clearAlerts() {
    _alerts.clear();
    notifyListeners();
  }

  @override
  void dispose() {
    disconnect();
    super.dispose();
  }
}
