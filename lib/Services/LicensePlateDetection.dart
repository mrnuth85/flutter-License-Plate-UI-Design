import 'dart:io';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image/image.dart' as img;
import 'dart:ui' as ui;
import 'package:path_provider/path_provider.dart';

class PlateDetectionResult {
  final String? plateText;
  final String? croppedImagePath;
  final ui.Rect? boundingBox;
  
  PlateDetectionResult({this.plateText, this.croppedImagePath, this.boundingBox});
}

class PlateDetector {
  static final _recognizer = TextRecognizer(script: TextRecognitionScript.latin);
  
  static Future<PlateDetectionResult> detect(String imagePath) async {
    final input = InputImage.fromFilePath(imagePath);
    final result = await _recognizer.processImage(input);
    
    TextLine? bestLine;
    String? bestText;

    for (final block in result.blocks) {
      for (final line in block.lines) {

        String cleaned = line.text.replaceAll(' ', '').toUpperCase();

        if (_lookLikePlate(cleaned)) {

          final match = RegExp(r'\d[A-Za-z]{1,2}[-\s]?\d{4}').firstMatch(cleaned);
          bestText = match?.group(0); 
          
          bestLine = line;
          break; 
        }
      }
      if (bestText != null) break;
    }

    String? croppedPath;
    ui.Rect? box;
    
    if (bestLine != null) {
      final line = bestLine;
      if (line.boundingBox != null) {
        box = line.boundingBox;
        croppedPath = await _cropToFile(imagePath, box!);
      }
    }
    
    return PlateDetectionResult(
      plateText: bestText,
      croppedImagePath: croppedPath,
      boundingBox: box,
    );
  }

  static bool _lookLikePlate(String s) {
    final licensePlate = RegExp(r'\d[A-Za-z]{1,2}[-\s]?\d{4}');
    return licensePlate.hasMatch(s);
  }

  static Future<String?> _cropToFile(String srcPath, ui.Rect box) async {
    final bytes = await File(srcPath).readAsBytes();
    var decoded = img.decodeImage(bytes);
    if (decoded == null) return null;

    decoded = img.bakeOrientation(decoded);

    final W = decoded.width;
    final H = decoded.height;

    final x = box.left.clamp(0, W - 1).toInt();
    final y = box.top.clamp(0, H - 1).toInt();
    final w = box.width.clamp(1, W - x).toInt();
    final h = box.height.clamp(1, H - y).toInt();

    const pad = 12;
    final px = (x - pad).clamp(0, W - 1);
    final py = (y - pad).clamp(0, H - 1);
    final pw = (w + pad * 2).clamp(1, W - px);
    final ph = (h + pad * 2).clamp(1, H - py);

    final cropped = img.copyCrop(decoded, x: px, y: py, width: pw, height: ph);

    final docs = await getApplicationDocumentsDirectory();
    final outPath = '${docs.path}/plate_${DateTime.now().millisecondsSinceEpoch}.jpg';
    await File(outPath).writeAsBytes(img.encodeJpg(cropped, quality: 95));
    return outPath;
  }

  static Future<void> dispose() async {
    await _recognizer.close();
  }
}