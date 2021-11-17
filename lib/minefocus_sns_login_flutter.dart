import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

enum SnsLoginType { google, facebook, yahoo, apple }

class SnsLoginResult {
  bool isSuccess;
  String? accessToken;

  SnsLoginResult(this.isSuccess, {this.accessToken});
}

class SnsLogoutResult {
  bool isSuccess;

  SnsLogoutResult(this.isSuccess);
}

GoogleSignIn googleSignIn = GoogleSignIn(
  scopes: [
    'email',
    'https://www.googleapis.com/auth/contacts.readonly',
  ],
);

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
          final result = await googleSignIn.signIn();
          final accessToken = await result?.authentication;
          return SnsLoginResult(true, accessToken: accessToken?.accessToken);
        } catch (e) {
          return SnsLoginResult(false);
        }
      case SnsLoginType.facebook:
        final LoginResult result = await FacebookAuth.instance.login();
        if (result.status == LoginStatus.success) {
          AccessToken? accessToken =  = result.accessToken;
          if (accessToken != null) {
            return SnsLoginResult(true, accessToken: accessToken.token);
          } else {
            return SnsLoginResult(true,accessToken:'');
          }
        } else {
          return SnsLoginResult(false);
        }

      case SnsLoginType.yahoo:
        // yahoo连携
        final Map<dynamic, dynamic> result = await _channel.invokeMethod('yahooLogIn');
        if (result["success"] == true) {
          return SnsLoginResult(true, accessToken: result["yahooAccessToken"]);
        } else {
          return SnsLoginResult(false);
        }
      case SnsLoginType.apple:
        //apple连携(ios)
        final Map<dynamic, dynamic> result = await _channel.invokeMethod('appleLogIn');
        if (result["success"] == true) {
          return SnsLoginResult(true, accessToken: result["appleAccessToken"]);
        } else {
          return SnsLoginResult(false);
        }
    }
  }

  void logout(SnsLoginType type) {
    switch (type) {
      case SnsLoginType.google:
        _handleGoogleLogout();
        break;
      case SnsLoginType.facebook:
        _handleFacebookLogout();
        break;
      case SnsLoginType.yahoo:
        break;
      case SnsLoginType.apple:
        break;
    }
  }

  Future<void> _handleGoogleLogout() => googleSignIn.signOut();

  Future<void> _handleFacebookLogout() async {
    await FacebookAuth.instance.logOut();
  }
}
