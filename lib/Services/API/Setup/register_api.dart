import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sdaemployee/Constant/constant.dart';
import 'package:sdaemployee/Models/User.dart';
import 'package:sdaemployee/Services/Storage/share_prefs.dart';

class RegisterApi {
  Future<Map<String, dynamic>> register(  String first_name,
  String last_name,
  String middle_name,
  String email,
  String mobile,
) async {
    try {
       User user = await SharePrefs().getUser();
      final Map<String, dynamic> body = {
        "first_name": first_name,
        "last_name": last_name,
        "middle_name": middle_name,
        "email": email,
        "mobile": mobile,
        "role": "Client",
        "emp_id":user.user_id
      };
      String token = await SharePrefs().getToken();
      final url = Uri.parse("${api_link}/client");
      final res = await http.post(url,
          headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer $token"
          },
          body: jsonEncode(body));
      final response_data = jsonDecode(res.body);
      return response_data;
    } catch (e) {
      print(e);
      return {"status": false, "message": "Something went Wrong"};
    }
  }


  Future<Map<String, dynamic>> sendOtp(String val,String mobile_no) async {
    try {
      final Map<String, dynamic> body = {"receive": mobile_no, "val": val};

      final url = Uri.parse('${api_link}/auth');
      final res = await http.post(url,
          headers: {"Content-Type": "application/json"},
          body: jsonEncode(body));
      final response_data = jsonDecode(res.body);
      return response_data;
    } catch (e) {
      print(e);
      return {"status": false, "message": "Error sending request"};
    }
  }

  Future<Map<String,dynamic>> verifyOtp(String mobile_no,String otp) async{
    try {
      final Map<String,dynamic> body = {"receive": mobile_no, "otp": otp};
     final url = Uri.parse('${api_link}/auth');
      final res = await http.put(url,
          headers: {"Content-Type": "application/json"},
          body: jsonEncode(body));
      final response_data = jsonDecode(res.body);
      return response_data;
    } catch (e) {
      print(e);
      return {"status": false, "message": "Error sending request"};
    }
  }

}
