import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shopping/models/auth.dart';
import 'package:shopping/pages/auth_page.dart';
import 'package:shopping/pages/products_overview_page.dart';

class AuthOrHomePage extends StatelessWidget {
  const AuthOrHomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Auth auth = Provider.of(context);
    return auth.isAuth ? const ProductsOverviewPage() : const AuthPage();
  }
}
