import 'package:flutter/material.dart';
import 'package:flutter_app/button_style.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RegisterScreen extends StatefulWidget{
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>{
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();


  Future<void> register() async {
    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');

    if(name.isEmpty || email.isEmpty || password.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Пожалуйста заполните все поля')
            ),
          );
          return;
    }

    if(!emailRegex.hasMatch(email)){
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Введите корректный email'))
      );
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('Id', DateTime.now().microsecondsSinceEpoch);
    await prefs.setString('name', nameController.text);
    await prefs.setString('email', emailController.text);
    await prefs.setString('password', passwordController.text);
    Navigator.pushReplacementNamed(context, '/main');
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
            controller: nameController,
            decoration: InputDecoration(labelText: 'Имя пользователя'),
          ),
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