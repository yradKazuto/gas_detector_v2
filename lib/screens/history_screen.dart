import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../services/websocket_service.dart';
import '../models/gas_reading.dart';
import '../theme.dart';
import '../widgets/common_widgets.dart';
import '../widgets/gas_chart.dart';
import '../models/settings.dart';

class HistoryScreen extends StatelessWidget {
  final AppSettings settings;
  const HistoryScreen({super.key, required this.settings});

  String _formatTime(DateTime dt) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final day = DateTime(dt.year, dt.month, dt.day);
    final timeStr = DateFormat('HH:mm:ss').format(dt);
    if (day == today) return 'Today $timeStr';
    if (day == today.subtract(const Duration(days: 1))) return 'Yesterday $timeStr';
    return DateFormat('MMM d, HH:mm').format(dt);
  }

  Color _statusColor(GasStatus s) {
    switch (s) {
      case GasStatus.danger:
        return AppColors.danger;
      case GasStatus.warning:
        return AppColors.warning;
      case GasStatus.safe:
        return AppColors.safe;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<WebSocketService>(
      builder: (context, ws, _) {
        final reversed = ws.history.reversed.toList();

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            title: const Text('Reading history'),
            actions: [
              if (ws.history.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: TextButton(
                    onPressed: () => _showExportDialog(context, ws.history),
                    child: const Text('Export', style: TextStyle(color: AppColors.textSecondary)),
                  ),
                ),
            ],
          ),
          body: ws.history.isEmpty
              ? const Center(
                  child: Text(
                    'No readings yet.\nConnect to your ESP32 to start.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.textMuted, fontSize: 14),
                  ),
                )
              : Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                      child: SectionCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('All readings', style: TextStyle(fontSize: 13, color: AppColors.textMuted)),
                            const SizedBox(height: 10),
                            GasBarChart(
                              readings: ws.history,
                              dangerThreshold: settings.dangerThreshold,
                              warningThreshold: settings.warningThreshold,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          Text(
                            '${ws.history.length} readings',
                            style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                          ),
                          const Spacer(),
                          _LegendDot(color: AppColors.safe, label: 'Safe'),
                          const SizedBox(width: 12),
                          _LegendDot(color: AppColors.warning, label: 'Warning'),
                          const SizedBox(width: 12),
                          _LegendDot(color: AppColors.danger, label: 'Danger'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                        itemCount: reversed.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 6),
                        itemBuilder: (context, i) {
                          final r = reversed[i];
                          return Container(
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.border, width: 0.5),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            child: Row(
                              children: [
                                AlertDot(status: r.status),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        r.statusLabel,
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: _statusColor(r.status),
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      Text(
                                        _formatTime(r.timestamp),
                                        style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  r.value.toString(),
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: _statusColor(r.status),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
        );
      },
    );
  }

  void _showExportDialog(BuildContext context, List<GasReading> readings) {
    final csv = StringBuffer('timestamp,value,status\n');
    for (final r in readings) {
      csv.writeln('${r.timestamp.toIso8601String()},${r.value},${r.statusLabel}');
    }
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Export data', style: TextStyle(color: AppColors.textPrimary)),
        content: Text(
          '${readings.length} readings ready to export.',
          style: const TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close', style: TextStyle(color: AppColors.textMuted)),
          ),
        ],
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 7, height: 7, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 10, color: AppColors.textMuted)),
      ],
    );
  }
}
