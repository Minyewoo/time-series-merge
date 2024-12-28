class TimedValue {
  final int timestamp;
  final double value;
  final String name;
  const TimedValue({required this.timestamp, required this.value, required this.name});
  factory TimedValue.fromRow(List<String> row, String name) {
    if(row.length < 2) {
      throw FormatException('Invalid entry: $row');
    }
    final timestamp = int.tryParse(row[0]);
    final value = double.tryParse(row[1]);
    if(timestamp == null || value == null) {
      throw FormatException('Invalid entry. Row: $row (timestamp: ${row[0]}, value: ${row[1]})');
    }
    return TimedValue(timestamp: timestamp, value: value, name: name);
  }
}