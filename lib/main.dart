import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bugly/flutter_bugly.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:ikuai_helper/extentions/string.dart';
import 'package:ikuai_helper/pages/home.dart';
import 'package:ikuai_helper/pages/login/auth_page.dart';
import 'package:ikuai_helper/pages/login/login.dart';
import 'package:ikuai_helper/providers/dark_mode.dart';
import 'package:ikuai_helper/providers/setting.dart';
import 'package:ikuai_helper/providers/shortcut.dart';
import 'package:ikuai_helper/util/function.dart';
import 'package:ikuai_helper/widgets/keyboard_dismisser.dart';
import 'package:oktoast/oktoast.dart';
import 'package:provider/provider.dart';

main() async {
  WidgetsFlutterBinding.ensureInitialized();
//判断是否需要启动密码
  bool launchAuth = false;
  bool password = false;
  bool biometrics = false;
  bool showShortcuts = true;
  int refreshDuration = 10;
  String? launchAuthStr = await Util.getStorage("launch_auth");
  String? launchAuthPasswordStr = await Util.getStorage("launch_auth_password");
  String? launchAuthBiometricsStr =
      await Util.getStorage("launch_auth_biometrics");
  if (launchAuthStr != null) {
    launchAuth = launchAuthStr == "1";
  } else {
    launchAuth = false;
  }
  if (launchAuthPasswordStr != null) {
    password = launchAuthPasswordStr == "1";
  } else {
    password = false;
  }
  if (launchAuthBiometricsStr != null) {
    biometrics = launchAuthBiometricsStr == "1";
  } else {
    biometrics = false;
  }
  bool authPage = launchAuth && (password || biometrics);

  //暗色模式
  String darkModeStr = await Util.getStorage("dark_mode") ?? "0";
  int darkMode = 2;
  if (darkModeStr.isNotBlank) {
    darkMode = int.parse(darkModeStr);
  }
  String? showShortcutsStr = await Util.getStorage("show_shortcut");
  if (showShortcutsStr!=null && showShortcutsStr.isNotBlank) {
    showShortcuts = showShortcutsStr == "1";
  }
  String? refreshDurationStr = await Util.getStorage("refresh_duration");
  if (refreshDurationStr!=null && refreshDurationStr.isNotBlank) {
    refreshDuration = int.parse(refreshDurationStr);
  }
  FlutterBugly.postCatchedException(() {
    runApp(MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: DarkModeProvider(darkMode)),
        ChangeNotifierProvider.value(value: ShortcutProvider(showShortcuts)),
        ChangeNotifierProvider.value(value: SettingProvider(refreshDuration)),
      ],
      child: MyApp(authPage),
    ));
  });
  if (Platform.isAndroid) {
    // 以下两行 设置android状态栏为透明的沉浸。写在组件渲染之后，是为了在渲染后进行set赋值，覆盖状态栏，写在渲染之前MaterialApp组件会覆盖掉这个值。
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
    ));
  }
}

class MyApp extends StatefulWidget {
  final bool authPage;

  const MyApp(this.authPage, {Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    FlutterBugly.init(
        androidAppId: "09f92fb8-0672-4aa2-8a46-9ddc935200f2",
        iOSAppId: "ef1bfdca-117f-40d2-9659-85092ce95d63",
        customUpgrade: true);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    ThemeData darkTheme = ThemeData.dark().copyWith(
      backgroundColor: const Color(0xff121212),
      scaffoldBackgroundColor: const Color(0xff121212),
      textTheme: const TextTheme(
        bodyText1: TextStyle(
          fontSize: 12.0,
          color: Color(0xffa6a6a6),
        ),
        bodyText2: TextStyle(
          fontSize: 15.0,
          color: Color(0xffa6a6a6),
        ),
        subtitle1: TextStyle(
          fontSize: 18.0,
          color: Color(0xffa6a6a6),
        ),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        hintStyle: TextStyle(
          fontSize: 16.0,
          color: Color(0xff808080),
        ),
        helperStyle: TextStyle(
          fontSize: 16.0,
          color: Color(0xff808080),
        ),
        labelStyle: TextStyle(
          fontSize: 16.0,
          color: Color(0xff808080),
        ),
      ),
      iconTheme: const IconThemeData(color: Color(0xffa6a6a6)),
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
        color: Color(0xff121212),
        iconTheme: IconThemeData(color: Color(0xffa6a6a6)),
        actionsIconTheme: IconThemeData(color: Color(0xffa6a6a6)),
        titleTextStyle: TextStyle(fontSize: 20.0, color: Color(0xffa6a6a6)),
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      colorScheme: const ColorScheme.dark(
        secondary: Color(0xff888888),
      ),
    );
    ThemeData lightTheme = ThemeData.light().copyWith(
      textTheme: const TextTheme(
        bodyText1: TextStyle(
          fontSize: 12.0,
          color: Colors.white,
        ),
        bodyText2: TextStyle(
          fontSize: 15.0,
          color: Colors.black,
        ),
        subtitle1: TextStyle(
          fontSize: 18.0,
          color: Colors.black,
        ),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        hintStyle: TextStyle(
          fontSize: 16.0,
          color: Colors.black,
        ),
        labelStyle: TextStyle(
          fontSize: 16.0,
          color: Colors.grey,
        ),
      ),
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
        color: Color(0xFFF4F4F4),
        iconTheme: IconThemeData(color: Colors.black),
        actionsIconTheme: IconThemeData(color: Colors.black),
        titleTextStyle: TextStyle(fontSize: 20.0, color: Colors.black),
        systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),
      backgroundColor: const Color(0xFFF4F4F4),
      scaffoldBackgroundColor: const Color(0xFFF4F4F4),
    );
    return Consumer<DarkModeProvider>(
      builder: (context, darkModeProvider, _) {
        return OKToast(
          child: KeyboardDismisser(
            child: darkModeProvider.darkMode == 2
                ? MaterialApp(
                    title: Util.appName,
                    debugShowCheckedModeBanner: false,
                    theme: lightTheme,
                    darkTheme: darkTheme,
                    localizationsDelegates: const [
                      GlobalCupertinoLocalizations.delegate,
                      GlobalMaterialLocalizations.delegate,
                      GlobalWidgetsLocalizations.delegate,
                    ],
                    supportedLocales: const [
                      Locale('zh', 'CN'),
                    ],
                    home: widget.authPage ? const AuthPage() : const Login(),
                    routes: {
                      "/login": (BuildContext context) => const Login(),
                      "/home": (BuildContext context) => const Home(),
                    },
                  )
                : MaterialApp(
                    title: Util.appName,
                    debugShowCheckedModeBanner: false,
                    theme:
                        darkModeProvider.darkMode == 0 ? lightTheme : darkTheme,
                    localizationsDelegates: const [
                      GlobalCupertinoLocalizations.delegate,
                      GlobalMaterialLocalizations.delegate,
                      GlobalWidgetsLocalizations.delegate,
                    ],
                    supportedLocales: const [
                      Locale('zh', 'CN'),
                    ],
                    home: widget.authPage ? const AuthPage() : const Login(),
                    routes: {
                      "/login": (BuildContext context) => const Login(),
                      "/home": (BuildContext context) => const Home(),
                    },
                  ),
          ),
        );
      },
    );
  }
}
