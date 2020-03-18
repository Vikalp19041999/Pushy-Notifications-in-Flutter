import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pushy_flutter/pushy_flutter.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        brightness: Brightness.light,
        primaryColor: Colors.grey[900],
        accentColor: Colors.redAccent,
      ),
      home: PushyDemo(),
    );
  }
}

class PushyDemo extends StatefulWidget {
  @override
  _PushyDemoState createState() => _PushyDemoState();
}

class _PushyDemoState extends State<PushyDemo> {
  String _deviceToken = 'Loading...';
  String _instruction = '(please wait)';

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  Future<void> initPlatformState() async {
    Pushy.listen();

    Pushy.requestStoragePermission();

    Pushy.setNotificationIcon('ic_notify');

    try {
      String deviceToken = await Pushy.register();

      print('Device token: $deviceToken');

      setState(() {
        _deviceToken = deviceToken;
        _instruction =
            Platform.isAndroid ? '(copy from logcat)' : '(copy from console)';
      });
    } on PlatformException catch (error) {
      print('Error: ${error.message}');

      setState(() {
        _deviceToken = 'Registration failed';
        _instruction = '(restart app to try again)';
      });
    }

    Pushy.setNotificationListener((Map<String, dynamic> data) {
      print('Received notifications: $data');

      Pushy.clearBadge();

      String message = data['message'] ?? 'A demo message';

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
              title: Text('Pushy Notifications'),
              content: Text(message),
              actions: [
                FlatButton(
                  child: Text('OK'),
                  onPressed: () {
                    Navigator.of(context, rootNavigator: true).pop('dialog');
                  },
                )
              ]);
        },
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pushy  Notifications'),
        centerTitle: true,
      ),
      body: Builder(
        builder: (context) => Center(
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
              Image.asset('assets/ic_logo.png', width: 90),
              Padding(
                padding: const EdgeInsets.all(10),
                child: Text(_deviceToken,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Colors.grey[700])),
              ),
              Text(_instruction,
                  style: TextStyle(fontSize: 13, color: Colors.grey[600])),
            ])),
      ),
    );
  }
}
