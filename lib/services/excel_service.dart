import 'dart:io';
import 'package:flutter/foundation.dart'; // Needed for kIsWeb
import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import '../screens/dashboard/home_screen.dart'; // To access ScheduleTask

class ExcelService {
  
  // 1. Pick the file (Returns PlatformFile instead of File)
  Future<PlatformFile?> pickExcelFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx'],
      // On Web, this automatically loads the 'bytes' into memory
    );

    if (result != null) {
      return result.files.single;
    }
    return null;
  }

  // 2. Parse the file
  Future<List<ScheduleTask>> parseTimetable(PlatformFile pFile) async {
    List<int> bytes;

    try {
      // --- CROSS-PLATFORM CHECK ---
      if (kIsWeb) {
        // On Web: The browser gives us the bytes directly. Path is null.
        if (pFile.bytes != null) {
          bytes = pFile.bytes!;
        } else {
          throw Exception("Web file bytes are empty.");
        }
      } else {
        // On Mobile/Desktop: We use the path to read the file.
        if (pFile.path != null) {
          bytes = File(pFile.path!).readAsBytesSync();
        } else {
          throw Exception("File path is missing on mobile.");
        }
      }

      // --- DECODE EXCEL ---
      var excel = Excel.decodeBytes(bytes);
      List<ScheduleTask> newTasks = [];
      
      for (var table in excel.tables.keys) {
        var sheet = excel.tables[table];
        if (sheet == null) continue;

        // Start from row 1 to skip Headers
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