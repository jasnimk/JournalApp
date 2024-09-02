// import 'dart:math';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:journal_app/Colors/color_theme.dart';
import 'package:journal_app/controllers/db_functions.dart';
import 'package:journal_app/model/moods.dart';
import 'package:journal_app/model/user.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

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

final ValueNotifier<List<MoodData>> moodDataNotifier = ValueNotifier([]);

// Future<void> fetchMoodData() async {
//   final box = Hive.box<User>('users');
//   final User? currentUser = box.get('loggedInUser');
//   final now = DateTime.now();
//   List<MoodData> chartData = [];

//   if (currentUser != null) {
//     DateTime startDate = now.subtract(const Duration(days: 6));

//     for (int i = 0; i < 7; i++) {
//       DateTime currentDate = startDate.add(Duration(days: i));

//       double averageValue =
//           await calculateAverageMoodValue(currentDate, currentUser);

//       String mood = moodFromAverage(averageValue);

//       chartData.add(MoodData(
//         date: currentDate,
//         moods: [mood],
//         values: [averageValue],
//         username: currentUser,
//         moodCount: 1,
//       ));
//     }
//   } else {
//     for (int i = 0; i < 7; i++) {
//       DateTime currentDate = now.subtract(Duration(days: 6 - i));
//       chartData.add(MoodData(
//         date: currentDate,
//         moods: ['Neutral'],
//         values: [40],
//         username: User(
//             fullname: 'default',
//             username: 'default',
//             password: 'default',
//             confirm: 'default',
//             email: 'default',
//             contact: 'default',
//             img: Uint8List(0)),
//         moodCount: 0,
//       ));
//     }
//   }

//   moodDataNotifier.value = chartData;
// }
Future<void> fetchMoodData() async {
  final box = Hive.box<User>('users');
  final User? currentUser = box.get('loggedInUser');
  final now = DateTime.now();
  List<MoodData> chartData = [];

  final moodBox = await Hive.openBox<MoodData>('moods');
  bool hasMoodData = moodBox.values
      .any((mood) => mood.username.username == currentUser?.username);

  if (currentUser != null && hasMoodData) {
    DateTime startDate = now.subtract(const Duration(days: 6));

    for (int i = 0; i < 7; i++) {
      DateTime currentDate = startDate.add(Duration(days: i));

      double averageValue =
          await calculateAverageMoodValue(currentDate, currentUser);

      String mood = moodFromAverage(averageValue);

      chartData.add(MoodData(
        date: currentDate,
        moods: [mood],
        values: [averageValue],
        username: currentUser,
        moodCount: 1,
      ));
    }
  } else {
    for (int i = 0; i < 7; i++) {
      DateTime currentDate = now.subtract(Duration(days: 6 - i));
      chartData.add(MoodData(
        date: currentDate,
        moods: ['Neutral'],
        values: [40],
        username: User(
            fullname: 'default',
            username: 'default',
            password: 'default',
            confirm: 'default',
            email: 'default',
            contact: 'default',
            img: Uint8List(0)),
        moodCount: 0,
      ));
    }
  }

  moodDataNotifier.value = chartData;
}

class MoodChart extends StatelessWidget {
  const MoodChart({super.key});

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final List<Color> colorForCards = ColorTheme.getColorForCards(brightness);
    return ValueListenableBuilder<List<MoodData>>(
      valueListenable: moodDataNotifier,
      builder: (context, chartData, _) {
        final now = DateTime.now();
        Map<int, String> valueToEmoji = {
          60: '🤩',
          50: '😊',
          40: '😑',
          30: '😴',
          20: '🫨',
          10: '😞',
        };

        return Container(
          height: 250,
          decoration: BoxDecoration(
            color: colorForCards[Random().nextInt(colorForCards.length)],
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: SfCartesianChart(
            primaryXAxis: DateTimeAxis(
              intervalType: DateTimeIntervalType.days,
              interval: 1,
              dateFormat: DateFormat('MM/dd'),
              minimum: now.subtract(const Duration(days: 7)),
              maximum: now,
            ),
            primaryYAxis: NumericAxis(
              minimum: 0,
              maximum: 60,
              interval: 10,
              axisLabelFormatter: (AxisLabelRenderDetails details) {
                int value = details.value.toInt();
                String emoji = valueToEmoji[value] ?? '';
                return ChartAxisLabel(emoji, details.textStyle);
              },
            ),
            series: <CartesianSeries>[
              LineSeries<MoodData, DateTime>(
                dataSource: chartData,
                xValueMapper: (MoodData moodData, _) => moodData.date,
                yValueMapper: (MoodData moodData, _) =>
                    moodData.values.isNotEmpty ? moodData.values.first : 0,
                markerSettings: const MarkerSettings(isVisible: true),
              )
            ],
          ),
        );
      },
    );
  }
}
