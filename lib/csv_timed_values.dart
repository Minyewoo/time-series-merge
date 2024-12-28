import 'dart:io';
import 'package:csv/csv.dart';
import 'package:time_series_merge/timed_values.dart';
///
class CsvTimedValues {
  final TimedValues _timeValues;
  final ListToCsvConverter _converter;
  final File _file;
  ///
  const CsvTimedValues({
    required TimedValues timeValues,
    required File file,
    required ListToCsvConverter converter
  }) :
    _file = file,
    _timeValues = timeValues,
    _converter = converter;
  ///
  Future<void> save() async {
    final timeValues = _timeValues.merged();
    await _file.create(recursive: true);
    final ioSink = _file.openWrite();
    ioSink.write(
      _converter.convert(
        [
          timeValues.last.headers(),
          ...timeValues.map((timeValue) => timeValue.toTableTow())
        ],
      ),
    );
    await ioSink.flush();
    await ioSink.close();
  }
}