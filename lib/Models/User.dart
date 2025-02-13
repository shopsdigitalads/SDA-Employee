import 'dart:convert';

class User {
  int user_id;
  String first_name;
  String? middle_name;
  String last_name;
  String mobile;
  String email;
  int ads_count;
  int user_count;
  String? role;
  String status;
  String? profile;
  bool is_active;

User({required this.user_id,required this.first_name,required this.middle_name,required this.last_name,required this.mobile,required this.email,this.role,required this.status,this.profile,required this.is_active,required this.ads_count, required this.user_count});

Map<String,dynamic> toJson(){
  return {
    "user_id":user_id,
    "first_name":first_name,
    "last_name":last_name,
    "middle_name":middle_name,
    "mobile":mobile,
    "email":email,
    "role":role,
    "status":status,
    "profile":profile,
    "is_partner":is_active,
    "ads_count":ads_count,
    "user_count":user_count
  };
}

String toRawJson(){
  return json.encode(toJson());
}


factory User.fromJson(Map<String,dynamic> json){
  return User(
    user_id:json['user_id'],
    first_name:json['first_name'],
    last_name: json['last_name'],
    middle_name: json['middle_name'],
    mobile:json['mobile'],
    email: json['email'],
    status:json['status'],
    profile: json['profile'],
    role:json['role'],
    is_active: json['is_partner'],
    ads_count: json['ads_count'],
    user_count: json['user_count'],
  );
}

 factory User.fromRawJson(String str){
  return User.fromJson(json.decode(str));
 }
  
}
