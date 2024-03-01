import 'dart:convert';

ReportModel reportModelFromJson(String str) => ReportModel.fromJson(json.decode(str));

String reportModelToJson(ReportModel data) => json.encode(data.toJson());

class ReportModel {
  String reportedId;
  String reporterId;
  String reason;

  ReportModel({
    required this.reportedId,
    required this.reporterId,
    required this.reason,
  });

  factory ReportModel.fromJson(Map<String, dynamic> json) => ReportModel(
    reportedId: json["reportedId"],
    reporterId: json["reporterId"],
    reason: json["reason"],
  );

  Map<String, dynamic> toJson() => {
    "reportedId": reportedId,
    "reporterId": reporterId,
    "reason": reason,
  };
}