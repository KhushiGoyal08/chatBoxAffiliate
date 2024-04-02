class MemberDirectoryModel {
  String message;
  int length;
  List<Alluser> allusers;

  MemberDirectoryModel({
    required this.message,
    required this.length,
    required this.allusers,
  });

  factory MemberDirectoryModel.fromJson(Map<String, dynamic> json) =>
      MemberDirectoryModel(
        message: json["message"],
        length: json["length"],
        allusers: List<Alluser>.from(
            json["allusers"].map((x) => Alluser.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "message": message,
        "length": length,
        "allusers": List<dynamic>.from(allusers.map((x) => x.toJson())),
      };
}

class Alluser {
  String id;
  String mobileNumber;
  bool status;
  bool iscontactverified;
  bool isverified;
  int v;
  String jwttoken;
  String sessionExpiration;
  String token;
  String aboutMe;
  String company;
  String designation;
  String facebook;
  String instagram;
  String linkedIn;
  String skype;
  String telegram;
  String email;
  String firstName;
  String flag;
  String lastName;
  String? awsbucketObjectkey;
  String? profileImageUrl;
  bool isSuspended;
  bool? isEmailVerified;

  Alluser({
    required this.id,
    required this.mobileNumber,
    required this.status,
    required this.iscontactverified,
    required this.isverified,
    required this.v,
    required this.jwttoken,
    required this.sessionExpiration,
    required this.token,
    required this.aboutMe,
    required this.company,
    required this.designation,
    required this.facebook,
    required this.instagram,
    required this.linkedIn,
    required this.skype,
    required this.telegram,
    required this.email,
    required this.firstName,
    required this.flag,
    required this.lastName,
    this.awsbucketObjectkey,
    this.profileImageUrl,
    required this.isSuspended,
    this.isEmailVerified,
  });

  factory Alluser.fromJson(Map<String, dynamic> json) => Alluser(
        id: json["_id"],
        mobileNumber: json["mobileNumber"],
        status: json["status"],
        iscontactverified: json["iscontactverified"],
        isverified: json["isverified"],
        v: json["__v"],
        jwttoken: json["jwttoken"],
        sessionExpiration: json["sessionExpiration"],
        token: json["token"],
        aboutMe: json["AboutMe"],
        company: json["Company"],
        designation: json["Designation"],
        facebook: json["Facebook"],
        instagram: json["Instagram"],
        linkedIn: json["LinkedIn"],
        skype: json["Skype"],
        telegram: json["Telegram"],
        email: json["email"],
        firstName: json["firstName"],
        flag: json["flag"],
        lastName: json["lastName"],
        awsbucketObjectkey: json["awsbucketObjectkey"],
        profileImageUrl: json["profileImageUrl"],
        isSuspended: json["isSuspended"],
        isEmailVerified: json["isEmailVerified"],
      );

  Map<String, dynamic> toJson() => {
        "_id": id,
        "mobileNumber": mobileNumber,
        "status": status,
        "iscontactverified": iscontactverified,
        "isverified": isverified,
        "__v": v,
        "jwttoken": jwttoken,
        "sessionExpiration": sessionExpiration,
        "token": token,
        "AboutMe": aboutMe,
        "Company": company,
        "Designation": designation,
        "Facebook": facebook,
        "Instagram": instagram,
        "LinkedIn": linkedIn,
        "Skype": skype,
        "Telegram": telegram,
        "email": email,
        "firstName": firstName,
        "flag": flag,
        "lastName": lastName,
        "awsbucketObjectkey": awsbucketObjectkey,
        "profileImageUrl": profileImageUrl,
        "isSuspended": isSuspended,
        "isEmailVerified": isEmailVerified,
      };
}
