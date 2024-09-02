// import 'dart:typed_data';

// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';

// import 'package:journal_app/Colors/color_theme.dart';
// import 'package:journal_app/controllers/db_functions.dart';
// import 'package:journal_app/model/user.dart';

// import 'dart:io';

// import 'package:journal_app/widgets/custom_widgets.dart';

// class SignupPage extends StatefulWidget {
//   const SignupPage({super.key});

//   @override
//   State<SignupPage> createState() => _SignupPageState();
// }

// class _SignupPageState extends State<SignupPage> {
//   final _formKey = GlobalKey<FormState>();
//   final _fullnameController = TextEditingController();
//   final _usernameController = TextEditingController();
//   final _passwordController = TextEditingController();
//   final _confirmPasswordController = TextEditingController();
//   final _emailController = TextEditingController();
//   final _contactController = TextEditingController();
//   File? img;
//   Uint8List? imgBytes;
//   Future<void> _pickImage(ImageSource source) async {
//     final pickedFile = await ImagePicker().pickImage(source: source);

//     setState(() {
//       if (pickedFile != null) {
//         img = File(pickedFile.path);
//         imgBytes = File(pickedFile.path).readAsBytesSync();
//       }
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     final brightness = Theme.of(context).brightness;
//     return Scaffold(
//       appBar: AppBar(
//         automaticallyImplyLeading: false,
//         title: Text('Signup',
//             style: TextStyle(
//                 fontFamily: 'Opensans2',
//                 fontSize: 20,
//                 color: ColorTheme.getTextColor(brightness))),
//         backgroundColor: ColorTheme.getPrimaryColor(brightness),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Center(
//           child: SingleChildScrollView(
//             child: Form(
//               key: _formKey,
//               autovalidateMode: AutovalidateMode.onUserInteraction,
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   GestureDetector(
//                     onTap: () async {
//                       await showDialog(
//                         context: context,
//                         builder: (BuildContext context) {
//                           return AlertDialog(
//                             title: const Text('Select Image'),
//                             content: Column(
//                               mainAxisSize: MainAxisSize.min,
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: <Widget>[
//                                 ListTile(
//                                   leading: const Icon(Icons.photo_library),
//                                   title: const Text('From Gallery'),
//                                   onTap: () {
//                                     _pickImage(ImageSource.gallery);
//                                     Navigator.of(context).pop();
//                                   },
//                                 ),
//                                 Form(
//                                   child: ListTile(
//                                     leading: const Icon(Icons.camera_alt),
//                                     title: const Text('From Camera'),
//                                     onTap: () {
//                                       _pickImage(ImageSource.camera);
//                                       Navigator.of(context).pop();
//                                     },
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           );
//                         },
//                       );
//                     },
//                     child: Padding(
//                       padding: const EdgeInsets.only(top: 5.0),
//                       child: Container(
//                         width: 150,
//                         height: 180,
//                         decoration: BoxDecoration(
//                           color: Colors.grey[200],
//                           borderRadius: BorderRadius.circular(50),
//                         ),
//                         child: img != null
//                             ? ClipRRect(
//                                 borderRadius: BorderRadius.circular(8),
//                                 child: Image.file(
//                                   img!,
//                                   fit: BoxFit.cover,
//                                 ),
//                               )
//                             : const Icon(
//                                 Icons.add_a_photo,
//                                 size: 50,
//                               ),
//                       ),
//                     ),
//                   ),
//                   const SizedBox(
//                     height: 30,
//                   ),
//                   createTextFormField(
//                     'Enter Your Name',
//                     _fullnameController,
//                     (value) {
//                       if (value == null || value.isEmpty) {
//                         return 'Please enter your Full name';
//                       }
//                       final spacesRegex = RegExp(r'\s{2,}');
//                       if (spacesRegex.hasMatch(value)) {
//                         return 'Name cannot contain multiple continuous spaces';
//                       }
//                       final nameRegex = RegExp(r'^[a-zA-Z\s]+$');
//                       if (!nameRegex.hasMatch(value)) {
//                         return 'Please enter a valid name (letters and spaces only)';
//                       }
//                       return null;
//                     },
//                   ),
//                   createTextFormField(
//                     'Enter Username',
//                     _usernameController,
//                     (value) {
//                       if (value == null || value.isEmpty) {
//                         return 'Please enter your username';
//                       }
//                       if (value.length < 4 || value.length > 20) {
//                         return 'Username must be between 4 and 20 characters';
//                       }
//                       final usernameRegex = RegExp(r'^[a-zA-Z0-9_]+$');
//                       if (!usernameRegex.hasMatch(value)) {
//                         return 'Username can only contain letters, numbers, and underscores';
//                       }
//                       if (value.contains(' ')) {
//                         return 'Username cannot contain spaces';
//                       }
//                       return null;
//                     },
//                   ),
//                   createTextFormField(
//                     'Enter Password',
//                     _passwordController,
//                     (value) {
//                       if (value == null || value.isEmpty) {
//                         return 'Please enter your password';
//                       }
//                       return null;
//                     },
//                     obscureText: true,
//                   ),
//                   createTextFormField(
//                     'Confirm Password',
//                     _confirmPasswordController,
//                     (value) {
//                       if (value == null || value.isEmpty) {
//                         return 'Please confirm your password';
//                       }
//                       if (value != _passwordController.text) {
//                         return 'Passwords do not match';
//                       }
//                       return null;
//                     },
//                     obscureText: true,
//                   ),
//                   createTextFormField(
//                     'Enter Email',
//                     _emailController,
//                     (value) {
//                       if (value == null || value.isEmpty) {
//                         return 'Please enter your email';
//                       }
//                       final emailRegex = RegExp(
//                           r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
//                       if (!emailRegex.hasMatch(value)) {
//                         return 'Please enter a valid email';
//                       }
//                       return null;
//                     },
//                   ),
//                   createTextFormField(
//                     'Enter Contact',
//                     _contactController,
//                     (value) {
//                       if (value == null || value.isEmpty) {
//                         return 'Please enter your contact number';
//                       }
//                       final contactRegex = RegExp(r'^[0-9]+$');
//                       if (!contactRegex.hasMatch(value)) {
//                         return 'Please enter a valid contact number';
//                       }
//                       return null;
//                     },
//                   ),
//                   Row(
//                     children: [
//                       Expanded(
//                         child: ElevatedButton(
//                           onPressed: () {
//                             _signup();
//                           },
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor:
//                                 ColorTheme.getPrimaryColor(brightness),
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(5),
//                             ),
//                           ),
//                           child: Text(
//                             'Signup',
//                             style: TextStyle(
//                                 color: ColorTheme.getTextColor(brightness)),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Future<void> _signup() async {
//     if (_formKey.currentState!.validate()) {
//       final fullname = _fullnameController.text;
//       final username = _usernameController.text;
//       final password = _passwordController.text;
//       final confirmPassword = _confirmPasswordController.text;
//       final email = _emailController.text;
//       final contact = _contactController.text;
//       final img1 = imgBytes;
//       if (imgBytes == null) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Please select an image')),
//         );
//         return;
//       }

//       final user = User(
//         fullname: fullname,
//         username: username,
//         password: password,
//         confirm: confirmPassword,
//         email: email,
//         contact: contact,
//         img: img1,
//       );
//       saveUser(username, user, context);
//     }
//   }
// }

import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

import 'package:journal_app/Colors/color_theme.dart';
import 'package:journal_app/controllers/db_functions.dart';
import 'package:journal_app/model/user.dart';

import 'package:journal_app/widgets/custom_widgets.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _formKey = GlobalKey<FormState>();
  final _fullnameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _emailController = TextEditingController();
  final _contactController = TextEditingController();
  Uint8List? imgBytes;

  Future<void> _pickImage() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
    );

    if (result != null) {
      setState(() {
        imgBytes = result.files.first.bytes;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('Signup',
            style: TextStyle(
                fontFamily: 'Opensans2',
                fontSize: 20,
                color: ColorTheme.getTextColor(brightness))),
        backgroundColor: ColorTheme.getPrimaryColor(brightness),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () async {
                      await _pickImage();
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(top: 5.0),
                      child: Container(
                        width: 150,
                        height: 180,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(50),
                        ),
                        child: imgBytes != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.memory(
                                  imgBytes!,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : const Icon(
                                Icons.add_a_photo,
                                size: 50,
                              ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  createTextFormField(
                    'Enter Your Name',
                    _fullnameController,
                    (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your Full name';
                      }
                      return null;
                    },
                  ),
                  createTextFormField(
                    'Enter Username',
                    _usernameController,
                    (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your username';
                      }
                      return null;
                    },
                  ),
                  createTextFormField(
                    'Enter Password',
                    _passwordController,
                    (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your password';
                      }
                      return null;
                    },
                    obscureText: true,
                  ),
                  createTextFormField(
                    'Confirm Password',
                    _confirmPasswordController,
                    (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please confirm your password';
                      }
                      if (value != _passwordController.text) {
                        return 'Passwords do not match';
                      }
                      return null;
                    },
                    obscureText: true,
                  ),
                  createTextFormField(
                    'Enter Email',
                    _emailController,
                    (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email';
                      }
                      return null;
                    },
                  ),
                  createTextFormField(
                    'Enter Contact',
                    _contactController,
                    (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your contact number';
                      }
                      return null;
                    },
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            _signup();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                ColorTheme.getPrimaryColor(brightness),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5),
                            ),
                          ),
                          child: const Text(
                            'Signup',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _signup() async {
    if (_formKey.currentState!.validate()) {
      final fullname = _fullnameController.text;
      final username = _usernameController.text;
      final password = _passwordController.text;
      final confirmPassword = _confirmPasswordController.text;
      final email = _emailController.text;
      final contact = _contactController.text;
      final img1 = imgBytes;
      if (imgBytes == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select an image')),
        );
        return;
      }

      final user = User(
        fullname: fullname,
        username: username,
        password: password,
        confirm: confirmPassword,
        email: email,
        contact: contact,
        img: img1,
      );
      saveUser(username, user, context);
    }
  }
}
