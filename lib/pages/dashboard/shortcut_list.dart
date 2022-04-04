import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ikuai_helper/pages/dashboard/shortcut_item_model.dart';
import 'package:neumorphic/neumorphic.dart';

import '../../util/badge.dart';

List supportedShortcuts = [
  "SYNO.SDS.PkgManApp.Instance",
  "SYNO.SDS.AdminCenter.Application",
  "SYNO.SDS.StorageManager.Instance",
  "SYNO.SDS.Docker.Application",
  "SYNO.SDS.Docker.ContainerDetail.Instance",
  "SYNO.SDS.LogCenter.Instance",
  "SYNO.SDS.ResourceMonitor.Instance",
  "SYNO.SDS.Virtualization.Application",
  "SYNO.SDS.DownloadStation.Application",
  "SYNO.SDS.XLPan.Application",
];

class ShortcutList extends StatelessWidget {
  final List<ShortcutItemModel> shortcutItems;
  final Map? system;
  final List volumes;
  final List disks;
  final Map? appNotify;
  const ShortcutList(this.shortcutItems, this.system, this.volumes, this.disks, this.appNotify, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return NeuCard(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      bevel: 20,
      curveType: CurveType.flat,
      decoration: NeumorphicDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: SizedBox(
        height: 140,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemBuilder: (context, i) {
            return _buildShortcutItem(context, shortcutItems[i]);
          },
          itemCount: shortcutItems.length,
        ),
      ),
    );
  }

  Widget _buildShortcutItem(BuildContext context, ShortcutItemModel shortcut) {
    String icon = "";
    String name = "";
    CupertinoPageRoute? route;
    int unread = 0;
    switch (shortcut.className) {
      // case "SYNO.SDS.PkgManApp.Instance":
      //   icon = "assets/applications/${Util.version}/package_center.png";
      //   name = "套件中心";
      //   route = CupertinoPageRoute(
      //       builder: (context) {
      //         return Packages(system['firmware_ver']);
      //       },
      //       settings: const RouteSettings(name: "packages"));
      //   if (appNotify != null && appNotify['SYNO.SDS.PkgManApp.Instance'] != null) {
      //     unread = appNotify['SYNO.SDS.PkgManApp.Instance']['unread'];
      //   }
      //   break;
      // case "SYNO.SDS.AdminCenter.Application":
      //   icon = "assets/applications/${Util.version}/control_panel.png";
      //   name = "控制面板";
      //   route = CupertinoPageRoute(
      //       builder: (context) {
      //         return ControlPanel(system, volumes, disks, appNotify['SYNO.SDS.AdminCenter.Application'] == null ? null : appNotify['SYNO.SDS.AdminCenter.Application']['fn']);
      //       },
      //       settings: const RouteSettings(name: "control_panel"));
      //   if (appNotify != null && appNotify['SYNO.SDS.AdminCenter.Application'] != null) {
      //     unread = appNotify['SYNO.SDS.AdminCenter.Application']['unread'];
      //   }
      //   break;
      // case "SYNO.SDS.StorageManager.Instance":
      //   icon = "assets/applications/${Util.version}/storage_manager.png";
      //   name = "存储空间管理员";
      //   route = CupertinoPageRoute(
      //       builder: (context) {
      //         return StorageManager();
      //       },
      //       settings: const RouteSettings(name: "storage_manager"));
      //   break;
      // case "SYNO.SDS.Docker.Application":
      //   icon = "assets/applications/docker.png";
      //   name = "Docker";
      //   route = CupertinoPageRoute(
      //     builder: (context) {
      //       return Docker();
      //     },
      //     settings: const RouteSettings(name: "docker"),
      //   );
      //   break;
      // case "SYNO.SDS.Docker.ContainerDetail.Instance":
      //   icon = "assets/applications/docker.png";
      //   name = "${shortcut.param.data.name}";
      //   if (shortcut.type == 'url') {
      //     route = CupertinoPageRoute(
      //       builder: (context) {
      //         return Browser(
      //           url: shortcut.url,
      //           title: name,
      //         );
      //       },
      //       settings: const RouteSettings(name: "browser"),
      //     );
      //   } else {
      //     route = CupertinoPageRoute(
      //       builder: (context) {
      //         return ContainerDetail(name);
      //       },
      //       settings: const RouteSettings(name: "docker_container_detail"),
      //     );
      //   }
      //
      //   break;
      // case "SYNO.SDS.LogCenter.Instance":
      //   icon = "assets/applications/${Util.version}/log_center.png";
      //   name = "日志中心";
      //   route = CupertinoPageRoute(
      //       builder: (context) {
      //         return LogCenter();
      //       },
      //       settings: const RouteSettings(name: "log_center"));
      //   break;
      // case "SYNO.SDS.ResourceMonitor.Instance":
      //   icon = "assets/applications/${Util.version}/resource_monitor.png";
      //   name = "资源监控";
      //   route = CupertinoPageRoute(
      //       builder: (context) {
      //         return ResourceMonitor();
      //       },
      //       settings: const RouteSettings(name: "resource_monitor"));
      //
      //   break;
      // // case "SYNO.SDS.SecurityScan.Instance":
      // //   icon = "assets/applications/security_scan.png";
      // //   break;
      // case "SYNO.SDS.Virtualization.Application":
      //   icon = "assets/applications/${Util.version}/virtual_machine.png";
      //   name = "Virtual Machine Manager";
      //   route = CupertinoPageRoute(
      //     builder: (context) {
      //       return VirtualMachine();
      //     },
      //     settings: const RouteSettings(name: "virtual_machine_manager"),
      //   );
      //   break;
      // case "SYNO.SDS.DownloadStation.Application":
      //   icon = "assets/applications/download_station.png";
      //   name = "Download Station";
      //   route = CupertinoPageRoute(
      //     builder: (context) {
      //       return DownloadStation();
      //     },
      //     settings: const RouteSettings(name: "download_station"),
      //   );
      //   break;
      // case "SYNO.SDS.XLPan.Application":
      //   icon = "assets/applications/xunlei.png";
      //   name = "迅雷";
      //   route = CupertinoPageRoute(builder: (context) {
      //     return Browser(
      //       title: "迅雷-远程设备",
      //       url: "https://pan.xunlei.com/yc/?fromApp=paipai",
      //     );
      //   });
      //   break;
    }
    if (icon != "") {
      return Padding(
        padding: const EdgeInsets.only(left: 20, top: 20, bottom: 20),
        child: GestureDetector(
          onTap: () {
            // Navigator.of(context).push(route);
          },
          child: NeuCard(
            bevel: 20,
            width: 100,
            curveType: CurveType.flat,
            decoration: NeumorphicDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Stack(
              children: [
                Align(
                  alignment: Alignment.center,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Column(
                      children: [
                        Image.asset(
                          icon,
                          width: 50,
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        Text(
                          name,
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.clip,
                          style: const TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  right: 10,
                  top: 10,
                  child: Badge(
                    unread,
                    size: 20,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    } else {
      return const SizedBox();
    }
  }
}
