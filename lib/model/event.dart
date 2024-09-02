import 'package:hive_flutter/adapters.dart';
import 'package:journal_app/model/user.dart';
part 'event.g.dart';

@HiveType(typeId: 2)
class Event extends HiveObject {
  @HiveField(0)
  late final String title;

  @HiveField(1)
  DateTime date;

  @HiveField(2)
  User username;

  @HiveField(3)
  int eventcount;

  Event(
      {required this.title,
      required this.date,
      required this.username,
      required this.eventcount});
}
