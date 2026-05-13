import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/settings.dart';
import '../theme.dart';
import '../widgets/common_widgets.dart';

class SettingsScreen extends StatefulWidget {
  final AppSettings settings;
  final ValueChanged<AppSettings> onChanged;

  const SettingsScreen({super.key, required this.settings, required this.onChanged});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late AppSettings _s;

  @override
  void initState() {
    super.initState();
    _s = widget.settings;
  }

  void _update(VoidCallback fn) {
    setState(fn);
    _s.save();
    widget.onChanged(_s);
  }

  void _editText(String title, String initial, ValueChanged<String> onSave) {
    final ctrl = TextEditingController(text: initial);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text(title, style: const TextStyle(color: AppColors.textPrimary, fontSize: 16)),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          style: const TextStyle(color: AppColors.textPrimary),
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.surfaceAlt,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.border, width: 0.5),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.border, width: 0.5),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textMuted)),
          ),
          TextButton(
            onPressed: () {
              onSave(ctrl.text.trim());
              Navigator.pop(context);
            },
            child: const Text('Save', style: TextStyle(color: AppColors.safe)),
          ),
        ],
      ),
    );
  }

  void _editInt(String title, int initial, int min, int max, ValueChanged<int> onSave) {
    final ctrl = TextEditingController(text: initial.toString());
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text(title, style: const TextStyle(color: AppColors.textPrimary, fontSize: 16)),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          style: const TextStyle(color: AppColors.textPrimary),
          decoration: InputDecoration(
            helperText: 'Range: $min – $max',
            helperStyle: const TextStyle(color: AppColors.textMuted),
            filled: true,
            fillColor: AppColors.surfaceAlt,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.border, width: 0.5),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.border, width: 0.5),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textMuted)),
          ),
          TextButton(
            onPressed: () {
              final v = int.tryParse(ctrl.text) ?? initial;
              onSave(v.clamp(min, max));
              Navigator.pop(context);
            },
            child: const Text('Save', style: TextStyle(color: AppColors.safe)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _sectionLabel('Connection'),
          const SizedBox(height: 6),
          GestureDetector(
            onTap: () => _editText('ESP32 IP address', _s.ipAddress, (v) => _update(() => _s.ipAddress = v)),
            child: SettingRow(
              label: 'IP address',
              subtitle: 'WebSocket host',
              trailing: _valueText(_s.ipAddress),
            ),
          ),
          const SizedBox(height: 6),
          GestureDetector(
            onTap: () => _editInt('Port', _s.port, 1, 65535, (v) => _update(() => _s.port = v)),
            child: SettingRow(
              label: 'Port',
              trailing: _valueText(_s.port.toString()),
            ),
          ),
          const SizedBox(height: 20),

          _sectionLabel('Thresholds'),
          const SizedBox(height: 6),
          GestureDetector(
            onTap: () => _editInt(
              'Warning level',
              _s.warningThreshold,
              0,
              AppConstants.maxAdcValue,
              (v) => _update(() => _s.warningThreshold = v),
            ),
            child: SettingRow(
              label: 'Warning level',
              subtitle: 'Amber alert trigger',
              trailing: _valueText(_s.warningThreshold.toString(), color: AppColors.warning),
            ),
          ),
          const SizedBox(height: 6),
          GestureDetector(
            onTap: () => _editInt(
              'Danger level',
              _s.dangerThreshold,
              0,
              AppConstants.maxAdcValue,
              (v) => _update(() => _s.dangerThreshold = v),
            ),
            child: SettingRow(
              label: 'Danger level',
              subtitle: 'Red alert + buzzer trigger',
              trailing: _valueText(_s.dangerThreshold.toString(), color: AppColors.danger),
            ),
          ),
          const SizedBox(height: 20),

          _sectionLabel('Notifications'),
          const SizedBox(height: 6),
          SettingRow(
            label: 'Sound alarm',
            trailing: _toggle(_s.soundEnabled, (v) => _update(() => _s.soundEnabled = v)),
          ),
          const SizedBox(height: 6),
          SettingRow(
            label: 'Vibration',
            trailing: _toggle(_s.vibrationEnabled, (v) => _update(() => _s.vibrationEnabled = v)),
          ),
          const SizedBox(height: 6),
          SettingRow(
            label: 'Push notifications',
            trailing: _toggle(_s.pushEnabled, (v) => _update(() => _s.pushEnabled = v)),
          ),
          const SizedBox(height: 20),

          _sectionLabel('Display'),
          const SizedBox(height: 6),
          GestureDetector(
            onTap: () => _editInt(
              'Update interval (ms)',
              _s.intervalMs,
              200,
              5000,
              (v) => _update(() => _s.intervalMs = v),
            ),
            child: SettingRow(
              label: 'Update interval',
              subtitle: 'How often to refresh readings',
              trailing: _valueText('${_s.intervalMs} ms'),
            ),
          ),
          const SizedBox(height: 6),
          SettingRow(
            label: 'Keep screen on',
            trailing: _toggle(_s.keepScreenOn, (v) => _update(() => _s.keepScreenOn = v)),
          ),
          const SizedBox(height: 32),

          // About
          Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border, width: 0.5),
            ),
            padding: const EdgeInsets.all(16),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Gas detector v1.0.0', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                SizedBox(height: 4),
                Text('ESP32 · WebSocket · MQ sensor', style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _sectionLabel(String text) => Padding(
        padding: const EdgeInsets.only(left: 2),
        child: Text(
          text.toUpperCase(),
          style: const TextStyle(fontSize: 11, color: AppColors.textMuted, letterSpacing: 0.5),
        ),
      );

  Widget _valueText(String text, {Color? color}) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            text,
            style: TextStyle(fontSize: 13, color: color ?? AppColors.textMuted),
          ),
          const SizedBox(width: 4),
          const Icon(Icons.chevron_right, size: 16, color: AppColors.textMuted),
        ],
      );

  Widget _toggle(bool value, ValueChanged<bool> onChanged) => GestureDetector(
        onTap: () => onChanged(!value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 44,
          height: 24,
          decoration: BoxDecoration(
            color: value ? AppColors.safe : AppColors.surfaceAlt,
            borderRadius: BorderRadius.circular(12),
          ),
          child: AnimatedAlign(
            duration: const Duration(milliseconds: 200),
            alignment: value ? Alignment.centerRight : Alignment.centerLeft,
            child: Container(
              width: 20,
              height: 20,
              margin: const EdgeInsets.symmetric(horizontal: 2),
              decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
            ),
          ),
        ),
      );
}
