import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:frontend/models/models.dart';
import 'package:frontend/shared_preferences/preferences.dart';

class ChatsService extends ChangeNotifier {
  // URL Backend
  final String _baseUrl = '10.0.2.2:8082';
  final String _authUrl = '10.0.2.2:8081';
  List<UserModel> chats = [];
  late UserModel selectedChat;

  bool isLoadingChats = false;
  bool isLoadingMessages = false;

  ChatsService() {
    loadChats();
  }

  Future<List<UserModel>> loadChats() async {
    isLoadingChats = true;
    notifyListeners();

    final url =
        Uri.http(_authUrl, '/getAllChats', {'email': Preferences.userEmail});
    final response = await http.get(url);
    final Map<String, dynamic>? decodedData = json.decode(response.body);

    if (decodedData == null) {
      isLoadingChats = false;
      notifyListeners();
      return [];
    }

    if (decodedData['data']['data'] == null) {
      isLoadingChats = false;
      notifyListeners();
      return [];
    }

    UserResponse userResponse = userResponseFromJson(response.body);
    chats = userResponse.data.data;

    isLoadingChats = false;
    notifyListeners();

    return chats;
  }

  Future<MessageResponse> loadMessages() async {
    isLoadingMessages = true;
    notifyListeners();

    final url = Uri.http(_baseUrl, '/getMessages',
        {'userFrom': Preferences.userEmail, 'userTo': selectedChat.email});
    final response = await http.get(url);
    final Map<String, dynamic>? decodedData = json.decode(response.body);

    MessageResponse emptyMessages = MessageResponse(
      status: 200,
      message: 'Sin mensajes',
      data: MessageData(
        data: [],
      ),
    );

    if (decodedData == null) {
      isLoadingMessages = false;
      notifyListeners();

      return emptyMessages;
    }

    if (decodedData['data']['data'] == null) {
      isLoadingMessages = false;
      notifyListeners();

      return emptyMessages;
    }

    MessageResponse messageResponse = messageResponseFromJson(response.body);

    isLoadingMessages = false;
    notifyListeners();

    return messageResponse;
  }

  Future<String?> createMessage(MessageModel messageModel) async {
    final url = Uri.http(_baseUrl, '/newMessage');
    final response =
        await http.post(url, body: messageModelToJson(messageModel));
    final Map<String, dynamic>? decodedData = json.decode(response.body);

    if (decodedData == null) return 'Error en la conexión con el servidor';

    if (decodedData['status'] == 201) {
      return null;
    } else {
      return decodedData['message'];
    }
  }
}
