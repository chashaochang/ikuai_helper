import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:oktoast/oktoast.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum FileType {
  folder,
  image,
  movie,
  music,
  ps,
  html,
  word,
  ppt,
  excel,
  text,
  zip,
  code,
  other,
  pdf,
  apk,
  iso,
}
enum UploadStatus {
  running,
  complete,
  failed,
  canceled,
  wait,
}

class Util {
  static String account = "";
  static String hostname = "";
  static int version = 6;
  static bool checkSsl = true;
  static String? cookie = "";
  static Map strings = {};
  static Map notifyStrings = {};
  static bool isAuthPage = false;
  static String appName = "";

  static String downloadSavePath = "";
  static bool downloadWifiOnly = true;

  static toast(String? text) {
    if (text != null) showToast(text, dismissOtherToast: true);
  }

  static String parseOpTime(int time) {
    var map = timeLong(time);
    String optime = '${map["hours"]}:${map["minutes"]}:${map["seconds"]}';
    List items = optime.split(":");
    int days = int.parse(items[0]) ~/ 24;
    items[0] = (int.parse(items[0]) % 24).toString().padLeft(2, "0");
    items[1] = items[1].toString().padLeft(2, "0");
    items[2] = items[2].toString().padLeft(2, "0");
    return "${days > 0 ? "$days天" : ""}${items[0]}时${items[1]}分${items[2]}秒";
  }

  static Map timeLong(int ticket) {
    int seconds = ticket % 60;
    int minutes = ticket ~/ 60 % 60;
    int hours = ticket ~/ 60 ~/ 60;
    return {
      "hours": hours,
      "minutes": minutes,
      "seconds": seconds,
    };
  }

  static Color getAdjustColor(Color baseColor, double amount) {
    Map<String, int> colors = {
      'r': baseColor.red,
      'g': baseColor.green,
      'b': baseColor.blue
    };

    colors = colors.map((key, value) {
      if (value + amount < 0) {
        return MapEntry(key, 0);
      }
      if (value + amount > 255) {
        return MapEntry(key, 255);
      }
      return MapEntry(key, (value + amount).floor());
    });
    return Color.fromRGBO(colors['r']!, colors['g']!, colors['b']!, 1);
  }

  static String getUniqueName(String path, String name) {
    bool unique = true;
    int num = 0;
    String uniqueName = "";
    String ext = name
        .split(".")
        .last;
    while (unique) {
      if (num == 0) {
        uniqueName = name;
      } else {
        uniqueName = name.replaceAll(".$ext", "-$num.$ext");
      }
      print(path + "/" + uniqueName);
      if (File(path + "/" + uniqueName).existsSync()) {
        print("文件存在");
        num++;
      } else {
        print("文件不存在");
        unique = false;
      }
    }
    return uniqueName;
  }

  static String formatSize(num size, {int format = 1024, int fixed = 2}) {
    if (size < format) {
      return "${size}B";
    } else if (size < pow(format, 2)) {
      return "${(size / format).toStringAsFixed(fixed)} KB";
    } else if (size < pow(format, 3)) {
      return "${(size / pow(format, 2)).toStringAsFixed(fixed)} MB";
    } else if (size < pow(format, 4)) {
      return "${(size / pow(format, 3)).toStringAsFixed(fixed)} GB";
    } else {
      return "${(size / pow(format, 4)).toStringAsFixed(fixed)} TB";
    }
  }

  static String timeRemaining(int seconds) {
    int hour = seconds / 60 ~/ 60;
    int minute = (seconds - hour * 60 * 60) ~/ 60;
    int second = seconds ~/ 60;
    return "${hour.toString().padLeft(2, "0")}:${minute.toString().padLeft(
        2, "0")}:${second.toString().padLeft(2, "0")}";
  }

  static Future<bool> setStorage(String name, String value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setString(name, value);
  }

  static Future<String?> getStorage(String name) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(name);
  }

  static Future<bool> removeStorage(String name) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.remove(name);
  }

  static String rand() {
    var r = Random().nextInt(2147483646);
    return r.toString();
  }
}
