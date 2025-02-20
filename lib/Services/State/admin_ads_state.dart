import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:sdaemployee/Constant/constant.dart';
import 'package:sdaemployee/Models/admin_ads.dart';
import 'package:sdaemployee/Services/Storage/share_prefs.dart';
class AdProvider with ChangeNotifier {
  List<Ad> _ads = [];
  bool _isLoading = true;

  List<Ad> get ads => _ads;
  bool get isLoading => _isLoading;

  Future<void> fetchAds() async {
    final url = Uri.parse("$api_link/admin/ads");

    try {
      String token = await SharePrefs().getToken();
      final response = await http.get(
        url,
        headers: {"Authorization": "Bearer $token"},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
         List<Ad> adsList = [];

        for (var adJson in data['ads']) {
          Ad ad = Ad.fromJson(adJson);
          File file = await base64ToFile(ad.base64, ad.filename);
          adsList.add(Ad(filename: file.path, type: ad.type, base64: ""));
        }

        _ads = adsList;
      }
    } catch (e) {
      print("Error fetching ads: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<File> base64ToFile(String base64, String filename) async {
  Uint8List bytes = base64Decode(base64);
  Directory dir = await getApplicationDocumentsDirectory();
  File file = File('${dir.path}/$filename');

  await file.writeAsBytes(bytes);
  return file;
}
}
