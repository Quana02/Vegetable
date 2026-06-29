import 'package:flutter/material.dart';

import '../../models/cart_item.dart';
import '../../widgets/network_vegetable_image.dart';
import '../../widgets/price_text.dart';
import '../../widgets/responsive_content.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({
    super.key,
    required this.cart,
    required this.onQuantityChanged,
    required this.onCheckout,
    required this.onContinueShopping,
  });

  final List<CartItem> cart;
  final Future<void> Function(CartItem item, int quantity) onQuantityChanged;
  final Future<void> Function() onCheckout;
  final VoidCallback onContinueShopping;

  double get subtotal => cart.fold(0, (sum, item) => sum + item.total);
  double get shipping => subtotal >= 200000 || subtotal == 0 ? 0 : 25000;

  Future<void> _checkout(BuildContext context) async {
    try {
      await onCheckout();
      if (!context.mounted) return;
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error.toString())));
      }
      return;
    }
    if (!context.mounted) return;
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(
          Icons.check_circle_rounded,
          color: Colors.green,
          size: 52,
        ),
        title: const Text('Đặt hàng thành công!', textAlign: TextAlign.center),
        content: const Text(
          'Đơn hàng đã được lưu trên hệ thống và tồn kho đã được cập nhật.',
          textAlign: TextAlign.center,
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hoàn tất'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (cart.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.shopping_basket_outlined,
              size: 88,
              color: Theme.of(
                context,
              ).colorScheme.primary.withValues(alpha: .35),
            ),
            const SizedBox(height: 18),
            Text(
              'Giỏ hàng đang trống',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            const Text('Hãy chọn vài món rau tươi cho hôm nay nhé.'),
            const SizedBox(height: 22),
            FilledButton.icon(
              onPressed: onContinueShopping,
              icon: const Icon(Icons.storefront),
              label: const Text('Tiếp tục mua sắm'),
            ),
          ],
        ),
      );
    }

    return ResponsiveContent(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final list = ListView.separated(
            shrinkWrap: true,
            physics: constraints.maxWidth >= 800
                ? const NeverScrollableScrollPhysics()
                : null,
            itemCount: cart.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final item = cart[index];
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: SizedBox(
                          width: 88,
                          height: 88,
                          child: NetworkVegetableImage(
                            url: item.vegetable.imageUrl,
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.vegetable.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 5),
                            PriceText(
                              item.vegetable.price,
                              unit: item.vegetable.unit,
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                _QuantityButton(
                                  icon: Icons.remove,
                                  onPressed: () => onQuantityChanged(
                                    item,
                                    item.quantity - 1,
                                  ),
                                ),
                                SizedBox(
                                  width: 38,
                                  child: Text(
                                    '${item.quantity}',
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                                _QuantityButton(
                                  icon: Icons.add,
                                  onPressed: () => onQuantityChanged(
                                    item,
                                    item.quantity + 1,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          IconButton(
                            onPressed: () => onQuantityChanged(item, 0),
                            icon: const Icon(Icons.delete_outline_rounded),
                            color: Colors.redAccent,
                            tooltip: 'Xóa',
                          ),
                          PriceText(item.total),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
          final summary = _OrderSummary(
            subtotal: subtotal,
            shipping: shipping,
            onCheckout: () => _checkout(context),
          );
          if (constraints.maxWidth >= 800) {
            return SingleChildScrollView(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 2, child: list),
                  const SizedBox(width: 20),
                  SizedBox(width: 340, child: summary),
                ],
              ),
            );
          }
          return ListView(
            children: [
              list,
              const SizedBox(height: 16),
              summary,
              const SizedBox(height: 20),
            ],
          );
        },
      ),
    );
  }
}

class _QuantityButton extends StatelessWidget {
  const _QuantityButton({required this.icon, required this.onPressed});
  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 17),
      ),
    );
  }
}

class _OrderSummary extends StatelessWidget {
  const _OrderSummary({
    required this.subtotal,
    required this.shipping,
    required this.onCheckout,
  });
  final double subtotal;
  final double shipping;
  final VoidCallback onCheckout;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Tóm tắt đơn hàng',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 20),
            _SummaryRow(label: 'Tạm tính', value: formatPrice(subtotal)),
            const SizedBox(height: 12),
            _SummaryRow(
              label: 'Phí giao hàng',
              value: shipping == 0 ? 'Miễn phí' : formatPrice(shipping),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Divider(),
            ),
            _SummaryRow(
              label: 'Tổng cộng',
              value: formatPrice(subtotal + shipping),
              emphasized: true,
            ),
            const SizedBox(height: 22),
            FilledButton.icon(
              onPressed: onCheckout,
              icon: const Icon(Icons.lock_outline_rounded),
              label: const Text('Thanh toán'),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.value,
    this.emphasized = false,
  });
  final String label;
  final String value;
  final bool emphasized;

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(
      fontSize: emphasized ? 18 : 15,
      fontWeight: emphasized ? FontWeight.w900 : FontWeight.w500,
      color: emphasized ? Theme.of(context).colorScheme.primary : null,
    );
    return Row(
      children: [
        Text(label, style: style),
        const Spacer(),
        Text(value, style: style),
      ],
    );
  }
}
