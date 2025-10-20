import 'dart:js_interop';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:web/web.dart' as web;

void main() {
  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  _MainAppState createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  String _message = '';
  web.Window? _popupWindow;
  final TextEditingController _controller = TextEditingController();
  bool _isListening = false;

  void _openPopup() {
    if (kIsWeb) {
      const features =
          'width=600,height=400,menubar=no,toolbar=no,location=no,status=no,scrollbars=yes';
      _popupWindow = web.window.open('popup.html', 'popup', features);
      
      if (_popupWindow == null) {
        setState(() {
          _message = 'Failed to open popup (blocked by browser?)';
        });
        return;
      }

      if (!_isListening) {
        _isListening = true;
        
        web.window.addEventListener(
          'message',
          ((web.MessageEvent event) {
            if (event.origin != web.window.location.origin) return;

            final jsData = event.data;
            final dartData = jsData.dartify();

            if (dartData is String) {
              setState(() {
                _message = dartData;
              });
            }
          }).toJS,
        );
      }
    } else {
      print('web platform only');
    }
  }

  void _sendMessageToPopup() {
    if (kIsWeb && _popupWindow != null && !_popupWindow!.closed) {
      print('message: ${_controller.text}');
      _popupWindow!.postMessage(_controller.text.toJS, '*'.toJS);
    } else {
      print('popup is null');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton(
                onPressed: _openPopup,
                child: const Text('Open Popup'),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _controller,
                decoration: const InputDecoration(
                  hintText: 'Enter message',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: _sendMessageToPopup,
                child: const Text('Send to Popup'),
              ),
              if (_message.isNotEmpty) Text(_message),
            ],
          ),
        ),
      ),
    );
  }
}