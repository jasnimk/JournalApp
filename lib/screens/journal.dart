// ignore_for_file: prefer_typing_uninitialized_variables, use_build_context_synchronously

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:journal_app/screens/record.dart';
import 'package:hive/hive.dart';
import 'package:journal_app/Colors/color_theme.dart';
import 'package:journal_app/model/user.dart';
import 'package:journal_app/model/diary.dart';
import 'package:journal_app/controllers/db_functions.dart';
import 'package:journal_app/widgets/custom_widgets.dart';

class Journal extends StatefulWidget {
  final DateTime selecteddate;
  const Journal({super.key, required this.selecteddate});

  @override
  State<Journal> createState() => _JournalState();
}

class _JournalState extends State<Journal> {
  late Box<User> userBox;
  final _contentController = TextEditingController();
  final _titleController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  final List<String> _imagePaths = [];
  final List<String> _audioPaths = [];
  late final loggedInUser;

  @override
  void initState() {
    super.initState();
    userBox = Hive.box<User>('users');
    _updateUserData();
  }

  void _updateUserData() {
    setState(() {
      loggedInUser = userBox.get('loggedInUser');
    });
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _imagePaths.add(image.path);
      });
    }
  }

  Future<void> _pickAudioFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.audio,
      allowMultiple: false,
    );

    if (result != null) {
      setState(() {
        _audioPaths.add(result.files.single.path!);
      });
    }
  }

  void _showAudioOptionsDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add Audio'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _pickAudioFile();
                },
                child: const Text('Select from File'),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _showRecorderDialog();
                },
                child: const Text('Record Audio'),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showRecorderDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: SimpleRecorder(
            onRecordingComplete: (String filePath) {
              setState(() {
                _audioPaths.add(filePath);
              });
              Navigator.of(context).pop();
            },
            onCancel: () {
              Navigator.of(context).pop();
            },
          ),
        );
      },
    );
  }

  Future<void> _saveJournal() async {
    if (loggedInUser == null) {
      showSnackBar('No user logged in.', context);
      return;
    }

    final journal = Diary(
      date: widget.selecteddate.toIso8601String(),
      content: _contentController.text,
      username: loggedInUser,
      imagePaths: _imagePaths,
      audioPaths: _audioPaths,
      title: _titleController.text,
    );

    try {
      await saveJournal(journal, context, loggedInUser!);
      showSnackBar('Journal saved successfully!', context);
      _contentController.clear();
      _titleController.clear();

      Navigator.of(context).pop(true);
    } catch (e) {
      showSnackBar('Error saving journal: ${e.toString()}', context);
      Navigator.of(context).pop(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: ColorTheme.getPrimaryColor(brightness),
        title: const Text('Add Journal',
            style: TextStyle(
                fontFamily: 'Bearsville', fontSize: 20, color: Colors.black)),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveJournal,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                border: InputBorder.none,
                hintText: 'Title',
                hintStyle: TextStyle(
                  color: Colors.grey,
                  fontSize: 20,
                ),
              ),
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 1,
              autofocus: true,
            ),
            const SizedBox(height: 16),
            Expanded(
              child: TextField(
                controller: _contentController,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Write your note here...',
                  hintStyle: TextStyle(
                    color: Colors.grey,
                    fontSize: 18,
                  ),
                ),
                style: const TextStyle(
                  fontSize: 18,
                ),
                maxLines: null,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.camera_alt),
                  onPressed: _pickImage,
                  tooltip: 'Add Image',
                ),
                IconButton(
                  icon: const Icon(Icons.music_note),
                  onPressed: _showAudioOptionsDialog,
                  tooltip: 'Add Audio',
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_imagePaths.isNotEmpty)
              Wrap(
                spacing: 8,
                children: _imagePaths.map((path) {
                  return Image.file(File(path), width: 100, height: 100);
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }
}
