import 'dart:io';
import 'dart:math';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:intl/intl.dart';
import 'package:journal_app/Colors/color_theme.dart';
import 'package:journal_app/controllers/db_functions.dart';
import 'package:journal_app/model/diary.dart';
import 'package:journal_app/model/user.dart';
import 'package:journal_app/screens/edit_journal.dart';
import 'package:journal_app/screens/journal.dart';
import 'package:journal_app/screens/preview_image.dart';
import 'package:journal_app/widgets/app_drawer.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:journal_app/widgets/custom_appbar.dart';
import 'package:journal_app/widgets/custom_widgets.dart';

class DiaryScreen extends StatefulWidget {
  const DiaryScreen({super.key});

  @override
  DiaryScreenState createState() => DiaryScreenState();
}

class DiaryScreenState extends State<DiaryScreen> {
  final Random random = Random();
  DateTime _selectedDate = DateTime.now();
  late Box<Diary> _journalBox;
  List<String> _combinedImagePaths = [];
  List<String> _combinedAudioPaths = [];
  final AudioPlayer _audioPlayer = AudioPlayer();
  String? _currentAudioPath;
  bool _isPlaying = false;
  int _currentAudioIndex = -1;
  bool _hasEntriesForCurrentDate = false;
  Diary? entry;
  User? loggedInUser;

  @override
  void initState() {
    super.initState();
    _fetchCurrentUser();
  }

  Future<void> _fetchCurrentUser() async {
    final userBox = await Hive.openBox<User>('users');
    setState(() {
      loggedInUser = userBox.get('loggedInUser');
    });
    await _updateData();
  }

  Future<void> _updateData() async {
    if (loggedInUser == null) return;
    _journalBox = await Hive.openBox<Diary>('journals');
    final journalEntries = _getJournalEntries();

    setState(() {
      _combinedImagePaths =
          journalEntries.expand((entry) => entry.imagePaths).toList();
      _combinedAudioPaths =
          journalEntries.expand((entry) => entry.audioPaths).toList();
      _hasEntriesForCurrentDate = journalEntries.isNotEmpty;
      _currentAudioPath =
          _combinedAudioPaths.isNotEmpty ? _combinedAudioPaths[0] : null;
      _currentAudioIndex = _currentAudioPath != null
          ? _combinedAudioPaths.indexOf(_currentAudioPath!)
          : -1;
    });
  }

  List<Diary> _getJournalEntries() {
    return _journalBox.values
        .where((entry) =>
            DateTime.parse(entry.date).isSameDay(_selectedDate) &&
            entry.username.username == loggedInUser!.username)
        .toList();
  }

  Future<void> _onDateChanged(DateTime newDate) async {
    setState(() {
      _selectedDate = newDate;
    });
    await _updateData();
  }

  Future<void> _selectDate() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (pickedDate != null) {
      await _onDateChanged(pickedDate);
    }
  }

  void _playAudio(String path, int index) async {
    if (_isPlaying && _currentAudioPath == path) {
      await _pauseAudio();
    } else {
      if (_isPlaying) {
        await _audioPlayer.stop();
      }

      setState(() {
        _currentAudioPath = path;
        _isPlaying = true;
        _currentAudioIndex = index;
      });

      await _audioPlayer.play(DeviceFileSource(path));
    }
  }

  Future<void> _pauseAudio() async {
    if (_isPlaying) {
      await _audioPlayer.pause();
      setState(() {
        _isPlaying = false;
      });
    }
  }

  void refreshDate() {
    setState(() {
      _selectedDate = DateTime.now();
    });
    _updateData();
  }

  void _playNextAudio() {
    _playAdjacentAudio(1, 'No more audio clips available');
  }

  void _playPreviousAudio() {
    _playAdjacentAudio(-1, 'This is the first audio clip');
  }

  void _playAdjacentAudio(int direction, String message) {
    if (_combinedAudioPaths.isNotEmpty) {
      final newIndex = _currentAudioIndex + direction;
      if (newIndex >= 0 && newIndex < _combinedAudioPaths.length) {
        _playAudio(_combinedAudioPaths[newIndex], newIndex);
      } else {
        showSnackBar(message, context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final List<Color> colorForCards = ColorTheme.getColorForCards(brightness);
    return Scaffold(
      appBar: customAppBar('Memories', context),
      endDrawer: const AppDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: loggedInUser == null
            ? const Center(child: CircularProgressIndicator())
            : ValueListenableBuilder<Box<Diary>>(
                valueListenable: Hive.box<Diary>('journals').listenable(),
                builder: (context, box, _) {
                  List<Diary> journalEntries = _getJournalEntries();
                  _combinedImagePaths = journalEntries
                      .expand((entry) => entry.imagePaths)
                      .toList();
                  _combinedAudioPaths = journalEntries
                      .expand((entry) => entry.audioPaths)
                      .toList();
                  _currentAudioIndex =
                      _combinedAudioPaths.indexOf(_currentAudioPath ?? '');
                  _hasEntriesForCurrentDate = journalEntries.isNotEmpty;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDateRow(),
                      const SizedBox(height: 16),
                      _buildImageCarousel(),
                      const SizedBox(height: 16),
                      _buildAudioControls(),
                      const SizedBox(height: 16),
                      _buildJournalEntries(
                          journalEntries, colorForCards, brightness),
                    ],
                  );
                },
              ),
      ),
      floatingActionButton: !_hasEntriesForCurrentDate
          ? FloatingActionButton(
              onPressed: () async {
                final result = await Navigator.of(context).push<bool>(
                    MaterialPageRoute(
                        builder: (ctx) =>
                            Journal(selecteddate: _selectedDate)));
                if (result == true) {
                  await _updateData();
                  setState(() {});
                }
              },
              heroTag: null,
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  _buildDateRow() {
    return Row(
      children: [
        Text(DateFormat.yMMMd().format(_selectedDate),
            style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(width: 8),
        IconButton(
            icon: const Icon(Icons.calendar_today), onPressed: _selectDate),
        if (_hasEntriesForCurrentDate)
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () async {
                    final result = await Navigator.of(context).push<bool>(
                      MaterialPageRoute(
                          builder: (ctx) => EditJournal(journal: entry!)),
                    );
                    if (result == true) {
                      await _updateData();
                      setState(() {});
                    }
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () {
                    final key = entry?.key;

                    _deleteEntry(key);
                  },
                ),
              ],
            ),
          ),
      ],
    );
  }

  _buildImageCarousel() {
    return _combinedImagePaths.isNotEmpty
        ? SizedBox(
            height: 250,
            child: CarouselSlider(
              options: CarouselOptions(
                height: 200,
                aspectRatio: 16 / 9,
                viewportFraction: 0.8,
                initialPage: 0,
                enableInfiniteScroll: true,
                autoPlay: false,
                autoPlayInterval: const Duration(seconds: 3),
                autoPlayAnimationDuration: const Duration(milliseconds: 800),
                scrollDirection: Axis.horizontal,
              ),
              items: _combinedImagePaths.map((path) {
                return GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) =>
                            ImagePreviewScreen(imagePath: path),
                      ),
                    );
                  },
                  child: Image.file(File(path), fit: BoxFit.cover),
                );
              }).toList(),
            ),
          )
        : const Text('Nothing to display');
  }

  _buildAudioControls() {
    return _combinedAudioPaths.isNotEmpty
        ? Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Text('🎵', style: Theme.of(context).textTheme.headlineMedium),
              IconButton(
                icon: const Icon(Icons.skip_previous),
                onPressed: _playPreviousAudio,
              ),
              IconButton(
                icon: Icon(
                  _isPlaying ? Icons.pause : Icons.play_arrow,
                ),
                onPressed: () {
                  if (_currentAudioPath != null) {
                    _playAudio(_currentAudioPath!, _currentAudioIndex);
                  } else if (_combinedAudioPaths.isNotEmpty) {
                    _playAudio(_combinedAudioPaths[0], 0);
                  }
                },
              ),
              IconButton(
                icon: const Icon(Icons.skip_next),
                onPressed: _playNextAudio,
              ),
            ],
          )
        : const Text('No audio clips available');
  }

  _buildJournalEntries(List<Diary> journalEntries, List<Color> colorForCards,
      Brightness brightness) {
    return journalEntries.isNotEmpty
        ? Expanded(
            child: ListView.builder(
              itemCount: journalEntries.length,
              itemBuilder: (context, index) {
                entry = journalEntries[index];

                if (entry?.title?.isNotEmpty ?? false) {
                  return Card(
                    color:
                        colorForCards[Random().nextInt(colorForCards.length)],
                    child: ListTile(
                      title: Text(
                        entry?.title ?? 'No Title',
                        style: TextStyle(
                            color: ColorTheme.getTextColor(brightness)),
                      ),
                      subtitle: Text(entry?.content ?? 'No Content'),
                    ),
                  );
                } else {
                  return const SizedBox.shrink();
                }
              },
            ),
          )
        : const Text('No diary entries available');
  }

  _deleteEntry(int key) async {
    final isDelete = await _showDeleteConfirmationDialog();

    if (isDelete) {
      try {
        await deleteJournalEntry(key, loggedInUser!);
        // ignore: use_build_context_synchronously
        showSnackBar('Journal entry deleted successfully!', context);
        await _updateData();
        setState(() {});
      } catch (e) {
        // ignore: use_build_context_synchronously
        showSnackBar('Error deleting journal entry: ${e.toString()}', context);
      }
    }
  }

  Future<bool> _showDeleteConfirmationDialog() async {
    return await showDialog<bool>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Confirm Delete'),
              content: const Text(
                  'Are you sure you want to delete this journal entry?'),
              actions: [
                TextButton(
                  child: const Text('Cancel'),
                  onPressed: () => Navigator.of(context).pop(false),
                ),
                TextButton(
                  child: const Text('Delete'),
                  onPressed: () => Navigator.of(context).pop(true),
                ),
              ],
            );
          },
        ) ??
        false;
  }
}

extension DateOnlyComparison on DateTime {
  bool isSameDay(DateTime other) {
    return year == other.year && month == other.month && day == other.day;
  }
}
