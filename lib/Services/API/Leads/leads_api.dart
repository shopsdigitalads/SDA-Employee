import 'dart:convert';
import 'dart:core';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:http_parser/http_parser.dart';

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
    String remark,
    File? visiting_card) async {
  try {
    User user = await SharePrefs().getUser();
    String token = await SharePrefs().getToken();
    final url = Uri.parse("$api_link/leads");
    final request = http.MultipartRequest('POST', url);

    request.headers['Authorization'] = 'Bearer $token';
    request.headers['Content-Type'] = 'multipart/form-data';
    request.fields['name'] = name;
    request.fields['org_name'] = orgnization_name;
    request.fields['email'] = email;
    request.fields['mobile'] = mobile;
    request.fields['contact_date'] = contact_date;
    request.fields['follow_up_date'] = follow_up_date;
    request.fields['lead_type'] = lead_type;
    request.fields['remark'] = remark;
    request.fields['user_id'] = user.user_id.toString();

    // Add visiting_card file only if it's not null
    if (visiting_card != null) {
      final v_card = await http.MultipartFile.fromPath(
        'visiting_card',
        visiting_card.path,
        contentType: MediaType('image', 'jpeg'),
      );
      request.files.add(v_card);
    }

    final response = await request.send();

    if (response.statusCode == 201) {
      final responseBody = await response.stream.bytesToString();
      return {
        "status": true,
        "response": jsonDecode(responseBody),
        "message": "Business Added Successfully"
      };
    } else {
      return {"status": false, "message": "Business Addition Failed"};
    }
  } catch (e) {
    debugPrint(e.toString());
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
      return {"status": false, "message": "Something Went Wrong"};
    }
  }
}
