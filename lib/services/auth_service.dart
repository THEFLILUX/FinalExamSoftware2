import 'dart:convert';

import 'package:frontend/shared_preferences/preferences.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import 'package:frontend/models/models.dart';

class AuthService extends ChangeNotifier {
  // URL Backend
  final String _baseUrl = '10.0.2.2:8081';

  // Uses AES encryption for Android and Windows
  // Uses WebCrypto for Web
  final storage = const FlutterSecureStorage();

  Future<String?> getCredentialsLogin(UserModel userModel) async {
    final url = Uri.http(_baseUrl, '/getCredentialsLogin');
    final response = await http.post(url, body: userModelToJson(userModel));
    final Map<String, dynamic>? decodedData = json.decode(response.body);

    if (decodedData == null) return 'Error de conexión con el servidor';

    if (decodedData['status'] == 200) {
      // Guardar datos del usuario en las preferencias
      Preferences.userId = decodedData['data']['id'];
      Preferences.userName = decodedData['data']['name'];
      Preferences.userEmail = decodedData['data']['email'];
      Preferences.userPublicKey = decodedData['data']['publicKey'];
      Preferences.userPrivateKey = decodedData['data']['privateKey'];
      // Guardar llave privada en el cliente
      await storage.write(
          key: 'privateKey', value: decodedData['data']['privateKey']);
      return null;
    } else {
      return decodedData['message'];
    }
  }

  Future<String?> saveCredentialsRegister(UserModel userModel) async {
    final url = Uri.http(_baseUrl, '/saveCredentialsRegister');
    final response = await http.post(url, body: userModelToJson(userModel));
    final Map<String, dynamic>? decodedData = json.decode(response.body);

    if (decodedData == null) return 'Error de conexión con el servidor';

    if (decodedData['status'] == 201) {
      // Guardar datos del usuario en las preferencias
      Preferences.userId = decodedData['data']['InsertedID'];
      Preferences.userName = userModel.name!;
      Preferences.userEmail = userModel.email!;
      Preferences.userPublicKey = userModel.publicKey!;
      Preferences.userPrivateKey = userModel.privateKey!;
      // Guardar llave privada en el cliente
      await storage.write(key: 'privateKey', value: userModel.privateKey);
      return null;
    } else {
      return decodedData['message'];
    }
  }

  Future<String> readPrivateKey() async {
    return await storage.read(key: 'privateKey') ?? '';
  }

  Future logout() async {
    Preferences.userId = '';
    Preferences.userName = '';
    Preferences.userEmail = '';
    Preferences.userPublicKey = '';
    Preferences.userPrivateKey = '';
    await storage.delete(key: 'privateKey');
    return;
  }
}
