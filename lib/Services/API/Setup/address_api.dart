import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sdaemployee/Constant/constant.dart';
import 'package:sdaemployee/Services/Storage/share_prefs.dart';

class AddressApi {
  String? pin_code;
  String? area;
  String? cluster;
  String? district;
  String? state;
  String? client_business_id;
  String? address_type;
  String? user_id;

  AddressApi(
      {
      this.user_id,  
      this.pin_code,
      this.area,
      this.cluster,
      this.district,
      this.state,
      this.client_business_id,
      this.address_type});

  // Function to fetch data from API based on the entered PIN code
  Future<Map<String, dynamic>> getDataFromPinCode(String pinCode) async {
    final url = "http://www.postalpincode.in/api/pincode/$pinCode";
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        if (jsonResponse['Status'] == 'Success') {
          return {"status": true, "locations": jsonResponse['PostOffice']};
        } else {
          return {"status": false};
        }
      } else {
        return {"status": false};
      }
    } catch (e) {
      return {"status": false};
    }
  }

  Future<Map<String, dynamic>> submitAddress() async {
    try {
      Map<String, dynamic> body = {
        "pin_code": pin_code,
        "area": area,
        "cluster": cluster,
        "district": district,
        "state": state,
        "address_type": address_type,
        "user_id": user_id,
        "client_business_id": client_business_id
      };

      final uri = Uri.parse("$api_link/address");

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

  Future<Map<String, dynamic>> fetchBusinessAddress(
      int business_type_id) async {
    try {
      final url = Uri.parse("$api_link/address/ads/$business_type_id");
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

  Future<Map<String, dynamic>> fetchAddressOfUser(String user_id) async {
    try {
      final url = Uri.parse("$api_link/address/${user_id}");
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

  Future<Map<String, dynamic>> updateAdderss(int address_id
     ) async {
    try {
      String token = await SharePrefs().getToken();

      List<String> update_fields = [
        'pin_code',
        'area',
        'cluster',
        'district',
        'state',
      ];

      List<String?> update_data = [
        pin_code,
        area,
        cluster,
        district,
        state,
        address_id.toString(),
      ];
    
      Map<String,dynamic> body={
        "field":jsonEncode(update_fields),
        "data":jsonEncode(update_data)
      };
      final uri = Uri.parse("$api_link/address");
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

  Future<Map<String, dynamic>> updateRequestAddress(String remark,int address_id
     ) async {
    try {
      String token = await SharePrefs().getToken();
    
      Map<String,dynamic> body={
        "remark":remark,
        "address_id":address_id
      };

      print(body);
      final uri = Uri.parse("$api_link/address/update_request");
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
