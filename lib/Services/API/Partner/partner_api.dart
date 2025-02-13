import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sdaemployee/Constant/constant.dart';
import 'package:sdaemployee/Models/User.dart';
import 'package:sdaemployee/Services/Storage/share_prefs.dart';

class PartnerApi {
  Future<Map<String,dynamic>> fetchClients()async{
    try {
      User user = await SharePrefs().getUser();
      final url = Uri.parse("$api_link/employee/clients/${user.user_id}");
      String token = await SharePrefs().getToken();
      final response = await http.get(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token"
        },
      );

      final responseData = jsonDecode(response.body);
      return responseData;
    } catch (e) {
      print(e);
      return {"status": false};
    }
  }
}