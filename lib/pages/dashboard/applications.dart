import 'package:flutter/material.dart';
import 'package:neumorphic/neumorphic.dart';

import '../../util/badge.dart';
import '../../util/function.dart';

class ApplicationList extends StatelessWidget {
  final List applications;
  final Map? system;
  final List volumes;
  final List disks;
  final Map? appNotify;
  const ApplicationList(this.applications, this.system, this.volumes, this.disks, this.appNotify, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.8,
      color: Theme.of(context).scaffoldBackgroundColor,
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          children: [
            Wrap(
              spacing: 20,
              runSpacing: 20,
              children: _buildApplicationList(context),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildApplicationList(BuildContext context) {
    List<Widget> apps = [];
    for (var application in applications) {
      switch (application) {
        case "SYNO.SDS.AdminCenter.Application":
          apps.add(
            GestureDetector(
              onTap: () {
                Navigator.of(context).pop();
                // Navigator.of(context).push(CupertinoPageRoute(
                //     builder: (context) {
                //       return ControlPanel(system, volumes, disks, appNotify['SYNO.SDS.AdminCenter.Application'] == null ? null : appNotify['SYNO.SDS.AdminCenter.Application']['fn']);
                //     },
                //     settings: const RouteSettings(name: "control_panel")));
              },
              child: NeuCard(
                width: (MediaQuery.of(context).size.width * 0.8 - 60) / 2,
                padding: const EdgeInsets.symmetric(vertical: 20),
                curveType: CurveType.flat,
                decoration: NeumorphicDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                bevel: 20,
                child: Stack(
                  children: [
                    Align(
                      alignment: Alignment.center,
                      child: Column(
                        children: [
                          Image.asset(
                            "assets/applications/${Util.version}/control_panel.png",
                            height: 45,
                            width: 45,
                            fit: BoxFit.contain,
                          ),
                          const SizedBox(
                            height: 5,
                          ),
                          const Text("控制面板"),
                        ],
                      ),
                    ),
                    if (appNotify != null && appNotify!['SYNO.SDS.AdminCenter.Application'] != null)
                      Positioned(
                        right: 30,
                        child: Badge(
                          appNotify!['SYNO.SDS.AdminCenter.Application']['unread'],
                          size: 20,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          );
          break;
        case "SYNO.SDS.PkgManApp.Instance":
          apps.add(
            GestureDetector(
              onTap: () {
                Navigator.of(context).pop();
                // Navigator.of(context).push(CupertinoPageRoute(
                //     builder: (context) {
                //       return Packages(system['firmware_ver']);
                //     },
                //     settings: const RouteSettings(name: "packages")));
              },
              child: NeuCard(
                width: (MediaQuery.of(context).size.width * 0.8 - 60) / 2,
                curveType: CurveType.flat,
                decoration: NeumorphicDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                bevel: 20,
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Stack(
                  children: [
                    Align(
                      alignment: Alignment.center,
                      child: Column(
                        children: [
                          Image.asset(
                            "assets/applications/${Util.version}/package_center.png",
                            height: 45,
                            width: 45,
                            fit: BoxFit.contain,
                          ),
                          const SizedBox(
                            height: 5,
                          ),
                          const Text("套件中心"),
                        ],
                      ),
                    ),
                    if (appNotify != null && appNotify!['SYNO.SDS.PkgManApp.Instance'] != null)
                      Positioned(
                        right: 30,
                        child: Badge(
                          appNotify!['SYNO.SDS.PkgManApp.Instance']['unread'],
                          size: 20,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          );
          break;
        case "SYNO.SDS.ResourceMonitor.Instance":
          apps.add(
            GestureDetector(
              onTap: () {
                Navigator.of(context).pop();
                // Navigator.of(context).push(CupertinoPageRoute(
                //     builder: (context) {
                //       return ResourceMonitor();
                //     },
                //     settings: const RouteSettings(name: "resource_monitor")));
              },
              child: NeuCard(
                width: (MediaQuery.of(context).size.width * 0.8 - 60) / 2,
                curveType: CurveType.flat,
                decoration: NeumorphicDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                bevel: 20,
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Column(
                  children: [
                    Image.asset(
                      "assets/applications/${Util.version}/resource_monitor.png",
                      height: 45,
                      width: 45,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    const Text("资源监控"),
                  ],
                ),
              ),
            ),
          );
          break;
        case "SYNO.SDS.StorageManager.Instance":
          apps.add(
            GestureDetector(
              onTap: () {
                Navigator.of(context).pop();
                // Navigator.of(context).push(CupertinoPageRoute(
                //     builder: (context) {
                //       return StorageManager();
                //     },
                //     settings: const RouteSettings(name: "storage_manager")));
              },
              child: NeuCard(
                width: (MediaQuery.of(context).size.width * 0.8 - 60) / 2,
                curveType: CurveType.flat,
                decoration: NeumorphicDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                bevel: 20,
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Column(
                  children: [
                    Image.asset(
                      "assets/applications/${Util.version}/storage_manager.png",
                      height: 45,
                      width: 45,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    const Text("存储空间管理员"),
                  ],
                ),
              ),
            ),
          );
          break;
        case "SYNO.SDS.LogCenter.Instance":
          apps.add(
            GestureDetector(
              onTap: () {
                Navigator.of(context).pop();
                // Navigator.of(context).push(CupertinoPageRoute(
                    // builder: (context) {
                    //   return LogCenter();
                    // },
                    // settings: const RouteSettings(name: "log_center")));
              },
              child: NeuCard(
                width: (MediaQuery.of(context).size.width * 0.8 - 60) / 2,
                curveType: CurveType.flat,
                decoration: NeumorphicDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                bevel: 20,
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Column(
                  children: [
                    Image.asset(
                      "assets/applications/${Util.version}/log_center.png",
                      height: 45,
                      width: 45,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    const Text("日志中心"),
                  ],
                ),
              ),
            ),
          );
          break;
        case "SYNO.SDS.SecurityScan.Instance":
          apps.add(
            GestureDetector(
              onTap: () {
                Navigator.of(context).pop();
                // Navigator.of(context).push(
                //   CupertinoPageRoute(
                //       builder: (context) {
                //         return SecurityScan();
                //       },
                //       settings: const RouteSettings(name: "security_scan")),
                // );
              },
              child: NeuCard(
                width: (MediaQuery.of(context).size.width * 0.8 - 60) / 2,
                curveType: CurveType.flat,
                decoration: NeumorphicDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                bevel: 20,
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Stack(
                  children: [
                    Align(
                      alignment: Alignment.center,
                      child: Column(
                        children: [
                          Image.asset(
                            "assets/applications/${Util.version}/security_scan.png",
                            height: 45,
                            width: 45,
                            fit: BoxFit.contain,
                          ),
                          const SizedBox(
                            height: 5,
                          ),
                          const Text("安全顾问"),
                        ],
                      ),
                    ),
                    if (appNotify != null && appNotify!['SYNO.SDS.SecurityScan.Instance'] != null)
                      Positioned(
                        right: 30,
                        child: Badge(
                          appNotify!['SYNO.SDS.SecurityScan.Instance']['unread'],
                          size: 20,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          );
          break;
        case "SYNO.SDS.XLPan.Application":
          apps.add(
            GestureDetector(
              onTap: () {
                // Navigator.of(context).push(
                //   CupertinoPageRoute(builder: (context) {
                //     return Browser(
                //       title: "迅雷-远程设备",
                //       url: "https://pan.xunlei.com/yc",
                //     );
                //   }),
                // );
              },
              child: NeuCard(
                width: (MediaQuery.of(context).size.width * 0.8 - 60) / 2,
                curveType: CurveType.flat,
                decoration: NeumorphicDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                bevel: 20,
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Column(
                  children: [
                    Image.asset(
                      "assets/applications/xunlei.png",
                      height: 45,
                      width: 45,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    const Text("迅雷"),
                  ],
                ),
              ),
            ),
          );
          break;
        case "SYNO.SDS.Virtualization.Application":
          apps.add(
            GestureDetector(
              onTap: () {
                Navigator.of(context).pop();
                // Navigator.of(context).push(CupertinoPageRoute(
                //   builder: (context) {
                //     return VirtualMachine();
                //   },
                //   settings: const RouteSettings(name: "virtual_machine_manager"),
                // ));
              },
              child: NeuCard(
                width: (MediaQuery.of(context).size.width * 0.8 - 60) / 2,
                curveType: CurveType.flat,
                decoration: NeumorphicDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                bevel: 20,
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Column(
                  children: [
                    Image.asset(
                      "assets/applications/${Util.version}/virtual_machine.png",
                      height: 45,
                      width: 45,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    const Text(
                      "Virtual Machine Manager",
                      maxLines: 1,
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          );
          break;
        case "SYNO.SDS.Docker.Application":
          apps.add(
            GestureDetector(
              onTap: () {
                Navigator.of(context).pop();
                // Navigator.of(context).push(CupertinoPageRoute(
                //   builder: (context) {
                //     return Docker();
                //   },
                //   settings: const RouteSettings(name: "docker"),
                // ));
              },
              child: NeuCard(
                width: (MediaQuery.of(context).size.width * 0.8 - 60) / 2,
                curveType: CurveType.flat,
                decoration: NeumorphicDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                bevel: 20,
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Column(
                  children: [
                    Image.asset(
                      "assets/applications/docker.png",
                      height: 45,
                      width: 45,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    const Text(
                      "Docker",
                      maxLines: 1,
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          );
          break;
        case "SYNO.SDS.DownloadStation.Application":
          apps.add(
            GestureDetector(
              onTap: () {
                Navigator.of(context).pop();
                // Navigator.of(context).push(CupertinoPageRoute(
                //   builder: (context) {
                //     return DownloadStation();
                //   },
                //   settings: const RouteSettings(name: "download_station"),
                // ));
              },
              child: NeuCard(
                width: (MediaQuery.of(context).size.width * 0.8 - 60) / 2,
                curveType: CurveType.flat,
                decoration: NeumorphicDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                bevel: 20,
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Column(
                  children: [
                    Image.asset(
                      "assets/applications/download_station.png",
                      height: 45,
                      width: 45,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    const Text(
                      "Download Station",
                      maxLines: 1,
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          );
          break;
        case "SYNO.Photo.AppInstance":
          apps.add(
            GestureDetector(
              onTap: () {
                Navigator.of(context).pop();
                // Navigator.of(context).push(CupertinoPageRoute(
                //   builder: (context) {
                //     return Moments();
                //   },
                //   settings: const RouteSettings(name: "moments"),
                // ));
              },
              child: NeuCard(
                width: (MediaQuery.of(context).size.width * 0.8 - 60) / 2,
                curveType: CurveType.flat,
                decoration: NeumorphicDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                bevel: 20,
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Column(
                  children: [
                    Image.asset(
                      "assets/applications/6/moments.png",
                      height: 45,
                      width: 45,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    const Text(
                      "Moments",
                      maxLines: 1,
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          );
          break;
        case "SYNO.Foto.AppInstance":
          apps.add(
            GestureDetector(
              onTap: () {
                Navigator.of(context).pop();
                // Navigator.of(context).push(CupertinoPageRoute(
                //   builder: (context) {
                //     return Moments();
                //   },
                //   settings: const RouteSettings(name: "moments"),
                // ));
              },
              child: NeuCard(
                width: (MediaQuery.of(context).size.width * 0.8 - 60) / 2,
                curveType: CurveType.flat,
                decoration: NeumorphicDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                bevel: 20,
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Column(
                  children: [
                    Image.asset(
                      "assets/applications/7/synology_photos.png",
                      height: 45,
                      width: 45,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    const Text(
                      "Synology Photos",
                      maxLines: 1,
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          );
          break;
      }
    }
    // if (applications.contains("SYNO.SDS.EzInternet.Instance")) {
    //   apps.add(
    //     NeuCard(
    //       width: (MediaQuery.of(context).size.width * 0.8 - 60) / 2,
    //       height: 110,
    //       padding: EdgeInsets.symmetric(vertical: 20),
    //       curveType: CurveType.flat,
    //       decoration: NeumorphicDecoration(
    //         color: Theme.of(context).scaffoldBackgroundColor,
    //         borderRadius: BorderRadius.circular(20),
    //       ),
    //       bevel: 20,
    //       child: Column(
    //         children: [
    //           Image.asset(
    //             "assets/applications/ez_internet.png",
    //             height: 45,
    //             width: 45,
    //             fit: BoxFit.contain,
    //           ),
    //           SizedBox(
    //             height: 5,
    //           ),
    //           Text("EZ-Internet"),
    //         ],
    //       ),
    //     ),
    //   );
    // }
    // if (applications.contains("SYNO.SDS.SupportForm.Application")) {
    //   apps.add(
    //     NeuCard(
    //       width: (MediaQuery.of(context).size.width * 0.8 - 60) / 2,
    //       curveType: CurveType.flat,
    //       decoration: NeumorphicDecoration(
    //         color: Theme.of(context).scaffoldBackgroundColor,
    //         borderRadius: BorderRadius.circular(20),
    //       ),
    //       bevel: 20,
    //       padding: EdgeInsets.symmetric(vertical: 20),
    //       child: Column(
    //         children: [
    //           Image.asset(
    //             "assets/applications/support_center.png",
    //             height: 45,
    //             width: 45,
    //             fit: BoxFit.contain,
    //           ),
    //           SizedBox(
    //             height: 5,
    //           ),
    //           Text("技术支持中心"),
    //         ],
    //       ),
    //     ),
    //   );
    // }

    // if (applications.contains("SYNO.SDS.iSCSI.Application")) {
    //   apps.add(
    //     GestureDetector(
    //       onTap: () {
    //         Navigator.of(context).pop();
    //         Navigator.of(context).push(CupertinoPageRoute(
    //             builder: (context) {
    //               return ISCSIManger();
    //             },
    //             settings: RouteSettings(name: "iSCSI_manager")));
    //       },
    //       child: NeuCard(
    //         width: (MediaQuery.of(context).size.width * 0.8 - 60) / 2,
    //         curveType: CurveType.flat,
    //         decoration: NeumorphicDecoration(
    //           color: Theme.of(context).scaffoldBackgroundColor,
    //           borderRadius: BorderRadius.circular(20),
    //         ),
    //         bevel: 20,
    //         padding: EdgeInsets.symmetric(vertical: 20),
    //         child: Column(
    //           children: [
    //             Image.asset(
    //               "assets/applications/iSCSI_manager.png",
    //               height: 45,
    //               width: 45,
    //               fit: BoxFit.contain,
    //             ),
    //             SizedBox(
    //               height: 5,
    //             ),
    //             Text("iSCSI Manager"),
    //           ],
    //         ),
    //       ),
    //     ),
    //   );
    // }

    // if (applications.contains("SYNO.SDS.App.FileStation3.Instance")) {
    //   apps.add(
    //     NeuCard(
    //       width: (MediaQuery.of(context).size.width * 0.8 - 60) / 2,
    //       curveType: CurveType.flat,
    //       decoration: NeumorphicDecoration(
    //         color: Theme.of(context).scaffoldBackgroundColor,
    //         borderRadius: BorderRadius.circular(20),
    //       ),
    //       bevel: 20,
    //       padding: EdgeInsets.symmetric(vertical: 20),
    //       child: Column(
    //         children: [
    //           Image.asset(
    //             "assets/applications/file_browser.png",
    //             height: 45,
    //             width: 45,
    //             fit: BoxFit.contain,
    //           ),
    //           SizedBox(
    //             height: 5,
    //           ),
    //           Text("File Station"),
    //         ],
    //       ),
    //     ),
    //   );
    // }

    // if (applications.contains("SYNO.Finder.Application")) {
    //   apps.add(
    //     GestureDetector(
    //       onTap: () {
    //         Navigator.of(context).pop();
    //         Navigator.of(context).push(CupertinoPageRoute(
    //             builder: (context) {
    //               return UniversalSearch();
    //             },
    //             settings: RouteSettings(name: "universal_search")));
    //       },
    //       child: NeuCard(
    //         width: (MediaQuery.of(context).size.width * 0.8 - 60) / 2,
    //         curveType: CurveType.flat,
    //         decoration: NeumorphicDecoration(
    //           color: Theme.of(context).scaffoldBackgroundColor,
    //           borderRadius: BorderRadius.circular(20),
    //         ),
    //         bevel: 20,
    //         padding: EdgeInsets.symmetric(vertical: 20),
    //         child: Column(
    //           children: [
    //             Image.asset(
    //               "assets/applications/${Util.version}/universal_search.png",
    //               height: 45,
    //               width: 45,
    //               fit: BoxFit.contain,
    //             ),
    //             SizedBox(
    //               height: 5,
    //             ),
    //             Text("Universal Search"),
    //           ],
    //         ),
    //       ),
    //     ),
    //   );
    // }
    // print(applications);

    //SYNO.SDS.PhotoStation  6.0 photo station
    //SYNO.Foto.AppInstance  7.0 photo
    // print(applications);
    return apps;
  }
}
