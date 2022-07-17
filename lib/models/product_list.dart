import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:shopping/data/dummy_data.dart';
import 'package:shopping/models/product.dart';

class ProductList with ChangeNotifier {
  final List<Product> _items = dummyProducts;
  // bool _showFavoriteOnly = false;
  final _baseUrl = dotenv.env['FIREBASE_BASE_URL'];

  List<Product> get items => [..._items];
  List<Product> get favoriteItems =>
      _items.where((prod) => prod.isFavorite).toList();

  int get itemsCount {
    return _items.length;
  }

  // List<Product> get items {
  //   if (_showFavoriteOnly) {
  //     return _items.where((prod) => prod.isFavorite).toList();
  //   }
  //   return [..._items];
  // }

  // void showFavoriteOnly() {
  //   _showFavoriteOnly = true;
  //   notifyListeners();
  // }

  // void showAll() {
  //   _showFavoriteOnly = false;
  //   notifyListeners();
  // }

  Future<void> addProduct(Product produto) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/products.json'),
      body: jsonEncode(
        {
          "name": produto.name,
          "description": produto.description,
          "price": produto.price,
          "imageUrl": produto.imageUrl,
          "isFavorite": produto.isFavorite,
        },
      ),
    );

    final id = jsonDecode(response.body)['name'];
    _items.add(Product(
      id: id,
      name: produto.name,
      description: produto.description,
      price: produto.price,
      imageUrl: produto.imageUrl,
      isFavorite: produto.isFavorite,
    ));
    notifyListeners();
  }

  Future<void> updateProduct(Product produto) {
    int index = _items.indexWhere((p) => p.id == produto.id);
    if (index >= 0) {
      _items[index] = produto;
      notifyListeners();
    }

    return Future.value();
  }

  void removeProduct(Product produto) {
    int index = _items.indexWhere((p) => p.id == produto.id);
    if (index >= 0) {
      _items.removeWhere((p) => p.id == produto.id);
      notifyListeners();
    }
  }

  Future<void> saveProduct(Map<String, Object> data) {
    bool hasId = data['id'] != null;

    final product = Product(
      id: hasId ? data['id'] as String : Random().nextDouble().toString(),
      name: data['name'] as String,
      description: data['description'] as String,
      price: data['price'] as double,
      imageUrl: data['imageUrl'] as String,
    );
    if (hasId) {
      return updateProduct(product);
    } else {
      return addProduct(product);
    }
  }
}
