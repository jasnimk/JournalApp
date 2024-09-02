// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:journal_app/controllers/notification_service.dart';
import 'package:journal_app/controllers/notification_task.dart';
import 'package:journal_app/model/diary.dart';
import 'package:journal_app/model/event.dart';
import 'package:journal_app/model/moods.dart';
import 'package:journal_app/model/user.dart';
import 'package:journal_app/widgets/custom_widgets.dart';
import 'package:journal_app/widgets/mood_chart.dart';
import 'package:shared_preferences/shared_preferences.dart';

late Box<User> userBox;
late Box<Event> eventBox;
var noti = NotificationService();

const List<String> positiveQuotes = [
  "You're on fire this week! 🔥 Your positive vibes are inspiring. Keep shining and spread the joy! 🌈😊",
  "Fantastic week ahead! ✨ Your positivity is truly uplifting. Keep embracing the good times and share the love! ❤️🎉",
  "Well done! 🏆 Your week has been full of positivity. Continue to radiate happiness and inspire those around you. 🌟😄",
  "Amazing effort this week! 🌺 Your cheerful spirit is contagious. Keep enjoying the good moments and sharing your positivity. 🌟🙌",
  "Cheers to a week of great vibes! 🍾 Your optimism is making waves. Keep riding the wave of happiness and encouraging others! 🌊😊",
  "You're thriving! 🌟 Your positive energy is through the roof. Keep up the great work and continue to spread the joy. 🌞💪",
  "Kudos to you! 👏 Your positive mindset is shining bright. Keep basking in the good times and sharing your smiles. 😃🌈",
  "What a wonderful week! 🎉 Your positivity is infectious. Continue to celebrate the good moments and inspire those around you. 🌟💖",
  "You're doing great! 🌟 Your optimism is lighting up the week. Keep embracing the positive and sharing your happiness with others. 😊✨",
  "Bravo! 🏅 You've had a week filled with positivity. Keep spreading those good vibes and making the most of every moment! 🌈👏",
];
const List<String> negativeQuotes = [
  "It's been a tough week, and that's okay. 🌧️ Remember to be kind to yourself and take time for self-care. 🌼💖",
  "Challenging times can be tough. 🌪️ Consider reaching out to loved ones or finding a calming activity to help lift your spirits. 💬🧘‍♀️",
  "It seems like things have been rough lately. 🌫️ Take a deep breath and try something you enjoy to bring a bit of light to your day. 🌟📚",
  "You’ve faced some challenges this week. 💔 Remember that it's okay to ask for support or find solace in activities that bring you comfort. 🤝🌿",
  "It looks like you’ve had a bit of a struggle this week. 🌧️ Finding a relaxing hobby or talking things over with someone might help improve your mood. 🎨🗣️",
  "This week has been tough, but you're stronger than you think. 💪 Try engaging in activities that help you relax and recharge. 🌺📖",
  "It’s been a difficult week, but you’re not alone. 🤗 Consider spending time with friends or indulging in self-care to help brighten your days. 🌈🎶",
  "Tough weeks can be challenging, but they also offer a chance to reflect and grow. 🌱 Take time for self-compassion and enjoy small moments of joy. 🌸💤",
  "It seems like you've had a rough week. 🌩️ Give yourself permission to rest and seek comfort in things that bring you peace. 🍵🌟",
  "Challenging moments are part of life’s journey. 🌿 Embrace this time for self-reflection and find comfort in activities that uplift your spirit. 🧘‍♀️🌷",
];
const List<String> neutralQuotes = [
  "Your mood has been balanced this week. ⚖️ Explore new hobbies or revisit old ones to add a bit more joy to your days. 🎨🚴‍♀️",
  "It's been a steady week for you. 🌟 Consider trying something new or spending time with loved ones to bring a touch of excitement to your routine. 🌈📚",
  "Your mood has been consistent. 🎭 Why not use this as an opportunity to indulge in activities you love or try something fresh? 🌟🎶",
  "A steady mood is a good base. 🏠 Add a bit of fun to your daily life with new experiences or creative projects. 🌟🖌️",
  "You’ve had a stable week. 🌼 It might be a great time to focus on activities that uplift you and bring a bit of variety to your schedule. 📖🚶‍♀️",
  "Your mood has remained steady. 🌟 Consider incorporating enjoyable activities or spending time in nature to enhance your daily experiences. 🍃🎨",
  "A balanced mood is a positive sign. ⚖️ Engage in things that make you happy or explore new interests to add a spark to your days. 🎶🎯",
  "Your mood has been even this week. 🌺 Use this stability to explore new passions or revisit old hobbies that bring you joy. 📚🎨",
  "It looks like your mood has been stable. 🌟 Why not take this opportunity to try something new or enjoy activities you haven’t had time for recently? 🌼🚴‍♂️",
  "You’ve had a steady mood. ⚖️ Infuse your days with new experiences or activities you enjoy to bring a little extra happiness into your routine. 🎨🍀",
];

const List<String> variedMoodQuotes = [
  "This week has seen some ups and downs. 🌈 Take time to reflect on what might be affecting your mood and explore activities that uplift you. 🌟📝",
  "Your mood has been fluctuating. 🌿 Consider identifying any triggers and try incorporating calming or joyful activities into your routine. 🌼🧩",
  "You've experienced a range of emotions this week. 🌟 Reflect on your experiences and consider ways to nurture your well-being. 🌱✨",
  "This week has been full of mood swings. 🤔 Explore what might be causing these changes and find balance through self-care and positive activities. 🌼💡",
  "Your mood has been varied. 🌺 Reflect on what’s been influencing you and consider adding routines or hobbies that bring you peace and joy. 🌟🧘‍♀️",
  "It seems your mood has shifted this week. 🌈 Understanding the factors behind this can help you focus on activities that support your mental well-being. 🌱📝",
  "You've had a mixed bag of emotions. 🌻 Take a moment to analyze what might be affecting you and introduce positive changes to enhance your mood. 💫📖",
  "Your emotions have varied this week. 🌟 Reflect on any patterns you notice and try engaging in activities that boost your happiness and relaxation. 🌼🌱",
  "This week has brought a mix of moods. 🌿 Consider exploring what’s been influencing you and find ways to integrate positive experiences into your life. 🌟🧘‍♂️",
  "You've experienced a range of feelings. 🌺 Reflect on these changes and explore strategies or hobbies that could help stabilize and uplift your mood. 🌼💭",
];

final ValueNotifier<String> suggestionNotifier = ValueNotifier('');
final random = Random();

Future<void> saveUser(String username, User value, BuildContext context) async {
  var userBox = await Hive.openBox<User>('users');
  try {
    if (userBox.containsKey(username)) {
      throw Exception('Username already exists');
    }
    await userBox.put(username, value);
    Navigator.of(context).pop();
  } catch (e) {
    showSnackBar(e.toString(), context);
  }
}

User? login(String username, String password, BuildContext context) {
  // Define default credentials
  const String defaultUsername = 'admin';
  const String defaultPassword = 'admin123';

  // Check if the provided credentials match the default ones
  if (username == defaultUsername && password == defaultPassword) {
    return User(
      fullname: 'Admin',
      username: defaultUsername,
      password: defaultPassword,
      confirm: defaultPassword,
      email: 'email@gmail.com',
      contact: '123456789',
      img: Uint8List(0),
    );
  }
  userBox = Hive.box<User>('users');
  final user = userBox.get(username);
  if (user != null) {
    if (user.password == password) {
      return user;
    } else {
      showSnackBar(
          'Password does not match for user: ${user.username}', context);
    }
  } else {
    showSnackBar('User not found: $username', context);
  }
  return null;
}

Future<void> addEvent(
    Event value, BuildContext context, User currentUser) async {
  var eventBox = await Hive.openBox<Event>('events');
  try {
    value.username = currentUser;
    await eventBox.add(value);
    updateUserStreak();
    registerNotificationTask(
      value.eventcount,
      value.title,
      'Your event is starting now!',
      value.date,
    );
  } catch (e) {
    showSnackBar(e.toString(), context);
  }
}

Stream<List<Event>> fetchEvents(DateTime day, User currentUser) async* {
  final eventBox = await Hive.openBox<Event>('events');
  final streamController = StreamController<List<Event>>();
  streamController.add(
    eventBox.values
        .where((e) =>
            e.date.year == day.year &&
            e.date.month == day.month &&
            e.date.day == day.day &&
            e.username.username == currentUser.username)
        .toList(),
  );
  eventBox.watch().listen((_) {
    streamController.add(
      eventBox.values
          .where((e) =>
              e.date.year == day.year &&
              e.date.month == day.month &&
              e.date.day == day.day &&
              e.username.username == currentUser.username)
          .toList(),
    );
  });
  yield* streamController.stream;
}

Stream<int> streamEventCount(DateTime day, User currentUser) async* {
  var eventBox = await Hive.openBox<Event>('events');
  final streamController = StreamController<int>();
  eventBox.watch().listen((event) {
    final count = eventBox.values
        .where((e) =>
            e.date.year == day.year &&
            e.date.month == day.month &&
            e.date.day == day.day &&
            e.username.username == currentUser.username)
        .length;
    streamController.add(count);
  });
  final initialCount = eventBox.values
      .where((e) =>
          e.date.year == day.year &&
          e.date.month == day.month &&
          e.date.day == day.day &&
          e.username.username == currentUser.username)
      .length;
  streamController.add(initialCount);
  yield* streamController.stream;
}

Future<void> deleteEvent(
    int key, BuildContext context, User currentUser) async {
  try {
    var eventBox = await Hive.openBox<Event>('events');
    Event? event = eventBox.get(key);
    if (event != null && event.username.username == currentUser.username) {
      await eventBox.delete(key);
    } else {
      throw Exception('Event not found or does not belong to the current user');
    }
  } catch (e) {
    showSnackBar('Error deleting event: ${e.toString()}', context);
  }
}

Future<void> setLogin() async {
  final shrd = await SharedPreferences.getInstance();
  await shrd.setBool('login', true);
}

Future<List<Event>> fetchAllData(User currentUser) async {
  var eventBox = await Hive.openBox<Event>('events');
  return eventBox.values
      .where((event) => event.username.username == currentUser.username)
      .toList();
}

Future<void> editEvent(
    Event updatedEvent, Event originalEvent, User currentUser) async {
  final eventBox = Hive.box<Event>('events');

  if (originalEvent.username.username != currentUser.username) {
    throw Exception('You do not have permission to edit this event');
  }

  final newEvent = Event(
    title: updatedEvent.title,
    date: updatedEvent.date,
    username: currentUser,
    eventcount: updatedEvent.eventcount,
  );

  final eventKey = originalEvent.key;

  await eventBox.put(eventKey, newEvent);

  registerNotificationTask(
    newEvent.eventcount,
    newEvent.title,
    'Your event is starting now!',
    newEvent.date,
  );
}

Future<void> addMoodData(
    MoodData moodData, BuildContext context, User currentUser) async {
  var moodBox = await Hive.openBox<MoodData>('moods');
  try {
    moodData.username = currentUser;
    await moodBox.add(moodData);
    updateUserStreak();
    await fetchMoodDataAndGenerateSuggestion(currentUser);
  } catch (e) {
    showSnackBar('Error saving mood data: ${e.toString()}', context);
  }
  moodBox.values
      .where((m) => m.username.username == currentUser.username)
      .toList();
}

Future<double> calculateAverageMoodValue(DateTime date, User user) async {
  var moodBox = await Hive.openBox<MoodData>('moods');

  final moodDataList = moodBox.values
      .where((m) =>
          m.date.year == date.year &&
          m.date.month == date.month &&
          m.date.day == date.day &&
          m.username.username == user.username)
      .toList();

  if (moodDataList.isEmpty) {
    return 0.0;
  }

  List<double> allValues = [];
  for (var moodData in moodDataList) {
    allValues.addAll(moodData.values);
  }

  final total = allValues.reduce((a, b) => a + b);
  final average = total / allValues.length;

  return average;
}

Future<void> saveJournal(
    Diary journalData, BuildContext context, User currentUser) async {
  var journalBox = await Hive.openBox<Diary>('journals');
  try {
    Diary newDiary = Diary(
        date: journalData.date,
        content: journalData.content,
        username: currentUser,
        title: journalData.title,
        imagePaths: journalData.imagePaths,
        audioPaths: journalData.audioPaths);

    await journalBox.add(newDiary);
    updateUserStreak();

    showSnackBar('Journal entry saved successfully!', context);
  } catch (e) {
    showSnackBar('Error adding journal entry: ${e.toString()}', context);
  }
}

Future<void> updateUserProfile({
  required String fullname,
  required String email,
  required String contact,
  Uint8List? image,
}) async {
  final userBox = Hive.box<User>('users');
  final loggedInUser = userBox.get('loggedInUser');

  if (loggedInUser != null) {
    loggedInUser.fullname = fullname;
    loggedInUser.email = email;
    loggedInUser.contact = contact;
    loggedInUser.img = image;
    await userBox.put('loggedInUser', loggedInUser);
  }
}

Future<void> deleteJournalItem(
    String itemPath, bool isImage, User currentUser) async {
  final diaryBox = Hive.box<Diary>('journals');

  Diary? diaryToUpdate;
  dynamic diaryKey;

  for (var entryKey in diaryBox.keys) {
    final diary = diaryBox.get(entryKey) as Diary;
    if (diary.username.username == currentUser.username) {
      if (isImage) {
        if (diary.imagePaths.contains(itemPath)) {
          diaryToUpdate = diary;
          diaryKey = entryKey;
          break;
        }
      } else {
        if (diary.audioPaths.contains(itemPath)) {
          diaryToUpdate = diary;
          diaryKey = entryKey;
          break;
        }
      }
    }
  }

  if (diaryToUpdate != null && diaryKey != null) {
    if (isImage) {
      diaryToUpdate.imagePaths.remove(itemPath);
    } else {
      diaryToUpdate.audioPaths.remove(itemPath);
    }

    await diaryBox.put(diaryKey, diaryToUpdate);

    final file = File(itemPath);
    if (await file.exists()) {
      await file.delete();
    }
  }
}

Future<void> updateJournal(int key, Diary updatedJournal, BuildContext context,
    User currentUser) async {
  try {
    final diaryBox = Hive.box<Diary>('journals');

    Diary? existingJournal = diaryBox.get(key);
    if (existingJournal != null &&
        existingJournal.username.username == currentUser.username) {
      Diary newDiary = Diary(
        date: updatedJournal.date,
        content: updatedJournal.content,
        username: currentUser,
        title: updatedJournal.title,
        imagePaths: updatedJournal.imagePaths,
        audioPaths: updatedJournal.audioPaths,
      );
      await diaryBox.put(key, newDiary);
      updateUserStreak();
      showSnackBar('Journal Updated!', context);
    } else {
      throw Exception(
          'Journal entry not found or does not belong to the current user');
    }
  } catch (e) {
    throw Exception('Failed to update journal entry: ${e.toString()}');
  }
}

Future<void> deleteJournalEntry(int key, User currentUser) async {
  final box = await Hive.openBox<Diary>('journals');

  if (box.containsKey(key)) {
    Diary? entry = box.get(key);
    if (entry != null && entry.username.username == currentUser.username) {
      await box.delete(key);
    } else {
      throw Exception(
          'Entry with key $key not found or does not belong to the current user');
    }
  } else {
    throw Exception('Entry with key $key not found');
  }
}

Future<void> updatePassword(String username, String newPassword) async {
  var userBox = Hive.box<User>('users');
  User? user = userBox.values.firstWhere((user) => user.username == username);

  user.password = newPassword;
  user.confirm = newPassword;
  await userBox.put(user.username, user);
}

String moodFromAverage(double average) {
  if (average >= 55) {
    return 'Excited';
  } else if (average >= 45) {
    return 'Happy';
  } else if (average >= 35) {
    return 'Neutral';
  } else if (average >= 25) {
    return 'Sleepy';
  } else if (average >= 15) {
    return 'Confused';
  } else {
    return 'Sad';
  }
}

String generateSuggestion(List<MoodData> moodData) {
  if (moodData.length < 7) {
    return "Not enough data to generate a suggestion.";
  }

  double averageMood =
      moodData.map((data) => data.values.first).reduce((a, b) => a + b) / 7;
  String overallMood = moodFromAverage(averageMood);

  int positiveCount = moodData.where((data) => data.values.first >= 45).length;
  int negativeCount = moodData.where((data) => data.values.first < 35).length;

  if (positiveCount >= 5) {
    final randomIndex = random.nextInt(positiveQuotes.length);
    return positiveQuotes[randomIndex];
  } else if (negativeCount >= 5) {
    final randomIndex = random.nextInt(negativeQuotes.length);
    return negativeQuotes[randomIndex];
  } else if (overallMood == 'Neutral') {
    final randomIndex = random.nextInt(neutralQuotes.length);
    return neutralQuotes[randomIndex];
  } else {
    final randomIndex = random.nextInt(variedMoodQuotes.length);
    return variedMoodQuotes[randomIndex];
  }
}

Future<void> fetchMoodDataAndGenerateSuggestion(User currentUser) async {
  final now = DateTime.now();
  List<MoodData> moodData = [];

  for (int i = 6; i >= 0; i--) {
    final date = now.subtract(Duration(days: i));
    double averageValue = await calculateAverageMoodValue(date, currentUser);

    moodData.add(MoodData(
      date: date,
      moods: [moodFromAverage(averageValue)],
      values: [averageValue],
      username: currentUser,
      moodCount: 1,
    ));
  }

  String suggestion = generateSuggestion(moodData);
  suggestionNotifier.value = suggestion;
}

void updateUserStreak() {
  final User? loggedInUser = Hive.box<User>('users').get('loggedInUser');
  if (loggedInUser == null) return;

  final today = DateTime.now();
  final lastEntryDate = loggedInUser.lastUpdateDate;

  final difference = today.difference(lastEntryDate).inDays;

  if (difference == 1) {
    loggedInUser.currentStreak = (loggedInUser.currentStreak) + 1;
  } else if (difference > 1) {
    loggedInUser.currentStreak = 1;
  }

  loggedInUser.lastUpdateDate = today;

  Hive.box<User>('users').put('loggedInUser', loggedInUser);
}

Future<void> clearAllUserData(User currentUser, BuildContext context) async {
  try {
    // Clear events
    final eventBox = await Hive.openBox<Event>('events');
    final eventsToDelete = eventBox.values
        .where((event) => event.username.username == currentUser.username)
        .toList();
    for (var event in eventsToDelete) {
      await eventBox.delete(event.key);
    }

    // Clear journals
    final journalBox = await Hive.openBox<Diary>('journals');
    final journalsToDelete = journalBox.values
        .where((journal) => journal.username.username == currentUser.username)
        .toList();
    for (var journal in journalsToDelete) {
      for (var imagePath in journal.imagePaths) {
        final file = File(imagePath);
        if (await file.exists()) {
          await file.delete();
        }
      }
      for (var audioPath in journal.audioPaths) {
        final file = File(audioPath);
        if (await file.exists()) {
          await file.delete();
        }
      }
      await journalBox.delete(journal.key);
    }

    // Clear moods
    final moodBox = await Hive.openBox<MoodData>('moods');
    final moodsToDelete = moodBox.values
        .where((mood) => mood.username.username == currentUser.username)
        .toList();
    for (var mood in moodsToDelete) {
      await moodBox.delete(mood.key);
    }

    // Reset user streak
    currentUser.currentStreak = 1;
    currentUser.lastUpdateDate = DateTime.now();
    await Hive.box<User>('users').put(currentUser.username, currentUser);

    showSnackBar('All your data has been cleared successfully', context);

    // Refresh mood chart data
    await fetchMoodData();
  } catch (e) {
    showSnackBar('Error clearing data: ${e.toString()}', context);
  }
}
