import 'package:flutter/material.dart';
import 'package:flutter_app/button_style.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RegisterScreen extends StatefulWidget{
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>{
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  Future<void> register() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('email', emailController.text);
    await prefs.setString('password', passwordController.text);
    Navigator.pop(context);
}
  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: Text('Регистрация'),
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
          ),
          SizedBox(height: 12),
          TextField(
            controller: passwordController,
            decoration: InputDecoration(labelText: 'Пароль'),
          ),
          SizedBox(height: 24),
          ElevatedButton(
            onPressed: register,
            style: buttonStyle(),
            child: Text('Зарегистрироваться'),
          ),
        ],
      ),
    ),
    );
  }
}