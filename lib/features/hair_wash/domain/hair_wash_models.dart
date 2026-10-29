import '../../../core/date_utils.dart';

class HairWashSettings {
  const HairWashSettings({
    required this.widgetTitle,
    required this.washIntervalDays,
    required this.lastWashDate,
  });

  final String widgetTitle;
  final int washIntervalDays;
  final DateTime? lastWashDate;

  factory HairWashSettings.defaults() {
    return const HairWashSettings(
      widgetTitle: 'HEAD.WASH',
      washIntervalDays: 3,
      lastWashDate: null,
    );
  }

  HairWashSettings copyWith({
    String? widgetTitle,
    int? washIntervalDays,
    DateTime? lastWashDate,
  }) {
    return HairWashSettings(
      widgetTitle: widgetTitle ?? this.widgetTitle,
      washIntervalDays: washIntervalDays ?? this.washIntervalDays,
      lastWashDate: lastWashDate ?? this.lastWashDate,
    );
  }
}

enum HairWashStatusKind { unknown, dueToday, dueTomorrow, upcoming, overdue }

class HairWashStatus {
  const HairWashStatus({
    required this.kind,
    required this.message,
    required this.nextWashDate,
    required this.daysDelta,
  });

  final HairWashStatusKind kind;
  final String message;
  final DateTime? nextWashDate;
  final int? daysDelta;
}

HairWashStatus buildHairWashStatus(HairWashSettings settings, DateTime now) {
  final lastWashDate = settings.lastWashDate;
  if (lastWashDate == null) {
    return const HairWashStatus(
      kind: HairWashStatusKind.unknown,
      message: 'set last wash date',
      nextWashDate: null,
      daysDelta: null,
    );
  }

  final today = dateOnly(now);
  final nextWashDate = dateOnly(
    lastWashDate,
  ).add(Duration(days: settings.washIntervalDays));
  final daysDelta = nextWashDate.difference(today).inDays;

  if (daysDelta == 0) {
    return HairWashStatus(
      kind: HairWashStatusKind.dueToday,
      message: 'wash today',
      nextWashDate: nextWashDate,
      daysDelta: daysDelta,
    );
  }

  if (daysDelta == 1) {
    return HairWashStatus(
      kind: HairWashStatusKind.dueTomorrow,
      message: 'wash tomorrow',
      nextWashDate: nextWashDate,
      daysDelta: daysDelta,
    );
  }

  if (daysDelta > 1) {
    return HairWashStatus(
      kind: HairWashStatusKind.upcoming,
      message: 'wash in $daysDelta day(s)',
      nextWashDate: nextWashDate,
      daysDelta: daysDelta,
    );
  }

  final overdueDays = daysDelta.abs();
  return HairWashStatus(
    kind: HairWashStatusKind.overdue,
    message: 'late by $overdueDays day(s)',
    nextWashDate: nextWashDate,
    daysDelta: daysDelta,
  );
}
