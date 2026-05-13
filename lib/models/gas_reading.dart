enum GasStatus { safe, warning, danger }

class GasReading {
  final int value;
  final bool danger;
  final DateTime timestamp;
  final GasStatus status;

  GasReading({
    required this.value,
    required this.danger,
    required this.timestamp,
    required this.status,
  });

  factory GasReading.fromJson(
    Map<String, dynamic> json, {
    int warningThreshold = 1500,
    int dangerThreshold = 2000,
  }) {
    final value = (json['value'] as num).toInt();
    GasStatus status;
    if (value >= dangerThreshold) {
      status = GasStatus.danger;
    } else if (value >= warningThreshold) {
      status = GasStatus.warning;
    } else {
      status = GasStatus.safe;
    }
    return GasReading(
      value: value,
      danger: json['danger'] as bool? ?? value >= dangerThreshold,
      timestamp: DateTime.now(),
      status: status,
    );
  }

  String get statusLabel {
    switch (status) {
      case GasStatus.safe:
        return 'Safe';
      case GasStatus.warning:
        return 'Warning';
      case GasStatus.danger:
        return 'Danger';
    }
  }
}

class GasAlert {
  final GasStatus status;
  final int value;
  final DateTime timestamp;
  final String message;

  GasAlert({
    required this.status,
    required this.value,
    required this.timestamp,
    required this.message,
  });
}
