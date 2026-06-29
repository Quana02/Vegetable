import 'package:flutter/material.dart';

import '../../models/cart_item.dart';
import '../../models/user_account.dart';
import '../../models/vegetable.dart';
import '../../services/api_client.dart';
import '../../widgets/adaptive_role_scaffold.dart';
import 'cart_screen.dart';
import 'home_screen.dart';
import 'profile_screen.dart';

class UserShell extends StatefulWidget {
  const UserShell({super.key, required this.account});

  final UserAccount account;

  @override
  State<UserShell> createState() => _UserShellState();
}

class _UserShellState extends State<UserShell> {
  int _index = 0;
  List<CartItem> _cart = [];

  @override
  void initState() {
    super.initState();
    _loadCart();
  }

  Future<void> _loadCart() async {
    try {
      final cart = await apiClient.getCart(widget.account.numericId);
      if (mounted) setState(() => _cart = cart);
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error.toString())));
      }
    }
  }

  int get _cartCount => _cart.fold(0, (sum, item) => sum + item.quantity);

  void _addToCart(Vegetable vegetable, int quantity) async {
    try {
      final cart = await apiClient.addCartItem(
        widget.account.numericId,
        vegetable,
        quantity,
      );
      if (!mounted) return;
      setState(() => _cart = cart);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Đã thêm ${vegetable.name} vào giỏ'),
          action: SnackBarAction(
            label: 'Xem giỏ',
            onPressed: () => setState(() => _index = 1),
          ),
        ),
      );
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error.toString())));
      }
    }
  }

  Future<void> _changeQuantity(CartItem item, int quantity) async {
    try {
      final cart = quantity <= 0
          ? await apiClient.removeCartItem(
              widget.account.numericId,
              item.vegetable.id,
            )
          : await apiClient.updateCartItem(
              widget.account.numericId,
              item.vegetable.id,
              quantity,
            );
      if (mounted) setState(() => _cart = cart);
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error.toString())));
      }
    }
  }

  Future<void> _checkout() async {
    await apiClient.checkout(widget.account);
    await _loadCart();
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      HomeScreen(
        onAddToCart: _addToCart,
        onOpenCart: () => setState(() => _index = 1),
      ),
      CartScreen(
        cart: _cart,
        onQuantityChanged: _changeQuantity,
        onCheckout: _checkout,
        onContinueShopping: () => setState(() => _index = 0),
      ),
      UserProfileScreen(account: widget.account),
    ];
    const titles = ['Rau tươi hôm nay', 'Giỏ hàng của bạn', 'Tài khoản'];

    return AdaptiveRoleScaffold(
      title: titles[_index],
      currentIndex: _index,
      onDestinationSelected: (value) => setState(() => _index = value),
      destinations: const [
        RoleDestination(
          'Trang chủ',
          Icons.storefront_outlined,
          Icons.storefront_rounded,
        ),
        RoleDestination(
          'Giỏ hàng',
          Icons.shopping_bag_outlined,
          Icons.shopping_bag_rounded,
        ),
        RoleDestination(
          'Tài khoản',
          Icons.person_outline_rounded,
          Icons.person_rounded,
        ),
      ],
      actions: _index == 0
          ? [
              Badge(
                label: Text('$_cartCount'),
                isLabelVisible: _cartCount > 0,
                child: IconButton(
                  onPressed: () => setState(() => _index = 1),
                  icon: const Icon(Icons.shopping_cart_outlined),
                ),
              ),
              const SizedBox(width: 12),
            ]
          : null,
      body: IndexedStack(index: _index, children: pages),
    );
  }
}
