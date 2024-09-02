import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:journal_app/Colors/color_theme.dart';
import 'package:journal_app/model/user.dart';
import 'package:journal_app/screens/edit_profile.dart';
import 'package:journal_app/widgets/app_drawer.dart';
import 'package:journal_app/widgets/custom_appbar.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  Box<User> userBox = Hive.box<User>('users');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar('Account', context),
      endDrawer: const AppDrawer(),
      body: SingleChildScrollView(
        child: ValueListenableBuilder(
          valueListenable: userBox.listenable(keys: ['loggedInUser']),
          builder: (context, Box<User> box, _) {
            final loggedInUser = box.get('loggedInUser');
            if (loggedInUser != null) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _createEdit(),
                  _createImageDisplay(loggedInUser.img),
                  Card(
                    borderOnForeground: false,
                    shadowColor: Colors.transparent,
                    child: Column(
                      children: [
                        _createRow('Name', loggedInUser.fullname),
                        _createRow('Contact', loggedInUser.contact),
                        _createRow('Email', loggedInUser.email),
                      ],
                    ),
                  ),
                ],
              );
            } else {
              return const Center(
                child: Text(
                  'User not found',
                  style: TextStyle(fontFamily: 'Opensans2', fontSize: 22),
                ),
              );
            }
          },
        ),
      ),
    );
  }

  _createRow(String text1, String text2) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            text1,
            style: const TextStyle(fontFamily: 'Opensans2', fontSize: 18),
          ),
          Text(
            text2,
            style: const TextStyle(fontFamily: 'Opensans2', fontSize: 16),
          ),
        ],
      ),
    );
  }

  _createImageDisplay(Uint8List? image) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Container(
        width: 200,
        height: 200,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(75),
        ),
        child: image != null
            ? ClipRRect(
                child: Image.memory(
                  image,
                  fit: BoxFit.cover,
                ),
              )
            : Icon(
                Icons.account_circle,
                size: 100,
                color: Colors.grey[400],
              ),
      ),
    );
  }

  _createEdit() {
    final brightness = Theme.of(context).brightness;
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          IconButton(
            icon: Icon(Icons.edit, color: ColorTheme.getTextColor(brightness)),
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (ctx) {
                return const EditProfile();
              }));
            },
          ),
        ],
      ),
    );
  }
}
