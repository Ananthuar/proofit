import 'dart:io';
import 'package:google_ml_kit/google_ml_kit.dart';

class ImageVerifier {
  static Future<bool> verify(String description, String imagePath) async {
    final inputImage = InputImage.fromFilePath(imagePath);
    final textRecognizer = GoogleMlKit.vision.textRecognizer();
    final RecognizedText recognizedText = await textRecognizer.processImage(inputImage);
    await textRecognizer.close();

    final scannedText = recognizedText.text.toLowerCase();
    final desc = description.toLowerCase();

    // Split description into keywords (words longer than 3 chars)
    final keywords = desc.split(RegExp(r'\s+')).where((w) => w.length > 3).toList();

    // Check if at least one keyword is present in scanned text
    return keywords.any((kw) => scannedText.contains(kw));
  }
}