import 'dart:io';

import 'package:args/args.dart';
import 'package:csv/csv.dart';
import 'package:time_series_merge/csv_timed_values.dart';
import 'package:time_series_merge/timed_values.dart';

ArgParser buildParser() {
  return ArgParser()
    ..addFlag(
      'help',
      abbr: 'h',
      negatable: false,
      help: 'Print this usage information.',
    )
    ..addOption(
      'output',
      abbr: 'o',
      defaultsTo: 'output.csv'
    );
}

void printUsage(ArgParser argParser) {
  print('Usage: time_series_merge [-o <outputFile>] <csvFile1>, <csvFile2>, ...');
  print(argParser.usage);
}

Future<void> main(List<String> arguments) async {
  final ArgParser argParser = buildParser();
  try {
    final ArgResults results = argParser.parse(arguments);
    if (results.wasParsed('help')) {
      printUsage(argParser);
      return;
    }
    final outputPath = results.option('output')!;
    final inputPaths = results.rest;
    if(inputPaths.length < 2) {
      print('Please, provide 2 or more files');
      return;
    }
    for(final filePath in inputPaths) {
      if(!File(filePath).existsSync()) {
        print("File '$filePath' does not exist");
        return;
      }
    }
    const fieldDelimiter = ';';
    const eol = '\r\n';
    await CsvTimedValues(
      file: File(outputPath),
      converter: const ListToCsvConverter(
        fieldDelimiter: fieldDelimiter,
        eol: eol,
      ),
      timeValues: await TimedValues.fromCsvFiles(
        inputPaths.map((path) => File(path)).toList(),
        CsvToListConverter(
          fieldDelimiter: fieldDelimiter,
          eol: eol,
        )
      ),
    ).save();
  } on FormatException catch (e) {
    print(e.message);
    print('');
    printUsage(argParser);
  }
}
