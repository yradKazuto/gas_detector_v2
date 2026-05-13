import 'package:flutter/material.dart';
import '../theme.dart';
import '../models/gas_reading.dart';

class StatusCard extends StatelessWidget {
  final GasReading? reading;
  const StatusCard({super.key, this.reading});

  @override
  Widget build(BuildContext context) {
    final status = reading?.status ?? GasStatus.safe;
    final value = reading?.value ?? 0;

    Color bg, border, iconBg, textColor;
    IconData icon;
    String label, sub;

    switch (status) {
      case GasStatus.danger:
        bg = AppColors.dangerBackground;
        border = AppColors.dangerBorder;
        iconBg = const Color(0xFF3D0F0F);
        textColor = AppColors.danger;
        icon = Icons.warning_rounded;
        label = 'Gas detected!';
        sub = 'Value $value — exceeds danger threshold';
        break;
      case GasStatus.warning:
        bg = AppColors.warningBackground;
        border = AppColors.warningBorder;
        iconBg = const Color(0xFF3D2E0A);
        textColor = AppColors.warning;
        icon = Icons.warning_amber_rounded;
        label = 'Warning';
        sub = 'Value $value — rising, approaching danger';
        break;
      case GasStatus.safe:
        bg = AppColors.safeBackground;
        border = AppColors.safeBorder;
        iconBg = const Color(0xFF0F3D1F);
        textColor = AppColors.safe;
        icon = Icons.check_circle_rounded;
        label = 'Air is safe';
        sub = reading == null ? 'Waiting for sensor data...' : 'All readings within normal range';
        break;
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: border, width: 0.5),
      ),
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
      child: Column(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 400),
            width: 72,
            height: 72,
            decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
            child: Icon(icon, color: textColor, size: 34),
          ),
          const SizedBox(height: 12),
          AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 300),
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600, color: textColor),
            child: Text(label),
          ),
          const SizedBox(height: 4),
          Text(sub, style: const TextStyle(fontSize: 13, color: AppColors.textMuted)),
        ],
      ),
    );
  }
}

class ReadingChip extends StatelessWidget {
  final String label;
  final String value;
  final String unit;
  final Color? valueColor;

  const ReadingChip({
    super.key,
    required this.label,
    required this.value,
    required this.unit,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border, width: 0.5),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
            const SizedBox(height: 4),
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: value,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                      color: valueColor ?? AppColors.textPrimary,
                    ),
                  ),
                  TextSpan(
                    text: ' $unit',
                    style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ConnectionBadge extends StatelessWidget {
  final bool connected;
  final String ipAddress;
  final int port;

  const ConnectionBadge({
    super.key,
    required this.connected,
    required this.ipAddress,
    required this.port,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 400),
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: connected ? AppColors.safe : AppColors.textMuted,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  connected ? 'ESP32 connected' : 'Connecting…',
                  style: const TextStyle(fontSize: 13, color: AppColors.textPrimary),
                ),
                Text(
                  '$ipAddress · ws:$port',
                  style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                ),
              ],
            ),
          ),
          if (connected)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.safeBackground,
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text(
                'Live',
                style: TextStyle(fontSize: 11, color: AppColors.safe),
              ),
            )
          else
            const SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(
                strokeWidth: 1.5,
                color: AppColors.textMuted,
              ),
            ),
        ],
      ),
    );
  }
}

class SectionCard extends StatelessWidget {
  final Widget child;
  const SectionCard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      padding: const EdgeInsets.all(14),
      child: child,
    );
  }
}

class AlertDot extends StatelessWidget {
  final GasStatus status;
  const AlertDot({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (status) {
      case GasStatus.danger:
        color = AppColors.danger;
        break;
      case GasStatus.warning:
        color = AppColors.warning;
        break;
      case GasStatus.safe:
        color = AppColors.safe;
        break;
    }
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}

class SettingRow extends StatelessWidget {
  final String label;
  final String? subtitle;
  final Widget trailing;

  const SettingRow({
    super.key,
    required this.label,
    this.subtitle,
    required this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 14, color: AppColors.textPrimary)),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(subtitle!, style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
                ],
              ],
            ),
          ),
          trailing,
        ],
      ),
    );
  }
}
