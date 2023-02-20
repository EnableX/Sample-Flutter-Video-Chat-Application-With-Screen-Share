//
// Generated file. Do not edit.
// This file is generated from template in file `flutter_tools/lib/src/flutter_plugins.dart`.
//

// @dart = 2.19

import 'dart:io'; // flutter_ignore: dart_io_import.
import 'package:shared_preferences_linux/shared_preferences_linux.dart';
import 'package:shared_preferences_windows/shared_preferences_windows.dart';

@pragma('vm:entry-point')
class _PluginRegistrant {

  @pragma('vm:entry-point')
  static void register() {
    if (Platform.isAndroid) {
    } else if (Platform.isIOS) {
    } else if (Platform.isLinux) {
      try {
        SharedPreferencesLinux.registerWith();
      } catch (err) {
        print(
          '`shared_preferences_linux` threw an error: $err. '
          'The app may not function as expected until you remove this plugin from pubspec.yaml'
        );
        rethrow;
      }

    } else if (Platform.isMacOS) {
    } else if (Platform.isWindows) {
      try {
        SharedPreferencesWindows.registerWith();
      } catch (err) {
        print(
          '`shared_preferences_windows` threw an error: $err. '
          'The app may not function as expected until you remove this plugin from pubspec.yaml'
        );
        rethrow;
      }

    }
  }
}
