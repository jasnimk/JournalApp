// ignore_for_file: prefer_typing_uninitialized_variables

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:journal_app/Colors/color_theme.dart';
import 'package:journal_app/main.dart';
import 'package:journal_app/model/user.dart';
import 'package:journal_app/screens/change_password.dart';
import 'package:journal_app/screens/edit_profile.dart';
import 'package:journal_app/screens/privacy.dart';
import 'package:journal_app/widgets/custom_widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppDrawer extends StatefulWidget {
  const AppDrawer({super.key});

  @override
  AppDrawerState createState() => AppDrawerState();
}

class AppDrawerState extends State<AppDrawer> {
  late Box<User> userBox;
  late ValueNotifier<User?> userNotifier;
  ValueNotifier<bool>? themeModeNotifier;
  var loggedInUser;

  @override
  void initState() {
    super.initState();
    userBox = Hive.box<User>('users');
    User? loggedInUser = userBox.get('loggedInUser');
    userNotifier = ValueNotifier<User?>(loggedInUser);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final isDarkMode = Theme.of(context).brightness == Brightness.dark;
      themeModeNotifier = ValueNotifier<bool>(isDarkMode);
    });
  }

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final List<Color> colorForCards = ColorTheme.getColorForCards(brightness);
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: BoxDecoration(
              color: colorForCards[Random().nextInt(colorForCards.length)],
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(0.0),
              ),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  offset: Offset(0, 2),
                  blurRadius: 6,
                ),
              ],
            ),
            child: ValueListenableBuilder<User?>(
              valueListenable: userNotifier,
              builder: (context, user, _) {
                final userName = user?.fullname ?? "Loading...";
                final userImage = user?.img;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(75),
                      ),
                      child: userImage != null && userImage.isNotEmpty
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(75),
                              child: Image.memory(
                                userImage,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Icon(
                                    Icons.account_circle,
                                    size: 100,
                                    color: Colors.grey[400],
                                  );
                                },
                              ),
                            )
                          : Icon(
                              Icons.account_circle,
                              size: 100,
                              color: Colors.grey[400],
                            ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      userName,
                      style: TextStyle(
                        color: ColorTheme.getTextColor(brightness),
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      'Welcome!',
                      style: TextStyle(
                        color: ColorTheme.getTextColor(brightness),
                        fontSize: 16,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          ListTile(
            leading: const Icon(Icons.lock),
            title: const Text('Change Password'),
            onTap: () {
              Navigator.pop(context);
              Navigator.of(context).push(MaterialPageRoute(builder: (ctx) {
                return const ChangePassword();
              }));
            },
          ),
          ListTile(
            leading: const Icon(Icons.edit),
            title: const Text('Edit Profile'),
            onTap: () {
              Navigator.pop(context);
              Navigator.of(context).push(MaterialPageRoute(builder: (ctx) {
                return const EditProfile();
              }));
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete),
            title: const Text('Clear all data'),
            onTap: () {
              Navigator.pop(context);
              showClear(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.exit_to_app),
            title: const Text('Logout'),
            onTap: () {
              Navigator.pop(context);
              showLogout(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text('About'),
            onTap: () {
              Navigator.pop(context);
              showAboutAppDialog(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.brightness_6),
            title: const Text('Toggle Theme'),
            trailing: ValueListenableBuilder<bool>(
              valueListenable: themeModeNotifier ??
                  ValueNotifier<bool>(
                      Theme.of(context).brightness == Brightness.dark),
              builder: (context, isDarkMode, _) {
                return Switch(
                  value: isDarkMode,
                  activeColor: ColorTheme.getTextColor(brightness),
                  onChanged: (value) async {
                    setState(() {
                      themeModeNotifier?.value = value;
                      final themeData = ThemeData(
                        brightness: value ? Brightness.dark : Brightness.light,
                      );
                      MyApp.of(context)?.setThemeData(themeData);
                    });
                  },
                );
              },
            ),
          ),
          ListTile(
            leading: const Icon(Icons.policy),
            title: const Text('Privacy Policy'),
            onTap: () {
              Navigator.pop(context);
              Navigator.of(context).push(MaterialPageRoute(builder: (ctx) {
                return const Privacy();
              }));
            },
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    userNotifier.dispose();
    themeModeNotifier?.dispose();
    super.dispose();
  }

  Future<void> setLogin() async {
    final shrd = await SharedPreferences.getInstance();
    await shrd.setBool('login', false);
  }
}
