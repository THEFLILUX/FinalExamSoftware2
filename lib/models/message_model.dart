import 'dart:convert';

MessageResponse messageResponseFromJson(String str) => MessageResponse.fromJson(json.decode(str));
String messageResponseToJson(MessageResponse data) => json.encode(data.toJson());

class MessageResponse {
  MessageResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  int status;
  String message;
  MessageData data;

  factory MessageResponse.fromJson(Map<String, dynamic> json) => MessageResponse(
    status: json['status'],
    message: json['message'],
    data: MessageData.fromJson(json['data']),
  );

  Map<String, dynamic> toJson() => {
    'status': status,
    'message': message,
    'data': data.toJson(),
  };
}

MessageData messageDataFromJson(String str) => MessageData.fromJson(json.decode(str));
String messageDataToJson(MessageData data) => json.encode(data.toJson());

class MessageData {
  MessageData({
    required this.data,
  });

  List<MessageModel> data;

  factory MessageData.fromJson(Map<String, dynamic> json) => MessageData(
    data: List<MessageModel>.from(json['data'].map((x) => MessageModel.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    'data': List<dynamic>.from(data.map((x) => x.toJson())),
  };
}

MessageModel messageModelFromJson(String str) => MessageModel.fromJson(json.decode(str));
String messageModelToJson(MessageModel data) => json.encode(data.toJson());

class MessageModel {
  String? id;
  String? status;
  String? text;
  String? decryptedText;
  String? type;
  String? to;
  int? createdAt;
  AuthorModel author;

  MessageModel({
    this.id,
    this.status,
    this.text,
    this.decryptedText,
    this.type,
    this.to,
    this.createdAt,
    required this.author,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) => MessageModel(
    id: json['id'],
    status: json['status'],
    text: json['text'],
    decryptedText: json['decryptedText'],
    type: json['type'],
    to: json['to'],
    createdAt: json['createdAt'],
    author: AuthorModel.fromJson(json['author']),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'status': status,
    'text': text,
    'decryptedText': decryptedText,
    'type': type,
    'to': to,
    'createdAt': createdAt,
    'author': author.toJson(),
  };
}

AuthorModel authorModelFromJson(String str) => AuthorModel.fromJson(json.decode(str));
String authorModelToJson(AuthorModel data) => json.encode(data.toJson());

class AuthorModel {
  String? id;
  String? firstName;
  String? email;

  AuthorModel({
    this.id,
    this.firstName,
    this.email,
  });

  factory AuthorModel.fromJson(Map<String, dynamic> json) => AuthorModel(
    id: json['id'],
    firstName: json['firstName'],
    email: json['email'],
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'firstName': firstName,
    'email': email,
  };
}