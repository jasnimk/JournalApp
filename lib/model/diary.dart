import 'package:hive/hive.dart';
import 'package:journal_app/model/user.dart';

part 'diary.g.dart';

@HiveType(typeId: 4)
class Diary extends HiveObject {
  @HiveField(0)
  final String date;

  @HiveField(1)
  String? content;

  @HiveField(2)
  User username;

  @HiveField(3)
  final List<String> imagePaths;

  @HiveField(4)
  final List<String> audioPaths;

  @HiveField(5)
  String? title;

  Diary({
    required this.date,
    this.content,
    required this.username,
    this.title,
    this.imagePaths = const [],
    this.audioPaths = const [],
  });
}
