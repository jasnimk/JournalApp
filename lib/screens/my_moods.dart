import 'dart:math';

import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:journal_app/Colors/color_theme.dart';
import 'package:journal_app/controllers/db_functions.dart';
import 'package:journal_app/model/moods.dart';
import 'package:journal_app/model/user.dart';
import 'package:journal_app/widgets/app_drawer.dart';
import 'package:journal_app/widgets/custom_appbar.dart';
import 'package:journal_app/widgets/custom_widgets.dart';
import 'package:journal_app/widgets/mood_chart.dart';
import 'package:journal_app/widgets/suggestion_widget.dart';

final Map<String, double> moodWeights = {
  'Excited': 60,
  'Happy': 50,
  'Neutral': 40,
  'Sleepy': 30,
  'Confused': 20,
  'Sad': 10,
};

class MyMoods extends StatefulWidget {
  const MyMoods({super.key});

  @override
  State<MyMoods> createState() => _MyMoodsState();
}

class _MyMoodsState extends State<MyMoods> {
  late Box<User> userBox;
  late User loggedInUser;
  String userName = "Loading...";

  @override
  void initState() {
    super.initState();
    userBox = Hive.box<User>('users');
    _updateUserData();
    fetchMoodData();
  }

  _updateUserData() {
    setState(() {
      loggedInUser = userBox.get('loggedInUser')!;
      userName = loggedInUser.username;
      fetchMoodDataAndGenerateSuggestion(loggedInUser);
    });
  }

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final List<Color> colorForCards = ColorTheme.getColorForCards(brightness);
    return Scaffold(
      appBar: customAppBar('My Moods', context),
      endDrawer: const AppDrawer(),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const SuggestionWidget(),
              const Text(
                'How are you feeling today?',
                style: TextStyle(
                    fontFamily: 'Opensans2', fontSize: 20, color: Colors.black),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  createMoodButton(
                    color:
                        colorForCards[Random().nextInt(colorForCards.length)],
                    value1: '😊',
                    onPressed: () => _showMoodSelectionDialog(context, 'Happy'),
                    value2: 'Happy',
                    context: context,
                  ),
                  createMoodButton(
                    color:
                        colorForCards[Random().nextInt(colorForCards.length)],
                    value1: '😞',
                    onPressed: () => _showMoodSelectionDialog(context, 'Sad'),
                    value2: 'Sad',
                    context: context,
                  ),
                  createMoodButton(
                    color:
                        colorForCards[Random().nextInt(colorForCards.length)],
                    value1: '😑',
                    onPressed: () =>
                        _showMoodSelectionDialog(context, 'Neutral'),
                    value2: 'Neutral',
                    context: context,
                  ),
                ],
              ),
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  createMoodButton(
                    color:
                        colorForCards[Random().nextInt(colorForCards.length)],
                    value1: '😴',
                    onPressed: () =>
                        _showMoodSelectionDialog(context, 'Sleepy'),
                    value2: 'Sleepy',
                    context: context,
                  ),
                  createMoodButton(
                    color:
                        colorForCards[Random().nextInt(colorForCards.length)],
                    value1: '🫨',
                    onPressed: () =>
                        _showMoodSelectionDialog(context, 'Confused'),
                    value2: 'Confused',
                    context: context,
                  ),
                  createMoodButton(
                    color:
                        colorForCards[Random().nextInt(colorForCards.length)],
                    value1: '🤩',
                    onPressed: () =>
                        _showMoodSelectionDialog(context, 'Excited'),
                    value2: 'Excited',
                    context: context,
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: moodContainerHeading(
                    'See Your Mood Insights[Last 7 days]!', context),
              ),
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: MoodChart(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _selectMood(String mood) async {
    final moodData = MoodData(
      date: DateTime.now(),
      moods: [mood],
      values: [moodWeights[mood]!],
      username: loggedInUser,
      moodCount: 1,
    );

    await addMoodData(moodData, context, loggedInUser);

    fetchMoodData();
  }

  void _showMoodSelectionDialog(BuildContext context, String mood) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Mood'),
          content: Text('Are you sure you want to select "$mood"?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                _selectMood(mood);
                Navigator.of(context).pop();
              },
              child: const Text('Confirm'),
            ),
          ],
        );
      },
    );
  }
}
