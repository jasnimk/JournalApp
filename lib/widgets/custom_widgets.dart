// ignore_for_file: use_build_context_synchronously

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:intl/intl.dart';
import 'package:journal_app/Colors/color_theme.dart';
import 'package:journal_app/controllers/db_functions.dart';
import 'package:journal_app/model/event.dart';
import 'package:journal_app/model/user.dart';
import 'package:journal_app/screens/login_screen.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

createContainer(
    BuildContext context, String t1, String t2, String t3, Color cl) {
  final brightness = Theme.of(context).brightness;
  return Expanded(
    child: Container(
      height: 150,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(7)),
        color: cl,
      ),
      child: Padding(
        padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Text(
              t1,
              style: TextStyle(
                  fontSize: 24,
                  fontFamily: 'Nunito2',
                  color: ColorTheme.getTextColor(brightness)),
            ),
            Text(
              t2,
              style: TextStyle(
                  fontSize: 35,
                  fontFamily: 'Nunito',
                  color: ColorTheme.getTextColor(brightness)),
            ),
            Text(
              t3,
              style: TextStyle(
                  fontSize: 18,
                  fontFamily: 'Nunito2',
                  color: ColorTheme.getTextColor(brightness)),
            ),
          ],
        ),
      ),
    ),
  );
}

createTextFormField(String labelText, TextEditingController controller,
    String? Function(String?) validator,
    {bool obscureText = false}) {
  return Column(
    children: [
      TextFormField(
        controller: controller,
        obscureText: obscureText,
        decoration: InputDecoration(
          labelText: labelText,
          border: const OutlineInputBorder(),
        ),
        validator: validator,
      ),
      const SizedBox(height: 10),
    ],
  );
}

createDivider() {
  return const Row(
    children: <Widget>[
      Expanded(
        child: Divider(
          color: Colors.grey,
          thickness: 1,
        ),
      ),
      Padding(
        padding: EdgeInsets.symmetric(horizontal: 10),
        child: Text(
          'or',
          style: TextStyle(color: Colors.grey),
        ),
      ),
      Expanded(
        child: Divider(
          color: Colors.grey,
          thickness: 1,
        ),
      ),
    ],
  );
}

final Random random = Random();

ElevatedButton createMoodButton(
    {required Color color,
    required String value1,
    required String value2,
    double borderRadius = 4.0,
    required VoidCallback? onPressed,
    double fontSize = 25.0,
    required BuildContext context}) {
  final brightness = Theme.of(context).brightness;
  return ElevatedButton(
    onPressed: onPressed,
    style: ElevatedButton.styleFrom(
      backgroundColor: color,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    ),
    child: SizedBox(
      width: 45,
      height: 80,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value1,
            style: TextStyle(
                fontSize: fontSize, color: ColorTheme.getTextColor(brightness)),
          ),
          Text(
            value2,
            style: TextStyle(
                fontSize: fontSize * 0.5,
                color: ColorTheme.getTextColor(brightness)),
          ),
        ],
      ),
    ),
  );
}

Container moodContainerHeading(String value, BuildContext context) {
  final brightness = Theme.of(context).brightness;
  final List<Color> colorForCards = ColorTheme.getColorForCards(brightness);
  return Container(
    height: 50,
    decoration: BoxDecoration(
      color: colorForCards[
          Random().nextInt(colorForCards.length)], // Background color
      borderRadius: BorderRadius.circular(10.0),
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Text(
          '👇',
          style: TextStyle(
              fontFamily: 'Baltijens',
              fontSize: 30,
              color: ColorTheme.getTextColor(brightness)),
        ),
        Text(
          value,
          style: TextStyle(
            fontFamily: 'Opensans2',
            fontSize: 15,
            color: ColorTheme.getTextColor(brightness),
          ),
        )
      ],
    ),
  );
}

showDeleteConfirmationDialog(
  BuildContext context,
  Event event,
) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Delete Event'),
      content: const Text('Are you sure you want to delete this event?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () async {
            final userBox = Hive.box<User>('users');
            final user = userBox.get('loggedInUser');
            if (user != null) {
              deleteEvent(event.key, context, user);
              Navigator.pop(context);
            }
          },
          child: const Text('Delete', style: TextStyle(color: Colors.red)),
        ),
      ],
    ),
  );
}

showEditEventDialog(
  BuildContext context,
  Event event,
) {
  final TextEditingController titleController =
      TextEditingController(text: event.title);
  DateTime selectedDate = event.date;
  final brightness = Theme.of(context).brightness;
  final List<Color> colorForCards = ColorTheme.getColorForCards(brightness);

  showDialog(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setState) => AlertDialog(
        title: const Text('Edit Event'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: titleController,
              decoration: InputDecoration(
                labelText: 'Title',
                fillColor:
                    colorForCards[Random().nextInt(colorForCards.length)],
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: colorForCards[Random().nextInt(colorForCards.length)],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: [
                  GestureDetector(
                    onTap: () async {
                      DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: selectedDate,
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2101),
                      );

                      if (pickedDate != null) {
                        TimeOfDay? pickedTime = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.fromDateTime(selectedDate),
                        );

                        if (pickedTime != null) {
                          setState(() {
                            selectedDate = DateTime(
                              pickedDate.year,
                              pickedDate.month,
                              pickedDate.day,
                              pickedTime.hour,
                              pickedTime.minute,
                            );
                          });
                        }
                      }
                    },
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today),
                        const SizedBox(width: 8),
                        Text(DateFormat('yyyy-MM-dd – kk:mm')
                            .format(selectedDate)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () async {
              final userBox = Hive.box<User>('users');
              final user = userBox.get('loggedInUser');
              final eventBox = Hive.box<Event>('events');
              final updatedEvent = Event(
                title: titleController.text,
                date: selectedDate,
                username: event.username,
                eventcount: eventBox.values.length,
              );

              await editEvent(updatedEvent, event, user!);
              Navigator.pop(context);
            },
            child: const Text('Save', style: TextStyle(color: Colors.green)),
          ),
        ],
      ),
    ),
  );
}

showLogout(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure?'),
        actions: <Widget>[
          TextButton(
            child: const Text('Cancel'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          TextButton(
            child: const Text('Confirm'),
            onPressed: () async {
              setLogin();
              final userBox = Hive.box<User>('users');
              //final loggedInUser = userBox.get('loggedInUser');

              await userBox.delete('loggedInUser');
              Navigator.of(context).push(MaterialPageRoute(builder: (ctx) {
                return const LoginPage();
              }));
            },
          ),
        ],
      );
    },
  );
}

Future<void> setLogin() async {
  final shrd = await SharedPreferences.getInstance();
  await shrd.setBool('login', false);
}

Future<void> showAboutAppDialog(BuildContext context) async {
  final PackageInfo packageInfo = await PackageInfo.fromPlatform();
  final String version = packageInfo.version;
  final String buildNumber = packageInfo.buildNumber;

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('About ℹ️'),
        content: Text(
          '''This app offers a comprehensive offline platform for managing daily activities, tracking moods, journaling, and organizing calendar events. It’s designed to boost productivity, support mental well-being, and foster self-awareness, all without needing an internet connection          
          
          Version: $version (Build $buildNumber)
          
          ''',
          style: const TextStyle(),
          textAlign: TextAlign.justify,
        ),
        actions: <Widget>[
          TextButton(
            child: const Text('Close'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}

showSnackBar(String message, BuildContext context) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      duration: const Duration(seconds: 2),
    ),
  );
}

showClear(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Clear All Data!'),
        content: const Text('Are you sure?'),
        actions: <Widget>[
          TextButton(
            child: const Text('Cancel'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          TextButton(
            child: const Text('Confirm'),
            onPressed: () async {
              final userBox = Hive.box<User>('users');
              final loggedInUser = userBox.get('loggedInUser');
              clearAllUserData(loggedInUser!, context);
            },
          ),
        ],
      );
    },
  );
}
