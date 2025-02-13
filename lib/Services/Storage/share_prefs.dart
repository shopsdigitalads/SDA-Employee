import 'package:sdaemployee/Models/User.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharePrefs {
    SharedPreferencesAsync prefs = SharedPreferencesAsync();

    storePrefs(String key,dynamic value,String data_type)async{
        if((data_type == "String")){
           await prefs.setString(key, value);
        }else if(data_type == "Int"){
            await prefs.setInt(key, value);
        }else if(data_type == "Bool"){
            await prefs.setBool(key, value);
        }
    }

    Future<dynamic> getPrefs(String key,String data_type)async{
        dynamic value;
        if((data_type == "String")){
           value =  prefs.getString(key);
        }else if(data_type == "Int"){
            value =  prefs.getInt(key);
        }else if(data_type == "Bool"){
           value =  await prefs.getBool(key);
        }

        return value;
    }

    Future<String> getToken()async{
      String? token =await prefs.getString("token");
      print(token);
      if(token == null){
        return "Token Absent";
      }else{
        return token;
      }
    }

    Future<bool> storeUser(User user) async{
      String str_user = user.toRawJson();
      await prefs.setString("user",str_user);
      return true;
    }

    Future<User> getUser() async{
      String? str_user = await prefs.getString("user");
      User user = User.fromRawJson(str_user!);
      return user;
    }

    Future<bool> logout()async{
      try {
        await prefs.clear();
        return true;
      } catch (e) {
        return false;
      }
    }
}