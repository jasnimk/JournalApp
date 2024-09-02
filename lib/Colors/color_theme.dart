import 'package:flutter/material.dart';

class ColorTheme {
  static const Color lightPrimaryColor = Color(0xffCED0CE);
  static const Color textColor = Color.fromARGB(255, 14, 13, 13);

  static const Color darkPrimaryColor = Color(0xff1E1E1E);

  static const Color textDarkColor = Colors.white;

  static Color getPrimaryColor(Brightness brightness) {
    return brightness == Brightness.dark ? darkPrimaryColor : lightPrimaryColor;
  }

  static Color getTextColor(Brightness brightness) {
    return brightness == Brightness.dark ? textDarkColor : textColor;
  }

  static List<Color> getColorForCards(Brightness brightness) {
    if (brightness == Brightness.dark) {
      return [
        const Color(0xff1A1A1A),
        const Color(0xff2C2C2C),
        const Color(0xff3E3E3E),
        const Color(0xff505050),
        const Color(0xff6A6A6A),
        const Color(0xff7F7F7F),
        const Color(0xff9E9E9E),
        const Color(0xffBEBEBE),
      ];
    } else {
      return [
        const Color.fromARGB(117, 240, 228, 121),
        const Color(0xffF5F5F5),
        const Color(0xffA3B18A),
        const Color(0xffD2C7C7),
        const Color(0xffF4ECD8),
        const Color(0xffE5E5E5),
        const Color(0xffA7C7E7),
        const Color(0xffD4A5A5),
      ];
    }
  }
}
