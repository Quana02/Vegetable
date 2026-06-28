import 'package:flutter/material.dart';

import '../../models/vegetable.dart';
import '../../widgets/network_vegetable_image.dart';
import '../../widgets/price_text.dart';

class VegetableDetailScreen extends StatefulWidget {
  const VegetableDetailScreen({
    super.key,
    required this.vegetable,
    required this.onAddToCart,
  });
  final Vegetable vegetable;
  final void Function(Vegetable vegetable, int quantity) onAddToCart;

  @override
  State<VegetableDetailScreen> createState() => _VegetableDetailScreenState();
}

class _VegetableDetailScreenState extends State<VegetableDetailScreen> {
  int _quantity = 1;

  Widget _info() {
    final vegetable = widget.vegetable;
    return Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Chip(
            avatar: const Icon(Icons.eco_outlined, size: 18),
            label: Text(vegetable.category),
          ),
          const SizedBox(height: 14),
          Text(
            vegetable.name,
            style: Theme.of(
              context,
            ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 10),
          PriceText(
            vegetable.price,
            unit: vegetable.unit,
            style: TextStyle(
              fontSize: 24,
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 22),
          const Text(
            'Mô tả sản phẩm',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 9),
          Text(
            vegetable.description,
            style: const TextStyle(
              fontSize: 16,
              height: 1.55,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 22),
          Row(
            children: [
              const Icon(Icons.inventory_2_outlined, size: 20),
              const SizedBox(width: 8),
              Text(
                'Còn ${vegetable.stock} sản phẩm',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 26),
          Row(
            children: [
              const Text(
                'Số lượng',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
              ),
              const Spacer(),
              IconButton.outlined(
                onPressed: _quantity > 1
                    ? () => setState(() => _quantity--)
                    : null,
                icon: const Icon(Icons.remove),
              ),
              SizedBox(
                width: 44,
                child: Text(
                  '$_quantity',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              IconButton.outlined(
                onPressed: _quantity < vegetable.stock
                    ? () => setState(() => _quantity++)
                    : null,
                icon: const Icon(Icons.add),
              ),
            ],
          ),
          const SizedBox(height: 26),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => widget.onAddToCart(vegetable, _quantity),
                  icon: const Icon(Icons.add_shopping_cart_rounded),
                  label: const Text('Thêm vào giỏ'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  onPressed: () {
                    widget.onAddToCart(vegetable, _quantity);
                    Navigator.pop(context, true);
                  },
                  child: const Text('Mua ngay'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chi tiết sản phẩm')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1100),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final image = ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: AspectRatio(
                    aspectRatio: 1.05,
                    child: NetworkVegetableImage(
                      url: widget.vegetable.imageUrl,
                    ),
                  ),
                );
                if (constraints.maxWidth >= 760) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: image),
                      Expanded(child: _info()),
                    ],
                  );
                }
                return Column(children: [image, _info()]);
              },
            ),
          ),
        ),
      ),
    );
  }
}
