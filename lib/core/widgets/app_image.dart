import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class AppImage extends StatelessWidget {
  final ImageProvider? image;
  final String? assetPath;
  final String? url;
  final BoxFit fit;
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;
  final Widget Function(BuildContext, Object, StackTrace?)? errorBuilder;

  const AppImage._({
    super.key,
    this.image,
    this.assetPath,
    this.url,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    this.borderRadius,
    this.errorBuilder,
  });

  factory AppImage.asset(
    String path, {
    double? width,
    double? height,
    BoxFit fit = BoxFit.cover,
    BorderRadius? borderRadius,
    Widget Function(BuildContext, Object, StackTrace?)? errorBuilder,
  }) {
    return AppImage._(
      assetPath: path,
      width: width,
      height: height,
      fit: fit,
      borderRadius: borderRadius,
      errorBuilder: errorBuilder,
    );
  }

  factory AppImage.network(
    String url, {
    double? width,
    double? height,
    BoxFit fit = BoxFit.cover,
    BorderRadius? borderRadius,
    Widget Function(BuildContext, Object, StackTrace?)? errorBuilder,
  }) {
    return AppImage._(
      url: url,
      width: width,
      height: height,
      fit: fit,
      borderRadius: borderRadius,
      errorBuilder: errorBuilder,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (url != null) {
      final cachedImage = CachedNetworkImage(
        imageUrl: url!,
        fit: fit,
        width: width,
        height: height,
        placeholder: (context, url) => _placeholder(),
        errorWidget: (context, url, error) => _fallback(),
      );

      if (borderRadius != null) {
        return ClipRRect(borderRadius: borderRadius!, child: cachedImage);
      }
      return cachedImage;
    }

    final provider = image ??
        (assetPath != null ? AssetImage(assetPath!) : null);

    if (provider == null) {
      return _fallback();
    }

    final imageWidget = Image(
      image: provider,
      fit: fit,
      width: width,
      height: height,
      errorBuilder: errorBuilder ?? (_, __, ___) => _fallback(),
    );

    if (borderRadius != null) {
      return ClipRRect(borderRadius: borderRadius!, child: imageWidget);
    } else {
      return imageWidget;
    }
  }

  Widget _placeholder() {
    return Container(
      width: width,
      height: height,
      color: const Color(0xFFF3F4F6),
      child: const Center(
        child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
    );
  }

  Widget _fallback() {
    return Container(
      width: width,
      height: height,
      color: const Color(0xFFF3F4F6),
      child: const Icon(Icons.image_not_supported_outlined, size: 28, color: Color(0xFF9AA4B2)),
    );
  }
}
