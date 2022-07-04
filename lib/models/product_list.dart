import 'dart:math';

import 'package:flutter/material.dart';
import 'package:shopping/data/dummy_data.dart';
import 'package:shopping/models/product.dart';

class ProductList with ChangeNotifier {
  final List<Product> _items = dummyProducts;
  // bool _showFavoriteOnly = false;

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

  void addProduct(Product produto) {
    _items.add(produto);
    notifyListeners();
  }

  void updateProduct(Product produto) {
    int index = _items.indexWhere((p) => p.id == produto.id);
    if (index >= 0) {
      _items[index] = produto;
      notifyListeners();
    }
  }

  void removeProduct(Product produto) {
    int index = _items.indexWhere((p) => p.id == produto.id);
    if (index >= 0) {
      _items.removeWhere((p) => p.id == produto.id);
      notifyListeners();
    }
  }

  void saveProduct(Map<String, Object> data) {
    bool hasId = data['id'] != null;

    final product = Product(
      id: hasId ? data['id'] as String : Random().nextDouble().toString(),
      name: data['name'] as String,
      description: data['description'] as String,
      price: data['price'] as double,
      imageUrl: data['imageUrl'] as String,
    );
    if (hasId) {
      updateProduct(product);
    } else {
      addProduct(product);
    }
  }
}
