import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/gas_reading.dart';
import '../theme.dart';

class GasBarChart extends StatelessWidget {
  final List<GasReading> readings;
  final int dangerThreshold;
  final int warningThreshold;

  const GasBarChart({
    super.key,
    required this.readings,
    required this.dangerThreshold,
    required this.warningThreshold,
  });

  Color _barColor(GasReading r) {
    switch (r.status) {
      case GasStatus.danger:
        return AppColors.danger.withValues(alpha: 0.7);
      case GasStatus.warning:
        return AppColors.warning.withValues(alpha: 0.7);
      case GasStatus.safe:
        return AppColors.safe.withValues(alpha: 0.4);
    }
  }

  @override
  Widget build(BuildContext context) {
    final last = readings.length > 20 ? readings.sublist(readings.length - 20) : readings;

    if (last.isEmpty) {
      return const SizedBox(
        height: 100,
        child: Center(
          child: Text('Waiting for data…', style: TextStyle(color: AppColors.textMuted, fontSize: 13)),
        ),
      );
    }

    return SizedBox(
      height: 110,
      child: BarChart(
        BarChartData(
          maxY: AppConstants.maxAdcValue.toDouble(),
          minY: 0,
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: dangerThreshold.toDouble(),
            getDrawingHorizontalLine: (_) => FlLine(
              color: AppColors.dangerBorder,
              strokeWidth: 0.5,
              dashArray: [4, 4],
            ),
          ),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 18,
                interval: 5,
                getTitlesWidget: (value, _) {
                  final idx = value.toInt();
                  if (idx % 5 != 0) return const SizedBox.shrink();
                  final secsAgo = (last.length - 1 - idx) ~/ 2;
                  return Text(
                    secsAgo == 0 ? 'now' : '-${secsAgo}s',
                    style: const TextStyle(fontSize: 9, color: AppColors.textMuted),
                  );
                },
              ),
            ),
          ),
          barGroups: List.generate(last.length, (i) {
            final r = last[i];
            return BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(
                  toY: r.value.toDouble(),
                  color: _barColor(r),
                  width: 8,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(3)),
                ),
              ],
            );
          }),
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              tooltipBgColor: AppColors.surfaceAlt,
              getTooltipItem: (group, _, rod, __) {
                return BarTooltipItem(
                  rod.toY.toInt().toString(),
                  const TextStyle(color: AppColors.textPrimary, fontSize: 12),
                );
              },
            ),
          ),
        ),
        swapAnimationDuration: const Duration(milliseconds: 200),
      ),
    );
  }
}
