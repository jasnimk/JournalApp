import 'package:flutter/material.dart';
import 'package:journal_app/Colors/color_theme.dart';

PreferredSizeWidget customAppBar(String text1, BuildContext context) {
  final brightness = Theme.of(context).brightness;

  return AppBar(
    automaticallyImplyLeading: false,
    backgroundColor: ColorTheme.getPrimaryColor(brightness),
    title: Text(
      text1,
      style: TextStyle(
        fontFamily: 'Opensans2',
        fontSize: 18,
        color: ColorTheme.getTextColor(brightness),
      ),
    ),
    actions: [
      Builder(
        builder: (BuildContext context) {
          return IconButton(
            icon: Icon(
              Icons.menu,
              color: ColorTheme.getTextColor(brightness),
            ),
            onPressed: () {
              Scaffold.of(context).openEndDrawer();
            },
          );
        },
      ),
    ],
  );
}
