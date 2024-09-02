import 'package:flutter/material.dart';
import 'package:journal_app/Colors/color_theme.dart';
import 'package:journal_app/model/user.dart';
import 'package:journal_app/screens/account_screen.dart';
import 'package:journal_app/screens/calendar_screen.dart';
import 'package:journal_app/screens/diary.dart';
import 'package:journal_app/screens/home_screen.dart';
import 'package:journal_app/screens/my_moods.dart';
import 'package:awesome_bottom_bar/awesome_bottom_bar.dart';

class BaseScreen extends StatefulWidget {
  const BaseScreen({super.key, required User user});

  @override
  State<BaseScreen> createState() => _BaseScreenState();
}

class _BaseScreenState extends State<BaseScreen> {
  int _selectedIndex = 0;
  final GlobalKey<DiaryScreenState> _diaryScreenKey =
      GlobalKey<DiaryScreenState>();

  late final List<Widget> _screens;
  int visit = 0;
  List<TabItem> items = [
    const TabItem(
      icon: Icons.home,
      title: 'Home',
    ),
    const TabItem(
      icon: Icons.calendar_month,
      title: 'Calendar',
    ),
    const TabItem(
      icon: Icons.mood,
      title: 'MyMoods',
    ),
    const TabItem(
      icon: Icons.book,
      title: 'Journal',
    ),
    const TabItem(
      icon: Icons.person,
      title: 'Profile',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _screens = [
      HomeScreen(onNavigate: (index) => setState(() => _selectedIndex = index)),
      const CalendarScreen(),
      const MyMoods(),
      DiaryScreen(key: _diaryScreenKey),
      const AccountScreen(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return Scaffold(
      backgroundColor: ColorTheme.getPrimaryColor(brightness),
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomBarFloating(
        items: items,
        backgroundColor: ColorTheme.getPrimaryColor(brightness),
        color: Colors.grey,
        colorSelected: ColorTheme.getTextColor(brightness),
        indexSelected: _selectedIndex,
        onTap: (int index) {
          setState(() {
            _selectedIndex = index;
          });
          if (index == 3) {
            _diaryScreenKey.currentState?.refreshDate();
          }
        },
      ),
    );
  }
}
