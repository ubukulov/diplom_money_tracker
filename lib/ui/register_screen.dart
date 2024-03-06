import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:diplom_money_tracker/config/vars.dart';
import '../business/routes/routes.dart';

class RegisterScreen extends StatefulWidget{
  static const routeName = '/register';

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<void> _register(BuildContext context) async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );
      Routes.router.navigateTo(context, '/');
    } catch (e) {
      final snackBar = SnackBar(
        content: Text('Ошибка при регистрации. Попробуйте позже'),
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
                      decoration: InputDecoration(
                          labelText: 'E-mail'
                      ),
                      controller: _emailController,
                    ),
                    TextField(
                      decoration: InputDecoration(
                        labelText: 'Пароль',
                      ),
                      controller: _passwordController,
                    ),
                    SizedBox(height: 20.0),
                    Container(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          _register(context);
                        },
                        style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all(mainColor),
                            padding: MaterialStateProperty.all(EdgeInsets.symmetric(vertical: 15.0)),
                            shape: MaterialStateProperty.all(RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15.0)
                            ))
                        ),
                        child: const Text('Регистрация'),
                      ),
                    )
                  ],
                ),
              ),
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Уже есть аккаунт? '),
                    GestureDetector(
                      onTap: () {
                        Routes.router.navigateTo(context, '/');
                      },
                      child: Text('Войти', style: TextStyle(color: mainColor, fontWeight: FontWeight.bold),),
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