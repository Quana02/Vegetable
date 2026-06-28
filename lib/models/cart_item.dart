import 'vegetable.dart';

class CartItem {
  CartItem({required this.vegetable, this.quantity = 1});

  final Vegetable vegetable;
  int quantity;

  double get total => vegetable.price * quantity;
}
