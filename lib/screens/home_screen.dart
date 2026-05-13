import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/websocket_service.dart';
import '../models/gas_reading.dart';
import '../theme.dart';
import '../widgets/common_widgets.dart';
import '../widgets/gas_chart.dart';
import '../models/settings.dart';

class HomeScreen extends StatelessWidget {
  final AppSettings settings;
  const HomeScreen({super.key, required this.settings});

  @override
  Widget build(BuildContext context) {
    return Consumer<WebSocketService>(
      builder: (context, ws, _) {
        final reading = ws.latestReading;
        final isConnected = ws.isConnected;

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            title: const Text('Gas detector'),
            actions: [
              IconButton(
                icon: Icon(
                  isConnected ? Icons.wifi : Icons.wifi_off,
                  color: isConnected ? AppColors.safe : AppColors.textMuted,
                ),
                onPressed: () {
                  if (isConnected) {
                    ws.disconnect();
                  } else {
                    ws.connect();
                  }
                },
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ConnectionBadge(
                  connected: isConnected,
                  ipAddress: settings.ipAddress,
                  port: settings.port,
                ),
                const SizedBox(height: 14),

                StatusCard(reading: reading),
                const SizedBox(height: 14),

                // Reading chips row
                Row(
                  children: [
                    ReadingChip(
                      label: 'Gas level',
                      value: reading?.value.toString() ?? '--',
                      unit: '/ ${AppConstants.maxAdcValue}',
                      valueColor: reading == null
                          ? null
                          : reading.status == GasStatus.danger
                              ? AppColors.danger
                              : reading.status == GasStatus.warning
                                  ? AppColors.warning
                                  : null,
                    ),
                    const SizedBox(width: 8),
                    ReadingChip(
                      label: 'Threshold',
                      value: settings.dangerThreshold.toString(),
                      unit: 'limit',
                    ),
                    const SizedBox(width: 8),
                    ReadingChip(
                      label: 'Updates',
                      value: (settings.intervalMs / 1000).toStringAsFixed(1),
                      unit: 's',
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Chart
                SectionCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Live readings',
                            style: TextStyle(fontSize: 13, color: AppColors.textMuted),
                          ),
                          Text(
                            '${ws.history.length} points',
                            style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      GasBarChart(
                        readings: ws.history,
                        dangerThreshold: settings.dangerThreshold,
                        warningThreshold: settings.warningThreshold,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                // Gauge row
                _GaugeMeter(
                  value: reading?.value ?? 0,
                  max: AppConstants.maxAdcValue,
                  warningThreshold: settings.warningThreshold,
                  dangerThreshold: settings.dangerThreshold,
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _GaugeMeter extends StatelessWidget {
  final int value;
  final int max;
  final int warningThreshold;
  final int dangerThreshold;

  const _GaugeMeter({
    required this.value,
    required this.max,
    required this.warningThreshold,
    required this.dangerThreshold,
  });

  @override
  Widget build(BuildContext context) {
    final pct = (value / max).clamp(0.0, 1.0);
    final warnPct = warningThreshold / max;
    final dangerPct = dangerThreshold / max;

    Color fillColor;
    if (value >= dangerThreshold) {
      fillColor = AppColors.danger;
    } else if (value >= warningThreshold) {
      fillColor = AppColors.warning;
    } else {
      fillColor = AppColors.safe;
    }

    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Level meter', style: TextStyle(fontSize: 13, color: AppColors.textMuted)),
          const SizedBox(height: 12),
          Stack(
            children: [
              // Track
              Container(
                height: 12,
                decoration: BoxDecoration(
                  color: AppColors.surfaceAlt,
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              // Fill
              AnimatedFractionallySizedBox(
                duration: const Duration(milliseconds: 300),
                widthFactor: pct,
                child: Container(
                  height: 12,
                  decoration: BoxDecoration(
                    color: fillColor,
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ),
              // Warning marker
              FractionallySizedBox(
                widthFactor: warnPct,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Container(width: 1.5, height: 12, color: AppColors.warning.withValues(alpha: 0.5)),
                ),
              ),
              // Danger marker
              FractionallySizedBox(
                widthFactor: dangerPct,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Container(width: 1.5, height: 12, color: AppColors.danger.withValues(alpha: 0.5)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('0', style: const TextStyle(fontSize: 10, color: AppColors.textMuted)),
              Text(
                'warn $warningThreshold',
                style: const TextStyle(fontSize: 10, color: AppColors.warning),
              ),
              Text(
                'danger $dangerThreshold',
                style: const TextStyle(fontSize: 10, color: AppColors.danger),
              ),
              Text('$max', style: const TextStyle(fontSize: 10, color: AppColors.textMuted)),
            ],
          ),
        ],
      ),
    );
  }
}
