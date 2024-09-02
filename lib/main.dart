import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:journal_app/controllers/notification_service.dart';
import 'package:journal_app/model/diary.dart';
import 'package:journal_app/model/event.dart';
import 'package:journal_app/model/moods.dart';
import 'package:journal_app/model/user.dart';
import 'package:journal_app/screens/calendar_screen.dart';
import 'package:journal_app/screens/journal.dart';
import 'package:journal_app/screens/my_moods.dart';
import 'package:journal_app/screens/splash_screen.dart';
import 'package:workmanager/workmanager.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:journal_app/controllers/notification_task.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await NotificationService().init();

  Workmanager().initialize(callbackDispatcher, isInDebugMode: false);

  Hive.registerAdapter(UserAdapter());
  Hive.registerAdapter(EventAdapter());
  Hive.registerAdapter(MoodDataAdapter());
  Hive.registerAdapter(DiaryAdapter());

  await Hive.openBox<User>('users');
  await Hive.openBox<Event>('events');
  await Hive.openBox<MoodData>('moods');
  await Hive.openBox<Diary>('journals');

  final prefs = await SharedPreferences.getInstance();
  final isDarkMode = prefs.getBool('isDarkMode') ?? false;
  final initialThemeData = isDarkMode ? ThemeData.dark() : ThemeData.light();

  runApp(MyApp(initialThemeData: initialThemeData));
}

class MyApp extends StatefulWidget {
  final ThemeData initialThemeData;

  const MyApp({super.key, required this.initialThemeData});

  static MyAppState? of(BuildContext context) {
    return context.findAncestorStateOfType<MyAppState>();
  }

  @override
  MyAppState createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  late ThemeData _themeData;

  @override
  void initState() {
    super.initState();
    _themeData = widget.initialThemeData;
  }

  void setThemeData(ThemeData themeData) async {
    setState(() {
      _themeData = themeData;
    });

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', themeData.brightness == Brightness.dark);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: _themeData,
      home: const Splash(),
      routes: {
        '/calendar': (context) => const CalendarScreen(),
        '/mood': (context) => const MyMoods(),
        '/journal': (context) => Journal(selecteddate: DateTime.now()),
      },
    );
  }
}
