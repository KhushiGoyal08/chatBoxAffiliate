class PartnerModel {
  String message;
  List<Allpartner> allpartners;

  PartnerModel({
    required this.message,
    required this.allpartners,
  });

  factory PartnerModel.fromJson(Map<String, dynamic> json) => PartnerModel(
        message: json["message"],
        allpartners: List<Allpartner>.from(
            json["allpartners"].map((x) => Allpartner.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "message": message,
        "allpartners": List<dynamic>.from(allpartners.map((x) => x.toJson())),
      };
}

class Allpartner {
  String id;
  String logo;
  String description;
  String link;
  DateTime createdAt;
  DateTime updatedAt;
  int v;

  Allpartner({
    required this.id,
    required this.logo,
    required this.description,
    required this.link,
    required this.createdAt,
    required this.updatedAt,
    required this.v,
  });

  factory Allpartner.fromJson(Map<String, dynamic> json) => Allpartner(
        id: json["_id"],
        logo: json["logo"],
        description: json["description"],
        link: json["link"],
        createdAt: DateTime.parse(json["createdAt"]),
        updatedAt: DateTime.parse(json["updatedAt"]),
        v: json["__v"],
      );

  Map<String, dynamic> toJson() => {
        "_id": id,
        "logo": logo,
        "description": description,
        "link": link,
        "createdAt": createdAt.toIso8601String(),
        "updatedAt": updatedAt.toIso8601String(),
        "__v": v,
      };
}
