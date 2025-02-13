import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

import 'package:sdaemployee/Constant/constant.dart';
import 'package:sdaemployee/Models/User.dart';
import 'package:sdaemployee/Services/Storage/share_prefs.dart';

class AdvertisementApi {
  Future<Map<String, dynamic>> submitCreateAd(
    Map<String,dynamic> user,
    String camp_name,
      String ad_media_type,
      String business_type_id,
      String ad_goal,
      String ad_description,
      int budget) async {
    try {

      Map<String, dynamic> body = {
        "camp_name":camp_name,
        "make_ad_type": ad_media_type,
        "make_ad_description": ad_description,
        "make_ad_goal": ad_goal,
        "business_type_id": business_type_id,
        "budget": budget,
        "user_id": user['user_id'],
      };

      final uri = Uri.parse("$api_link/ads/create");

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

  Future<Map<String, dynamic>> submitUploadAd(
        Map<String,dynamic> user,
     String camp_name,
      String ad_type,
      String ad_description,
      String ad_goal,
      String business_type_id,
      String start_date,
      String end_date,
      File ad) async {
    try {
      print(start_date);
      print(end_date);
      String token = await SharePrefs().getToken();
      User emp = await SharePrefs().getUser();
      final url = Uri.parse("$api_link/ads/upload");

      final request = http.MultipartRequest('POST', url);
      request.headers['Authorization'] = 'Bearer $token';
      request.headers['Content-Type'] = 'multipart/form-data';
      request.fields['camp_name'] = camp_name;
      request.fields['ad_type'] = ad_type;
      request.fields['business_type_id'] = business_type_id.toString();
      request.fields['ad_description'] = ad_description;
      request.fields['ad_goal'] = ad_goal;
      request.fields['start_date'] = start_date;
      request.fields['end_date'] = end_date;
      request.fields['emp_id'] = emp.user_id.toString();
      request.fields['user_id'] = user['user_id'].toString();
      request.fields['name'] =
          "${user['first_name']}_${user['middle_name']}_${user['last_name']}";

      final adFile;
      if (ad_type == "IMAGE") {
        adFile = await http.MultipartFile.fromPath(
          'ad_file', // Field name for the interior image
          ad.path,
          contentType: MediaType('image', 'jpeg'),
        ); // Specify the MIME type
      } else {
        adFile = await http.MultipartFile.fromPath(
          'ad_file', // Field name for the exterior image
          ad.path,
          contentType: MediaType('video', "mp4"), // Specify the MIME type
        );
      }

      request.files.add(adFile);

      final response = await request.send();

      if (response.statusCode == 201) {
        final responseBody = await response.stream.bytesToString();
        return {
          "status": true,
          "response": jsonDecode(responseBody),
          "message": "Business Added Successfully"
        };
      } else {
        return {"status": false, "message": "Business Added Successfully"};
      }
    } catch (e) {
      return {"status": false, "message": "Something Went Wrong"};
    }
  }

  Future<Map<String, dynamic>> submitAdvertisementLocation(
      List<dynamic> addressIds, int ad_id) async {
    try {
      User user = await SharePrefs().getUser();

      Map<String, dynamic> body = {
        "address_id": addressIds,
        "ad_id": ad_id,
        "user_id": user.user_id,
      };

      final uri = Uri.parse("$api_link/ads/location");

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

  Future<Map<String, dynamic>> fetchDisplayWithAreas(
      List<dynamic> addressIds) async {
    try {
      Map<String, dynamic> body = {
        "address_ids": addressIds,
      };

      final uri = Uri.parse("$api_link/display/ads");

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

  Future<Map<String, dynamic>> submitDisplay(
      List<dynamic> display_ids, int ad_id) async {
    try {
      Map<String, dynamic> body = {
        "displays": display_ids,
        "ad_id": ad_id,
      };

      final uri = Uri.parse("$api_link/ads/display");

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

  Future<Map<String, dynamic>> fetchAdsOfUser(Map<String,dynamic> user) async {
    try {
      final uri = Uri.parse("$api_link/ads/${user['user_id']}");

      String token = await SharePrefs().getToken();
      final response = await http.get(
        uri,
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

 Future<Map<String, dynamic>> fetchAdDetails(int ad_id) async {
    try {
      final uri = Uri.parse("$api_link/ads/details/${ad_id}");

      String token = await SharePrefs().getToken();
      final response = await http.get(
        uri,
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

  Future<Map<String, dynamic>> fetchDisplayOfAds(
      List<dynamic> addressIds,int ad_id) async {
    try {
      Map<String, dynamic> body = {
        "address_ids": addressIds,
        'ad_id':ad_id
      };

      final uri = Uri.parse("$api_link/ads/ad_display");

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


  Future<Map<String, dynamic>> updateUploadAd(
      String ad_type,
      dynamic ads,
      String add_action,
      File ad) async {
    try {
      String token = await SharePrefs().getToken();
      User user = await SharePrefs().getUser();

      final url = Uri.parse("$api_link/ads/upload");
      print("AddActin $add_action");
      final request = http.MultipartRequest('PUT', url);
      request.headers['Authorization'] = 'Bearer $token';
      request.headers['Content-Type'] = 'multipart/form-data';
       request.fields['camp_name'] = ads['ad_campaign_name'];
      request.fields['ad_type'] = ad_type;
      request.fields['business_type_id'] = ads['business_type_id'].toString();
      request.fields['ad_description'] = ads['ad_description'];
      request.fields['ad_goal'] = ads['ad_goal'];
      request.fields['start_date'] = ads['start_date'];
      request.fields['add_action'] = add_action;
      request.fields['end_date'] = ads['end_date'];
      request.fields['ad_id'] = ads['ads_id'].toString();
      request.fields['user_id'] = user.user_id.toString();
      request.fields['name'] =
          "${user.first_name}_${user.middle_name}_${user.last_name}";

      final adFile;
      if (ad_type == "IMAGE") {
        adFile = await http.MultipartFile.fromPath(
          'ad_file', // Field name for the interior image
          ad.path,
          contentType: MediaType('image', 'jpeg'),
        ); // Specify the MIME type
      } else {
        adFile = await http.MultipartFile.fromPath(
          'ad_file', // Field name for the exterior image
          ad.path,
          contentType: MediaType('video', "mp4"), // Specify the MIME type
        );
      }

      request.files.add(adFile);

      final response = await request.send();

      if (response.statusCode == 200) {
        final responseBody = await response.stream.bytesToString();
        return {
          "status": true,
          "response": jsonDecode(responseBody),
          "message": "Business Added Successfully"
        };
      } else {
        return {"status": false, "message": "Business Added Successfully"};
      }
    } catch (e) {
      print("errrrrrrrrrr $e");
      return {"status": false, "message": "Something Went Wrong"};
    }
  }

}
