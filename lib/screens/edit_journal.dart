// ignore_for_file: use_build_context_synchronously

import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:journal_app/screens/record.dart';
import 'package:hive/hive.dart';
import 'package:journal_app/Colors/color_theme.dart';
import 'package:journal_app/model/user.dart';
import 'package:journal_app/model/diary.dart';
import 'package:journal_app/controllers/db_functions.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:journal_app/widgets/custom_widgets.dart';

class EditJournal extends StatefulWidget {
  final Diary journal;

  const EditJournal({super.key, required this.journal});

  @override
  State<EditJournal> createState() => _EditJournalState();
}

class _EditJournalState extends State<EditJournal> {
  late final Box<User> userBox;
  late final TextEditingController _titleController;
  late final TextEditingController _contentController;
  late final List<String> _imagePaths;
  late final List<String> _audioPaths;
  final ImagePicker _picker = ImagePicker();
  late final User user;

  @override
  void initState() {
    super.initState();
    userBox = Hive.box<User>('users');
    _updateUserData();
    _titleController = TextEditingController(text: widget.journal.title);
    _contentController = TextEditingController(text: widget.journal.content);
    _imagePaths = List.from(widget.journal.imagePaths);
    _audioPaths = List.from(widget.journal.audioPaths);
  }

  void _updateUserData() {
    setState(() {
      user = userBox.get('loggedInUser')!;
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

  Future<void> _updateJournal() async {
    final updatedJournal = Diary(
      date: widget.journal.date,
      title: _titleController.text,
      content: _contentController.text,
      username: user, // Ensure User is correctly mapped
      imagePaths: _imagePaths,
      audioPaths: _audioPaths,
    );

    try {
      await updateJournal(widget.journal.key, updatedJournal, context, user);
      showSnackBar('Journal updated successfully!', context);
      Navigator.of(context).pop();
    } catch (e) {
      showSnackBar('Error updating journal: ${e.toString()}', context);
    }
  }

  void _playAudio(String filePath) {
    final player = AudioPlayer();
    player.play(DeviceFileSource(filePath));
  }

  Future<void> _showDeleteConfirmationDialog(
      String filePath, bool isImage) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Delete'),
          content: Text(
              'Are you sure you want to delete this ${isImage ? 'image' : 'audio'}?'),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
            TextButton(
              child: const Text('Delete'),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      },
    );

    if (result == true) {
      _deleteItem(filePath, isImage);
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

  Future<void> _deleteItem(String filePath, bool isImage) async {
    try {
      await deleteJournalItem(filePath, isImage, user);
      setState(() {
        if (isImage) {
          _imagePaths.remove(filePath);
        } else {
          _audioPaths.remove(filePath);
        }
      });

      showSnackBar(
          '${isImage ? 'Image' : 'Audio'} deleted successfully!', context);
    } catch (e) {
      showSnackBar(
          'Error deleting ${isImage ? 'image' : 'audio'}: ${e.toString()}',
          context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: ColorTheme.getPrimaryColor(brightness),
        title: Text('Edit Journal',
            style: TextStyle(
                fontFamily: 'Opensans2',
                fontSize: 18,
                color: ColorTheme.getTextColor(brightness))),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _updateJournal,
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.all(16.0),
            sliver: SliverList(
              delegate: SliverChildListDelegate(
                [
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
                  TextField(
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
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.camera_alt),
                        onPressed: _pickImage,
                        tooltip: 'Add Image',
                      ),
                      IconButton(
                        icon: const Icon(Icons.mic),
                        onPressed: _showAudioOptionsDialog,
                        tooltip: 'Record Audio',
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (_imagePaths.isNotEmpty)
                    Wrap(
                      spacing: 8,
                      children: _imagePaths.map((path) {
                        return GestureDetector(
                          onLongPress: () =>
                              _showDeleteConfirmationDialog(path, true),
                          child:
                              Image.file(File(path), width: 100, height: 100),
                        );
                      }).toList(),
                    ),
                  const SizedBox(height: 16),
                  if (_audioPaths.isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: _audioPaths.map((path) {
                        return ListTile(
                          title: Text('Audio ${_audioPaths.indexOf(path) + 1}'),
                          trailing: IconButton(
                            icon: const Icon(Icons.play_arrow),
                            onPressed: () => _playAudio(path),
                          ),
                          onLongPress: () =>
                              _showDeleteConfirmationDialog(path, false),
                        );
                      }).toList(),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
