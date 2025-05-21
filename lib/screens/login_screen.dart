import 'package:flutter/material.dart';
import 'package:flutter_app/button_style.dart';
import 'package:shared_preferences/shared_preferences.dart';


class LoginScreen extends StatefulWidget{
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>{
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  Future<void> login() async {
    final prefs = await SharedPreferences.getInstance();
    final storedEmail = prefs.getString('email');
    final storedPassword = prefs.getString('password');

    if(emailController.text == storedEmail && passwordController.text == storedPassword) {
      Navigator.pushReplacementNamed(context, '/profile');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Неверный email или пароль')),
      );
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
    appBar: AppBar(
    title: Text('Вход'),
    backgroundColor: Colors.deepOrangeAccent,
    centerTitle: true,
    ),
    body: Container(
      width: double.infinity,
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        image: DecorationImage
          (image: AssetImage
          ('assets/images/fon_main.jpg'),
            fit: BoxFit.cover
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TextField(
            controller: emailController,
            decoration: InputDecoration(labelText: 'Email'),
            keyboardType: TextInputType.emailAddress,
          ),
          SizedBox(height: 12),
          TextField(
            controller: passwordController,
            obscureText: true,
            decoration: InputDecoration(labelText: 'Пароль'),
          ),
          SizedBox(height: 24),
          ElevatedButton(
            onPressed: login,
            style: buttonStyle(),
            child: Text('Войти'),
          ),
        ],
      ),
    ),
    );
  }
}