import 'dart:typed_data';
import 'package:hive_flutter/adapters.dart';

part 'user.g.dart';

@HiveType(typeId: 1)
class User {
  @HiveField(0)
  String fullname;

  @HiveField(1)
  String username;

  @HiveField(2)
  String password;

  @HiveField(3)
  String confirm;

  @HiveField(4)
  String email;

  @HiveField(5)
  String contact;

  @HiveField(6)
  Uint8List? img;

  @HiveField(7)
  int? entrycount;

  @HiveField(8)
  DateTime lastUpdateDate;

  @HiveField(9)
  int currentStreak;

  User({
    required this.fullname,
    required this.username,
    required this.password,
    required this.confirm,
    required this.email,
    required this.contact,
    required this.img,
    this.entrycount,
    DateTime? lastUpdateDate,
    this.currentStreak = 1,
  }) : lastUpdateDate = lastUpdateDate ?? DateTime.now();
}
