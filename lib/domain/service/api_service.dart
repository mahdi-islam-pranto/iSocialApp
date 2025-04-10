import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:isocial/domain/service/default_response.dart';

class ApiService {
  static Future<DefaultResponse> post(
      {required String url,
      required Map<String, dynamic> body,
      Map<String, dynamic>? header}) async {
    try {
      HttpClient httpClient = HttpClient();

      log("API URL -> $url");

      HttpClientRequest request = await httpClient.postUrl(Uri.parse(url));

      request.headers.set('content-type', 'application/json');

      header?.forEach((key, value) => request.headers.set(key, value));

      request.add(utf8.encode(json.encode(body)));

      HttpClientResponse response = await request.close();
      var reply = await response.transform(utf8.decoder).join();
      httpClient.close();

      // log("API Response -> $reply");

      // Check if response is empty
      if (reply.isEmpty) {
        log("Empty response received from API");
        return DefaultResponse(
            success: false,
            response: {"message": "Empty response received from server"});
      }

      // Try to parse the JSON response
      Map<String, dynamic> jsonResponse;
      try {
        jsonResponse = jsonDecode(reply);
      } catch (e) {
        log("Error parsing JSON response: $e");
        log("Raw response: $reply");
        return DefaultResponse(
            success: false,
            response: {"message": "Invalid response format: $e"});
      }

      if (isSuccess(statusCode: response.statusCode)) {
        return DefaultResponse(success: true, response: jsonResponse);
      }
    } on HttpException catch (e, tr) {
      log("Error -> $e");
      log("Error -> $tr");
      return DefaultResponse(
          success: false, response: {"message": e.toString()});
    }

    return DefaultResponse(
        success: false, response: {"message": "Something went wrong"});
  }

  static Future<DefaultResponse> get(
      {required String url, Map<String, String>? header}) async {
    try {
      log("API URL -> $url");

      var hostUrl = Uri.parse(url);
      http.Response response = await http.get(hostUrl, headers: header);

      if (isSuccess(statusCode: response.statusCode)) {
        return DefaultResponse(
            success: true, response: jsonDecode(response.body));
      }
    } on http.ClientException catch (e, tr) {
      log("Error -> $e");
      log("Error -> $tr");
      return DefaultResponse(
          success: false, response: {"message": e.toString()});
    }

    return DefaultResponse(
        success: false, response: {"message": "Something went wrong"});
  }

  static bool isSuccess({required int statusCode}) {
    if (statusCode == 200 ||
        statusCode == 201 ||
        statusCode == 202 ||
        statusCode == 203 ||
        statusCode == 204 ||
        statusCode == 205 ||
        statusCode == 206 ||
        statusCode == 207 ||
        statusCode == 208 ||
        statusCode == 226) {
      return true;
    }
    return false;
  }
}
