import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:ventalink_mobile/utils/formatters.dart';

/// Renders a store/product image whether it's a remote URL or a base64
/// `data:` URL (the backend stores logos/product images as data URLs since
/// there's no file-upload endpoint) — `Image.network` alone can't decode `data:`.
class RemoteOrDataImage extends StatelessWidget {
  final String? url;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Widget Function(BuildContext context)? placeholderBuilder;

  const RemoteOrDataImage({
    super.key,
    required this.url,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.placeholderBuilder,
  });

  @override
  Widget build(BuildContext context) {
    final resolved = resolveImageUrl(url);

    if (resolved.isEmpty) {
      return placeholderBuilder?.call(context) ?? const SizedBox.shrink();
    }

    if (resolved.startsWith("data:")) {
      try {
        final base64Part = resolved.substring(resolved.indexOf(",") + 1);
        return Image.memory(
          base64Decode(base64Part),
          width: width,
          height: height,
          fit: fit,
          errorBuilder: (context, error, stackTrace) => placeholderBuilder?.call(context) ?? const SizedBox.shrink(),
        );
      } catch (_) {
        return placeholderBuilder?.call(context) ?? const SizedBox.shrink();
      }
    }

    return Image.network(
      resolved,
      width: width,
      height: height,
      fit: fit,
      errorBuilder: (context, error, stackTrace) => placeholderBuilder?.call(context) ?? const SizedBox.shrink(),
    );
  }
}
