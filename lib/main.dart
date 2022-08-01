import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart' hide State;
import 'package:id_details_extractor/image_service.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Option<String> recognizedText = const None();
  final _imageService = ImageService();
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            recognizedText.match(
              (t) => Text(t),
              () => Text('Please choose id'),
            ),
            ElevatedButton(
              onPressed: () async {
                final result = await cameraOrGalleryDialog(context);
                if (result != null) {
                  await result.match(
                    (image) async {
                      setState(() {
                        isLoading = true;
                      });
                      final text = await _imageService.recognizeText(image);
                      recognizedText = Some(text);
                    },
                    () => null,
                  );
                  setState(() {
                    isLoading = false;
                  });
                }
              },
              child: Text(
                recognizedText.match(
                  (t) => 'Change Image',
                  () => 'Take Picture/Choose ID',
                ),
              ),
            ),
            if (isLoading) Center(child: CircularProgressIndicator()),
          ],
        ),
      ),
    );
  }

  /// returns true if camera, false if gallery
  Future<Option<File>?> cameraOrGalleryDialog(BuildContext context) async {
    final dialog = SimpleDialog(
      title: const Text('Choose the image source.'),
      children: [
        SimpleDialogOption(
          child: const Text('Take a picture using your camera'),
          onPressed: () {
            Navigator.of(context).pop(true);
          },
        ),
        SimpleDialogOption(
          child: const Text('Select a photo from your gallery'),
          onPressed: () {
            Navigator.of(context).pop(false);
          },
        ),
      ],
    );
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => dialog,
    );
    if (result != null) {
      if (result) {
        return _imageService.takePicture();
      } else {
        return _imageService.pickImage();
      }
    }
    return None();
  }
}
