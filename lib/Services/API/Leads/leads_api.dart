import 'dart:convert';
import 'dart:core';
import 'package:http/http.dart' as http;
import 'package:sdaemployee/Constant/constant.dart';
import 'package:sdaemployee/Models/User.dart';
import 'package:sdaemployee/Services/Storage/share_prefs.dart';

class LeadApi {
  Future<Map<String, dynamic>> submitLead(
      String name,
      String orgnization_name,
      String email,
      String mobile,
      String lead_type,
      String contact_date,
      String follow_up_date,
      String remark) async {
    try {
      User user = await SharePrefs().getUser();
      Map<String, dynamic> body = {
        "name": name,
        "org_name": orgnization_name,
        "email": email,
        "mobile": mobile,
        "contact_date": contact_date,
        "follow_up_date": follow_up_date,
        "lead_type":lead_type,
        "remark": remark,
        "user_id":user.user_id
      };

      final uri = Uri.parse("$api_link/leads");

      String token = await SharePrefs().getToken();
      final response = await http.post(uri,
          headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer $token"
          },
          body: jsonEncode(body));

      final responseData = jsonDecode(response.body);
      return responseData;
    } catch (e) {
      return {"status": false, "message": "Something Went Wrong"};
    }
  }

  Future<Map<String, dynamic>> fetchLeads() async {
    try {
      final url = Uri.parse("$api_link/leads");
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
      return {
        "status": false,
        "message":"Something Went Wrong"
        };
    }
  }
}
