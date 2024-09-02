// ignore_for_file: use_build_context_synchronously

import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:flutter_sound_platform_interface/flutter_sound_recorder_platform_interface.dart';
import 'package:journal_app/widgets/custom_widgets.dart';
import 'package:path_provider/path_provider.dart';
//import 'package:permission_handler/permission_handler.dart';

const theSource = AudioSource.microphone;

class SimpleRecorder extends StatefulWidget {
  final Function(String) onRecordingComplete;
  final Function() onCancel;

  const SimpleRecorder({
    super.key,
    required this.onRecordingComplete,
    required this.onCancel,
  });

  @override
  State<SimpleRecorder> createState() => _SimpleRecorderState();
}

class _SimpleRecorderState extends State<SimpleRecorder> {
  final Codec _codec = Codec.aacMP4;
  String _mPath = '';
  FlutterSoundRecorder? _mRecorder = FlutterSoundRecorder();
  bool _isRecording = false;

  @override
  void initState() {
    super.initState();
    // _initRecorder();
  }

  @override
  void dispose() {
    _mRecorder!.closeRecorder();
    _mRecorder = null;
    super.dispose();
  }

  // Future<void> _initRecorder() async {
  //   if (!kIsWeb) {
  //    // var status = await Permission.microphone.request();
  //     //if (status != PermissionStatus.granted) {
  //       throw RecordingPermissionException('Microphone permission not granted');
  //     }
  //   }
  //   await _mRecorder!.openRecorder();
  // }

  void _startRecording() async {
    try {
      final directory = await getTemporaryDirectory();
      _mPath =
          '${directory.path}/audio_${DateTime.now().millisecondsSinceEpoch}.aac';
      if (!_isRecording) {
        await _mRecorder!.startRecorder(
          toFile: _mPath,
          codec: _codec,
          audioSource: theSource,
        );
        setState(() {
          _isRecording = true;
        });
      }
    } catch (e) {
      showSnackBar('Error starting recording: $e', context);
    }
  }

  void _stopRecording() async {
    try {
      await _mRecorder!.stopRecorder();
      setState(() {
        _isRecording = false;
      });
      widget.onRecordingComplete(_mPath);

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Audio Saved'),
            content: const Text('Your audio has been recorded successfully.'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    } catch (e) {
      showSnackBar('Error stopping recording: $e', context);
    }
  }

  void _cancelRecording() async {
    if (_isRecording) {
      await _mRecorder!.stopRecorder();
      setState(() {
        _isRecording = false;
      });
    }

    if (File(_mPath).existsSync()) {
      await File(_mPath).delete();
    }
    widget.onCancel();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: Icon(
                    _isRecording ? Icons.pause : Icons.fiber_manual_record,
                    color: Colors.red),
                onPressed: () {
                  if (_isRecording) {
                    _stopRecording();
                  } else {
                    _startRecording();
                  }
                },
              ),
              IconButton(
                icon: const Icon(Icons.save, color: Colors.green),
                onPressed: () {
                  if (_isRecording) {
                    _stopRecording();
                  } else {
                    widget.onRecordingComplete(_mPath);
                  }
                },
              ),
              IconButton(
                icon: const Icon(Icons.cancel, color: Colors.grey),
                onPressed: _cancelRecording,
              ),
            ],
          ),
          if (_isRecording)
            const Text('Recording in progress',
                style: TextStyle(color: Colors.red)),
        ],
      ),
    );
  }
}
