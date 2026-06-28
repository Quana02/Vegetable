import 'package:flutter/material.dart';

String formatPrice(double value) {
  final digits = value.round().toString();
  final buffer = StringBuffer();
  for (var i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) buffer.write('.');
    buffer.write(digits[i]);
  }
  return '${buffer.toString()}đ';
}

class PriceText extends StatelessWidget {
  const PriceText(this.price, {super.key, this.unit, this.style});
  final double price;
  final String? unit;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    return Text(
      '${formatPrice(price)}${unit == null ? '' : ' / $unit'}',
      style:
          style ??
          TextStyle(
            color: Theme.of(context).colorScheme.primary,
            fontWeight: FontWeight.w800,
            fontSize: 16,
          ),
    );
  }
}
