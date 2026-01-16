import 'dart:io';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class OcrService {
  /// Scans the given image file and returns recognized text
  /// Works only on Android / iOS (ML Kit)
  static Future<String> scanImage(File imageFile) async {
    final inputImage = InputImage.fromFile(imageFile);

    final textRecognizer =
        TextRecognizer(script: TextRecognitionScript.latin);

    final RecognizedText recognizedText =
        await textRecognizer.processImage(inputImage);

    await textRecognizer.close();

    return recognizedText.text;
  }
}
