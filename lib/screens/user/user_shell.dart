import 'package:flutter/material.dart';

import '../../data/mock_data.dart';
import '../../models/cart_item.dart';
import '../../models/vegetable.dart';
import '../../widgets/adaptive_role_scaffold.dart';
import 'cart_screen.dart';
import 'home_screen.dart';
import 'profile_screen.dart';

class UserShell extends StatefulWidget {
  const UserShell({super.key});

  @override
  State<UserShell> createState() => _UserShellState();
}

class _UserShellState extends State<UserShell> {
  int _index = 0;
  late final List<CartItem> _cart = mockCart
      .map(
        (item) => CartItem(vegetable: item.vegetable, quantity: item.quantity),
      )
      .toList();

  int get _cartCount => _cart.fold(0, (sum, item) => sum + item.quantity);

  void _addToCart(Vegetable vegetable, int quantity) {
    setState(() {
      final found = _cart
          .where((item) => item.vegetable.id == vegetable.id)
          .firstOrNull;
      if (found != null) {
        found.quantity += quantity;
      } else {
        _cart.add(CartItem(vegetable: vegetable, quantity: quantity));
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Đã thêm ${vegetable.name} vào giỏ'),
        action: SnackBarAction(
          label: 'Xem giỏ',
          onPressed: () => setState(() => _index = 1),
        ),
      ),
    );
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
        onChanged: () => setState(() {}),
        onContinueShopping: () => setState(() => _index = 0),
      ),
      const UserProfileScreen(),
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
