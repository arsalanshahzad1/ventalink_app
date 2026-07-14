// To parse this JSON data, do
//
//     final userModel = userModelFromJson(jsonString);

import 'dart:convert';

UserModel userModelFromJson(String str) => UserModel.fromJson(json.decode(str));

String userModelToJson(UserModel data) => json.encode(data.toJson());

class UserModel {
  String? accessToken;
  User? user;

  UserModel({this.accessToken, this.user});

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
    accessToken: json["accessToken"],
    user: json["user"] == null ? null : User.fromJson(json["user"]),
  );

  Map<String, dynamic> toJson() => {
    "accessToken": accessToken,
    "user": user?.toJson(),
  };
}

class User {
  String? id;
  String? fullName;
  String? email;
  String? phone;
  String? role;
  DateTime? createdAt;

  User({this.id, this.fullName, this.email, this.phone, this.role, this.createdAt});

  factory User.fromJson(Map<String, dynamic> json) => User(
    id: json["id"],
    fullName: json["fullName"],
    email: json["email"],
    phone: json["phone"],
    role: json["role"],
    createdAt: json["createdAt"] == null ? null : DateTime.parse(json["createdAt"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "fullName": fullName,
    "email": email,
    "phone": phone,
    "role": role,
    "createdAt": createdAt?.toIso8601String(),
  };
}
