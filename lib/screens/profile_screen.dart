import 'package:flutter/material.dart';
import 'package:flutter_app/button_style.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../user_data.dart';

class ProfileScreen extends StatefulWidget {
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  User? currentUser;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    final Id = prefs.getInt('Id');
    final name = prefs.getString('name');
    final email = prefs.getString('email');
    final password = prefs.getString('password');
    if (Id != null && name != null && email != null && password != null) {
      setState(() {
        currentUser = User(Id: Id, name: name,email: email, password: password);
      });
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('email');
    await prefs.remove('password');
    setState(() {
      currentUser = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool isLoggedIn = currentUser != null;

    return Scaffold(
      appBar: AppBar(
        title: Text('Профиль'),
        backgroundColor: Colors.deepOrangeAccent,
        centerTitle: true,
      ),
      body: Container(
        width: double.infinity,
        padding: EdgeInsets.all(24),
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/fon_main.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: isLoggedIn
            ? _buildProfile(context, currentUser!)
            : _buildLoginPromt(context),
      ),
    );
  }

  Widget _buildLoginPromt(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Вы не вошли в систему',
          style: TextStyle(
              fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black),
        ),
        SizedBox(height: 24),
        ElevatedButton(
          onPressed: () {
            Navigator.pushNamed(context, '/login');
          },
          child: Text('Войти'),
          style: buttonStyle(),
        ),
        SizedBox(height: 12),
        ElevatedButton(
          onPressed: () {
            Navigator.pushNamed(context, '/register');
          },
          child: Text('Зарегистрироваться'),
          style: buttonStyle(),
        ),
      ],
    );
  }

  Widget _buildProfile(BuildContext context, User user) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CircleAvatar(
          radius: 50,
          backgroundImage: AssetImage('assets/images/logo_profile.jpg'),
        ),
        SizedBox(height: 16),
        Text(
          currentUser!.name,
          style: TextStyle(
              fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black),
        ),
        SizedBox(height: 8),
        Text(
            currentUser!.email
        ),
        SizedBox(height: 32),
        ElevatedButton(
          onPressed: () async {
            await logout();
          },
          child: Text('Выйти'),
          style: buttonStyle(),
        ),
      ],
    );
  }
}