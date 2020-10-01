import 'package:flutter/material.dart';
import '../models/product.dart';
import '../providers/counter_provider.dart';

class ProductDetailScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final Product product =
        ModalRoute.of(context).settings.arguments as Product;
    return Scaffold(
      appBar: AppBar(
        title: Text(product.title),
      ),
      body: Column(
        children: [
          RaisedButton(
            child: Text('+'),
            onPressed: () {
              CounterProvider.of(context).state.inc();
            },
          ),
        ],
      ),
    );
  }
}
