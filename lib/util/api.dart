import 'package:dio/dio.dart';

import 'http.dart';

class Api {
  static Future<Map> login(
      {required String host,
      required String account,
      required String password,
      CancelToken? cancelToken,
      bool rememberPassword = false,
      String? cookie}) async {
    var data = {
      "username": account,
      "passwd": password,
      "pass": password,
      "remember_password": rememberPassword,
    };
    return await Http.post("login",
        host: host, data: data, cancelToken: cancelToken, cookie: cookie);
  }

  static Future<Map> getPoolNum(
      {String? host,
      Map<String, Object>? data,
      CancelToken? cancelToken,
      String? cookie}) async {
    return await call(data: {
      "func_name": "homepage",
      "action": "show",
      "param": {"TYPE": "dhcp_addrpool_num"}
    }, cancelToken: cancelToken, cookie: cookie);
  }

  static Future<Map> call(
      {String? host,
      Map<String, Object>? data,
      CancelToken? cancelToken,
      String? cookie}) async {
    return await Http.post("call",
        host: host, data: data, cancelToken: cancelToken, cookie: cookie);
  }
}
