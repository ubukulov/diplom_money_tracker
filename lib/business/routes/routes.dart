import 'package:diplom_money_tracker/ui/home_screen.dart';
import 'package:diplom_money_tracker/ui/login_screen.dart';
import 'package:diplom_money_tracker/ui/register_screen.dart';
import 'package:diplom_money_tracker/ui/cat_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:fluro/fluro.dart';

class Routes {
  static final router = FluroRouter();

  static final Handler _loginHandler = Handler(handlerFunc: (BuildContext? context, Map<String, dynamic> params) {
    return LoginScreen();
  });

  static final Handler _registerHandler = Handler(handlerFunc: (BuildContext? context, Map<String, dynamic> params) {
    return RegisterScreen();
  });

  static final Handler _homeHandler = Handler(handlerFunc: (BuildContext? context, Map<String, dynamic> params) {
    return HomeScreen();
  });

  static final Handler _catDetailHandler = Handler(handlerFunc: (BuildContext? context, Map<String, dynamic> params) {
    return CatDetailScreen(
      id: params['id'][0],
      color: params['color'][0]
    );
  });

  static void setupRouter() {
    router.define(HomeScreen.routeName, handler: _homeHandler);
    router.define(LoginScreen.routeName, handler: _loginHandler);
    router.define(RegisterScreen.routeName, handler: _registerHandler);
    router.define('${CatDetailScreen.routeName}/:id/:color', handler: _catDetailHandler);
  }
}