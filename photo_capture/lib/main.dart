import 'package:flutter/material.dart';
import 'package:photo_capture/take_picture.dart';

Future<void> main() async {
  runApp(
    const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: TakePicture(),
    ),
  );
}
