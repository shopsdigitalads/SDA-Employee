import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sdaemployee/Constant/constant.dart';
import 'package:sdaemployee/Models/User.dart';
import 'package:sdaemployee/Services/Storage/share_prefs.dart';

class AuthApi {
  String mobile_no;
  int? otp;

  AuthApi(this.mobile_no);

  Future<Map<String, dynamic>> sendOtp(String val) async {
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

  Future<Map<String,dynamic>> verifyOtp() async{
    try {
      final Map<String,dynamic> body = {"receive": mobile_no, "otp": otp};
     final url = Uri.parse('${api_link}/auth');
      final res = await http.put(url,
          headers: {"Content-Type": "application/json"},
          body: jsonEncode(body));
      final response_data = jsonDecode(res.body);
      if(response_data['status']){
        SharePrefs().storePrefs("token", response_data['token'], "String");
        if(response_data['user_exists']){
          Map<String,dynamic> new_user = response_data['user'];
          print(response_data['user']);
          User user = User(user_id: new_user["user_id"], first_name: new_user['first_name'], middle_name: new_user['middle_name'], last_name: new_user['last_name'], mobile: new_user['mobile'], email: new_user['email'], status: new_user['status'],user_count: response_data['user_count'],ads_count: response_data['ads_count'],is_active:response_data['is_active']==0?false:true);
          print("here");
          await SharePrefs().storeUser(user);
          print("here");
          SharePrefs().storePrefs("token",response_data['token'],"String");
          print(response_data['token']);
          SharePrefs().storePrefs("isLogin", true, "Bool");
        }
      }
      return response_data;
    } catch (e) {
      print(e);
      return {"status": false, "message": "Error sending request"};
    }
  }
}
