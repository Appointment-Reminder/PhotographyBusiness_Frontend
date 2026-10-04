import 'package:equatable/equatable.dart';

enum TimeframePreset {
  thisMonth('This month'),
  lastMonth('Last month'),
  last30Days('Last 30 days'),
  thisYear('This year'),
  custom('Custom');

  final String label;
  const TimeframePreset(this.label);
}

/// How the overview's income series is grouped.
enum OverviewBucket { day, week, month }

DateTime _dateOnly(DateTime d) => DateTime.utc(d.year, d.month, d.day);

/// A range of whole days, both ends inclusive, and the preset it came from.
class Timeframe extends Equatable {
  final DateTime start;
  final DateTime end;
  final TimeframePreset preset;

  Timeframe({required DateTime start, required DateTime end, required this.preset})
      : start = _dateOnly(start),
        end = _dateOnly(end);

  /// Resolves a non-custom [preset] against [today].
  factory Timeframe.preset(TimeframePreset preset, {required DateTime today}) {
    final t = _dateOnly(today);
    switch (preset) {
      case TimeframePreset.thisMonth:
        return Timeframe(
            start: DateTime(t.year, t.month, 1), end: DateTime(t.year, t.month + 1, 0), preset: preset);
      case TimeframePreset.lastMonth:
        return Timeframe(
            start: DateTime(t.year, t.month - 1, 1), end: DateTime(t.year, t.month, 0), preset: preset);
      case TimeframePreset.last30Days:
        return Timeframe(start: DateTime(t.year, t.month, t.day - 29), end: t, preset: preset);
      case TimeframePreset.thisYear:
        return Timeframe(start: DateTime(t.year, 1, 1), end: DateTime(t.year, 12, 31), preset: preset);
      case TimeframePreset.custom:
        throw ArgumentError('Custom needs explicit dates: use Timeframe.custom');
    }
  }

  /// Future dates are allowed.
  factory Timeframe.custom(DateTime start, DateTime end) =>
      Timeframe(start: start, end: end, preset: TimeframePreset.custom);

  int get days => end.difference(start).inDays + 1;

  /// Up to 31 days groups by day, up to about 120 by week, longer by month.
  OverviewBucket get bucket => days <= 31
      ? OverviewBucket.day
      : days <= 120
          ? OverviewBucket.week
          : OverviewBucket.month;

  @override
  List<Object?> get props => [start, end, preset];
}
