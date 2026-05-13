# Gas Detector — Flutter App

Real-time ESP32 gas sensor monitor over WebSocket.

## Project structure

```
lib/
├── main.dart                  # Entry point, app shell, bottom nav
├── theme.dart                 # Colors, theme, constants
├── models/
│   ├── gas_reading.dart       # GasReading + GasAlert models
│   └── settings.dart          # AppSettings with SharedPreferences
├── services/
│   └── websocket_service.dart # WebSocket client + state management
├── screens/
│   ├── home_screen.dart       # Live reading, chart, gauge
│   ├── history_screen.dart    # Full reading log + chart
│   ├── alerts_screen.dart     # Alert events list
│   └── settings_screen.dart   # IP, thresholds, toggles
└── widgets/
    ├── common_widgets.dart    # StatusCard, ReadingChip, ConnectionBadge, etc.
    └── gas_chart.dart         # fl_chart bar chart
```

## Setup

### 1. Install dependencies

```bash
flutter pub get
```

### 2. Configure your ESP32 IP

Open `Settings` in the app and enter your ESP32's IP address.
Or edit the default in `lib/theme.dart`:

```dart
static const String defaultIp = '192.168.1.100';
```

Find your ESP32 IP in the Arduino Serial Monitor after it connects to WiFi.

### 3. Flash the ESP32

See the ESP32 code (WebSocket server on port 81).
Required Arduino libraries:
- WebSockets by Markus Sattler
- ArduinoJson by Benoit Blanchon

### 4. Run

```bash
flutter run
```

## ESP32 JSON format

The app expects this JSON from the ESP32 every ~500ms:

```json
{ "value": 842, "danger": false }
```

- `value`: ADC reading (0–4095)
- `danger`: true when value exceeds threshold

## Thresholds

| Level   | Default | Color  |
|---------|---------|--------|
| Safe    | < 1500  | Green  |
| Warning | 1500+   | Amber  |
| Danger  | 2000+   | Red    |

Both thresholds are configurable from the Settings screen and saved locally.

## Features

- Live WebSocket connection with auto-reconnect
- Animated status card (safe / warning / danger)
- Real-time bar chart (last 60 readings)
- Level meter with threshold markers
- Full reading history log
- Alert event log with timestamps
- Configurable thresholds, IP, port
- Sound, vibration, push notification toggles
- Keep screen on option
- Dark theme throughout
