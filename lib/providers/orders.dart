import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:shop/utils/constants.dart';

import 'cart.dart';

class Order {
  final String id;
  final double amount;
  final List<CartItem> products;
  final DateTime date;

  Order({this.id, this.amount, this.products, this.date});
}

class Orders with ChangeNotifier {
  String _token;
  String _userId;
  List<Order> _items = [];
  final _baseUrl = '${Constants.BASE_API_URL}/orders';

  Orders([this._token, this._userId, this._items = const []]);

  List<Order> get items {
    return [..._items];
  }

  int get itemsCount {
    return _items.length;
  }

  Future<void> loadOrders() async {
    List<Order> loadedItems = [];
    final response = await http.get("$_baseUrl/$_userId.json?auth=$_token");
    print(json.decode(response.body));
    Map<String, dynamic> data = json.decode(response.body);

    if (data != null) {
      data.forEach((orderId, orderData) {
        loadedItems.add(
          Order(
            id: orderId,
            amount: orderData['amount'],
            date: DateTime.parse(orderData['date']),
            products: (orderData['products'] as List<dynamic>).map((item) {
              return CartItem(
                id: item['id'],
                price: item['price'],
                productId: item['productId'],
                quantity: item['quantity'],
                title: item['title'],
              );
            }).toList(),
          ),
        );
      });
      notifyListeners();
    }

    _items = loadedItems.reversed.toList();
    return Future.value();
  }

  Future<void> addOrder(Cart cart) async {
    // final combine = (t, i) => t + (i.price * i.quantity);
    // final total = products.fold(0.0, combine);

    final date = DateTime.now();

    final response = await http.post(
      "$_baseUrl/$_userId.json?auth=$_token",
      body: json.encode({
        'amount': cart.totalAmount,
        'date': date.toIso8601String(),
        'products': cart.items.values
            .map((cartItem) => {
                  'id': cartItem.id,
                  'productId': cartItem.productId,
                  'title': cartItem.title,
                  'quantity': cartItem.quantity,
                  'price': cartItem.price,
                })
            .toList(),
      }),
    );

    _items.insert(
      0,
      Order(
        id: json.decode(response.body)['name'],
        amount: cart.totalAmount,
        date: date,
        products: cart.items.values.toList(),
      ),
    );

    notifyListeners();
  }
}
