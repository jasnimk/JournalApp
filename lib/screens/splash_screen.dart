import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:journal_app/Colors/color_theme.dart';
import 'package:journal_app/model/user.dart';
import 'package:journal_app/screens/base_screen.dart';
import 'package:journal_app/screens/login_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Splash extends StatefulWidget {
  const Splash({super.key});

  @override
  SplashState createState() => SplashState();
}

class SplashState extends State<Splash> {
  @override
  void initState() {
    super.initState();
    checkLoginAndNavigate();
  }

  Future<void> checkLoginAndNavigate() async {
    await Future.delayed(const Duration(seconds: 1));
    final shr = await SharedPreferences.getInstance();
    final userLoggedIn = shr.getBool('login');

    if (userLoggedIn == true) {
      var userBox = Hive.box<User>('users');
      var loggedInUser = userBox.get('loggedInUser');

      if (loggedInUser != null) {
        // ignore: use_build_context_synchronously
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (ctx) {
          return BaseScreen(user: loggedInUser);
        }));
      } else {
        // ignore: use_build_context_synchronously
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (ctx) {
          return const LoginPage();
        }));
      }
    } else {
      // ignore: use_build_context_synchronously
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (ctx) {
        return const LoginPage();
      }));
    }
  }

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return Scaffold(
        // backgroundColor: const Color.fromARGB(255, 243, 241, 241),
        body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset('assets/Images/diary.png', width: 200, height: 200),
          Text(
            'Journal',
            style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                fontFamily: 'Castlenight',
                color: ColorTheme.getTextColor(brightness)),
          ),
          const SizedBox(height: 20),
          const CircularProgressIndicator()
        ],
      ),
    ));
  }
}
