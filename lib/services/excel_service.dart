import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import '../screens/dashboard/home_screen.dart';

class ExcelService {
  
  Future<PlatformFile?> pickExcelFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx'],
    );

    if (result != null) {
      return result.files.single;
    }
    return null;
  }

  Future<List<ScheduleTask>> parseTimetable(PlatformFile pFile) async {
    List<int> bytes;

    try {
      if (kIsWeb) {
        if (pFile.bytes != null) {
          bytes = pFile.bytes!;
        } else {
          throw Exception("Web file bytes are empty.");
        }
      } else {
        if (pFile.path != null) {
          bytes = File(pFile.path!).readAsBytesSync();
        } else {
          throw Exception("File path is missing on mobile.");
        }
      }

      var excel = Excel.decodeBytes(bytes);
      List<ScheduleTask> newTasks = [];
      
      for (var table in excel.tables.keys) {
        var sheet = excel.tables[table];
        if (sheet == null) continue;

        for (int i = 1; i < sheet.maxRows; i++) {
          var row = sheet.rows[i];
          
          if (row.length < 4 || row[0] == null) continue; 

          try {
            String startTime = _getCellValue(row[1]);
            String endTime = _getCellValue(row[2]);
            String subject = _getCellValue(row[3]);
            String location = row.length > 4 ? _getCellValue(row[4]) : "Classroom";

            newTasks.add(ScheduleTask(
              id: DateTime.now().microsecondsSinceEpoch.toString() + i.toString(),
              time: startTime,
              endTime: endTime,
              title: subject,
              location: location,
              status: TaskStatus.scheduled,
            ));
          } catch (e) {
            print("Error parsing row $i: $e");
          }
        }
      }
      return newTasks;

    } catch (e) {
      print("Error reading file: $e");
      return [];
    }
  }

  String _getCellValue(Data? cell) {
    return cell?.value?.toString() ?? "";
  }
}