import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:shopping/models/product.dart';

class ProductList with ChangeNotifier {
  final List<Product> _items = [];
  // bool _showFavoriteOnly = false;
  final _url = dotenv.env['FIREBASE_BASE_URL'] ?? '';

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
      Uri.parse('$_url.json'),
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

  Future<void> updateProduct(Product produto) async {
    int index = _items.indexWhere((p) => p.id == produto.id);
    if (index >= 0) {
      await http.patch(
        Uri.parse('$_url/${produto.id}.json'),
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

  Future<void> loadProducts() async {
    _items.clear();
    final response = await http.get(Uri.parse('$_url.json'));
    if (response.body == 'null') return;
    Map<String, dynamic> data = jsonDecode(response.body);
    data.forEach((productId, productData) {
      _items.add(
        Product(
          id: productId,
          name: productData['name'],
          description: productData['description'],
          price: productData['price'],
          imageUrl: productData['imageUrl'],
          isFavorite: productData['isFavorite'],
        ),
      );
    });
    notifyListeners();
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
