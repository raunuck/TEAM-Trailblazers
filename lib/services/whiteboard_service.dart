import 'package:google_mlkit_digital_ink_recognition/google_mlkit_digital_ink_recognition.dart' as ml_kit;
import 'package:flutter/material.dart';

class WhiteboardService {
  // Use 'en-US' for English. 
  final String _languageCode = 'en-US';
  late ml_kit.DigitalInkRecognizer _recognizer;
  final ml_kit.DigitalInkRecognizerModelManager _modelManager = ml_kit.DigitalInkRecognizerModelManager();

  WhiteboardService() {
    _recognizer = ml_kit.DigitalInkRecognizer(languageCode: _languageCode);
  }

  // 1. Check and Download the AI Model
  Future<String> checkModelStatus() async {
    try {
      final isDownloaded = await _modelManager.isModelDownloaded(_languageCode);
      if (isDownloaded) return "Ready";
      
      debugPrint("Downloading Ink Model ($_languageCode)...");
      final isSuccess = await _modelManager.downloadModel(_languageCode);
      return isSuccess ? "Ready" : "Download Failed";
    } catch (e) {
      return "Error: $e";
    }
  }

  // 2. Recognize Handwriting
  Future<String> recognizeText(List<ml_kit.Stroke> strokes) async {
    try {
      if (strokes.isEmpty) return "";

      // Create Ink object
      final ink = ml_kit.Ink();
      ink.strokes.addAll(strokes);

      // Recognize
      final candidates = await _recognizer.recognize(ink);
      
      if (candidates.isNotEmpty) {
        String result = candidates.first.text;
        debugPrint("Recognized: $result"); // Debug log
        return result;
      }
      return "";
    } catch (e) {
      debugPrint("Recognition Error: $e");
      return "Error";
    }
  }

  void dispose() {
    _recognizer.close();
  }
}

// Helper Classes
class DrawPoint {
  final Offset offset;
  final int timestamp;
  DrawPoint(this.offset, this.timestamp);
}

class DrawingStroke {
  final List<DrawPoint> points;
  DrawingStroke(this.points);
}
