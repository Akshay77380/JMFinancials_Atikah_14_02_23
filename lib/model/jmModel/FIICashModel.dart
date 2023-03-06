// To parse this JSON data, do
//
//     final fiiCash = fiiCashFromJson(jsonString);

import 'dart:convert';

FiiCash fiiCashFromJson(String str) => FiiCash.fromJson(json.decode(str));

String fiiCashToJson(FiiCash data) => json.encode(data.toJson());

class FiiCash {
  FiiCash({
      this.success,
      this.data,
      this.status,
      this.message,
      this.responsecode,
  });

  bool success;
  List<Datum> data;
  String status;
  String message;
  String responsecode;

  factory FiiCash.fromJson(Map<String, dynamic> json) => FiiCash(
    success: json["success"],
    data: List<Datum>.from(json["data"].map((x) => Datum.fromJson(x))),
    status: json["status"],
    message: json["message"],
    responsecode: json["responsecode"],
  );

  Map<String, dynamic> toJson() => {
    "success": success,
    "data": List<dynamic>.from(data.map((x) => x.toJson())),
    "status": status,
    "message": message,
    "responsecode": responsecode,
  };
}

class Datum {
  Datum({
      this.category,
      this.fiiDate,
      this.buyValue,
      this.sellValue,
      this.netValue,
  });

  String category;
  DateTime fiiDate;
  double buyValue;
  double sellValue;
  double netValue;

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
    category: json["Category"],
    fiiDate: DateTime.parse(json["FIIDate"]),
    buyValue: json["BuyValue"]?.toDouble(),
    sellValue: json["SellValue"]?.toDouble(),
    netValue: json["NetValue"]?.toDouble(),
  );

  Map<String, dynamic> toJson() => {
    "Category": category,
    "FIIDate": fiiDate.toIso8601String(),
    "BuyValue": buyValue,
    "SellValue": sellValue,
    "NetValue": netValue,
  };
}
