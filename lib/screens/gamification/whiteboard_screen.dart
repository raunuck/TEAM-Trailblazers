import 'package:flutter/material.dart';
import 'package:google_mlkit_digital_ink_recognition/google_mlkit_digital_ink_recognition.dart' as ml_kit;
import '../../core/theme.dart';
import '../../services/whiteboard_service.dart';

class WhiteboardScreen extends StatefulWidget {
  const WhiteboardScreen({super.key});

  @override
  State<WhiteboardScreen> createState() => _WhiteboardScreenState();
}

class _WhiteboardScreenState extends State<WhiteboardScreen> {
  final WhiteboardService _service = WhiteboardService();
  final List<DrawingStroke> _strokes = [];
  DrawingStroke? _currentStroke;
  
  String _modelStatus = "Checking AI..."; 
  String _recognizedText = "Draw here...";
  
  @override
  void initState() {
    super.initState();
    _initModel();
  }

  Future<void> _initModel() async {
    final status = await _service.checkModelStatus();
    if (mounted) {
      setState(() => _modelStatus = status);
    }
  }

  @override
  void dispose() {
    _service.dispose();
    super.dispose();
  }

  // DRAWING LOGIC
  void _startStroke(DragStartDetails details) {
    final point = DrawPoint(details.localPosition, DateTime.now().millisecondsSinceEpoch);
    setState(() {
      _currentStroke = DrawingStroke([point]);
      _strokes.add(_currentStroke!);
    });
  }

  void _updateStroke(DragUpdateDetails details) {
    final point = DrawPoint(details.localPosition, DateTime.now().millisecondsSinceEpoch);
    setState(() {
      _currentStroke!.points.add(point);
    });
  }

  void _endStroke(DragEndDetails details) {
    _currentStroke = null;
    _performRecognition(); 
  }

  void _clearCanvas() {
    setState(() {
      _strokes.clear();
      _recognizedText = "Draw here...";
    });
  }

  Future<void> _performRecognition() async {
    if (_strokes.isEmpty) return;

    // Convert to ML Kit format
    List<ml_kit.Stroke> mlStrokes = [];
    
    for (var stroke in _strokes) {
      final mlStroke = ml_kit.Stroke();
      for (var p in stroke.points) {
        final mlPoint = ml_kit.StrokePoint(
          x: p.offset.dx, 
          y: p.offset.dy, 
          t: p.timestamp
        );
        mlStroke.points.add(mlPoint);
      }
      mlStrokes.add(mlStroke);
    }

    final result = await _service.recognizeText(mlStrokes);
    
    if (mounted) {
      setState(() {
        // If result is empty, keep "..."
        _recognizedText = result.isEmpty ? "..." : result;
      });
    }
  }

  void _useTextAsTask() {
    if (_recognizedText.isEmpty || _recognizedText == "Draw here..." || _recognizedText == "...") {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Please write something clear first!"))
        );
        return;
    }
    Navigator.pop(context, _recognizedText);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final canvasColor = isDark ? Colors.black : Colors.grey.shade50;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: const Text("Smart Whiteboard"),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.red), 
            onPressed: _clearCanvas
          )
        ],
      ),
      body: Column(
        children: [
          // 1. MODEL STATUS BAR
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 4),
            color: _modelStatus == "Ready" ? Colors.green.withOpacity(0.2) : Colors.orange.withOpacity(0.2),
            child: Text(
              "AI Status: $_modelStatus", 
              textAlign: TextAlign.center, 
              style: TextStyle(
                color: _modelStatus == "Ready" ? Colors.green : Colors.orange, 
                fontWeight: FontWeight.bold,
                fontSize: 12
              )
            ),
          ),

          // 2. CANVAS
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: canvasColor,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: GestureDetector(
                  onPanStart: _startStroke,
                  onPanUpdate: _updateStroke,
                  onPanEnd: _endStroke,
                  child: CustomPaint(
                    painter: WhiteboardPainter(_strokes, isDark ? Colors.white : Colors.black),
                    size: Size.infinite,
                  ),
                ),
              ),
            ),
          ),

          // 3. RECOGNITION BOX
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF2C2C2C) : Colors.white,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              // --- CRITICAL FIX IS HERE ---
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1), 
                  blurRadius: 10, // Must be positive!
                  offset: const Offset(0, -4)
                )
              ],
              // ----------------------------
            ),
            child: Column(
              children: [
                Text(
                  _recognizedText,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24, 
                    fontWeight: FontWeight.bold,
                    color: _recognizedText == "..." ? Colors.grey : AppTheme.primaryBlue,
                    fontFamily: 'Courier'
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _useTextAsTask,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryBlue, 
                      foregroundColor: Colors.white
                    ),
                    child: const Text("Create Task"),
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}

class WhiteboardPainter extends CustomPainter {
  final List<DrawingStroke> strokes;
  final Color strokeColor;
  WhiteboardPainter(this.strokes, this.strokeColor);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = strokeColor
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 4.0
      ..style = PaintingStyle.stroke;

    for (final stroke in strokes) {
      if (stroke.points.isEmpty) continue;
      final path = Path();
      path.moveTo(stroke.points.first.offset.dx, stroke.points.first.offset.dy);
      for (int i = 1; i < stroke.points.length; i++) {
        path.lineTo(stroke.points[i].offset.dx, stroke.points[i].offset.dy);
      }
      canvas.drawPath(path, paint);
    }
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}