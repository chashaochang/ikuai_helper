import 'dart:async';
import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ikuai_helper/pages/dashboard/shortcut_item_model.dart';
import 'package:ikuai_helper/pages/dashboard/shortcut_list.dart';
import 'package:neumorphic/neumorphic.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:provider/provider.dart';

import '../../providers/setting.dart';
import '../../providers/shortcut.dart';
import '../../util/api.dart';
import '../../util/function.dart';
import '../../widgets/animation_progress_bar.dart';
import '../../widgets/label.dart';
import 'applications.dart';
import 'indicator.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({key}) : super(key: key);

  @override
  DashboardState createState() => DashboardState();
}

class DashboardState extends State<Dashboard> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  List volumes = [];
  List disks = [];
  List connectedUsers = [];
  List interfaces = [];
  List networks = [];
  Map<String, int>? flows;
  int flowTotal = 0;
  List ssdCaches = [];
  List tasks = [];
  List latestLog = [];
  List notifies = [];
  List widgets = [];
  List applications = [];
  List fileLogs = [];
  List<ShortcutItemModel> shortcutItems = [];
  List esatas = [];
  Map? appNotify;
  Map? system;
  Map? restoreSizePos;
  Map? converter;
  bool loading = true;
  bool success = true;
  int refreshDuration = 10;
  String hostname = "获取中";

  int get maxNetworkSpeed {
    int maxSpeed = 0;
    for (int i = 0; i < networks.length; i++) {
      int maxVal = max(networks[i]['download'], networks[i]['upload']);
      if (maxSpeed < maxVal) {
        maxSpeed = maxVal;
      }
    }
    return maxSpeed;
  }

  Map? volWarnings;
  String msg = "";

  bool get showMainMenu => Util.account != "challengerv";

  @override
  void initState() {
    if (showMainMenu) {
      showFirstLaunchDialog();
    }

    getNotifyStrings();
    getInfo().then((_) {
      getData(init: true);
    });
    super.initState();
  }

  bool? get isDrawerOpen {
    return _scaffoldKey.currentState?.isDrawerOpen;
  }

  closeDrawer() {
    if (_scaffoldKey.currentState?.isDrawerOpen == true) {
      Navigator.of(context).pop();
    }
  }

  showFirstLaunchDialog() async {
    bool firstLaunch = await Util.getStorage("first_launch") == null;
    if (firstLaunch) {
      showCupertinoDialog(
        context: context,
        builder: (context) {
          return Material(
            color: Colors.transparent,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                NeuCard(
                  width: double.infinity,
                  margin: const EdgeInsets.symmetric(horizontal: 50),
                  curveType: CurveType.emboss,
                  bevel: 5,
                  decoration: NeumorphicDecoration(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Text(
                          "${Util.appName}公众号",
                          style: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(
                          height: 16,
                        ),
                        NeuCard(
                          decoration: NeumorphicDecoration(
                            color: Theme.of(context).scaffoldBackgroundColor,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          bevel: 20,
                          curveType: CurveType.flat,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 5),
                          child: Text(
                              "关注公众号，获取最新${Util.appName}更新内容、操作说明，浏览广告内容，还可以获取现金红包奖励！"),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: NeuButton(
                                onPressed: () async {
                                  ClipboardData data =
                                      ClipboardData(text: Util.appName);
                                  Clipboard.setData(data);
                                  Util.toast("已复制到剪贴板");
                                  Navigator.of(context).pop();
                                  Util.setStorage("first_launch", "0");
                                },
                                decoration: NeumorphicDecoration(
                                  color:
                                      Theme.of(context).scaffoldBackgroundColor,
                                  borderRadius: BorderRadius.circular(25),
                                ),
                                bevel: 20,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 10),
                                child: const Text(
                                  "复制",
                                  style: TextStyle(fontSize: 18),
                                ),
                              ),
                            ),
                            const SizedBox(
                              width: 16,
                            ),
                            Expanded(
                              child: NeuButton(
                                onPressed: () async {
                                  Navigator.of(context).pop();
                                  Util.setStorage("first_launch", "0");
                                },
                                decoration: NeumorphicDecoration(
                                  color:
                                      Theme.of(context).scaffoldBackgroundColor,
                                  borderRadius: BorderRadius.circular(25),
                                ),
                                bevel: 20,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 10),
                                child: const Text(
                                  "不再提示",
                                  style: TextStyle(fontSize: 18),
                                ),
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      );
    }
  }

  getNotifyStrings() async {
    // var res = await Api.notifyStrings();
    // if (res['success']) {
    //   setState(() {
    //     Util.notifyStrings = res['data'];
    //   });
    // }
  }

  getExternalDevice() async {
    // var res = await Api.externalDevice();
    // if (res['success']) {
    //   List result = res['data']['result'];
    //   result.forEach((item) {
    //     if (item['success'] == true) {
    //       switch (item['api']) {
    //         case "SYNO.Core.ExternalDevice.Storage.eSATA":
    //           setState(() {
    //             esatas = item['data']['devices'];
    //           });
    //       }
    //     }
    //   });
    // }
  }

  getMediaConverter() async {
    // var res = await Api.mediaConverter("status");
    // if (res['success']) {
    //   setState(() {
    //     converter = res['data'];
    //     if (converter != null && (converter['photo_remain'] + converter['thumb_remain'] + converter['video_remain'] > 0)) {
    //       Future.delayed(const Duration(seconds: 5)).then((value) => getMediaConverter());
    //     }
    //   });
    // }
  }

  Future<void> getInfo() async {
    // widgets = ["SYNO.SDS.SystemInfoApp.SystemHealthWidget"];
    // applications.add("SYNO.SDS.AdminCenter.Application");
    // applications.add("SYNO.SDS.PkgManApp.Instance");
    // applications.add("SYNO.SDS.Docker.Application");
    var res = await Api.call(data: {
      "func_name": "homepage",
      "action": "show",
      "param": {"TYPE": "sysstat,ac_status"}
    });
    if (res['Result'] == 30000) {
      system = res['Data']['sysstat'];
      if (system != null) {
        hostname = system!['hostname'];
        Util.hostname = hostname;
      }
      applications.add("SYNO.SDS.AdminCenter.Application");
      applications.add("SYNO.SDS.PkgManApp.Instance");
      applications.add("SYNO.SDS.Docker.Application");
      setState(() {
        widgets = ["SystemInfo", "ResourceMonitor", "Flow"];
        applications = applications;
        networks.add(system!['stream']);
        // if (init['data']['UserSettings'] != null) {
        //   if (init['data']['UserSettings']['SYNO.SDS._Widget.Instance'] != null) {
        //     widgets = init['data']['UserSettings']['SYNO.SDS._Widget.Instance']['modulelist'] ?? [];
        //     restoreSizePos = init['data']['UserSettings']['SYNO.SDS._Widget.Instance']['restoreSizePos'];
        //   }
        //   applications = init['data']['UserSettings']['Desktop']['valid_appview_order'] ?? init['data']['UserSettings']['Desktop']['appview_order'] ?? [];
        //
        //   shortcutItems = ShortcutItemModel.fromList(init['data']['UserSettings']['Desktop']['ShortcutItems']);
        //   wallpaperModel = WallpaperModel.fromJson(init['data']['UserSettings']['Desktop']['wallpaper']);
        // }
        // if (init['data']['Session'] != null) {
        //   hostname = init['data']['Session']['hostname'];
        //   Util.hostname = hostname;
        // }
        // if (init['data']['Strings'] != null) {
        //   Util.strings = init['data']['Strings'] ?? {};
        // }
      });
    }
    var flowRes = await Api.call(data: {
      "func_name": "homepage",
      "action": "show",
      "param": {"TYPE": "app_flow,app_historical"}
    });
    if (flowRes['Result'] == 30000) {
      if (flowRes['Data'] != null &&
          flowRes['Data']['app_flow'] != null &&
          flowRes['Data']['app_flow']['app_flow'] != null) {
        List flowData = flowRes['Data']['app_flow']['app_flow'];
        if (flowData.isNotEmpty) {
          flows = {};
          Map data = flowData[0];
          setState(() {
            data.forEach((key, value) {
              switch (key) {
                case 'Total':
                  flowTotal = value;
                  break;
                case 'Game':
                  flows?['网络游戏'] = value;
                  break;
                case 'Others':
                  flows?['其他应用'] = value;
                  break;
                case 'Test':
                  flows?['测速软件'] = value;
                  break;
                case 'UnKnown':
                  flows?['未知应用'] = value;
                  break;
                case 'HTTP':
                  flows?['HTTP协议'] = value;
                  break;
                case 'DownLoad':
                  flows?['网络下载'] = value;
                  break;
                case 'Transport':
                  flows?['文件传输'] = value;
                  break;
                case 'IM':
                  flows?['网络通讯'] = value;
                  break;
                case 'Video':
                  flows?['网络视频'] = value;
                  break;
                case 'Common':
                  flows?['常用协议'] = value;
                  break;
              }
            });
          });
        }
      }
    }
  }

  double get chartInterval {
    if (maxNetworkSpeed < 1024) {
      return 102.4;
    } else if (maxNetworkSpeed < 1024 * 10) {
      return 1024.0 * 2;
    } else if (maxNetworkSpeed < pow(1024, 2)) {
      return 1024.0 * 200;
    } else if (maxNetworkSpeed < pow(1024, 2) * 5) {
      return 1.0 * pow(1024, 2);
    } else if (maxNetworkSpeed < pow(1024, 2) * 10) {
      return 2.0 * pow(1024, 2);
    } else if (maxNetworkSpeed < pow(1024, 2) * 20) {
      return 4.0 * pow(1024, 2);
    } else if (maxNetworkSpeed < pow(1024, 2) * 40) {
      return 8.0 * pow(1024, 2);
    } else if (maxNetworkSpeed < pow(1024, 2) * 50) {
      return 10.0 * pow(1024, 2);
    } else if (maxNetworkSpeed < pow(1024, 2) * 100) {
      return 20.0 * pow(1024, 2);
    } else {
      return 50.0 * pow(1024, 2);
    }
  }

  String chartTitle(double v) {
    if (maxNetworkSpeed < 10) {
      return v.toString();
    } else if (maxNetworkSpeed < pow(1024, 2)) {
      String s = (v / 1024).floor().toString() + "K";
      if (s == "1000K") {
        return "1M";
      }
      return s;
    } else {
      v = v / pow(1024, 2);
      return (v.floor()).toString() + "M";
    }
  }

  String flowUnit(int v) {
    if (v < 10) {
      return v.toString();
    } else if (v < pow(1024, 2)) {
      String s = (v / 1024).floor().toString() + "K";
      if (s == "1000K") {
        return "1M";
      }
      return s;
    } else if (v < pow(1024, 3)) {
      return  (v / pow(1024, 2)).toStringAsFixed(2) + "M";
    } else {
      return (v / pow(1024, 3)).toStringAsFixed(2) + "G";
    }
  }

  getData({bool init = false}) async {
    getExternalDevice();
    getMediaConverter();
    //首次调用
    //{"func_name":"webuser","action":"show","param":{"TYPE":"mod_passwd","username":"admin"}}
    //{"func_name":"upgrade","action":"show","param":{"TYPE":"data,fileinfo"}}检测更新
    //{"func_name":"homepage","action":"show","param":{"TYPE":"monitor_system"}}
    //{"func_name":"homepage","action":"show","param":{"TYPE":"app_flow,app_historical"}}
    //{"func_name":"register","action":"show","param":{"TYPE":"data"}}
    //{"func_name":"ikmessages","action":"show","param":{"TYPE":"total","FILTER1":"read,==,0"}}
    //周期调用
    // {"func_name":"homepage","action":"show","param":{"TYPE":"sysstat,ac_status"}}
    // {"func_name":"homepage","action":"show","param":{"TYPE":"dhcp_addrpool_num"}}
    // {"func_name":"homepage","action":"show","param":{"TYPE":"ether_info,snapshoot"}}
    // {"func_name":"homepage","action":"show","param":{"TYPE":"app_historical"}}

    var res = await Api.call(data: {
      "func_name": "homepage",
      "action": "show",
      "param": {"TYPE": "sysstat,ac_status"}
    });

    if (res['Result'] == 30000) {
      if (!mounted) {
        return;
      }

      setState(() {
        loading = false;
        success = true;
        system = res['Data']['sysstat'];
        if (networks.length > 20) {
          networks.removeAt(0);
        }
        networks.add(system!['stream']);
      });

      // for (var item in result) {
      //   if (item['success'] == true) {
      //     switch (item['api']) {
      //       case "SYNO.Core.System.Utilization":
      //         setState(() {
      //           utilization = item['data'];
      //           if (networks.length > 20) {
      //             networks.removeAt(0);
      //           }
      //           networks.add(item['data']['network']);
      //         });
      //         break;
      //       case "SYNO.Core.System":
      //         setState(() {
      //           system = item['data'];
      //           Util.systemVersion(system['firmware_ver']);
      //         });
      //         break;
      //       case "SYNO.Core.CurrentConnection":
      //         setState(() {
      //           connectedUsers = item['data']['items'];
      //         });
      //         break;
      //       case "SYNO.Storage.CGI.Storage":
      //         setState(() {
      //           ssdCaches = item['data']['ssdCaches'];
      //           volumes = item['data']['volumes'];
      //           disks = item['data']['disks'];
      //         });
      //         break;
      //       case 'SYNO.Core.TaskScheduler':
      //         setState(() {
      //           tasks = item['data']['tasks'];
      //         });
      //         break;
      //       case 'SYNO.Core.SyslogClient.Status':
      //         setState(() {
      //           latestLog = item['data']['logs'];
      //         });
      //         break;
      //       case "SYNO.Core.DSMNotify":
      //         setState(() {
      //           notifies = item['data']['items'];
      //         });
      //         break;
      //       case "SYNO.Core.AppNotify":
      //         setState(() {
      //           appNotify = item['data'];
      //         });
      //         break;
      //       case "SYNO.Core.SyslogClient.Log":
      //         setState(() {
      //           fileLogs = item['data']['items'];
      //         });
      //         break;
      //     }
      //   }
      // }
    } else {
      setState(() {
        if (loading) {
          success = res['success'];
          loading = false;
        }
        msg = res['msg'] ?? "加载失败，code:${res['error']['code']}";
      });
    }
    if (init && mounted) {
      Future.delayed(Duration(seconds: refreshDuration)).then((value) {
        getData(init: init);
      });
      return;
    }
  }

  Widget _buildWidgetItem(widget) {
    if (widget == "SystemInfo") {
      return GestureDetector(
        onTap: () {
          // if (Util.account != 'challengerv')
          //   Navigator.of(context).push(CupertinoPageRoute(builder: (context) {
          //     return SystemInfo(0, system, volumes, disks);
          //   }));
        },
        child: NeuCard(
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          bevel: 20,
          curveType: CurveType.flat,
          decoration: NeumorphicDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Stack(
            children: [
              Consumer(
                builder: (context, wallpaperProvider, _) {
                  return Stack(
                    children: [
                      if (Theme.of(context).brightness == Brightness.dark)
                        Container(
                          height: 170,
                          decoration: BoxDecoration(
                            color: Theme.of(context)
                                .scaffoldBackgroundColor
                                .withOpacity(0.5),
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: DefaultTextStyle(
                            style: TextStyle(
                              color:
                                  Theme.of(context).textTheme.bodyText2?.color,
                            ),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Image.asset(
                                      "assets/icons/info.png",
                                      width: 26,
                                      height: 26,
                                    ),
                                    const SizedBox(
                                      width: 10,
                                    ),
                                    const Text(
                                      "系统状态",
                                      style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w600),
                                    ),
                                  ],
                                ),
                                const SizedBox(
                                  height: 5,
                                ),
                                if (system != null && system!['model'] != null)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 5),
                                    child: Row(
                                      children: [
                                        const Text("产品型号："),
                                        Text("${system!['model']}"),
                                      ],
                                    ),
                                  ),
                                const SizedBox(
                                  height: 5,
                                ),
                                Row(
                                  children: [
                                    const Text("系统名称："),
                                    Text(hostname),
                                    if (system != null &&
                                        system!['verinfo'] != null &&
                                        system!['verinfo']!['sysbit'] != null)
                                      Text(
                                          " ${system!['verinfo']!['sysbit']!}"),
                                    if (system != null &&
                                        system!['verinfo'] != null &&
                                        system!['verinfo']!['is_enterprise'] ==
                                            0)
                                      const Text(" 免费版"),
                                    if (system != null &&
                                        system!['verinfo'] != null &&
                                        system!['verinfo']!['version'] != null)
                                      Text(
                                          " ${system!['verinfo']!['version']!}")
                                  ],
                                ),
                                if (system != null &&
                                    system!['link_status'] != null)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 5),
                                    child: Row(
                                      children: [
                                        const Text("外网状态："),
                                        Text(
                                          (system!['link_status'] > 0
                                              ? "已断开"
                                              : "已连接"),
                                          style: TextStyle(
                                              color: (system!['link_status'] > 0
                                                  ? Colors.red
                                                  : Colors.green)),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                if (system != null &&
                                    system!['cputemp'] != null)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 5),
                                    child: Row(
                                      children: [
                                        const Text("CPU温度："),
                                        Text(
                                          "${system!['cputemp'][0]}℃ ${(system!['cputemp'][0] > 80) ? "警告" : "正常"}",
                                          style: TextStyle(
                                              color: (system!['cputemp'][0] > 80
                                                  ? Colors.red
                                                  : Colors.green)),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                if (system != null &&
                                    system!['uptime'] != null &&
                                    system!['uptime'] != "")
                                  Padding(
                                    padding: const EdgeInsets.only(top: 5),
                                    child: Row(
                                      children: [
                                        const Text("运行时间："),
                                        Text(Util.parseOpTime(
                                            system!['uptime'])),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      );
    } else if (widget == "SYNO.SDS.SystemInfoApp.ConnectionLogWidget" &&
        connectedUsers.isNotEmpty) {
      return NeuCard(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        bevel: 20,
        curveType: CurveType.flat,
        decoration: NeumorphicDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          children: [
            const SizedBox(
              height: 20,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Image.asset(
                    "assets/icons/user.png",
                    width: 26,
                    height: 26,
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  const Text(
                    "登录用户",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
            ...connectedUsers.map(_buildUserItem).toList(),
            const SizedBox(
              height: 20,
            ),
          ],
        ),
      );
    } else if (widget == "SYNO.SDS.TaskScheduler.TaskSchedulerWidget") {
      return GestureDetector(
        onTap: () {
          // Navigator.of(context).push(CupertinoPageRoute(builder: (context) {
          //   return TaskScheduler();
          // }));
        },
        child: NeuCard(
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          bevel: 20,
          curveType: CurveType.flat,
          decoration: NeumorphicDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            children: [
              const SizedBox(
                height: 20,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Image.asset(
                      "assets/icons/task.png",
                      width: 26,
                      height: 26,
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    const Text(
                      "计划任务",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
              ...tasks.map(_buildTaskItem).toList(),
              const SizedBox(
                height: 20,
              ),
            ],
          ),
        ),
      );
    } else if (widget == "SYNO.SDS.SystemInfoApp.RecentLogWidget") {
      return GestureDetector(
        onTap: () {
          // Navigator.of(context).push(CupertinoPageRoute(
          //     builder: (context) {
          //       return LogCenter();
          //     },
          //     settings: const RouteSettings(name: "log_center")));
        },
        child: NeuCard(
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          bevel: 20,
          curveType: CurveType.flat,
          decoration: NeumorphicDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            children: [
              const SizedBox(
                height: 20,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Image.asset(
                      "assets/icons/log.png",
                      width: 26,
                      height: 26,
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    const Text(
                      "最新日志",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              SizedBox(
                height: 300,
                child: latestLog.isNotEmpty
                    ? CupertinoScrollbar(
                        child: ListView.builder(
                          itemBuilder: (context, i) {
                            return _buildLogItem(latestLog[i]);
                          },
                          itemCount: latestLog.length,
                        ),
                      )
                    : const Center(
                        child: Text("暂无日志"),
                      ),
              ),
              const SizedBox(
                height: 10,
              ),
            ],
          ),
        ),
      );
    } else if (widget == "ResourceMonitor") {
      return GestureDetector(
        onTap: () {
          // Navigator.of(context).push(CupertinoPageRoute(builder: (context) {
          //   return ResourceMonitor();
          // }));
        },
        child: NeuCard(
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          bevel: 20,
          curveType: CurveType.flat,
          decoration: NeumorphicDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            children: [
              const SizedBox(
                height: 20,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Image.asset(
                      "assets/icons/resources.png",
                      width: 26,
                      height: 26,
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    const Text(
                      "资源监控",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
              if (system != null) ...[
                const SizedBox(
                  height: 10,
                ),
                GestureDetector(
                  onTap: () {
                    // Navigator.of(context).push(CupertinoPageRoute(
                    //     builder: (context) {
                    //       return Performance(
                    //         tabIndex: 1,
                    //       );
                    //     },
                    //     settings: const RouteSettings(name: "performance")));
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        const SizedBox(
                          width: 60,
                          child: Text("CPU："),
                        ),
                        Expanded(
                          child: NeuCard(
                            curveType: CurveType.flat,
                            bevel: 10,
                            decoration: NeumorphicDecoration(
                              color: Theme.of(context).scaffoldBackgroundColor,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: FAProgressBar(
                              backgroundColor: Colors.transparent,
                              changeColorValue: 90,
                              changeProgressColor: Colors.red,
                              progressColor: Colors.blue,
                              displayTextStyle:
                                  Theme.of(context).textTheme.bodyText1,
                              currentValue: double.parse(system?['cpu'][0]
                                          .toString()
                                          .replaceAll("%", "") ??
                                      "0.0")
                                  .toInt(),
                              displayText: '%',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(
                  height: 15,
                ),
                GestureDetector(
                  onTap: () {
                    // Navigator.of(context).push(CupertinoPageRoute(
                    //     builder: (context) {
                    //       return Performance(
                    //         tabIndex: 2,
                    //       );
                    //     },
                    //     settings: const RouteSettings(name: "performance")));
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        const SizedBox(width: 60, child: Text("RAM：")),
                        Expanded(
                          child: NeuCard(
                            curveType: CurveType.flat,
                            bevel: 10,
                            decoration: NeumorphicDecoration(
                              color: Theme.of(context).scaffoldBackgroundColor,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: FAProgressBar(
                              backgroundColor: Colors.transparent,
                              changeColorValue: 90,
                              changeProgressColor: Colors.red,
                              progressColor: Colors.blue,
                              displayTextStyle:
                                  Theme.of(context).textTheme.bodyText1,
                              currentValue: int.parse(system?['memory']['used']
                                      .toString()
                                      .replaceAll("%", "") ??
                                  "0"),
                              displayText: '%',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(
                  height: 15,
                ),
                GestureDetector(
                  onTap: () {
                    // Navigator.of(context).push(CupertinoPageRoute(
                    //     builder: (context) {
                    //       return Performance(
                    //         tabIndex: 3,
                    //       );
                    //     },
                    //     settings: const RouteSettings(name: "performance")));
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        const SizedBox(width: 60, child: Text("网络：")),
                        const Icon(
                          Icons.upload_sharp,
                          color: Colors.blue,
                        ),
                        Text(
                          Util.formatSize(system?['stream']['upload']) + "/S",
                          style: const TextStyle(color: Colors.blue),
                        ),
                        const SizedBox(
                          width: 30,
                        ),
                        const Icon(
                          Icons.download_sharp,
                          color: Colors.green,
                        ),
                        Text(
                          Util.formatSize(system?['stream']['download']) + "/S",
                          style: const TextStyle(color: Colors.green),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(
                  height: 5,
                ),
                GestureDetector(
                  onTap: () {
                    // Navigator.of(context).push(CupertinoPageRoute(
                    //     builder: (context) {
                    //       return Performance(
                    //         tabIndex: 3,
                    //       );
                    //     },
                    //     settings: const RouteSettings(name: "performance")));
                  },
                  child: AspectRatio(
                    aspectRatio: 1.70,
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: NeuCard(
                        curveType: CurveType.flat,
                        bevel: 20,
                        decoration: NeumorphicDecoration(
                          color: Theme.of(context).scaffoldBackgroundColor,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: LineChart(
                            LineChartData(
                              lineTouchData: LineTouchData(
                                touchTooltipData: LineTouchTooltipData(
                                  tooltipBgColor: Colors.white.withOpacity(0.6),
                                  tooltipRoundedRadius: 20,
                                  fitInsideHorizontally: true,
                                  fitInsideVertically: true,
                                  getTooltipItems: (List<LineBarSpot> items) {
                                    return items.map((LineBarSpot touchedSpot) {
                                      final textStyle = TextStyle(
                                        color: touchedSpot.bar.colors[0],
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      );
                                      return LineTooltipItem(
                                          '${touchedSpot.bar.colors[0] == Colors.blue ? "上传" : "下载"}:${Util.formatSize(touchedSpot.y.floor())}',
                                          textStyle);
                                    }).toList();
                                  },
                                ),
                              ),
                              gridData: FlGridData(
                                show: false,
                              ),
                              titlesData: FlTitlesData(
                                show: true,
                                bottomTitles: SideTitles(
                                  showTitles: false,
                                  reservedSize: 22,
                                ),
                                topTitles: SideTitles(showTitles: false),
                                rightTitles: SideTitles(showTitles: false),
                                leftTitles: SideTitles(
                                  showTitles: true,
                                  getTextStyles: (value, _) => const TextStyle(
                                    color: Color(0xff67727d),
                                    fontSize: 12,
                                  ),
                                  getTitles: chartTitle,
                                  reservedSize: 28,
                                  interval: chartInterval,
                                ),
                              ),
                              // maxY: 20,
                              minY: 0,
                              borderData: FlBorderData(
                                  show: true,
                                  border: Border.all(
                                      color: Colors.black12, width: 1)),
                              lineBarsData: [
                                LineChartBarData(
                                  spots: networks.map((network) {
                                    return FlSpot(
                                        networks.indexOf(network).toDouble(),
                                        network['upload'].toDouble());
                                  }).toList(),
                                  isCurved: true,
                                  colors: [
                                    Colors.blue,
                                  ],
                                  barWidth: 2,
                                  isStrokeCapRound: true,
                                  dotData: FlDotData(
                                    show: false,
                                  ),
                                  belowBarData: BarAreaData(
                                    show: true,
                                    colors: [Colors.blue.withOpacity(0.2)],
                                  ),
                                ),
                                LineChartBarData(
                                  spots: networks.map((network) {
                                    return FlSpot(
                                        networks.indexOf(network).toDouble(),
                                        network['download'].toDouble());
                                  }).toList(),
                                  isCurved: true,
                                  colors: [
                                    Colors.green,
                                  ],
                                  barWidth: 2,
                                  isStrokeCapRound: true,
                                  dotData: FlDotData(
                                    show: false,
                                  ),
                                  belowBarData: BarAreaData(
                                    show: true,
                                    colors: [
                                      Colors.green.withOpacity(0.2),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ] else
                const SizedBox(
                  height: 300,
                  child: Center(child: Text("数据加载失败")),
                ),
            ],
          ),
        ),
      );
    } else if (widget == "Flow") {
      return GestureDetector(
        onTap: () {
          // Navigator.of(context).push(CupertinoPageRoute(builder: (context) {
          //   return ResourceMonitor();
          // }));
        },
        child: NeuCard(
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          bevel: 20,
          curveType: CurveType.flat,
          decoration: NeumorphicDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            children: [
              const SizedBox(
                height: 20,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Image.asset(
                      "assets/icons/resources.png",
                      width: 26,
                      height: 26,
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    const Text(
                      "近30分钟协议流量分布",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
              if (flows != null) ...[
                GestureDetector(
                  onTap: () {
                    // Navigator.of(context).push(CupertinoPageRoute(
                    //     builder: (context) {
                    //       return Performance(
                    //         tabIndex: 3,
                    //       );
                    //     },
                    //     settings: const RouteSettings(name: "performance")));
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            const SizedBox(
                              child: Text("总流量："),
                            ),
                            Expanded(child: Text(flowUnit(flowTotal))),
                          ],
                        ),
                        AspectRatio(
                          aspectRatio: 1.4,
                          child: Row(
                            children: <Widget>[
                              Expanded(
                                child: AspectRatio(
                                  aspectRatio: 1,
                                  child: PieChart(
                                    PieChartData(
                                        pieTouchData: PieTouchData(
                                            touchCallback: (FlTouchEvent event,
                                                pieTouchResponse) {
                                          setState(() {
                                            if (!event
                                                    .isInterestedForInteractions ||
                                                pieTouchResponse == null ||
                                                pieTouchResponse
                                                        .touchedSection ==
                                                    null) {
                                              touchedIndex = -1;
                                              return;
                                            }
                                            touchedIndex = pieTouchResponse
                                                .touchedSection!
                                                .touchedSectionIndex;
                                          });
                                        }),
                                        borderData: FlBorderData(
                                          show: false,
                                        ),
                                        sectionsSpace: 0,
                                        centerSpaceRadius: 50,
                                        sections: showingSections()),
                                  ),
                                ),
                              ),
                              Column(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment: MainAxisAlignment.end,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: showIndicators(),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ] else
                const SizedBox(
                  height: 300,
                  child: Center(child: Text("数据加载失败")),
                ),
            ],
          ),
        ),
      );
    } else if (widget == "SYNO.SDS.SystemInfoApp.StorageUsageWidget") {
      return Column(
        children: [
          GestureDetector(
            onTap: () {
              // Navigator.of(context).push(CupertinoPageRoute(builder: (context) {
              //   return SystemInfo(2, system, volumes, disks);
              // }));
            },
            child: NeuCard(
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              curveType: CurveType.flat,
              bevel: 20,
              decoration: NeumorphicDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  const SizedBox(
                    height: 20,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        Image.asset(
                          "assets/icons/pie.png",
                          width: 26,
                          height: 26,
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        const Text(
                          "存储",
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                  ...volumes.reversed.map(_buildVolumeItem).toList(),
                  const SizedBox(
                    height: 20,
                  ),
                ],
              ),
            ),
          ),
          if (ssdCaches.isNotEmpty)
            NeuCard(
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              curveType: CurveType.flat,
              bevel: 20,
              decoration: NeumorphicDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  const SizedBox(
                    height: 20,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        Image.asset(
                          "assets/icons/cache.png",
                          width: 26,
                          height: 26,
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        const Text(
                          "缓存",
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                  ...ssdCaches.map(_buildSSDCacheItem).toList(),
                  const SizedBox(
                    height: 20,
                  ),
                ],
              ),
            )
        ],
      );
    } else if (widget == "SYNO.SDS.SystemInfoApp.FileChangeLogWidget") {
      return NeuCard(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        bevel: 20,
        curveType: CurveType.flat,
        decoration: NeumorphicDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          children: [
            const SizedBox(
              height: 20,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Image.asset(
                    "assets/icons/file_change.png",
                    width: 26,
                    height: 26,
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  const Text(
                    "文件更改日志",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            SizedBox(
              height: 300,
              child: fileLogs.isNotEmpty
                  ? CupertinoScrollbar(
                      child: ListView.builder(
                        itemBuilder: (context, i) {
                          return _buildFileLogItem(fileLogs[i]);
                        },
                        itemCount: fileLogs.length,
                      ),
                    )
                  : const Center(
                      child: Text("暂无日志"),
                    ),
            ),
            const SizedBox(
              height: 10,
            ),
          ],
        ),
      );
    } else {
      return Container();
    }
  }

  int touchedIndex = -1;
  var colors = [
    0xff9a7fd1,
    0xffffb980,
    0xffdc69aa,
    0xff07a2a4,
    0xff8d98b3,
    0xffb6a2de,
    0xff5ab1ef,
    0xff2ec7c9,
    0xffe5cf0d,
    0xffd87a80
  ];

  List<Widget> showIndicators() {
    List<Widget> list = [];
    int i = 0;
    flows?.forEach((key, value) {
      list.add(Indicator(
        color: Color(colors[i]),
        text: key,
        isSquare: true,
        size: 12,
      ));
      list.add(const SizedBox(
        height: 4,
      ));
      i++;
    });
    return list;
  }

  List<PieChartSectionData> showingSections() {
    List<PieChartSectionData> list = [];
    int i = 0;
    flows?.forEach((key, value) {
      if (key != "Total") {
        final isTouched = i == touchedIndex;
        const fontSize = 16.0;
        final radius = isTouched ? 60.0 : 50.0;
        double percent = value * 100 / flowTotal;
        list.add(PieChartSectionData(
            color: Color(colors[i]),
            value: percent,
            title: "",
            radius: radius,
            badgeWidget: Visibility(
              visible: isTouched,
              child: Card(
                  color: Colors.black26,
                  child: Text(
                    flowUnit(value),
                    style: const TextStyle(
                        fontSize: fontSize,
                        fontWeight: FontWeight.bold,
                        color: Color(0xffffffff)),
                  )),
            )));
        i++;
      }
    });
    return list;
  }

  Widget _buildUserItem(user) {
    user['running'] = user['running'] ?? false;
    DateTime loginTime =
        DateTime.parse(user['time'].toString().replaceAll("/", "-"));
    DateTime currentTime = DateTime.now();
    Map timeLong = Util.timeLong(currentTime.difference(loginTime).inSeconds);
    return NeuCard(
      decoration: NeumorphicDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(10),
      ),
      margin: const EdgeInsets.only(top: 20, left: 20, right: 20),
      bevel: 10,
      curveType: CurveType.flat,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          children: [
            Expanded(
              child: Text(
                "${user['who']}",
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Expanded(
              child: Text(
                "${user['type']}",
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Expanded(
              child: Text(
                "${timeLong['hours'].toString().padLeft(2, "0")}:${timeLong['minutes'].toString().padLeft(2, "0")}:${timeLong['seconds'].toString().padLeft(2, "0")}",
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.right,
              ),
            ),
            const SizedBox(
              width: 5,
            ),
            NeuButton(
              onPressed: () async {
                if (user['running']) {
                  return;
                }
                showCupertinoModalPopup(
                  context: context,
                  builder: (context) {
                    return Material(
                      color: Colors.transparent,
                      child: NeuCard(
                        width: double.infinity,
                        bevel: 5,
                        curveType: CurveType.emboss,
                        decoration: NeumorphicDecoration(
                            color: Theme.of(context).scaffoldBackgroundColor,
                            borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(22))),
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              const Text(
                                "终止连接",
                                style: TextStyle(
                                    fontSize: 20,
                                    color: Colors.black,
                                    fontWeight: FontWeight.w500),
                              ),
                              const SizedBox(
                                height: 12,
                              ),
                              const Text(
                                "确认要终止此连接？",
                                style: TextStyle(
                                    fontSize: 20,
                                    color: Colors.black,
                                    fontWeight: FontWeight.w400),
                              ),
                              const SizedBox(
                                height: 22,
                              ),
                              Row(
                                children: [
                                  Expanded(
                                    child: NeuButton(
                                      onPressed: () async {
                                        Navigator.of(context).pop();
                                        setState(() {
                                          user['running'] = true;
                                        });
                                        // var res = await Api.kickConnection({"who": user['who'], "from": user['from']});
                                        // setState(() {
                                        //   user['running'] = false;
                                        // });
                                        //
                                        // if (res['success']) {
                                        //   Util.toast("连接已终止");
                                        // }
                                      },
                                      decoration: NeumorphicDecoration(
                                        color: Theme.of(context)
                                            .scaffoldBackgroundColor,
                                        borderRadius: BorderRadius.circular(25),
                                      ),
                                      bevel: 5,
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 10),
                                      child: const Text(
                                        "终止连接",
                                        style: TextStyle(
                                            fontSize: 18,
                                            color: Colors.redAccent),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 16,
                                  ),
                                  Expanded(
                                    child: NeuButton(
                                      onPressed: () async {
                                        Navigator.of(context).pop();
                                      },
                                      decoration: NeumorphicDecoration(
                                        color: Theme.of(context)
                                            .scaffoldBackgroundColor,
                                        borderRadius: BorderRadius.circular(25),
                                      ),
                                      bevel: 5,
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 10),
                                      child: const Text(
                                        "取消",
                                        style: TextStyle(fontSize: 18),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(
                                height: 8,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
              decoration: NeumorphicDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.all(5),
              bevel: 5,
              child: SizedBox(
                width: 20,
                height: 20,
                child: user['running']
                    ? const CupertinoActivityIndicator()
                    : const Icon(
                        Icons.remove_circle_outline,
                        color: Colors.red,
                        size: 18,
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskItem(task) {
    task['running'] = task['running'] ?? false;
    return NeuCard(
      decoration: NeumorphicDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(10),
      ),
      margin: const EdgeInsets.only(top: 20, left: 20, right: 20),
      bevel: 10,
      curveType: CurveType.flat,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          children: [
            Expanded(
              child: Text(
                "${task['name']}",
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(
              width: 5,
            ),
            Text(
              "${task['next_trigger_time']}",
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(
              width: 5,
            ),
            NeuButton(
              onPressed: () async {
                // if (task['running']) {
                //   return;
                // }
                // setState(() {
                //   task['running'] = true;
                // });
                // var res = await Api.taskRun([task['id']]);
                // setState(() {
                //   task['running'] = false;
                // });
                // if (res['success']) {
                //   Util.toast("任务计划执行成功");
                // } else {
                //   Util.toast("任务计划执行失败，code：${res['error']['code']}");
                // }
              },
              decoration: NeumorphicDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.all(5),
              bevel: 5,
              child: SizedBox(
                width: 20,
                height: 20,
                child: task['running']
                    ? const CupertinoActivityIndicator()
                    : const Icon(
                        CupertinoIcons.play_arrow_solid,
                        color: Color(0xffff9813),
                        size: 16,
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogItem(log) {
    return NeuCard(
      decoration: NeumorphicDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.all(15),
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      bevel: 10,
      curveType: CurveType.flat,
      child: Row(
        children: [
          Expanded(
            child: Text(
              "${log['msg']}",
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFileLogItem(log) {
    return NeuCard(
      decoration: NeumorphicDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.all(15),
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      bevel: 10,
      curveType: CurveType.flat,
      child: Row(
        children: [
          Icon(log['cmd'] == "delete"
              ? Icons.delete
              : log['cmd'] == "copy"
                  ? Icons.copy
                  : log['cmd'] == "edit"
                      ? Icons.edit
                      : log['cmd'] == "move"
                          ? Icons.drive_file_move_outline
                          : log['cmd'] == "download"
                              ? Icons.download_outlined
                              : log['cmd'] == "upload"
                                  ? Icons.upload_outlined
                                  : log['cmd'] == "rename"
                                      ? Icons.drive_file_rename_outline
                                      : Icons.code),
          Expanded(
            child: Text(
              "${log['descr']}",
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVolumeItem(volume) {
    double used =
        int.parse(volume['size']['used']) / int.parse(volume['size']['total']);
    return NeuCard(
      decoration: NeumorphicDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      curveType: CurveType.flat,
      padding: const EdgeInsets.all(10),
      margin: const EdgeInsets.only(top: 20, left: 20, right: 20),
      bevel: 10,
      child: Row(
        children: [
          NeuCard(
            curveType: CurveType.flat,
            margin: const EdgeInsets.all(10),
            decoration: NeumorphicDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: BorderRadius.circular(80),
              // color: Colors.red,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 5),
            bevel: 8,
            child: CircularPercentIndicator(
              radius: 80,
              animation: true,
              linearGradient: LinearGradient(
                colors: used <= 0.9
                    ? [
                        Colors.blue,
                        Colors.blueAccent,
                      ]
                    : [
                        Colors.red,
                        Colors.orangeAccent,
                      ],
              ),
              animateFromLastPercent: true,
              circularStrokeCap: CircularStrokeCap.round,
              lineWidth: 12,
              backgroundColor: Colors.black12,
              percent: used,
              center: Text(
                "${(used * 100).toStringAsFixed(0)}%",
                style: TextStyle(
                    color: used <= 0.9 ? Colors.blue : Colors.red,
                    fontSize: 22),
              ),
            ),
          ),
          const SizedBox(
            width: 10,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      volume['deploy_path'] != null
                          ? volume['deploy_path']
                              .toString()
                              .replaceFirst("volume_", "存储空间 ")
                          : volume['id']
                              .toString()
                              .replaceFirst("volume_", "存储空间 "),
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(
                      width: 5,
                    ),
                    volume['status'] == "normal"
                        ? const Label(
                            "正常",
                            Colors.green,
                            fill: true,
                          )
                        : volume['status'] == "background"
                            ? const Label(
                                "正在检查硬盘",
                                Colors.lightBlueAccent,
                                fill: true,
                              )
                            : volume['status'] == "attention"
                                ? const Label(
                                    "注意",
                                    Colors.orangeAccent,
                                    fill: true,
                                  )
                                : Label(
                                    volume['status'],
                                    Colors.red,
                                    fill: true,
                                  ),
                  ],
                ),
                const SizedBox(
                  height: 5,
                ),
                Text(
                    "已用：${Util.formatSize(int.parse(volume['size']['used']))}"),
                const SizedBox(
                  height: 5,
                ),
                Text(
                    "可用：${Util.formatSize(int.parse(volume['size']['total']) - int.parse(volume['size']['used']))}"),
                const SizedBox(
                  height: 5,
                ),
                Text(
                    "容量：${Util.formatSize(int.parse(volume['size']['total']))}"),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildSSDCacheItem(volume) {
    return NeuCard(
      decoration: NeumorphicDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      curveType: CurveType.flat,
      padding: const EdgeInsets.all(10),
      margin: const EdgeInsets.only(top: 20, left: 20, right: 20),
      bevel: 10,
      child: Row(
        children: [
          NeuCard(
            curveType: CurveType.flat,
            margin: const EdgeInsets.all(10),
            decoration: NeumorphicDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: BorderRadius.circular(80),
              // color: Colors.red,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 5),
            bevel: 8,
            child: CircularPercentIndicator(
              radius: 80,
              animation: true,
              linearGradient: LinearGradient(
                colors: int.parse(volume['size']['used']) /
                            int.parse(volume['size']['total']) <=
                        0.9
                    ? [
                        Colors.blue,
                        Colors.blueAccent,
                      ]
                    : [
                        Colors.red,
                        Colors.orangeAccent,
                      ],
              ),
              animateFromLastPercent: true,
              circularStrokeCap: CircularStrokeCap.round,
              lineWidth: 12,
              backgroundColor: Colors.black12,
              percent: int.parse(volume['size']['used']) /
                  int.parse(volume['size']['total']),
              center: Text(
                "${(int.parse(volume['size']['used']) / int.parse(volume['size']['total']) * 100).toStringAsFixed(0)}%",
                style: TextStyle(
                    color: int.parse(volume['size']['used']) /
                                int.parse(volume['size']['total']) <=
                            0.9
                        ? Colors.blue
                        : Colors.red,
                    fontSize: 22),
              ),
            ),
          ),
          const SizedBox(
            width: 10,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      volume['id'].toString().replaceFirst("ssd_", "SSD 缓存 "),
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(
                      width: 5,
                    ),
                    Label(
                      volume['status'] == "normal" ? "正常" : volume['status'],
                      volume['status'] == "normal" ? Colors.green : Colors.red,
                      fill: true,
                    ),
                  ],
                ),
                const SizedBox(
                  height: 5,
                ),
                Text(
                    "已用：${Util.formatSize(int.parse(volume['size']['used']))}"),
                const SizedBox(
                  height: 5,
                ),
                Text(
                    "可用：${Util.formatSize(int.parse(volume['size']['total']) - int.parse(volume['size']['used']))}"),
                const SizedBox(
                  height: 5,
                ),
                Text(
                    "容量：${Util.formatSize(int.parse(volume['size']['total']))}"),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildESataItem(esata) {
    return NeuCard(
      margin: const EdgeInsets.only(bottom: 20),
      curveType: CurveType.flat,
      decoration: NeumorphicDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      bevel: 20,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  "${esata['dev_title']}",
                ),
                const SizedBox(
                  width: 10,
                ),
                esata['status'] == "normal"
                    ? const Label(
                        "正常",
                        Colors.green,
                        fill: true,
                      )
                    : Label(
                        esata['status'],
                        Colors.red,
                        fill: true,
                      ),
                const SizedBox(
                  width: 10,
                ),
                const Spacer(),
                NeuButton(
                  onPressed: () async {
                    // var res = await Api.ejectEsata(esata['dev_id']);
                    // if (res['success']) {
                    //   Util.toast("设备已退出");
                    //   getData();
                    // } else {
                    //   Util.toast("设备退出失败，代码${res['error']['code']}");
                    // }
                  },
                  decoration: NeumorphicDecoration(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.all(5),
                  bevel: 5,
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: Image.asset(
                      "assets/icons/eject.png",
                      width: 20,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    SettingProvider settingProvider = Provider.of<SettingProvider>(context);
    refreshDuration = settingProvider.refreshDuration;
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: const Text(
          "控制台",
        ),
        leadingWidth: 180,
        leading: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // if (showMainMenu)
            //   Padding(
            //     padding: const EdgeInsets.only(left: 10, top: 8, bottom: 8),
            //     child: NeuButton(
            //       decoration: NeumorphicDecoration(
            //         color: Theme.of(context).scaffoldBackgroundColor,
            //         borderRadius: BorderRadius.circular(10),
            //       ),
            //       padding: const EdgeInsets.all(10),
            //       bevel: 5,
            //       onPressed: () {
            //         _scaffoldKey.currentState?.openDrawer();
            //       },
            //       child: Image.asset(
            //         "assets/icons/application.png",
            //         width: 20,
            //       ),
            //     ),
            //   ),
            if (esatas.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(left: 10, top: 8, bottom: 8),
                child: NeuButton(
                  decoration: NeumorphicDecoration(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.all(10),
                  bevel: 5,
                  onPressed: () {
                    showCupertinoModalPopup(
                      context: context,
                      builder: (context) {
                        return Material(
                          color: Colors.transparent,
                          child: NeuCard(
                            width: double.infinity,
                            bevel: 5,
                            curveType: CurveType.emboss,
                            decoration: NeumorphicDecoration(
                                color:
                                    Theme.of(context).scaffoldBackgroundColor,
                                borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(22))),
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  const Text(
                                    "外接设备",
                                    style: TextStyle(
                                        fontSize: 20,
                                        color: Colors.black,
                                        fontWeight: FontWeight.w500),
                                  ),
                                  const SizedBox(
                                    height: 12,
                                  ),
                                  ...esatas.map(_buildESataItem).toList(),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: NeuButton(
                                          onPressed: () async {
                                            // Navigator.of(context).push(CupertinoPageRoute(
                                            //     builder: (context) {
                                            //       return ExternalDevice();
                                            //     },
                                            //     settings: const RouteSettings(name: "external_device")));
                                          },
                                          decoration: NeumorphicDecoration(
                                            color: Theme.of(context)
                                                .scaffoldBackgroundColor,
                                            borderRadius:
                                                BorderRadius.circular(25),
                                          ),
                                          bevel: 5,
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 10),
                                          child: const Text(
                                            "查看详情",
                                            style: TextStyle(fontSize: 18),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(
                                        width: 16,
                                      ),
                                      Expanded(
                                        child: NeuButton(
                                          onPressed: () async {
                                            Navigator.of(context).pop();
                                          },
                                          decoration: NeumorphicDecoration(
                                            color: Theme.of(context)
                                                .scaffoldBackgroundColor,
                                            borderRadius:
                                                BorderRadius.circular(25),
                                          ),
                                          bevel: 5,
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 10),
                                          child: const Text(
                                            "取消",
                                            style: TextStyle(fontSize: 18),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 8,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                  child: Image.asset(
                    "assets/icons/external_devices.png",
                    width: 20,
                  ),
                ),
              ),
            if (converter != null &&
                (converter!['photo_remain'] +
                        converter!['thumb_remain'] +
                        converter!['video_remain'] >
                    0))
              Padding(
                padding: const EdgeInsets.only(left: 10, top: 8, bottom: 8),
                child: NeuButton(
                  decoration: NeumorphicDecoration(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.all(10),
                  bevel: 5,
                  onPressed: () {
                    // showCupertinoModalPopup(
                    //     context: context,
                    //     builder: (context) {
                    //       return MediaConverter(converter);
                    //     });
                  },
                  child: Image.asset(
                    "assets/icons/converter.gif",
                    width: 20,
                  ),
                ),
              ),
          ],
        ),
        actions: const [
          // if (Util.account != 'challengerv')
          // Padding(
          //   padding: const EdgeInsets.only(right: 10, top: 8, bottom: 8),
          //   child: NeuButton(
          //     decoration: NeumorphicDecoration(
          //       color: Theme.of(context).scaffoldBackgroundColor,
          //       borderRadius: BorderRadius.circular(10),
          //     ),
          //     padding: const EdgeInsets.all(10),
          //     bevel: 5,
          //     onPressed: () {
          //       // Navigator.of(context).push(CupertinoPageRoute(builder: (context) {
          //       //   return WidgetSetting(widgets, restoreSizePos);
          //       // })).then((res) {
          //       //   if (res != null) {
          //       //     setState(() {
          //       //       widgets = res;
          //       //       getData();
          //       //     });
          //       //   }
          //       // });
          //     },
          //     child: Image.asset(
          //       "assets/icons/edit.png",
          //       width: 20,
          //       height: 20,
          //     ),
          //   ),
          // ),
          // Padding(
          //   padding: const EdgeInsets.only(right: 10, top: 8, bottom: 8),
          //   child: NeuButton(
          //     decoration: NeumorphicDecoration(
          //       color: Theme.of(context).scaffoldBackgroundColor,
          //       borderRadius: BorderRadius.circular(10),
          //     ),
          //     padding: const EdgeInsets.all(10),
          //     bevel: 5,
          //     onPressed: () {
          //       // Navigator.of(context)
          //       //     .push(CupertinoPageRoute(
          //       //         builder: (context) {
          //       //           return Notify(notifies);
          //       //         },
          //       //         settings: const RouteSettings(name: "notify")))
          //       //     .then((res) {
          //       //   if (res != null && res) {
          //       //     setState(() {
          //       //       notifies = [];
          //       //     });
          //       //   }
          //       // });
          //     },
          //     child: Stack(
          //       alignment: Alignment.topRight,
          //       children: [
          //         Image.asset(
          //           "assets/icons/message.png",
          //           width: 20,
          //           height: 20,
          //         ),
          //         if (notifies.isNotEmpty)
          //           Container(
          //             decoration: BoxDecoration(
          //               color: Colors.red,
          //               borderRadius: BorderRadius.circular(5),
          //             ),
          //             width: 5,
          //             height: 5,
          //           )
          //       ],
          //     ),
          //   ),
          // ),
        ],
      ),
      body: loading
          ? Center(
              child: NeuCard(
                padding: const EdgeInsets.all(50),
                curveType: CurveType.flat,
                decoration: NeumorphicDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                bevel: 20,
                child: const CupertinoActivityIndicator(
                  radius: 14,
                ),
              ),
            )
          : success
              ? ListView(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  children: [
                    if (shortcutItems
                            .where((element) =>
                                supportedShortcuts.contains(element.className))
                            .isNotEmpty &&
                        showMainMenu)
                      Consumer<ShortcutProvider>(
                        builder: (context, shortcutProvider, _) {
                          return shortcutProvider.showShortcut
                              ? ShortcutList(shortcutItems, system, volumes,
                                  disks, appNotify)
                              : Container();
                        },
                      ),
                    if (widgets.isNotEmpty)
                      ...widgets.map((widget) {
                        return _buildWidgetItem(widget);
                        // return Text(widget);
                      }).toList()
                    else
                      Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              "未添加小组件",
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            SizedBox(
                              width: 200,
                              child: NeuButton(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 10),
                                decoration: NeumorphicDecoration(
                                  color:
                                      Theme.of(context).scaffoldBackgroundColor,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                bevel: 5,
                                onPressed: () {
                                  // Navigator.of(context).push(CupertinoPageRoute(builder: (context) {
                                  //   return WidgetSetting(widgets, restoreSizePos);
                                  // })).then((res) {
                                  //   if (res != null) {
                                  //     setState(() {
                                  //       widgets = res;
                                  //       getData();
                                  //     });
                                  //   }
                                  // });
                                },
                                child: const Text(
                                  ' 添加 ',
                                  style: TextStyle(fontSize: 18),
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                  ],
                )
              : Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(msg),
                      const SizedBox(
                        height: 20,
                      ),
                      SizedBox(
                        width: 200,
                        child: NeuButton(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 10),
                          decoration: NeumorphicDecoration(
                            color: Theme.of(context).scaffoldBackgroundColor,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          bevel: 5,
                          onPressed: () {
                            getData();
                          },
                          child: const Text(
                            ' 刷新 ',
                            style: TextStyle(fontSize: 18),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
      drawer: applications.isNotEmpty
          ? ApplicationList(applications, system, volumes, disks, appNotify)
          : null,
    );
  }
}
