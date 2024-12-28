import 'dart:collection';
///
class TimedRow {
  final double _timestamp;
  final SplayTreeMap<String, double> attributes;
  ///
  const TimedRow({required double timestamp, required this.attributes}) : _timestamp = timestamp;
  ///
  List<double> toTableTow() => [ _timestamp, ...attributes.values];
  ///
  List<String> headers() => [ 'Timestamp, s', ...attributes.keys];
  ///
  TimedRow copyWith({
    double? timestamp,
    SplayTreeMap<String, double>? attributes,
  }) => TimedRow(
    timestamp: timestamp ?? _timestamp,
    attributes: attributes ?? this.attributes,
  );
}