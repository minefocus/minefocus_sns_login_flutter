import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:google_sign_in/google_sign_in.dart';

enum SnsLoginType { google, facebook, yahoo }

class SnsLoginResult {
  bool isSuccess;
  String accessToken;

  SnsLoginResult(this.isSuccess, {this.accessToken});
}

class MFSnsLogin {
  static const MethodChannel _channel = const MethodChannel('minefocus_sns_login_flutter');

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  // ignore: missing_return
  static Future<SnsLoginResult> login(SnsLoginType type) async {
    switch (type) {
      case SnsLoginType.google:
        // google连携
        try {
          GoogleSignIn googleSignIn = GoogleSignIn(
            scopes: [
              'email',
              'https://www.googleapis.com/auth/contacts.readonly',
            ],
          );
          final result = await googleSignIn.signIn();
          final accessToken = await result.authentication;
          return SnsLoginResult(true, accessToken: accessToken.accessToken);
        } catch (e) {
          return SnsLoginResult(false);
        }
        break;
      case SnsLoginType.facebook:
        // facebook连携
        final facebookLogin = FacebookLogin();
        final result = await facebookLogin.logIn(['email']);
        if (result.status == FacebookLoginStatus.loggedIn) {
          return SnsLoginResult(true, accessToken: result.accessToken.token);
        } else {
          return SnsLoginResult(false);
        }
        break;
      case SnsLoginType.yahoo:
        // yahoo连携
        final Map<dynamic, dynamic> result = await _channel.invokeMethod('yahooLogIn');
        if (result["success"] == true) {
          return SnsLoginResult(true, accessToken: result["yahooAccessToken"]);
        } else {
          return SnsLoginResult(false);
        }
        break;
    }
  }
}
