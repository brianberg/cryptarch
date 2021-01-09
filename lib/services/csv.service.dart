import "dart:convert";
import "dart:io";

import "package:csv/csv.dart";
import "package:intl/intl.dart";

class CsvService {
  static const TS_FORMAT = "yyyy-dd-MMTHH:mm:ss";

  static Future<File> export(
    String filepath,
    List<List<dynamic>> rows, {
    bool appendTimestamp = false,
  }) async {
    if (filepath.endsWith(".csv")) {
      filepath = filepath.substring(0, filepath.length - 4);
    }
    if (appendTimestamp) {
      String ts = DateFormat(CsvService.TS_FORMAT).format(DateTime.now());
      filepath += "${filepath}_$ts.csv";
    } else {
      filepath += "$filepath.csv";
    }
    final contents = const ListToCsvConverter().convert(rows);
    final file = File(filepath);
    return file.writeAsString(contents);
  }

  static Future<List<List<dynamic>>> import(String filepath) async {
    final stream = File(filepath).openRead();
    final rows = await stream
        .transform(utf8.decoder)
        .transform(CsvToListConverter())
        .toList();
    return rows;
  }
}
