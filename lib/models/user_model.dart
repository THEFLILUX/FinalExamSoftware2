import 'dart:convert';

UserResponse userResponseFromJson(String str) => UserResponse.fromJson(json.decode(str));
String userResponseToJson(UserResponse data) => json.encode(data.toJson());

class UserResponse {
  int status;
  String message;
  UserData data;

  UserResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory UserResponse.fromJson(Map<String, dynamic> json) => UserResponse(
    status: json['status'],
    message: json['message'],
    data: UserData.fromJson(json['data']),
  );

  Map<String, dynamic> toJson() => {
    'status': status,
    'message': message,
    'data': data.toJson(),
  };
}

UserData userDataFromJson(String str) => UserData.fromJson(json.decode(str));
String userDataToJson(UserData data) => json.encode(data.toJson());

class UserData {
  List<UserModel> data;

  UserData({
    required this.data,
  });

  factory UserData.fromJson(Map<String, dynamic> json) => UserData(
    data: List<UserModel>.from(json['data'].map((x) => UserModel.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    'data': List<dynamic>.from(data.map((x) => x.toJson())),
  };
}

UserModel userModelFromJson(String str) => UserModel.fromJson(json.decode(str));
String userModelToJson(UserModel data) => json.encode(data.toJson());

class UserModel {
  String? id;
  String? name;
  String? email;
  String? password;
  String? publicKey;
  String? privateKey;

  UserModel({
    this.id,
    this.name,
    this.email,
    this.password,
    this.publicKey,
    this.privateKey,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
    id: json['id'],
    name: json['name'],
    email: json['email'],
    password: json['password'],
    publicKey: json['publicKey'],
    privateKey: json['privateKey'],
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'email': email,
    'password': password,
    'publicKey': publicKey,
    'privateKey': privateKey,
  };

  UserModel copy() => UserModel(
    id: id,
    name: name,
    email: email,
    password: password,
    publicKey: publicKey,
    privateKey: privateKey,
  );
}