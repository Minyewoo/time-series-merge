import 'dart:collection';
import 'dart:convert';
import 'dart:io';

import 'package:csv/csv.dart';
import 'package:time_series_merge/timed_row.dart';
import 'package:time_series_merge/timed_value.dart';
///
class TimedValues {
  final List<TimedValue> _timeValues;
  ///
  const TimedValues({required List<TimedValue> timeValues}) : _timeValues = timeValues;
  static Future<TimedValues> fromCsvFiles(List<File> csvFiles, CsvToListConverter converter) async {
    final filesContent = await Future.wait(
      csvFiles.map((csvFile) => csvFile
        .openRead()
        .transform(utf8.decoder)
        .transform(converter)
        .toList(),
      ).toList(),
    );
    return TimedValues(
      timeValues: filesContent.indexed
        .map((item) {
          final index  = item.$1;
          final fileContent = item.$2;
          final valueName = csvFiles[index].uri.pathSegments.last.replaceAll('.csv', '');
          return fileContent.skip(1).map(
            (row) => TimedValue.fromRow(
              row.map((entry) => entry.toString()).toList(),
              valueName,
            ),
          );
        })
        .expand((values) => values)
        .toList(),
    );
  }
  ///
  List<TimedRow> merged() {
    _timeValues.sort(
      (a, b) => a.timestamp.compareTo(b.timestamp),
    );
    final mergedRows = <TimedRow>[];
    for(int i = 0; i<_timeValues.length; i++) {
      final changedAttribute = _timeValues[i];
      final row = SplayTreeMap<String, double>();
      if(mergedRows.isNotEmpty) {
        row.addAll(mergedRows[i-1].attributes);
      }
      row[changedAttribute.name] = changedAttribute.value;
      mergedRows.add(
        TimedRow(
          timestamp: changedAttribute.timestamp / 1000,
          attributes: row,
        ),
      );
    }
    // Adding missing keys to first rows
    final maxRowLength = mergedRows.last.attributes.length;
    final maxRowKeys = mergedRows.last.attributes.keys.toList();
    for(int i = 0; i<mergedRows.length; i++) {
      final row = mergedRows[i];
      final rowLength = row.attributes.length;
      if(rowLength < maxRowLength) {
        mergedRows[i] = row.copyWith(
          attributes: row.attributes
            ..addAll(
              Map.fromEntries(
                maxRowKeys.sublist(rowLength).map((key) => MapEntry(key, 0.0)),
              ),
            ),
        );
      } else {
        break;
      }
    }
    return mergedRows;
  }
}