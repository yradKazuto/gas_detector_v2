import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../services/websocket_service.dart';
import '../models/gas_reading.dart';
import '../theme.dart';
import '../widgets/common_widgets.dart';

class AlertsScreen extends StatelessWidget {
  const AlertsScreen({super.key});

  String _formatTime(DateTime dt) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final day = DateTime(dt.year, dt.month, dt.day);
    final timeStr = DateFormat('HH:mm').format(dt);
    if (day == today) return 'Today at $timeStr';
    if (day == today.subtract(const Duration(days: 1))) return 'Yesterday at $timeStr';
    return DateFormat('MMM d \'at\' HH:mm').format(dt);
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

  Color _statusBg(GasStatus s) {
    switch (s) {
      case GasStatus.danger:
        return AppColors.dangerBackground;
      case GasStatus.warning:
        return AppColors.warningBackground;
      case GasStatus.safe:
        return AppColors.safeBackground;
    }
  }

  Color _statusBorder(GasStatus s) {
    switch (s) {
      case GasStatus.danger:
        return AppColors.dangerBorder;
      case GasStatus.warning:
        return AppColors.warningBorder;
      case GasStatus.safe:
        return AppColors.safeBorder;
    }
  }

  IconData _statusIcon(GasStatus s) {
    switch (s) {
      case GasStatus.danger:
        return Icons.warning_rounded;
      case GasStatus.warning:
        return Icons.warning_amber_rounded;
      case GasStatus.safe:
        return Icons.check_circle_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<WebSocketService>(
      builder: (context, ws, _) {
        final alerts = ws.alerts;
        final active = alerts.isNotEmpty && alerts.first.status != GasStatus.safe
            ? alerts.first
            : null;

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            title: const Text('Alerts'),
            actions: [
              if (alerts.isNotEmpty)
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  color: AppColors.textMuted,
                  onPressed: () => _confirmClear(context, ws),
                ),
            ],
          ),
          body: alerts.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.check_circle_outline, size: 48, color: AppColors.safe),
                      SizedBox(height: 12),
                      Text(
                        'No alerts',
                        style: TextStyle(fontSize: 16, color: AppColors.textPrimary),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Everything is within safe range.',
                        style: TextStyle(fontSize: 13, color: AppColors.textMuted),
                      ),
                    ],
                  ),
                )
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    // Active alert banner
                    if (active != null) ...[
                      Container(
                        decoration: BoxDecoration(
                          color: _statusBg(active.status),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: _statusBorder(active.status), width: 0.5),
                        ),
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(_statusIcon(active.status), color: _statusColor(active.status), size: 24),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    active.message,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: _statusColor(active.status),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _formatTime(active.timestamp),
                                    style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // All alerts list
                    const Text(
                      'All alerts',
                      style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                    ),
                    const SizedBox(height: 8),

                    ...List.generate(alerts.length, (i) {
                      final alert = alerts[i];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.border, width: 0.5),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          child: Row(
                            children: [
                              AlertDot(status: alert.status),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      alert.message,
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: _statusColor(alert.status),
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      _formatTime(alert.timestamp),
                                      style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                alert.value.toString(),
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: _statusColor(alert.status),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ],
                ),
        );
      },
    );
  }

  void _confirmClear(BuildContext context, WebSocketService ws) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Clear alerts?', style: TextStyle(color: AppColors.textPrimary)),
        content: const Text(
          'This will remove all alert history.',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textMuted)),
          ),
          TextButton(
            onPressed: () {
              ws.clearAlerts();
              Navigator.pop(context);
            },
            child: const Text('Clear', style: TextStyle(color: AppColors.danger)),
          ),
        ],
      ),
    );
  }
}
