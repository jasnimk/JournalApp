// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:journal_app/Colors/color_theme.dart';
import 'package:journal_app/controllers/db_functions.dart';
import 'package:journal_app/model/user.dart';
import 'package:journal_app/widgets/custom_widgets.dart';

class ChangePassword extends StatefulWidget {
  const ChangePassword({super.key});

  @override
  State<ChangePassword> createState() => _ChangePasswordState();
}

class _ChangePasswordState extends State<ChangePassword> {
  late Box<User> userBox;
  late User loggedInUser;
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _currentPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    userBox = Hive.box<User>('users');
    _updateUserData();
  }

  void _updateUserData() {
    loggedInUser = userBox.get('loggedInUser')!;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('Change Password',
            style: TextStyle(
                fontFamily: 'Opensans2',
                fontSize: 20,
                color: ColorTheme.getTextColor(brightness))),
        backgroundColor: ColorTheme.getPrimaryColor(brightness),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                createTextFormField(
                  'Enter your current password',
                  _currentPasswordController,
                  (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your current password';
                    }
                    return null;
                  },
                  obscureText: true,
                ),
                createTextFormField(
                  'Enter new password',
                  _passwordController,
                  (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your new password';
                    }
                    return null;
                  },
                  obscureText: true,
                ),
                createTextFormField(
                  'Confirm new password',
                  _confirmPasswordController,
                  (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please confirm your new password';
                    }
                    if (value != _passwordController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                  obscureText: true,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.cancel),
                      label: const Text('Cancel'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ColorTheme.getPrimaryColor(brightness),
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          String currentPassword =
                              _currentPasswordController.text;
                          String newPassword = _passwordController.text;

                          if (loggedInUser.password == currentPassword) {
                            await updatePassword(
                                loggedInUser.username, newPassword);
                            showSnackBar(
                                'Password changed successfully', context);
                            Navigator.pop(context);
                          } else {
                            showSnackBar(
                                'Current password is incorrect', context);
                          }
                        }
                      },
                      icon: Icon(
                        Icons.save,
                        color: ColorTheme.getTextColor(brightness),
                      ),
                      label: Text(
                        'Save',
                        style: TextStyle(
                            color: ColorTheme.getTextColor(brightness)),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ColorTheme.getPrimaryColor(brightness),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
