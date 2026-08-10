/// Offline meter-reading capture via the device camera + on-device OCR
/// (Google ML Kit text recognition — runs fully offline, no network call).
///
/// NOTE: the `camera` and `google_mlkit_text_recognition` packages are
/// currently commented out in pubspec.yaml — they were pulling in Android
/// SDK requirements that broke the release build (R8 stripped classes for
/// ML Kit's optional per-language recognizers) for a feature nothing calls
/// yet. Uncomment them there when picking this up.
///
/// This is left as a clean interface so the camera/ML Kit wiring can be
/// completed against a real device (camera preview + capture UI can't be
/// meaningfully built/tested outside a Flutter/Android environment).
///
/// Implementation plan:
///   1. Open `CameraController` on the back camera.
///   2. Show a live preview with a rectangular guide over the meter's
///      digit window.
///   3. On capture, run `TextRecognizer.processImage` (google_mlkit_text_recognition)
///      against the captured frame.
///   4. Filter recognized text blocks to digit sequences, pick the longest
///      contiguous digit run within the guide rectangle.
///   5. Return the digits + a confidence flag (e.g. based on block
///      confidence score / digit count sanity check).
///   6. The result is ALWAYS shown to the user as an editable field —
///      never auto-saved without their confirmation (see spec: "OCR result
///      must NEVER be treated as unquestionably correct").
class OcrResult {
  final String value;
  final bool confident;
  OcrResult({required this.value, required this.confident});
}

class OcrService {
  static const String lowConfidenceMessage = 'میٹر نمبر دوبارہ چیک کریں';
  static const String cameraFailureMessage = 'تصویر لینے میں مسئلہ پیش آیا';

  /// Opens the camera, captures a frame, and runs on-device OCR.
  /// Returns null if the user cancels. Throws on hard camera failure
  /// (caller shows [cameraFailureMessage]).
  static Future<OcrResult?> captureAndRecognizeMeterReading() async {
    // TODO: wire up `camera` + `google_mlkit_text_recognition` here.
    // Left unimplemented intentionally — requires a real device/emulator
    // to build and test the camera preview UI and OCR accuracy tuning.
    throw UnimplementedError(
      'Camera OCR capture needs to be implemented and tested on a real '
      'Android device/emulator. Manual entry always works as the fallback.',
    );
  }
}
