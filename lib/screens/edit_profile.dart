// ignore_for_file: use_build_context_synchronously

import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:image_picker/image_picker.dart';
import 'package:journal_app/Colors/color_theme.dart';
import 'package:journal_app/controllers/db_functions.dart';
import 'package:journal_app/model/user.dart';
import 'package:journal_app/widgets/custom_widgets.dart';

class EditProfile extends StatefulWidget {
  const EditProfile({super.key});

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  final _fullnameController = TextEditingController();
  final _emailController = TextEditingController();
  final _contactController = TextEditingController();
  Uint8List? _image;
  late Box<User> userBox;

  @override
  void initState() {
    super.initState();
    userBox = Hive.box<User>('users');
    _updateUserData();
  }

  void _updateUserData() {
    final loggedInUser = userBox.get('loggedInUser');
    if (loggedInUser != null) {
      setState(() {
        _fullnameController.text = loggedInUser.fullname;
        _contactController.text = loggedInUser.contact;
        _emailController.text = loggedInUser.email;
        _image = loggedInUser.img;
      });
    }
  }

  Future<void> _pickImage() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  'Choose an option',
                  style: Theme.of(context).textTheme.headlineMedium ??
                      const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                ListTile(
                  leading: const Icon(Icons.camera_alt),
                  title: const Text('Take a photo'),
                  onTap: () async {
                    Navigator.of(context).pop();
                    final pickedFile = await ImagePicker()
                        .pickImage(source: ImageSource.camera);
                    if (pickedFile != null) {
                      final imageBytes = await pickedFile.readAsBytes();
                      setState(() {
                        _image = imageBytes;
                      });
                    }
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.photo_library),
                  title: const Text('Choose from gallery'),
                  onTap: () async {
                    Navigator.of(context).pop();
                    final pickedFile = await ImagePicker()
                        .pickImage(source: ImageSource.gallery);
                    if (pickedFile != null) {
                      final imageBytes = await pickedFile.readAsBytes();
                      setState(() {
                        _image = imageBytes;
                      });
                    }
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _cancelEdit() {
    Navigator.pop(context);
  }

  void _updateProfile() async {
    if (_fullnameController.text.isNotEmpty &&
        _emailController.text.isNotEmpty &&
        _contactController.text.isNotEmpty) {
      await updateUserProfile(
        fullname: _fullnameController.text,
        email: _emailController.text,
        contact: _contactController.text,
        image: _image,
      );

      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all the fields')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: ColorTheme.getPrimaryColor(brightness),
        title: const Text('Edit Profile',
            style: TextStyle(
                fontFamily: 'Bearsville', fontSize: 20, color: Colors.black)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Column(
                children: [
                  GestureDetector(
                    onTap: _pickImage,
                    child: _image != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(50),
                            child: Image.memory(
                              _image!,
                              fit: BoxFit.cover,
                              width: 100,
                              height: 100,
                            ),
                          )
                        : Icon(
                            Icons.account_circle,
                            size: 100,
                            color: Colors.grey[400],
                          ),
                  ),
                  const SizedBox(height: 16),
                  createTextFormField(
                    'Username',
                    _fullnameController,
                    (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your username';
                      }
                      return null;
                    },
                  ),
                  createTextFormField(
                    'Contact',
                    _contactController,
                    (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your contact';
                      }
                      return null;
                    },
                  ),
                  createTextFormField(
                    'Email',
                    _emailController,
                    (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email';
                      }
                      return null;
                    },
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: _cancelEdit,
                    icon: const Icon(Icons.cancel),
                    label: const Text('Cancel'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ColorTheme.getPrimaryColor(brightness),
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: _updateProfile,
                    icon: const Icon(Icons.save),
                    label: const Text('Save'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ColorTheme.getPrimaryColor(brightness),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
