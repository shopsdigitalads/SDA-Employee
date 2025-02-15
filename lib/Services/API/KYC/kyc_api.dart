import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:sdaemployee/Constant/constant.dart';
import 'package:sdaemployee/Services/Storage/share_prefs.dart';

class KycApi {
  Future<Map<String, dynamic>> applyForKYC(
      Map<String, dynamic> user,
      String adhar_card_no,
      File adhar_front_img,
      File adhar_back_img,
      String pan_no,
      File pan_img,
      String bank_name,
      String bank_ifsc,
      String acc_holder_name,
      String acc_no,
      File bank_proof_img,
      String bank_branch_name) async {
    try {
      String token = await SharePrefs().getToken();

      final url = Uri.parse("$api_link/kyc");

      final request = http.MultipartRequest('POST', url);
      request.headers['Authorization'] = 'Bearer $token';
      request.headers['Content-Type'] = 'multipart/form-data';

      request.fields['adhar_no'] = adhar_card_no;
      request.fields['pan_no'] = pan_no;
      request.fields['bank_name'] = bank_name;
      request.fields['bank_ifsc'] = bank_ifsc;
      request.fields['bank_branch_name'] = bank_branch_name;
      request.fields['acc_holder_name'] = acc_holder_name;
      request.fields['acc_no'] = acc_no;
      request.fields['user_id'] = user['user_id'].toString();
      request.fields['name'] =
          "${user['first_name']}_${user['middle_name']}_${user['last_name']}";

      final adhar_f_img = await http.MultipartFile.fromPath(
        'adhar_front_img', // Field name for the interior image
        adhar_front_img.path,
        contentType: MediaType('image', 'jpeg'), // Specify the MIME type
      );
      request.files.add(adhar_f_img);

      final adhar_b_img = await http.MultipartFile.fromPath(
        'adhar_back_img', // Field name for the interior image
        adhar_back_img.path,
        contentType: MediaType('image', 'jpeg'), // Specify the MIME type
      );
      request.files.add(adhar_b_img);

      final pan_i = await http.MultipartFile.fromPath(
        'pan_img', // Field name for the interior image
        pan_img.path,
        contentType: MediaType('image', 'jpeg'), // Specify the MIME type
      );
      request.files.add(pan_i);

      final bank_p_img = await http.MultipartFile.fromPath(
        'bank_proof_img', // Field name for the interior image
        bank_proof_img.path,
        contentType: MediaType('image', 'jpeg'), // Specify the MIME type
      );
      request.files.add(bank_p_img);

      final response = await request.send();

      if (response.statusCode == 201) {
        final responseBody = await response.stream.bytesToString();
        print(responseBody);
        return {
          "status": true,
          "response": responseBody,
          "message": "KYC Details Uploaded Successfully"
        };
      } else {
        return {"status": false, "message": "Business Added Successfully"};
      }
    } catch (e) {
      return {"status": false, "Message": "Something Went Wrong"};
    }
  }

  Future<Map<String, dynamic>> updateKYC(
      Map<String, dynamic> user,
      String adhar_card_no,
      File adhar_front_img,
      File adhar_back_img,
      String pan_no,
      File pan_img,
      String bank_name,
      String bank_ifsc,
      String acc_holder_name,
      String acc_no,
      File bank_proof_img,
      String bank_branch_name) async {
    try {
      String token = await SharePrefs().getToken();

      final url = Uri.parse("$api_link/kyc");

      final request = http.MultipartRequest('PUT', url);
      request.headers['Authorization'] = 'Bearer $token';
      request.headers['Content-Type'] = 'multipart/form-data';

      List<String> update_fields = [
        "adhar_no",
        "pan_no",
        "acc_holder_name",
        "acc_no",
        "bank_ifsc",
        "bank_name",
        "bank_branch_name",
        "update_request"
      ];

      List<String> update_data = [
        adhar_card_no,
        pan_no,
        acc_holder_name,
        acc_no,
        bank_ifsc,
        bank_name,
        bank_branch_name,
        "Rejected"
      ];

      request.fields['field'] = jsonEncode(update_fields);
      request.fields['data'] = jsonEncode(update_data);
      request.fields['user_id'] = user["user_id"].toString();
      request.fields['name'] =
          "${user['first_name']}_${user['middle_name']}_${user['last_name']}";

      final adhar_f_img = await http.MultipartFile.fromPath(
        'adhar_front_img', // Field name for the interior image
        adhar_front_img.path,
        contentType: MediaType('image', 'jpeg'), // Specify the MIME type
      );
      request.files.add(adhar_f_img);

      final adhar_b_img = await http.MultipartFile.fromPath(
        'adhar_back_img', // Field name for the interior image
        adhar_back_img.path,
        contentType: MediaType('image', 'jpeg'), // Specify the MIME type
      );
      request.files.add(adhar_b_img);

      final pan_i = await http.MultipartFile.fromPath(
        'pan_img', // Field name for the interior image
        pan_img.path,
        contentType: MediaType('image', 'jpeg'), // Specify the MIME type
      );
      request.files.add(pan_i);

      final bank_p_img = await http.MultipartFile.fromPath(
        'bank_proof_img', // Field name for the interior image
        bank_proof_img.path,
        contentType: MediaType('image', 'jpeg'), // Specify the MIME type
      );
      request.files.add(bank_p_img);

      final response = await request.send();

      if (response.statusCode == 200) {
        final responseBody = await response.stream.bytesToString();
        print(responseBody);
        return {
          "status": true,
          "response": responseBody,
          "message": "KYC Details Uploaded Successfully"
        };
      } else {
        return {"status": false, "message": "Business Added Successfully"};
      }
    } catch (e) {
      print(e);
      return {"status": false, "Message": "Something Went Wrong"};
    }
  }

  Future<Map<String, dynamic>> fetchKYCOfUser(int user_id) async {
    try {
      final url = Uri.parse("$api_link/kyc/${user_id}");
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
      return {"status": false, "message": "Someting Went Wrong"};
    }
  }

  Future<Map<String, dynamic>> updateRequestKYC(
      String remark, int kyc_id) async {
    try {
      String token = await SharePrefs().getToken();

      Map<String, dynamic> body = {"remark": remark, "kyc_id": kyc_id};

      print(body);
      final uri = Uri.parse("$api_link/kyc/update_request");
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
