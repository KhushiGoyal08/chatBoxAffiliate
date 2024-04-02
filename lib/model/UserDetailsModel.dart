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
  String? jwttoken;
  String? sessionExpiration;
  String? token;
  bool isSuspended;
  bool isEmailVerified;

  User(
      {required this.id,
      required this.mobileNumber,
      required this.status,
      required this.iscontactverified,
      required this.isverified,
      required this.v,
      required this.isSuspended,
      required this.isEmailVerified});

  factory User.fromJson(Map<String, dynamic> json) => User(
      id: json["_id"],
      mobileNumber: json["mobileNumber"],
      status: json["status"],
      iscontactverified: json["iscontactverified"],
      isverified: json["isverified"],
      v: json["__v"],
      isSuspended: json["isSuspended"] ?? false,
      isEmailVerified: json['isEmailVerified'] ?? false);

  Map<String, dynamic> toJson() => {
        "_id": id,
        "mobileNumber": mobileNumber,
        "status": status,
        "iscontactverified": iscontactverified,
        "isverified": isverified,
        "__v": v,
        "isSuspended": isSuspended,
        "isEmailVerified": isEmailVerified
      };
}
