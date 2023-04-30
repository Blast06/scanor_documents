import 'package:http/http.dart' as http;

class ApiService {
  static var client = http.Client();

  // static Future<Setting> loadSettings() async {
  //   Uri uri = Uri.parse(AppConsts.baseUrl + AppConsts.settings);

  //   String body = jsonEncode(<String, dynamic>{
  //     'api_key': AppConsts.apiKey,
  //   });

  //   var response = await client.post(
  //     uri,
  //     headers: <String, String>{
  //       'Content-Type': 'application/json; charset=UTF-8',
  //     },
  //     body: body,
  //   );

  //   if (response.statusCode == 200) {
  //     var jsonString = response.body;
  //     return Setting.fromJson(jsonDecode(jsonString));
  //   } else {
  //     return Setting();
  //   }
  // }
}
