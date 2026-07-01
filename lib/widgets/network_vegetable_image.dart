import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class NetworkVegetableImage extends StatelessWidget {
  const NetworkVegetableImage({
    super.key,
    required this.url,
    this.fit = BoxFit.cover,
  });

  final String url;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    final isRemote = url.startsWith('http://') || url.startsWith('https://');
    if (!isRemote && url.trim().isNotEmpty) {
      return FutureBuilder(
        future: XFile(url).readAsBytes(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return Image.memory(snapshot.data!, fit: fit);
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(strokeWidth: 2));
          }
          return _ImageFallback();
        },
      );
    }

    return Image.network(
      url,
      fit: fit,
      errorBuilder: (_, _, _) => _ImageFallback(),
    );
  }
}

class _ImageFallback extends StatelessWidget {
  const _ImageFallback();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFE6F2E6),
      alignment: Alignment.center,
      child: Icon(
        Icons.eco_rounded,
        size: 52,
        color: Theme.of(context).colorScheme.primary,
      ),
    );
  }
}
