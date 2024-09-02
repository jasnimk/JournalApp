// ignore_for_file: prefer_typing_uninitialized_variables

import 'dart:async';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:intl/intl.dart';
import 'package:journal_app/Colors/color_theme.dart';
import 'package:journal_app/controllers/db_functions.dart';
import 'package:journal_app/model/diary.dart';
import 'package:journal_app/model/event.dart';
import 'package:journal_app/model/moods.dart';
import 'package:journal_app/model/user.dart';
import 'package:journal_app/widgets/app_drawer.dart';
import 'package:journal_app/widgets/custom_appbar.dart';
import 'package:journal_app/widgets/custom_widgets.dart';
import 'dart:math';

class HomeScreen extends StatefulWidget {
  final Function(int) onNavigate;
  const HomeScreen({super.key, required this.onNavigate});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final Random random = Random();
  final DateTime _currentDate = DateTime.now();
  late Box<User> userBox;
  late Box<Event> eventBox;
  late Box<MoodData> moodBox;
  late Box<Diary> journalBox;
  late StreamSubscription<BoxEvent> _userBoxSubscription;
  ValueNotifier<String> fullnameNotifier = ValueNotifier<String>("Loading...");
  late Stream<List<Event>> _userEvents;
  late ValueNotifier<int> entryCountNotifier;
  final selectedDate = DateTime.now();
  var loggedInUser;

  @override
  void initState() {
    super.initState();
    userBox = Hive.box<User>('users');
    eventBox = Hive.box<Event>('events');
    moodBox = Hive.box<MoodData>('moods');
    journalBox = Hive.box<Diary>('journals');

    _updateUserData();
    _userBoxSubscription = userBox.watch().listen((event) {
      if (event.key == 'loggedInUser') {
        _updateUserData();
      }
    });

    entryCountNotifier = ValueNotifier<int>(0);
    _updateEntryCount();
    updateUserStreak();

    eventBox.listenable().addListener(_updateEntryCount);
    moodBox.listenable().addListener(_updateEntryCount);
    journalBox.listenable().addListener(_updateEntryCount);

    if (loggedInUser != null) {
      _userEvents = fetchEvents(_currentDate, loggedInUser!);
    }
  }

  void _updateEntryCount() {
    if (loggedInUser != null) {
      entryCountNotifier.value = eventBox.values
              .where(
                  (event) => event.username.username == loggedInUser!.username)
              .length +
          moodBox.values
              .where((mood) => mood.username.username == loggedInUser!.username)
              .length +
          journalBox.values
              .where((journal) =>
                  journal.username.username == loggedInUser!.username)
              .length;
    } else {
      entryCountNotifier.value = 0;
    }
  }

  _updateUserData() {
    loggedInUser = userBox.get('loggedInUser');
    if (loggedInUser != null) {
      fullnameNotifier.value = loggedInUser.fullname;
    } else {
      fullnameNotifier.value = "User not found";
    }
  }

  void updateFullname(String newFullname) {
    if (loggedInUser != null) {
      loggedInUser.fullname = newFullname;
      userBox.put('loggedInUser', loggedInUser);
      fullnameNotifier.value = newFullname;
    }
  }

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final List<Color> colorForCards = ColorTheme.getColorForCards(brightness);
    final List<Map<String, dynamic>> slides = [
      {
        'image': 'assets/Images/calendar6 .jpg',
        'text': '"🚀 Set calendar reminders and never miss a moment! 📅✨"',
        'buttonText': '📅 Plan It!',
        'onPressed': () {
          widget.onNavigate(1);
        },
      },
      {
        'image': 'assets/Images/mood2.jpg',
        'text':
            '"🌈 Capture your vibe! Let’s track your mood and color your day."',
        'buttonText': '🎨 Mood Palette!',
        'onPressed': () {
          widget.onNavigate(2);
        },
      },
      {
        'image': 'assets/Images/journal1.jpg',
        'text':
            '"🖊️ Time to jot it down! Share your thoughts and memories in your journal now.🌟"',
        'buttonText': '✍️ Write Now!',
        'onPressed': () {
          widget.onNavigate(3);
        },
      },
    ];

    return Scaffold(
      appBar: customAppBar('Home', context),
      endDrawer: const AppDrawer(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: const BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                        color: Colors.transparent,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Nice to see you😌",
                                style: TextStyle(
                                    fontSize: 25,
                                    fontFamily: "Montserrat-Thin",
                                    color:
                                        ColorTheme.getTextColor(brightness))),
                            ValueListenableBuilder<String>(
                              valueListenable: fullnameNotifier,
                              builder: (context, fullname, child) {
                                return Text(
                                  fullname,
                                  style: TextStyle(
                                    fontSize: 35,
                                    fontFamily: "Nunito2",
                                    color: ColorTheme.getTextColor(brightness),
                                  ),
                                );
                              },
                            ),
                            Text(
                              ' "The only way to do great work is to love what you do — Steve Jobs" ',
                              style: TextStyle(
                                // fontSize: 35,
                                //fontFamily: "Nunito2",
                                color: ColorTheme.getTextColor(brightness),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Center(
              child: CarouselSlider(
                options: CarouselOptions(
                  height: 200.0,
                  enlargeCenterPage: true,
                  autoPlay: true,
                  aspectRatio: 16 / 9,
                  autoPlayInterval: const Duration(seconds: 3),
                  autoPlayAnimationDuration: const Duration(milliseconds: 800),
                  viewportFraction: 0.8,
                ),
                items: slides.map((slide) {
                  return Builder(
                    builder: (BuildContext context) {
                      return Container(
                        width: MediaQuery.of(context).size.width,
                        margin: const EdgeInsets.symmetric(horizontal: 5.0),
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage(slide['image']),
                            fit: BoxFit.cover,
                          ),
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              slide['text']!,
                              style: const TextStyle(
                                color: Colors.black,
                                fontFamily: "Gallia",
                                fontSize: 15.0,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 20.0),
                            ElevatedButton(
                              onPressed: slide['onPressed'],
                              child: Text(slide['buttonText']!),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                }).toList(),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  ValueListenableBuilder<Box<User>>(
                    valueListenable: Hive.box<User>('users').listenable(),
                    builder: (context, box, _) {
                      User? loggedInUser = box.get('loggedInUser');
                      int streak = loggedInUser?.currentStreak ?? 0;
                      return createContainer(
                        context,
                        'Current Streak',
                        '$streak',
                        'Days',
                        colorForCards[Random().nextInt(colorForCards.length)],
                      );
                    },
                  ),
                  const SizedBox(width: 10),
                  ValueListenableBuilder<int>(
                    valueListenable: entryCountNotifier,
                    builder: (context, entryCount, child) {
                      return createContainer(
                        context,
                        'Total Entries',
                        '$entryCount',
                        'This Week',
                        colorForCards[Random().nextInt(colorForCards.length)],
                      );
                    },
                  ),
                ],
              ),
            ),
            StreamBuilder<List<Event>>(
              stream: _userEvents,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No events found.'));
                }

                final events = snapshot.data!;

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: events.length,
                  itemBuilder: (context, index) {
                    final event = events[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                          vertical: 5, horizontal: 10),
                      color:
                          colorForCards[Random().nextInt(colorForCards.length)],
                      child: ListTile(
                        title: Text(
                          event.title,
                          style: const TextStyle(
                              color: Colors.black,
                              fontSize: 20,
                              fontFamily: 'Nunito'),
                        ),
                        subtitle: Text(
                          DateFormat('yyyy-MM-dd – kk:mm').format(event.date),
                          style: const TextStyle(
                              color: Colors.black, fontSize: 15),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const FaIcon(FontAwesomeIcons.pencil),
                              onPressed: () {
                                showEditEventDialog(context, event);
                              },
                            ),
                            IconButton(
                              icon: const FaIcon(FontAwesomeIcons.trash),
                              onPressed: () {
                                showDeleteConfirmationDialog(context, event);
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
