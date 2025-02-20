import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

import 'package:http_parser/http_parser.dart';
import 'package:sdaemployee/Constant/constant.dart';
import 'package:sdaemployee/Services/Storage/share_prefs.dart';

class DisplayApi {
  Future<Map<String, dynamic>> fetchDisplayTypes() async {
    try {
      final url = Uri.parse("$api_link/display/types");
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
      return {"status": false};
    }
  }

  Future<Map<String, dynamic>> uploadDisplay(
    Map<String, dynamic> user,
    String clinet_business_name,
    String client_business_id,
    String display_type_id,
    String display_type,
    File display_img,
    File display_video,
  ) async {
    try {
      String token = await SharePrefs().getToken();

      final url = Uri.parse("$api_link/display");

      final request = http.MultipartRequest('POST', url);
      request.headers['Authorization'] = 'Bearer $token';
      request.headers['Content-Type'] = 'multipart/form-data';
      request.fields['client_business_id'] = client_business_id;
      request.fields['client_business_name'] = clinet_business_name;
      request.fields['display_type_id'] = display_type_id;
      request.fields['display_type'] = display_type;
      request.fields['user_id'] = user['user_id'].toString();
      request.fields['name'] =
          "${user['first_name']}_${user['middle_name']}_${user['last_name']}";
      final displayI = await http.MultipartFile.fromPath(
        'display_img', // Field name for the interior image
        display_img.path,
        contentType: MediaType('image', 'jpeg'), // Specify the MIME type
      );
      request.files.add(displayI);

      final displayV = await http.MultipartFile.fromPath(
        'display_video', // Field name for the interior image
        display_video.path,
        contentType: MediaType('image', 'jpeg'), // Specify the MIME type
      );
      request.files.add(displayV);
      final response = await request.send();

      if (response.statusCode == 201) {
        final responseBody = await response.stream.bytesToString();
        return {
          "status": true,
          "response": responseBody,
          "message": "Display Added Successfully"
        };
      } else {
        return {"status": false, "message": "Error Adding Display"};
      }
    } catch (e) {
      return {"status": false, "message": "Something Went Wrong"};
    }
  }

  Future<Map<String, dynamic>> updateDisplay(
    Map<String, dynamic> user,
    String clinet_business_name,
    String client_business_id,
    String display_id,
    String display_type_id,
    String display_type,
    File display_img,
    File display_video,
  ) async {
    try {
      String token = await SharePrefs().getToken();

      final url = Uri.parse("$api_link/display");

      final request = http.MultipartRequest('PUT', url);
      request.headers['Authorization'] = 'Bearer $token';
      request.headers['Content-Type'] = 'multipart/form-data';

         List<String> update_fields = ["display_type_id", "client_business_id","update_request"];

      List<String> update_data = [display_type_id,client_business_id,"Rejected"];

      request.fields['field'] = jsonEncode(update_fields);
      request.fields['client_business_name'] = clinet_business_name;
      request.fields['client_business_id'] = client_business_id.toString();
      request.fields["display_id"] = display_id;
      request.fields["display_type"] = display_type;
      request.fields['data'] = jsonEncode(update_data);
      request.fields['user_id'] = user['user_id'].toString();
      request.fields['name'] =
          "${user['first_name']}_${user['middle_name']}_${user['last_name']}";

      final d_img = await http.MultipartFile.fromPath(
        'display_img', // Field name for the interior image
        display_img.path,
        contentType: MediaType('image', 'jpeg'), // Specify the MIME type
      );
      request.files.add(d_img);

      final d_vid = await http.MultipartFile.fromPath(
        'display_video', // Field name for the interior image
        display_video.path,
        contentType: MediaType('video', 'jpeg'), // Specify the MIME type
      );
      request.files.add(d_vid);

      final response = await request.send();

      if (response.statusCode == 200) {
        final responseBody = await response.stream.bytesToString();
        print(responseBody);
        return {
          "status": true,
          "response": responseBody,
          "message": "DisplayUploaded Successfully"
        };
      } else {
        return {"status": false, "message": "Business Added Successfully"};
      }
    } catch (e) {
      print(e);
      return {"status": false, "Message": "Something Went Wrong"};
    }
  }

  Future<Map<String, dynamic>> fetchDisplayHistory(
      int display_id, String date) async {
    try {
      String token = await SharePrefs().getToken();
      final url = Uri.parse("$api_link/display/history/$display_id/$date");
      final response = await http.get(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token"
        },
      );

      final responseBody = jsonDecode(response.body);
      return responseBody;
    } catch (e) {
      return {"status": true, "message": "Good"};
    }
  }


  Future<Map<String, dynamic>> updateRequestDisplay(String remark,int display_id
     ) async {
    try {
      String token = await SharePrefs().getToken();
    
      Map<String,dynamic> body={
        "remark":remark,
        "display_id":display_id
      };

      print(body);
      final uri = Uri.parse("$api_link/display/update_request");
      final response = await http.put(uri,
          headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer $token"
          },
          body: jsonEncode(body));

      final responseData = jsonDecode(response.body);
      return responseData;
    } catch (e) {
      print(e);
      return {"status": false, "Message": "Something Went Wrong"};
    }
  }

   Future<Map<String,dynamic>> fetchDisplayUpdateRequest(int user_id)async{
    try {
     
       String token = await SharePrefs().getToken();
        final url = Uri.parse("$api_link/display/update_request/${user_id}");
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
        "status":false,
        "message":"Error Sending Request"
      };
    }
  }
}
