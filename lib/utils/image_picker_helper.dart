import 'dart:convert';
import 'dart:developer';

import 'package:image_picker/image_picker.dart';
import 'package:ventalink_mobile/utils/prompts.dart';

/// Picks an image, downscales/compresses it via the platform image codec, and
/// returns a base64 `data:image/jpeg;base64,...` string ready to send in a
/// JSON body — the backend has no file-upload endpoint, images are stored as
/// data URLs directly on the Store/Product document (same approach the web
/// dashboard uses).
Future<String?> pickAndEncodeImage({ImageSource source = ImageSource.gallery}) async {
  try {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: source,
      maxWidth: 1200,
      maxHeight: 1200,
      imageQuality: 70,
    );

    if (picked == null) return null;

    final bytes = await picked.readAsBytes();
    if (bytes.lengthInBytes > 5 * 1024 * 1024) {
      Prompts.showSnackBar("Image is too large, please choose a smaller one");
      return null;
    }

    return "data:image/jpeg;base64,${base64Encode(bytes)}";
  } catch (e) {
    log("Image pick/encode failed: $e");
    Prompts.showSnackBar("Could not load that image");
    return null;
  }
}
