import 'package:hive/hive.dart';
import 'package:journal_app/model/user.dart';

part 'moods.g.dart';

@HiveType(typeId: 3)
class MoodData extends HiveObject {
  @HiveField(0)
  final DateTime date;

  @HiveField(1)
  final List<String> moods;

  @HiveField(2)
  final List<double> values;

  @HiveField(3)
  User username;

  @HiveField(4)
  final int moodCount;

  MoodData({
    required this.date,
    required this.moods,
    required this.values,
    required this.username,
    required this.moodCount,
  });
}
