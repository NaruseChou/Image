import 'package:flutter/material.dart';

abstract class ImageHandler {
  Future<void> load(String path);
  Future<void> save(String destinationPath);
  Widget display();
}
