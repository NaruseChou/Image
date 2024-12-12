import 'png_handler.dart';
import 'svg_handler.dart';
import 'image_handler.dart';

class ImageHandlerFactory {
  static ImageHandler createHandler(String extension) {
    switch (extension.toLowerCase()) {
      case 'svg':
        return SvgHandler();
      case 'png':
      case 'jpg':
      case 'jpeg':
        return PngHandler();
      default:
        throw UnsupportedError("Формат $extension не поддерживается");
    }
  }
}
