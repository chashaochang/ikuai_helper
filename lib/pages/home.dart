import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:neumorphic/neumorphic.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'dart:async';

import '../util/function.dart';
import 'dashboard/dashboard.dart';
import 'login/auth_page.dart';

class Home extends StatefulWidget {

  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> with WidgetsBindingObserver {
  int _currentIndex = 0;
  DateTime? lastPopTime;
  PackageInfo? packageInfo;
  // final GlobalKey<FilesState> _filesStateKey = GlobalKey<FilesState>();
  final GlobalKey<DashboardState> _dashboardStateKey = GlobalKey<DashboardState>();

  //判断是否需要启动密码
  bool launchAuth = false;
  bool password = false;
  bool biometrics = false;
  bool authPage = false;

  @override
  void initState() {
    WidgetsBinding.instance?.addObserver(this);
    Util.setStorage("agreement", "1");
    super.initState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance?.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      checkAuth();
    }
  }

  checkAuth() async {
    // print("是否需要启动密码")
    String? launchAuthStr = await Util.getStorage("launch_auth");
    String? launchAuthPasswordStr = await Util.getStorage("launch_auth_password");
    String? launchAuthBiometricsStr = await Util.getStorage("launch_auth_biometrics");
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

    authPage = launchAuth && (password || biometrics);
    if (Util.isAuthPage == false && authPage) {
      Navigator.of(context).push(CupertinoPageRoute(builder: (context) {
        return const AuthPage(
          launch: false,
        );
      }));
    }
  }

  Future<bool> onWillPop() {
    Future<bool>? value = Future.value(true);
    if (_currentIndex == 0) {
      if (_dashboardStateKey.currentState?.isDrawerOpen == true) {
        _dashboardStateKey.currentState?.closeDrawer();
        return Future.value(false);
      }
    }
    // else
    // if (_currentIndex == 1) {
    //   if (_filesStateKey.currentState?.isDrawerOpen == true) {
    //     _filesStateKey.currentState?.closeDrawer();
    //     return Future.value(false);
    //   }
    //   value = _filesStateKey.currentState?.onWillPop();
    // }
    // else if (_currentIndex == 2) {
    //   value = Util.downloadKey.currentState.onWillPop();
    // }
    value.then((v) {
      if (v) {
        if (lastPopTime == null || DateTime.now().difference(lastPopTime!) > const Duration(seconds: 2)) {
          lastPopTime = DateTime.now();
          Util.toast('再按一次退出${Util.appName}');
        } else {
          lastPopTime = DateTime.now();
          // 退出app
          SystemNavigator.pop();
        }
      }
    });
    return Future.value(false);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: onWillPop,
      child: Scaffold(
        appBar: null,
        body: IndexedStack(
          children: [
            Dashboard(key: _dashboardStateKey),
            // Files(key: _filesStateKey),
            // Download(key: Util.downloadKey),
            // Setting(),
          ],
          index: _currentIndex,
        ),
        bottomNavigationBar: NeuSwitch<int>(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          thumbColor: Theme.of(context).scaffoldBackgroundColor,
          onValueChanged: (v) {
            setState(() {
              _currentIndex = v;
            });
          },
          groupValue: _currentIndex,
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
          children: {
            0: Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Column(
                children: [
                  Image.asset(
                    "assets/tabbar/meter.png",
                    width: 30,
                    height: 30,
                  ),
                  const Text(
                    "控制台",
                    style: TextStyle(fontSize: 12,color: Color.fromARGB(255, 0, 128, 255)),
                  ),
                ],
              ),
            ),
            1: Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Column(
                children: [
                  Image.asset(
                    "assets/tabbar/network.png",
                    width: 30,
                    height: 30,
                  ),
                  const Text(
                    "网络",
                    style: TextStyle(fontSize: 12,color: Color.fromARGB(255, 0, 128, 255)),
                  ),
                ],
              ),
            ),
            2: Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Column(
                children: [
                  Image.asset(
                    "assets/tabbar/monitor.png",
                    width: 30,
                    height: 30,
                  ),
                  const Text(
                    "监控",
                    style: TextStyle(fontSize: 12,color: Color.fromARGB(255, 0, 128, 255)),
                  ),
                ],
              ),
            ),
            3: Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Column(
                children: [
                  Image.asset(
                    "assets/tabbar/setting.png",
                    width: 30,
                    height: 30,
                  ),
                  const Text(
                    "设置",
                    style: TextStyle(fontSize: 12,color: Color.fromARGB(255, 0, 128, 255)),
                  ),
                ],
              ),
            ),
          },
        ),
      ),
    );
  }
}
