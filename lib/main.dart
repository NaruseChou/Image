import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_editor_plus/image_editor_plus.dart';
import 'package:image_picker/image_picker.dart';
import 'package:upload_image/handlers/image_handler.dart';
import 'package:upload_image/handlers/png_handler.dart';
import 'package:upload_image/handlers/svg_handler.dart';
import 'handlers/image_handler_factory.dart'; // Подключаем фабрику обработчиков

void main() => runApp(const MaterialApp(home: ImageEditorExample()));

class ImageEditorExample extends StatefulWidget {
  const ImageEditorExample({super.key});

  @override
  State<ImageEditorExample> createState() => _ImageEditorExampleState();
}

class _ImageEditorExampleState extends State<ImageEditorExample> {
  ImageHandler? _currentHandler;
  final _imagePicker = ImagePicker();

  // Загрузка изображения
  Future<void> _loadImage() async {
    final pickedFile =
        await _imagePicker.pickImage(source: ImageSource.gallery);
    if (pickedFile == null) return;

    try {
      final extension = pickedFile.path.split('.').last.toLowerCase();
      _currentHandler = ImageHandlerFactory.createHandler(extension);
      await _currentHandler!.load(pickedFile.path);
      setState(() {});
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Ошибка загрузки изображения: $e")),
      );
    }
  }

  // Редактирование изображения
  Future<void> _editImage() async {
    if (_currentHandler is! PngHandler) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Редактирование доступно только для PNG/JPG")),
      );
      return;
    }

    final handler = _currentHandler as PngHandler;
    final editedImage = await Navigator.of(context).push<Uint8List>(
      MaterialPageRoute(
        builder: (context) => ImageEditor(image: handler.imageData!),
      ),
    );

    if (editedImage != null) {
      setState(() {
        handler.imageData = editedImage;
      });
    }
  }

  // Сохранение изображения
  Future<void> _saveImage() async {
    if (_currentHandler == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Нет изображения для сохранения")),
      );
      return;
    }

    final downloadsDir = Directory('/storage/emulated/0/Download');
    if (!downloadsDir.existsSync()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Папка Downloads недоступна")),
      );
      return;
    }

    try {
      final extension = _currentHandler is SvgHandler ? 'svg' : 'jpg';
      final filePath =
          '${downloadsDir.path}/edited_image_${DateTime.now().millisecondsSinceEpoch}.$extension';
      await _currentHandler!.save(filePath);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Изображение сохранено: $filePath")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Ошибка сохранения: $e")),
      );
    }
  }

  // Изменение цвета для SVG
  void _changeSvgColor() {
    if (_currentHandler is SvgHandler) {
      final randomColor = _generateRandomColor();
      (_currentHandler as SvgHandler).changeColor(randomColor);
      setState(() {});
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Цвет можно изменить только для SVG")),
      );
    }
  }

  // Генерация случайного цвета
  Color _generateRandomColor() {
    final random = Random();
    return Color.fromRGBO(
      random.nextInt(256),
      random.nextInt(256),
      random.nextInt(256),
      1.0,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
          AppBar(title: const Text("Редактор изображений"), centerTitle: true),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _currentHandler?.display() ?? const SizedBox(),
            const SizedBox(height: 16),
            ElevatedButton(
                onPressed: _loadImage, child: const Text("Загрузить")),
            ElevatedButton(
                onPressed: _currentHandler == null ? null : _editImage,
                child: const Text("Редактировать")),
            ElevatedButton(
                onPressed: _currentHandler == null ? null : _saveImage,
                child: const Text("Сохранить")),
            if (_currentHandler is SvgHandler)
              ElevatedButton(
                  onPressed: _changeSvgColor,
                  child: const Text("Изменить цвет")),
          ],
        ),
      ),
    );
  }
}
