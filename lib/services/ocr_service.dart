import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class OcrService {
  final TextRecognizer _recognizer = TextRecognizer();

  static final RegExp _digitRun = RegExp(r'\d{10,20}');

  Future<List<String>> extractPinCandidates(String imagePath) async {
    final inputImage = InputImage.fromFilePath(imagePath);
    final result = await _recognizer.processImage(inputImage);

    final candidates = <String>{};
    for (final block in result.blocks) {
      final text = block.text.replaceAll(RegExp(r'[\s-]'), '');
      for (final match in _digitRun.allMatches(text)) {
        candidates.add(match.group(0)!);
      }
    }

    final sorted = candidates.toList()
      ..sort((a, b) => b.length.compareTo(a.length));
    return sorted;
  }

  void dispose() {
    _recognizer.close();
  }
}
