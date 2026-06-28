import 'package:flutter/material.dart';

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
    return Image.network(
      url,
      fit: fit,
      errorBuilder: (_, _, _) => Container(
        color: const Color(0xFFE6F2E6),
        alignment: Alignment.center,
        child: Icon(
          Icons.eco_rounded,
          size: 52,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}
