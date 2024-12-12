import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'image_handler.dart';

class SvgHandler extends ImageHandler {
  String? _svgData;

  @override
  Future<void> load(String path) async {
    final file = File(path);
    _svgData = await file.readAsString();
  }

  @override
  Future<void> save(String destinationPath) async {
    if (_svgData == null) throw Exception("Нет данных для сохранения");
    final file = File(destinationPath);
    await file.writeAsString(_svgData!);
  }

  @override
  Widget display() {
    if (_svgData == null) return const SizedBox();
    return SvgPicture.string(_svgData!,
        height: 300, width: 300, fit: BoxFit.cover);
  }

  void changeColor(Color color) {
    if (_svgData == null) return;
    final colorHex =
        '#${color.value.toRadixString(16).padLeft(8, '0').substring(2)}';
    _svgData = _svgData!.replaceAll(RegExp(r'#([0-9A-Fa-f]{6})'), colorHex);
  }
}
