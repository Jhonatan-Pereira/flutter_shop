import 'dart:math';

import 'package:flutter/cupertino.dart';

import 'cart.dart';

class Order {
  final String id;
  final double amount;
  final List<CartItem> products;
  final DateTime date;

  Order({this.id, this.amount, this.products, this.date});
}

class Orders with ChangeNotifier {
  List<Order> _items = [];

  List<Order> get items {
    return [..._items];
  }

  int get itemsCount {
    return _items.length;
  }

  void addOrder(Cart cart) {
    // final combine = (t, i) => t + (i.price * i.quantity);
    // final total = products.fold(0.0, combine);
    _items.insert(
      0,
      Order(
        id: Random().nextDouble().toString(),
        amount: cart.totalAmount,
        date: DateTime.now(),
        products: cart.items.values.toList(),
      ),
    );

    notifyListeners();
  }
}
