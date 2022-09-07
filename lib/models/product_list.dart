import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:shopping/exceptions/http_excepetion.dart';
import 'package:shopping/models/product.dart';

class ProductList with ChangeNotifier {
  String _token;
  List<Product> _items = [];
  // bool _showFavoriteOnly = false;
  final _url = dotenv.env['FIREBASE_BASE_URL'] ?? '';

  List<Product> get items => [..._items];
  List<Product> get favoriteItems =>
      _items.where((prod) => prod.isFavorite).toList();

  ProductList(this._token, this._items);

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
      Uri.parse('${_url}products.json'),
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
        Uri.parse('${_url}products/${produto.id}.json'),
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

  Future<void> removeProduct(Product produto) async {
    int index = _items.indexWhere((p) => p.id == produto.id);
    if (index >= 0) {
      final product = _items[index];
      _items.remove(product);
      notifyListeners();

      final response = await http.delete(
        Uri.parse('${_url}products/${product.id}.json'),
      );

      if (response.statusCode >= 400) {
        _items.insert(index, product);
        notifyListeners();
        throw HttpException(
          msg: 'Não foi possível excluir o produto',
          statusCode: response.statusCode,
        );
      }
    }
  }

  Future<void> loadProducts() async {
    _items.clear();
    final response =
        await http.get(Uri.parse('${_url}products.json?=auth=$_token'));
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
