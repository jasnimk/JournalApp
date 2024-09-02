import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:journal_app/Colors/color_theme.dart';
import 'package:journal_app/controllers/db_functions.dart';
import 'package:journal_app/model/user.dart';
import 'package:journal_app/screens/base_screen.dart';
import 'package:journal_app/screens/signup_screen.dart';
import 'package:journal_app/widgets/custom_widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();

  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('Login',
            style: TextStyle(
                fontFamily: 'Opensans2',
                fontSize: 20,
                color: ColorTheme.getTextColor(brightness))),
        backgroundColor: ColorTheme.getPrimaryColor(brightness),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              createTextFormField('Enter Username', _usernameController,
                  (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your username';
                }
                return null;
              }),
              createTextFormField('Enter Password', _passwordController,
                  (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your password';
                }
                return null;
              }, obscureText: true),
              const SizedBox(height: 5),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          _login();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ColorTheme.getPrimaryColor(brightness),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                      child: Text(
                        'Login',
                        style: TextStyle(
                            color: ColorTheme.getTextColor(brightness)),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 5),
              createDivider(),
              const SizedBox(height: 5),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context)
                            .push(MaterialPageRoute(builder: (ctx) {
                          return const SignupPage();
                        }));
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ColorTheme.getPrimaryColor(brightness),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                      child: Text(
                        'Signup',
                        style: TextStyle(
                            color: ColorTheme.getTextColor(brightness)),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _login() {
    final username = _usernameController.text;
    final password = _passwordController.text;
    final user = login(username, password, context);

    if (user != null) {
      setLogin();
      Hive.box<User>('users').put('loggedInUser', user);
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (ctx) {
        return BaseScreen(
          user: user,
        );
      }));
    } else {
      showSnackBar('Invalid login credentials', context);
    }
  }

  Future<void> setLogin() async {
    final shrd = await SharedPreferences.getInstance();
    await shrd.setBool('login', true);
  }
}
