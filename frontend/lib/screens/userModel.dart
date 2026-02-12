import 'dart:convert';

UserModel userJsonToUser(String str) =>
  UserModel.fromJson(json.decode(str));

String userToJson(UserModel data) =>
  json.encode(data.toJson());

class UserModel {
  int id;
  String email;
  String password;

  UserModel(this.id, this.email, this.password);

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
    json['id'],
    json['email'],
    json['password'],
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'email': email,
    'password': password,
  };
  
}
