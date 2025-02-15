import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

import 'package:http_parser/http_parser.dart';
import 'package:sdaemployee/Constant/constant.dart';
import 'package:sdaemployee/Services/Storage/share_prefs.dart';

class BusinessApi {
  Future<Map<String, dynamic>> fetchBusinessTypes() async {
    try {
      final url = Uri.parse("$api_link/business/types");
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

  Future<Map<String, dynamic>> submitBusiness(
      Map<String, dynamic> user,
      String client_business_name,
      String business_type_id,
      File interiorImage,
      File exteriorImage,
      String pin,
      String area,
      String cluster,
      String district,
      String state,
      String landmark,
      String address_line) async {
    try {
      String token = await SharePrefs().getToken();

      final url = Uri.parse("$api_link/business");

      final request = http.MultipartRequest('POST', url);
      request.headers['Authorization'] = 'Bearer $token';
      request.headers['Content-Type'] = 'multipart/form-data';

      request.fields['client_business_name'] = client_business_name;
      request.fields['business_type_id'] = business_type_id.toString();
      request.fields['pin_code'] = pin;
      request.fields['area'] = area;
      request.fields['cluster'] = cluster;
      request.fields['district'] = district;
      request.fields['state'] = state;
      request.fields['landmark'] = landmark;
      request.fields['address_line'] = address_line;
      request.fields['address_type'] = "Business";
      request.fields['user_id'] = user["user_id"].toString();
      request.fields['name'] =
          "${user["first_name"]}_${user["middle_name"]}_${user["last_name"]}";

      final interiorMultipartFile = await http.MultipartFile.fromPath(
        'interior_img', // Field name for the interior image
        interiorImage.path,
        contentType: MediaType('image', 'jpeg'), // Specify the MIME type
      );
      request.files.add(interiorMultipartFile);

      // Add exterior image
      final exteriorMultipartFile = await http.MultipartFile.fromPath(
        'exterior_img', // Field name for the exterior image
        exteriorImage.path,
        contentType: MediaType('image', 'jpeg'), // Specify the MIME type
      );
      request.files.add(exteriorMultipartFile);

      final response = await request.send();

      if (response.statusCode == 201) {
        final responseBody = await response.stream.bytesToString();
        return {
          "status": true,
          "response": responseBody,
          "message": "Business Added Successfully"
        };
      } else {
        return {"status": false, "message": "Business Added Successfully"};
      }
    } catch (e) {
      return {"status": false, "message": "Something Went Wrong"};
    }
  }

  Future<Map<String, dynamic>> getBusinessOfUser(int user_id) async {
    try {
      final url = Uri.parse("$api_link/business/${user_id}");
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
      return {"status": false, "message": "Something Went Wrong"};
    }
  }

  Future<Map<String, dynamic>> updateBusiness(
      Map<String, dynamic> user,
      String client_business_name,
      String client_business_id,
      String business_type_id,
      File interior_img,
      File exterior_img) async {
    try {
      String token = await SharePrefs().getToken();

      final url = Uri.parse("$api_link/business");

      final request = http.MultipartRequest('PUT', url);
      request.headers['Authorization'] = 'Bearer $token';
      request.headers['Content-Type'] = 'multipart/form-data';

      List<String> update_fields = [
        "client_business_name",
        "business_type_id",
        "update_request"
      ];

      List<String> update_data = [
        client_business_name,
        business_type_id.toString(),
        "Rejected"
      ];

      request.fields['field'] = jsonEncode(update_fields);
      request.fields['data'] = jsonEncode(update_data);
      request.fields['client_business_id'] = client_business_id.toString();
      request.fields['user_id'] = user['user_id'].toString();
      request.fields['name'] =
          "${user['first_name']}_${user['middle_name']}_${user['last_name']}";

      final i_img = await http.MultipartFile.fromPath(
        'interior_img',
        interior_img.path,
        contentType: MediaType('image', 'jpeg'),
      );
      request.files.add(i_img);

      final e_img = await http.MultipartFile.fromPath(
        'exterior_img',
        exterior_img.path,
        contentType: MediaType('image', 'jpeg'),
      );
      request.files.add(e_img);

      final response = await request.send();

      if (response.statusCode == 200) {
        final responseBody = await response.stream.bytesToString();
        print(responseBody);
        return {
          "status": true,
          "response": responseBody,
          "message": "Business Updated Successfully"
        };
      } else {
        return {"status": false, "message": "Business Updated Successfully"};
      }
    } catch (e) {
      print(e);
      return {"status": false, "Message": "Something Went Wrong"};
    }
  }

  Future<Map<String, dynamic>> updateRequestBusiness(
      String remark, int business_id) async {
    try {
      String token = await SharePrefs().getToken();

      Map<String, dynamic> body = {
        "remark": remark,
        "client_business_id": business_id
      };

      print(body);
      final uri = Uri.parse("$api_link/business/update_request");
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
}
