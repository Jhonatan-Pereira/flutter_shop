import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:shopping/models/cart.dart';
import 'package:shopping/models/order_list.dart';
import 'package:shopping/models/auth.dart';
import 'package:shopping/models/product_list.dart';
import 'package:shopping/pages/auth_or_home_page.dart';
import 'package:shopping/pages/auth_page.dart';
import 'package:shopping/pages/cart_page.dart';
import 'package:shopping/pages/orders_page.dart';
import 'package:shopping/pages/product_detail_page.dart';
import 'package:shopping/pages/product_form_page.dart';
import 'package:shopping/pages/products_overview_page.dart';
import 'package:shopping/pages/products_page.dart';
import 'package:shopping/utils/app_routes.dart';

Future main() async {
  await dotenv.load(fileName: ".env");
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => Auth(),
        ),
        ChangeNotifierProxyProvider<Auth, ProductList>(
          create: (_) => ProductList('', []),
          update: (ctx, auth, previous) {
            return ProductList(
              auth.token ?? '',
              previous?.items ?? [],
            );
          },
        ),
        ChangeNotifierProvider(
          create: (_) => Cart(),
        ),
        ChangeNotifierProvider(
          create: (_) => OrderList(),
        ),
      ],
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.purple)
              .copyWith(secondary: Colors.deepOrange),
          fontFamily: 'Lato',
        ),
        // home: ProductsOverviewPage(),
        routes: {
          // AppRoutes.PRODUCT_DETAIL: (ctx) => const CounterPage(),
          AppRoutes.AUTH_OR_HOME: (ctx) => const AuthOrHomePage(),
          AppRoutes.PRODUCT_DETAIL: (ctx) => const ProductDetailPage(),
          AppRoutes.CART: (ctx) => const CartPage(),
          AppRoutes.ORDERS: (ctx) => const OrdersPage(),
          AppRoutes.PRODUCTS: (ctx) => const ProductsPage(),
          AppRoutes.PRODUCT_FORM: (ctx) => const ProductFormPage(),
        },
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
