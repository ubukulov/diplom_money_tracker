import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:diplom_money_tracker/config/vars.dart';
import '../business/routes/routes.dart';

class LoginScreen extends StatelessWidget{
  static const routeName = '/login';

  final TextEditingController emailController    = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool _btnLoader = false;

  Future<void> signIn(BuildContext context) async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );
      Routes.router.navigateTo(context, '/');
    } on FirebaseAuthException catch (e) {
      final snackBar = SnackBar(
        content: Text('Логин или пароль не правильно'),
        action: SnackBarAction(
          label: 'Закрыть',
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      );

      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Container(
              child: Column(
                children: [
                  Container(
                    child: Image.asset('assets/images/gradient1.png'),
                    margin: EdgeInsets.only(bottom: 10.0),
                  ),
                  Container(
                    margin: EdgeInsets.only(bottom: 20.0),
                    child: Text('Учёт расходов', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0)),
                  ),
                  Text('Ваша история расходов'),
                  Text('всегда под рукой'),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.all(10.0),
              child: Column(
                children: [
                  TextField(
                    controller: emailController,
                    decoration: InputDecoration(
                        labelText: 'E-mail'
                    ),
                  ),
                  TextField(
                    controller: passwordController,
                    decoration: InputDecoration(
                        labelText: 'Пароль',
                    ),
                    obscureText: true,
                  ),
                  SizedBox(height: 20.0),
                  Container(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => signIn(context),
                      style: (_btnLoader)
                          ? ButtonStyle(
                              backgroundColor: MaterialStateProperty.all(Colors.grey),
                              padding: MaterialStateProperty.all(EdgeInsets.symmetric(vertical: 15.0)),
                              shape: MaterialStateProperty.all(RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15.0)
                              ))
                            )

                          : ButtonStyle(
                              backgroundColor: MaterialStateProperty.all(mainColor),
                              padding: MaterialStateProperty.all(EdgeInsets.symmetric(vertical: 15.0)),
                              shape: MaterialStateProperty.all(RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15.0)
                              ))
                            ),
                      child: (_btnLoader) ? CircularProgressIndicator(color: mainColor,) : const Text('Войти'),
                    ),
                  )
                ],
              ),
            ),
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Ещё нет аккаунта? '),
                  GestureDetector(
                    onTap: () {
                      Routes.router.navigateTo(context, '/register');
                    },
                    child: Text('Регистрация', style: TextStyle(color: mainColor, fontWeight: FontWeight.bold),),
                  )
                ],
              ),
            )
          ],
        ),
      )
    );
  }
}