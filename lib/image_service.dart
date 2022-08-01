import 'dart:io';

import 'package:fpdart/fpdart.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';

class ImageService {
  final _picker = ImagePicker();

  Future<Option<List<File>>> pickImages() async {
    final images = await _picker.pickMultiImage();
    if (images != null) {
      final asFiles = images.map((e) => File(e.path)).toList();
      return Some(asFiles);
    } else {
      return None();
    }
  }

  Future<Option<File>> pickImage() async {
    final photo = await _picker.pickImage(source: ImageSource.gallery);
    if (photo != null) {
      return Some(File(photo.path));
    }
    return None();
  }

  Future<Option<File>> takePicture() async {
    final photo = await _picker.pickImage(source: ImageSource.camera);
    if (photo != null) {
      return Some(File(photo.path));
    }
    return None();
  }

  Future<String> recognizeText(File file) async {
    final inputImage = InputImage.fromFile(file);
    final textRecognizer = TextRecognizer();
    final RecognizedText recognizedText =
        await textRecognizer.processImage(inputImage);

    for (var textBlock in recognizedText.blocks) {
      print(textBlock.text);
    }

    String text = recognizedText.text;
    return text;
  }
}
