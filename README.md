

# minefocus_sns_login_flutter

Flutter插件，用于Google、Facebook、Yahoo连携。其中Google和Facebook使用的是各自官方flutter插件，Yahoo是新追加的插件。

## 工程设置

工程设置参照下面的官方文档。

[Google Installation](https://pub.flutter-io.cn/packages/google_sign_in)

[Facebook Installation](https://pub.flutter-io.cn/packages/flutter_facebook_login)

[Yahoo Installation](https://developer.yahoo.co.jp/yconnect/v2/client_app/)

## 安装

minefocus_sns_login_flutter是私有库，有权限的人才能使用，无法使用的可能是没有权限。

#### 1.添加依赖

工程文件的pubspec.yaml追加下面代码。

```yaml
dependencies:
  minefocus_base_flutter:
    git:
      url: https://github.com/minefocus/minefocus_sns_login_flutter.git
      ref: master
```

#### 2.安装

在工程目录下运行命令:

```shell
flutter pub get
```

####  3.导入

```Dart
import 'package:minefocus_sns_login_flutter/minefocus_sns_login_flutter.dart';
```



## 使用例子

```Dart
/// google连携
MFSnsLogin.login(SnsLoginType.google).then((result) {
if (result.isSuccess) {
   print('google token is ------${result.accessToken}');
} else {
   print('google login error');
}
  
/// facebook连携
MFSnsLogin.login(SnsLoginType.facebook).then((result) {
if (result.isSuccess) {
   print('facebook token is ------${result.accessToken}');
} else {
   print('facebook login error');
}

/// yahoo连携
MFSnsLogin.login(SnsLoginType.yahoo).then((result) {
if (result.isSuccess) {
   print('yahoo token is ------${result.accessToken}');
} else {
   print('yahoo login error');
}
```





