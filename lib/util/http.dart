import 'dart:convert';
import 'dart:io';

import 'package:dio/adapter.dart';
import 'package:dio/dio.dart';

import 'function.dart';

class Http {
  static String baseUrl = "";

  static Future<dynamic> get(String url,
      {Map<String, dynamic>? data,
      bool login = true,
      String? host,
      Map<String, dynamic>? headers,
      CancelToken? cancelToken,
      bool? checkSsl,
      String? cookie,
      int timeout = 20,
      bool decode = true}) async {
    headers = headers ?? {};
    headers['Cookie'] = cookie ?? Util.cookie;
    headers["Accept-Language"] =
        "zh-CN,zh;q=0.9,en;q=0.8,en-GB;q=0.7,en-US;q=0.6,zh-TW;q=0.5";
    headers['origin'] = host ?? baseUrl;
    headers['referer'] = host ?? baseUrl;
    print(headers);
    Dio dio = Dio(
      BaseOptions(
        baseUrl: url.startsWith("http") ? "" : ((host ?? baseUrl) + "/Action/"),
        headers: headers,
        // connectTimeout: timeout,
      ),
    );
    //忽略Https校验
    if (!(checkSsl ?? Util.checkSsl)) {
      (dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate =
          (client) {
        client.badCertificateCallback = (cert, host, port) {
          return true;
        };
      };
    }

    Response response;
    try {
      response =
          await dio.get(url, queryParameters: data, cancelToken: cancelToken);

      if (response.data is String && decode) {
        try {
          return json.decode(response.data);
        } catch (e) {
          return response.data;
        }
      } else if (response.data is Map) {
        return response.data;
      } else {
        return response.data;
      }
    } on DioError catch (error) {
      print(error.message);
      String code = "";
      if (error.message.contains("CERTIFICATE_VERIFY_FAILED")) {
        code = "SSL/HTTPS证书有误";
      } else {
        code = error.message;
      }
      print("请求出错:${headers['origin']} $url");
      return {
        "success": false,
        "error": {"code": code},
        "data": null
      };
    }
  }

  static Future<dynamic> post(String url,
      {Map<String, dynamic>? data,
      bool login = true,
      String? host,
      CancelToken? cancelToken,
      Map<String, dynamic>? headers,
      bool? checkSsl,
      String? cookie,
      int timeout = 20}) async {
    headers = headers ?? {};
    headers['Cookie'] = cookie ?? Util.cookie;
    headers["Accept-Language"] =
        "zh-CN,zh;q=0.9,en;q=0.8,en-GB;q=0.7,en-US;q=0.6,zh-TW;q=0.5";
    headers['origin'] = host ?? baseUrl;
    headers['referer'] = host ?? baseUrl;
    print(host);
    print(baseUrl);
    Dio dio = Dio(
      BaseOptions(
        // connectTimeout: timeout,
        baseUrl: (host ?? baseUrl) + "/Action/",
        contentType: "application/json;charset=UTF-8",
        headers: headers,
      ),
    );
    // (dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate = (client) {
    //   client.findProxy = (uri) {
    //     return "PROXY 192.168.1.159:8888";
    //   };
    // };
    //忽略Https校验
    if (!(checkSsl ?? Util.checkSsl)) {
      (dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate =
          (client) {
        client.badCertificateCallback = (cert, host, port) {
          return true;
        };
      };
    }
    Response response;
    try {
      print(data);
      response = await dio.post(url, data: data, cancelToken: cancelToken);
      if (url == "login") {
        if (response.headers.map['set-cookie'] != null &&
            response.headers.map['set-cookie']!.isNotEmpty) {
          List cookies = [];
          for (int i = 0; i < response.headers.map['set-cookie']!.length; i++) {
            Cookie cookie = Cookie.fromSetCookieValue(
                response.headers.map['set-cookie']![i]);
            cookies.add("${cookie.name}=${cookie.value}");
          }

          Util.cookie = cookies.join("; ");
          Util.setStorage("cookie", Util.cookie!);
        }
      }
      print(response);
      return response.data;
    } on DioError catch (error) {
      print(error);
      print("请求出错:${headers['origin']} $url 请求内容:$data");
      return {
        "success": false,
        "error": {"code": error.message},
        "data": null
      };
    }
  }
}
