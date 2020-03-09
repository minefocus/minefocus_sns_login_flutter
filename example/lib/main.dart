import 'package:flutter/material.dart';
import 'package:minefocus_sns_login_flutter/minefocus_sns_login_flutter.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('sns login demo'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              RaisedButton(
                child: Text("google login"),
                onPressed: () async {
                  final snsLogin = MFSnsLogin();
                  snsLogin.login(SnsLoginType.google).then((value) {
                    if (value.success) {
                      print('google token is ------${value.accessToken}');
                    } else {
                      print('google login error');
                    }
                  });
                },
              ),
              SizedBox(height: 30),
              RaisedButton(
                child: Text("facebook login"),
                onPressed: () async {
                  final snsLogin = MFSnsLogin();
                  snsLogin.login(SnsLoginType.facebook).then((value) {
                    if (value.success) {
                      print('facebook token is ------${value.accessToken}');
                    } else {
                      print('facebook login error');
                    }
                  });
                },
              ),
              SizedBox(height: 30),
              RaisedButton(
                child: Text("yahoo login"),
                onPressed: () async {
                  // yahoo 联携需要传key
                  final snsLogin = MFSnsLogin(yahooKey: "yj-e4kn");
                  snsLogin.login(SnsLoginType.yahoo).then((value) {
                    if (value.success) {
                      print('yahoo token is ------${value.accessToken}');
                    } else {
                      print('yahoo login error');
                    }
                  });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}


