import 'dart:convert';
import 'dart:io';
import 'package:convert/convert.dart';
import 'package:crypto/crypto.dart';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluwx/fluwx.dart';
import 'package:ikuai_helper/extentions/string.dart';
import 'package:neumorphic/neumorphic.dart';

import '../../util/api.dart';
import '../../util/function.dart';
import '../../util/http.dart';
import '../setting/license.dart';
import '../setting/privacy.dart';

class Login extends StatefulWidget {
  final Map? server;
  final String type;

  const Login({Key? key, this.server, this.type = "login"}) : super(key: key);

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final TapGestureRecognizer _licenseRecognizer = TapGestureRecognizer();
  final TapGestureRecognizer _privacyRecognizer = TapGestureRecognizer();
  Map? updateInfo;
  String host = "";
  String baseUrl = '';
  String account = "";
  String note = "";
  String password = "";
  String port = "80";
  String cookie = "";

  bool? https = false;
  bool login = false;
  bool rememberPassword = true;
  bool autoLogin = true;
  bool checkSsl = true;
  bool read = false;
  final TextEditingController _hostController = TextEditingController();
  final TextEditingController _accountController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _portController = TextEditingController();
  List servers = [];
  List qcAddresses = [];
  CancelToken? cancelToken = CancelToken();

  @override
  initState() {
    Util.getStorage("read").then((value) {
      if (value != null && value.isNotBlank && value == "1") {
        setState(() {
          read = true;
        });
      }
    });
    checkAgreement();

    setState(() {
      read = true;
    });
    Util.getStorage("servers").then((serverString) {
      if (serverString != null && serverString.isNotBlank) {
        servers = jsonDecode(serverString);
      }
      if (widget.server != null) {
        setState(() {
          https = widget.server!['https'];
          host = widget.server!['host'];
          port = widget.server!['port'];
          account = widget.server!['account'];
          note = widget.server!['note'] ?? '';
          password = widget.server!['password'];
          autoLogin = widget.server!['auto_login'];
          rememberPassword = widget.server!['remember_password'];
          checkSsl = widget.server!['check_ssl'];
          if (host.isNotBlank) {
            _hostController.value = TextEditingValue(text: host);
          }
          if (port.isNotBlank) {
            _portController.value = TextEditingValue(text: port);
          }
          if (account.isNotBlank) {
            _accountController.value = TextEditingValue(text: account);
          }
          if (note.isNotBlank) {
            _noteController.value = TextEditingValue(text: note);
          }
          if (password.isNotBlank) {
            _passwordController.value = TextEditingValue(text: password);
          }
        });
        Util.cookie = widget.server!['cookie'];
        if (widget.server!['action'] == "login") {
          _login();
        }
      } else {
        if (widget.type == "login") {
          getInfo();
        }
      }
    });

    super.initState();
  }

  checkAgreement() async {
    String? agreement = await Util.getStorage("agreement");
    if (agreement == null || agreement != '1') {
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
                        NeuCard(
                          decoration: NeumorphicDecoration(
                            color: Theme.of(context).scaffoldBackgroundColor,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          bevel: 20,
                          curveType: CurveType.flat,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 5),
                          child: Text.rich(
                            TextSpan(
                              children: [
                                TextSpan(
                                    text:
                                        "感谢您使用${Util.appName}，为保护您的个人信息安全，我们将依据${Util.appName}的"),
                                TextSpan(
                                  text: "用户协议",
                                  style: const TextStyle(
                                      decoration: TextDecoration.underline,
                                      color: Colors.blue),
                                  recognizer: _licenseRecognizer
                                    ..onTap = () {
                                      FocusScope.of(context).unfocus();
                                      Navigator.of(context).push(
                                          CupertinoPageRoute(
                                              builder: (context) {
                                        return const License();
                                      }));
                                    },
                                ),
                                const TextSpan(text: "和 "),
                                TextSpan(
                                  text: "隐私政策",
                                  style: const TextStyle(
                                      decoration: TextDecoration.underline,
                                      color: Colors.blue),
                                  recognizer: _privacyRecognizer
                                    ..onTap = () {
                                      FocusScope.of(context).unfocus();
                                      Navigator.of(context).push(
                                          CupertinoPageRoute(
                                              builder: (context) {
                                        return const Privacy();
                                      }));
                                    },
                                ),
                                const TextSpan(
                                    text:
                                        "来帮助您了解：我们如何收集个人信息、如何使用及存储个人信息以及您享有的相关权利\n"),
                                TextSpan(text: "在您使用${Util.appName}前，请务必仔细阅读"),
                                TextSpan(
                                  text: "用户协议",
                                  style: const TextStyle(
                                      decoration: TextDecoration.underline,
                                      color: Colors.blue),
                                  recognizer: _licenseRecognizer
                                    ..onTap = () {
                                      FocusScope.of(context).unfocus();
                                      Navigator.of(context).push(
                                          CupertinoPageRoute(
                                              builder: (context) {
                                        return const License();
                                      }));
                                    },
                                ),
                                const TextSpan(text: "和 "),
                                TextSpan(
                                  text: "隐私政策",
                                  style: const TextStyle(
                                      decoration: TextDecoration.underline,
                                      color: Colors.blue),
                                  recognizer: _privacyRecognizer
                                    ..onTap = () {
                                      FocusScope.of(context).unfocus();
                                      Navigator.of(context).push(
                                          CupertinoPageRoute(
                                              builder: (context) {
                                        return const Privacy();
                                      }));
                                    },
                                ),
                                const TextSpan(
                                    text: "以了解详细内容，如您同意，请点击'同意并继续'开始使用我们的服务"),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: TextButton(
                                onPressed: () async {
                                  Navigator.of(context).pop();
                                  Util.setStorage("read", "1");
                                  Util.setStorage(
                                      "agreement", read ? "1" : "0");
                                  registerWxApi(
                                      appId: "wxabdf23571f34b49b",
                                      universalLink:
                                          "https://dsm.apaipai.top/app/");
                                },
                                // decoration: NeumorphicDecoration(
                                //   color:
                                //       Theme.of(context).scaffoldBackgroundColor,
                                //   borderRadius: BorderRadius.circular(25),
                                // ),
                                // bevel: 20,
                                // padding:
                                //     const EdgeInsets.symmetric(vertical: 10),
                                child: const Text(
                                  "同意并继续",
                                  style: TextStyle(fontSize: 18),
                                ),
                              ),
                            ),
                            const SizedBox(
                              width: 16,
                            ),
                            Expanded(
                              child: TextButton(
                                onPressed: () async {
                                  SystemNavigator.pop();
                                },
                                // decoration: NeumorphicDecoration(
                                //   color:
                                //       Theme.of(context).scaffoldBackgroundColor,
                                //   borderRadius: BorderRadius.circular(25),
                                // ),
                                // bevel: 20,
                                // padding:
                                //     const EdgeInsets.symmetric(vertical: 10),
                                child: const Text(
                                  "不同意",
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

  @override
  void dispose() {
    _licenseRecognizer.dispose();
    _privacyRecognizer.dispose();
    super.dispose();
  }

  getInfo() async {
    cookie = await Util.getStorage("cookie") ?? "";
    String httpsString = await Util.getStorage("https") ?? "";
    host = await Util.getStorage("host") ?? "";
    baseUrl = await Util.getStorage("base_url") ?? "";
    String portString = await Util.getStorage("port") ?? "";
    account = await Util.getStorage("account") ?? "";
    note = await Util.getStorage("note") ?? "";
    password = await Util.getStorage("password") ?? "";
    String autoLoginString = await Util.getStorage("auto_login") ?? "";

    String rememberPasswordString =
        await Util.getStorage("remember_password") ?? "";
    String checkSslString = await Util.getStorage("check_ssl") ?? "";
    Util.cookie = cookie;

    if (httpsString.isNotBlank) {
      setState(() {
        https = httpsString == "1";
      });
    }
    if (checkSslString.isNotBlank) {
      setState(() {
        checkSsl = checkSslString == "1";
      });
    }
    if (host.isNotBlank) {
      _hostController.value = TextEditingValue(text: host);
    }
    if (portString.isNotBlank) {
      port = portString;
      _portController.value = TextEditingValue(text: portString);
    } else {
      _portController.value = TextEditingValue(text: port);
    }
    if (account.isNotBlank) {
      _accountController.value = TextEditingValue(text: account);
    }
    if (note.isNotBlank) {
      _noteController.value = TextEditingValue(text: note);
    }
    if (password.isNotBlank) {
      _passwordController.value = TextEditingValue(text: password);
    }
    if (autoLoginString.isNotBlank) {
      setState(() {
        autoLogin = autoLoginString == "1";
      });
    }
    if (rememberPasswordString.isNotBlank) {
      setState(() {
        rememberPassword = rememberPasswordString == "1";
      });
    }
    checkLogin();
  }

  checkLogin() async {
    Util.account = account;
    if (https != null && host.isNotBlank) {
      if (baseUrl.isNotBlank) {
        Http.baseUrl = baseUrl;
      } else {
        Http.baseUrl = "${https == true ? "https" : "http"}://$host:$port";
      }
      //开始自动登录
      //print("BaseUrl:$baseUrl");
      //print("Util.BaseUrl:${Util.baseUrl}");
      //如果开启了自动登录，则判断当前登录状态
      if (autoLogin) {
        setState(() {
          login = true;
        });
        var checkLogin = await Api.call(data: {
          "func_name": "webuser",
          "action": "show",
          "param": {"TYPE": "mod_passwd", "username": "admin"}
        }, cancelToken: cancelToken);
        if (checkLogin['Result'] != 30000) {
          // if (checkLogin['code'] == "用户取消") {
          //   //如果用户主动取消登录
          //   setState(() {
          //     login = false;
          //   });
          // } else {
          //如果登录失效，尝试重新登录
          //print("尝试重新登录");
          _login();
          // }
        } else {
          //登录有效，进入首页
          Navigator.of(context)
              .pushNamedAndRemoveUntil("/home", (route) => false);
        }
      }
    }
  }

  _login() async {
    Util.checkSsl = checkSsl;
    FocusScope.of(context).unfocus();
    if (host.trim() == "") {
      Util.toast("请输入网址/IP");
      return;
    }
    if (account == "") {
      Util.toast("请输入账号");
      return;
    }
    setState(() {
      login = true;
    });
    String baseUri =
        "${https == true ? "https" : "http"}://${host.trim()}:${port.trim()}";
    //print(baseUri);
    doLogin(baseUri);
  }

  doLogin(String baseUri) async {
    var content = const Utf8Encoder().convert(password);
    var digest = md5.convert(content);
    var passwd = hex.encode(digest.bytes);
    var res = await Api.login(
        host: baseUri,
        account: account,
        password: passwd,
        cancelToken: cancelToken,
        rememberPassword: rememberPassword);
    setState(() {
      login = false;
    });
    if (res['Result'] == 10000) {
      //记住登录信息
      Util.account = account;
      Util.setStorage("https", https == true ? "1" : "0");
      Util.setStorage("host", host.trim());
      Util.setStorage("port", port);
      Util.setStorage("base_url", baseUri);
      Util.setStorage("account", account);
      Util.setStorage("note", note);
      Util.setStorage("remember_password", rememberPassword ? "1" : "0");
      Util.setStorage("auto_login", autoLogin ? "1" : "0");
      Util.setStorage("check_ssl", checkSsl ? "1" : "0");
      if (rememberPassword) {
        Util.setStorage("password", password);
      } else {
        Util.removeStorage("password");
      }
      if (autoLogin) {
        Util.setStorage("cookie", Util.cookie ?? "");
      }

      Http.baseUrl = baseUri;

      //添加服务器记录
      bool exist = false;
      for (int i = 0; i < servers.length; i++) {
        if (servers[i]['https'] == https &&
            servers[i]['host'] == host &&
            servers[i]['port'] == port &&
            servers[i]['account'] == account) {
          //print("账号已存在，更新信息");
          if (rememberPassword) {
            servers[i]['password'] = password;
          } else {
            servers[i]['password'] = "";
          }

          servers[i]['remember_password'] = rememberPassword;
          servers[i]['note'] = note;
          servers[i]['auto_login'] = autoLogin;
          servers[i]['check_ssl'] = checkSsl;
          servers[i]['cookie'] = Util.cookie;
          servers[i]['base_url'] = baseUri;
          exist = true;
        }
      }
      if (!exist) {
        //print("账号不存在");
        Map server = {
          "https": https,
          "host": host,
          "base_url": baseUri,
          "port": port,
          "note": note,
          "account": account,
          "remember_password": rememberPassword,
          "auto_login": autoLogin,
          "check_ssl": checkSsl,
          "cookie": Util.cookie,
        };
        if (rememberPassword) {
          server['password'] = password;
        } else {
          server['password'] = "";
        }
        servers.add(server);
      }
      Util.setStorage("servers", jsonEncode(servers));
      if (widget.type == "login") {
        Navigator.of(context)
            .pushNamedAndRemoveUntil("/home", (route) => false);
      } else {
        Navigator.of(context).pop(true);
      }
    } else {
      if (res['Result'] == 10001) {
        Util.toast(res['ErrMsg']);
      } else {
        Util.toast("登录失败，code:${res['Result']},msg:${res['ErrMsg']}");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: updateInfo != null
            ? Padding(
                padding: const EdgeInsets.only(left: 10, top: 8, bottom: 8),
                child: NeuButton(
                  decoration: NeumorphicDecoration(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.all(10),
                  bevel: 5,
                  onPressed: () {
                    // Navigator.of(context).push(CupertinoPageRoute(builder: (context) {
                    //   return Update(updateInfo);
                    // }));
                  },
                  child: Image.asset(
                    "assets/icons/update.png",
                    width: 20,
                    height: 20,
                    color: Colors.redAccent,
                  ),
                ),
              )
            : null,
        title: Text(
          widget.type == "login" ? "账号登录" : "添加账号",
        ),
        actions: [
          // Padding(
          //   padding: EdgeInsets.only(right: 10, top: 8, bottom: 8),
          //   child: NeuButton(
          //     decoration: NeumorphicDecoration(
          //       color: Theme.of(context).scaffoldBackgroundColor,
          //       borderRadius: BorderRadius.circular(10),
          //     ),
          //     padding: EdgeInsets.all(10),
          //     bevel: 5,
          //     onPressed: wakeup,
          //     child: Image.asset(
          //       "assets/icons/history.png",
          //       width: 20,
          //       height: 20,
          //     ),
          //   ),
          // ),
          if (servers.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(right: 10, top: 8, bottom: 8),
              child: NeuButton(
                decoration: NeumorphicDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.all(10),
                bevel: 5,
                onPressed: () {
                  // Navigator.of(context)
                  //     .push(CupertinoPageRoute(builder: (context) {
                  //   return Accounts();
                  // }));
                },
                child: Image.asset(
                  "assets/icons/history.png",
                  width: 20,
                  height: 20,
                ),
              ),
            )
        ],
      ),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: <Widget>[
            const SizedBox(
              height: 20,
            ),
            NeuCard(
              decoration: NeumorphicDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius: BorderRadius.circular(20),
              ),
              bevel: 20,
              curveType: CurveType.flat,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
              child: Row(
                children: [
                  SizedBox(
                    width: 60,
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          https = !https!;
                          if (https == true && port == "5000") {
                            port = "5001";
                            _portController.value =
                                TextEditingValue(text: port);
                          } else if (https != true && port == "5001") {
                            port = "5000";
                            _portController.value =
                                TextEditingValue(text: port);
                          }
                        });
                      },
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(
                            height: 4,
                          ),
                          const Text(
                            "协议",
                            style: TextStyle(
                                fontSize: 12, color: Colors.grey, height: 1),
                          ),
                          Text(
                            https == true ? "https" : "http",
                            style: const TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: TextField(
                      controller: _hostController,
                      onChanged: (v) {
                        setState(() {
                          host = v;
                        });
                      },
                      textInputAction: TextInputAction.next,
                      onEditingComplete: () {
                        FocusScope.of(context).nextFocus();
                      },
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        labelText: '网址/IP',
                      ),
                    ),
                  ),
                  if (host.contains(".") || host.contains(":"))
                    Expanded(
                      flex: 1,
                      child: TextField(
                        onChanged: (v) => port = v,
                        controller: _portController,
                        textInputAction: TextInputAction.next,
                        onEditingComplete: () {
                          FocusScope.of(context).nextFocus();
                        },
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          labelText: '端口',
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            Row(
              children: [
                Expanded(
                  child: NeuCard(
                    decoration: NeumorphicDecoration(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    bevel: 20,
                    curveType: CurveType.flat,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                    child: TextField(
                      keyboardAppearance: Brightness.light,
                      controller: _accountController,
                      onChanged: (v) => account = v,
                      textInputAction: TextInputAction.next,
                      onEditingComplete: () {
                        FocusScope.of(context).nextFocus();
                      },
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        labelText: '账号',
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  width: 20,
                ),
                Expanded(
                  child: NeuCard(
                    decoration: NeumorphicDecoration(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    bevel: 20,
                    curveType: CurveType.flat,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                    child: TextField(
                      keyboardAppearance: Brightness.light,
                      controller: _noteController,
                      onChanged: (v) => note = v,
                      textInputAction: TextInputAction.next,
                      onEditingComplete: () {
                        FocusScope.of(context).nextFocus();
                      },
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        labelText: '备注',
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 20,
            ),
            NeuCard(
              decoration: NeumorphicDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius: BorderRadius.circular(20),
              ),
              bevel: 12,
              curveType: CurveType.flat,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
              child: TextField(
                controller: _passwordController,
                onChanged: (v) => password = v,
                obscureText: true,
                textInputAction: TextInputAction.done,
                onEditingComplete: () {
                  FocusScope.of(context).unfocus();
                },
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  labelText: '密码',
                ),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        rememberPassword = !rememberPassword;
                        if (!rememberPassword) {
                          autoLogin = false;
                        }
                      });
                    },
                    child: NeuCard(
                      decoration: NeumorphicDecoration(
                        color: Theme.of(context).scaffoldBackgroundColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      curveType:
                          rememberPassword ? CurveType.emboss : CurveType.flat,
                      bevel: 12,
                      height: 60,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 5),
                      child: Row(
                        children: [
                          const Text("记住密码"),
                          const Spacer(),
                          if (rememberPassword)
                            const Icon(
                              CupertinoIcons.checkmark_alt,
                              color: Color(0xff0080ff),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  width: 20,
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        autoLogin = !autoLogin;
                        if (autoLogin) {
                          rememberPassword = true;
                        }
                      });
                    },
                    child: NeuCard(
                      decoration: NeumorphicDecoration(
                        color: Theme.of(context).scaffoldBackgroundColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      curveType: autoLogin ? CurveType.emboss : CurveType.flat,
                      bevel: 12,
                      height: 60,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 5),
                      child: Row(
                        children: [
                          const Text("自动登录"),
                          const Spacer(),
                          if (autoLogin)
                            const Icon(
                              CupertinoIcons.checkmark_alt,
                              color: Color(0xff0080ff),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 20,
            ),
            if (https == true)
              Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      checkSsl = !checkSsl;
                    });
                  },
                  child: NeuCard(
                    decoration: NeumorphicDecoration(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    curveType: checkSsl ? CurveType.emboss : CurveType.flat,
                    bevel: 12,
                    height: 60,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                    child: Row(
                      children: [
                        const Text("验证SSL证书"),
                        const Spacer(),
                        if (checkSsl)
                          const Icon(
                            CupertinoIcons.checkmark_alt,
                            color: Color(0xff0080ff),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            // SizedBox(
            //   height: 20,
            // ),

            NeuButton(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              decoration: NeumorphicDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius: BorderRadius.circular(20),
              ),
              onPressed: () {
                if (!read) {
                  Util.toast("请先阅读并同意用户协议和隐私政策");
                  return;
                }
                if (login) {
                  if (login == true) {
                    cancelToken?.cancel("取消登录");
                    cancelToken = CancelToken();
                    return;
                  }
                } else {
                  _login();
                }
              },
              child: login
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        CupertinoActivityIndicator(
                          radius: 13,
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Text(
                          "取消",
                          style: TextStyle(fontSize: 18),
                        ),
                      ],
                    )
                  : Text(
                      widget.type == "login" ? ' 登录 ' : ' 添加 ',
                      style: const TextStyle(fontSize: 18),
                    ),
            ),
            const SizedBox(
              height: 20,
            ),
            if (Platform.isAndroid)
              GestureDetector(
                onTap: () {
                  setState(() {
                    read = !read;
                    Util.setStorage("read", read ? "1" : "0");
                  });
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).scaffoldBackgroundColor,
                        borderRadius: BorderRadius.circular(5),
                        border: Border.all(
                            color:
                                read ? const Color(0xff0080ff) : Colors.grey),
                      ),
                      height: 20,
                      width: 20,
                      alignment: Alignment.center,
                      child: read
                          ? const Icon(
                              CupertinoIcons.checkmark_alt,
                              color: Color(0xff0080ff),
                              size: 16,
                            )
                          : const SizedBox(),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(text: "我已阅读并同意 ${Util.appName}"),
                          TextSpan(
                            text: "用户协议",
                            style: const TextStyle(
                                decoration: TextDecoration.underline,
                                color: Colors.blue,
                                fontSize: 12),
                            recognizer: _licenseRecognizer
                              ..onTap = () {
                                FocusScope.of(context).unfocus();
                                Navigator.of(context).push(
                                    CupertinoPageRoute(builder: (context) {
                                  return const License();
                                }));
                              },
                          ),
                          const TextSpan(text: "和 "),
                          TextSpan(
                            text: "隐私政策",
                            style: const TextStyle(
                                decoration: TextDecoration.underline,
                                color: Colors.blue,
                                fontSize: 12),
                            recognizer: _privacyRecognizer
                              ..onTap = () {
                                FocusScope.of(context).unfocus();
                                Navigator.of(context).push(
                                    CupertinoPageRoute(builder: (context) {
                                  return const Privacy();
                                }));
                              },
                          ),
                        ],
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
              )
          ],
        ),
      ),
    );
  }
}
