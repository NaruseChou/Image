import 'dart:io';
import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'image_handler.dart';

class PngHandler extends ImageHandler {
  Uint8List? _imageData;

  @override
  Future<void> load(String path) async {
    final file = File(path);
    _imageData = await file.readAsBytes();
  }

  @override
  Future<void> save(String destinationPath) async {
    if (_imageData == null) throw Exception("Нет данных для сохранения");
    final file = File(destinationPath);
    await file.writeAsBytes(_imageData!);
  }

  @override
  Widget display() {
    if (_imageData == null) return const SizedBox();
    return Image.memory(_imageData!,
        height: 300, width: 300, fit: BoxFit.cover);
  }

  Uint8List? get imageData => _imageData;
  set imageData(Uint8List? data) => _imageData = data;
}
