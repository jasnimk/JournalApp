// ignore_for_file: prefer_typing_uninitialized_variables, use_build_context_synchronously

import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:intl/intl.dart';
import 'package:journal_app/Colors/color_theme.dart';
import 'package:journal_app/controllers/db_functions.dart';
import 'package:journal_app/model/event.dart';
import 'package:journal_app/model/user.dart';
import 'package:journal_app/widgets/app_drawer.dart';
import 'package:journal_app/widgets/custom_appbar.dart';
import 'package:journal_app/widgets/custom_widgets.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  int eventcount = 0;
  var loggedInUser;
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();

  late Box<User> userBox;
  late Box<Event> eventBox;
  String userName = "Loading...";

  late ValueListenable<Box<Event>> eventListenable;
  List<Event> _events = [];

  @override
  @override
  void initState() {
    super.initState();
    userBox = Hive.box<User>('users');
    eventBox = Hive.box<Event>('events');
    eventListenable = eventBox.listenable();
    _updateUserData();
    _loadEvents();
  }

  List<Event> _getEventsForDay(DateTime day) {
    return _events.where((event) => isSameDay(event.date, day)).toList();
  }

  _updateUserData() {
    setState(() {
      loggedInUser = userBox.get('loggedInUser');

      if (loggedInUser != null) {
        userName = loggedInUser.username;
      } else {
        userName = "User not found";
      }
    });
  }

  void _loadEvents() {
    fetchEvents(_focusedDay, loggedInUser).listen((events) {
      setState(() {
        _events = events;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final List<Color> colorForCards = ColorTheme.getColorForCards(brightness);
    return Scaffold(
      appBar: customAppBar('Calendar', context),
      endDrawer: const AppDrawer(),
      body: Column(
        children: [
          ValueListenableBuilder<Box<Event>>(
            valueListenable: eventListenable,
            builder: (context, eventBox, _) {
              return TableCalendar(
                firstDay: DateTime.utc(2020, 1, 1),
                lastDay: DateTime.utc(2030, 12, 31),
                focusedDay: _focusedDay,
                selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                  });
                },
                eventLoader: _getEventsForDay,
                calendarStyle: CalendarStyle(
                  markersMaxCount: 1,
                  markerSizeScale: 0.1,
                  markersAutoAligned: true,
                  canMarkersOverflow: false,
                  markerSize: 3,
                  selectedDecoration: const BoxDecoration(
                    color: Colors.transparent,
                    shape: BoxShape.rectangle,
                  ),
                  todayDecoration: const BoxDecoration(
                    color: Colors.transparent,
                    shape: BoxShape.rectangle,
                  ),
                  selectedTextStyle: const TextStyle(color: Colors.amber),
                  todayTextStyle: const TextStyle(color: Colors.blue),
                  defaultTextStyle:
                      TextStyle(color: ColorTheme.getTextColor(brightness)),
                  weekendTextStyle:
                      TextStyle(color: ColorTheme.getTextColor(brightness)),
                  markerDecoration: const BoxDecoration(
                    color: Color.fromARGB(255, 75, 49, 10),
                    shape: BoxShape.circle,
                  ),
                ),
                headerStyle: HeaderStyle(
                  titleTextStyle:
                      TextStyle(color: ColorTheme.getTextColor(brightness)),
                  leftChevronIcon: Icon(Icons.chevron_left,
                      color: ColorTheme.getTextColor(brightness)),
                  rightChevronIcon: Icon(Icons.chevron_right,
                      color: ColorTheme.getTextColor(brightness)),
                  formatButtonVisible: false,
                  leftChevronPadding:
                      const EdgeInsets.symmetric(horizontal: 10.0),
                  rightChevronPadding:
                      const EdgeInsets.symmetric(horizontal: 10.0),
                  titleCentered: true,
                ),
                daysOfWeekStyle: const DaysOfWeekStyle(
                  weekdayStyle: TextStyle(color: Colors.transparent),
                  weekendStyle: TextStyle(color: Colors.transparent),
                ),
              );
            },
          ),
          const SizedBox(height: 10),
          Expanded(
            child: ValueListenableBuilder<Box<Event>>(
              valueListenable: eventListenable,
              builder: (context, eventBox, _) {
                final events = _getEventsForDay(_selectedDay);

                if (events.isEmpty) {
                  return const Center(child: Text('No events found.'));
                }

                return ListView.builder(
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
                          style: TextStyle(
                              color: ColorTheme.getTextColor(brightness),
                              fontSize: 20,
                              fontFamily: 'Nunito'),
                        ),
                        subtitle: Text(
                          DateFormat('yyyy-MM-dd – kk:mm').format(event.date),
                          style: TextStyle(
                              color: ColorTheme.getTextColor(brightness),
                              fontSize: 15),
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
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddEventDialog(_selectedDay);
        },
        child: const FaIcon(FontAwesomeIcons.plus),
      ),
    );
  }

  void _showAddEventDialog(DateTime selectedDate) {
    final brightness = Theme.of(context).brightness;
    final List<Color> colorForCards = ColorTheme.getColorForCards(brightness);
    final TextEditingController titleController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: const Text('Add Event'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: titleController,
                decoration: InputDecoration(
                  labelText: 'Title',
                  fillColor:
                      colorForCards[Random().nextInt(colorForCards.length)],
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: colorForCards[Random().nextInt(colorForCards.length)],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: () async {
                        DateTime? pickedDate = await showDatePicker(
                          context: context,
                          initialDate: selectedDate,
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2101),
                        );

                        if (pickedDate != null) {
                          TimeOfDay? pickedTime = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay.fromDateTime(selectedDate),
                          );

                          if (pickedTime != null) {
                            setState(() {
                              selectedDate = DateTime(
                                pickedDate.year,
                                pickedDate.month,
                                pickedDate.day,
                                pickedTime.hour,
                                pickedTime.minute,
                              );
                            });
                          }
                        }
                      },
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today),
                          const SizedBox(width: 8),
                          Text(DateFormat('yyyy-MM-dd – kk:mm')
                              .format(selectedDate)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                if (titleController.text.isNotEmpty) {
                  eventcount++;
                  _addEvent(titleController.text, selectedDate);

                  Navigator.pop(context);
                } else {
                  showSnackBar("Title shouldn't be empty!", context);
                }
              },
              child: const Text('Save', style: TextStyle(color: Colors.green)),
            ),
          ],
        ),
      ),
    );
  }

  void _addEvent(String title, DateTime date) {
    final event = Event(
        title: title,
        date: date,
        username: loggedInUser,
        eventcount: eventcount);
    addEvent(event, context, loggedInUser);

    setState(() {});
  }
}
