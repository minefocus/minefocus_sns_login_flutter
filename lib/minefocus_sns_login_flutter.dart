import 'dart:async';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_login_facebook/flutter_login_facebook.dart';

enum SnsLoginType { google, facebook, yahoo, apple }

class SnsLoginResult {
  bool isSuccess;
  String? accessToken;

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
          final accessToken = await result?.authentication;
          return SnsLoginResult(true, accessToken: accessToken?.accessToken);
        } catch (e) {
          return SnsLoginResult(false);
        }
      //break;
      case SnsLoginType.facebook:
        // facebook连携
        final plugin = FacebookLogin(debug: true);
        final FacebookLoginResult? result = await plugin.logIn(permissions: [
          FacebookPermission.publicProfile,
          FacebookPermission.email,
        ]);
        if (result?.status == FacebookLoginStatus.success) {
          return SnsLoginResult(true, accessToken: result?.accessToken?.token);
        } else if (result?.status == FacebookLoginStatus.cancel)
          return SnsLoginResult(false);
        else {
          return SnsLoginResult(false, accessToken: '');
        }
      // break;
      case SnsLoginType.yahoo:
        // yahoo连携
        final Map<dynamic, dynamic> result = await _channel.invokeMethod('yahooLogIn');
        if (result["success"] == true) {
          return SnsLoginResult(true, accessToken: result["yahooAccessToken"]);
        } else {
          return SnsLoginResult(false);
        }
      //  break;
      case SnsLoginType.apple:
        //apple连携(ios)
        final Map<dynamic, dynamic> result = await _channel.invokeMethod('appleLogIn');
        if (result["success"] == true) {
          return SnsLoginResult(true, accessToken: result["appleAccessToken"]);
        } else {
          return SnsLoginResult(false);
        }
      // break;
    }
  }
}
