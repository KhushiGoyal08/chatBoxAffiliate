// To parse this JSON data, do
//
//     final userData = userDataFromJson(jsonString);

import 'dart:convert';

UserData userDataFromJson(String str) => UserData.fromJson(json.decode(str));

String userDataToJson(UserData data) => json.encode(data.toJson());

class UserData {
  String message;
  User user;

  UserData({
    required this.message,
    required this.user,
  });

  factory UserData.fromJson(Map<String, dynamic> json) => UserData(
    message: json["message"],
    user: User.fromJson(json["user"]),
  );

  Map<String, dynamic> toJson() => {
    "message": message,
    "user": user.toJson(),
  };
}

class User {
  String id;
  String mobileNumber;
  bool status;
  bool iscontactverified;
  bool isverified;
  int v;

  User({
    required this.id,
    required this.mobileNumber,
    required this.status,
    required this.iscontactverified,
    required this.isverified,
    required this.v,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
    id: json["_id"],
    mobileNumber: json["mobileNumber"],
    status: json["status"],
    iscontactverified: json["iscontactverified"],
    isverified: json["isverified"],
    v: json["__v"],
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "mobileNumber": mobileNumber,
    "status": status,
    "iscontactverified": iscontactverified,
    "isverified": isverified,
    "__v": v,
  };
}
