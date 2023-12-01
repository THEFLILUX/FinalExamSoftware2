// ignore_for_file: depend_on_referenced_packages

import 'package:frontend/providers/providers.dart';
import 'package:frontend/shared_preferences/preferences.dart';
import 'package:frontend/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'package:frontend/models/models.dart';
import 'package:frontend/services/services.dart';
import 'package:rsa_encrypt/rsa_encrypt.dart';
import 'package:uuid/uuid.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  List<types.TextMessage> _messages = [];
  final types.User _user = types.User(
    id: Preferences.userId,
    firstName: Preferences.userName,
  );
  bool isDecrypted = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () async {
      _loadMessages(context);
    });
  }

  void _loadMessages(BuildContext context) async {
    final chatsService = Provider.of<ChatsService>(context, listen: false);
    final response = await chatsService.loadMessages();

    //Reemplazar mensajes propios con texto descifrado
    for (var i = 0; i < response.data.data.length; i++) {
      if (response.data.data[i].decryptedText != '') {
        response.data.data[i].text = response.data.data[i].decryptedText;
      }
    }

    final List<types.TextMessage> messages = [];
    for (var i = 0; i < response.data.data.length; i++) {
      var currentMessage = response.data.data[i];
      types.TextMessage textMessage = types.TextMessage(
        id: currentMessage.id!,
        author: types.User(
          id: currentMessage.author.id!,
          firstName: currentMessage.author.firstName,
        ),
        createdAt: currentMessage.createdAt,
        text: currentMessage.text!,
      );
      messages.insert(0, textMessage);
    }

    setState(() {
      _messages = messages;
    });
  }

  void _addMessage(types.TextMessage message) {
    setState(() {
      _messages.insert(0, message);
    });
  }

  Future<void> _handleSendPressed(types.PartialText message) async {
    final textMessage = types.TextMessage(
      id: const Uuid().v4(),
      author: _user,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      text: message.text,
    );

    _addMessage(textMessage);

    final chatsService = Provider.of<ChatsService>(context, listen: false);
    RsaKeyHelper rsaKeyHelper = RsaKeyHelper();
    String cyperText = encrypt(
      message.text,
      rsaKeyHelper.parsePublicKeyFromPem(chatsService.selectedChat.publicKey),
    );

    // Crear modelo de mensaje
    MessageModel messageModel = MessageModel(
      author: AuthorModel(
        id: Preferences.userId,
        firstName: Preferences.userName,
        email: Preferences.userEmail,
      ),
      createdAt: DateTime.now().millisecondsSinceEpoch,
      status: 'seen',
      text: cyperText,
      decryptedText: message.text,
      type: 'text',
      to: chatsService.selectedChat.email,
    );

    // Enviar POST a backend
    await chatsService.createMessage(messageModel);
  }

  @override
  Widget build(BuildContext context) {
    final chatsService = Provider.of<ChatsService>(context, listen: true);
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);

    if (chatsService.isLoadingMessages) {
      return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          backgroundColor: AppTheme.primaryColor,
          title: Text(
            chatsService.selectedChat.name!,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
          ),
          elevation: 0,
        ),
        body: const Center(
          child: CircularProgressIndicator(color: AppTheme.primaryColor),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: AppTheme.primaryColor,
        title: Text(
          chatsService.selectedChat.name!,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
        ),
        elevation: 0,
        actions: [
          (!isDecrypted)
              ? IconButton(
                  icon: const Icon(Icons.lock_open_outlined),
                  onPressed: () {
                    RsaKeyHelper rsaKeyHelper = RsaKeyHelper();
                    List<types.TextMessage> decryptedMessages = [];

                    for (var i = _messages.length - 1; i >= 0; i--) {
                      if (_messages[i].author.id != _user.id) {
                        types.TextMessage decryptedMessage = types.TextMessage(
                          author: _messages[i].author,
                          createdAt: _messages[i].createdAt,
                          id: _messages[i].id,
                          text: decrypt(
                            _messages[i].text,
                            rsaKeyHelper.parsePrivateKeyFromPem(
                                Preferences.userPrivateKey),
                          ),
                        );
                        decryptedMessages.insert(0, decryptedMessage);
                      } else {
                        decryptedMessages.insert(0, _messages[i]);
                      }
                    }

                    setState(() {
                      isDecrypted = true;
                      _messages = decryptedMessages;
                    });
                  },
                )
              : Container(),
          IconButton(
            icon: const Icon(Icons.update),
            onPressed: () {
              isDecrypted = false;
              Future.delayed(Duration.zero, () async {
                _loadMessages(context);
              });
            },
          ),
        ],
      ),
      body: Chat(
        messages: _messages,
        user: _user,
        onSendPressed: _handleSendPressed,
        scrollPhysics: const BouncingScrollPhysics(),
        dateFormat: DateFormat.yMMMMd('es-ES'),
        theme: DefaultChatTheme(
          backgroundColor: themeProvider.currentThemeName == 'light'
              ? Colors.white
              : const Color.fromRGBO(48, 48, 48, 1),
          primaryColor: AppTheme.primaryColor,
          secondaryColor: themeProvider.currentThemeName == 'light'
              ? Colors.grey.shade300
              : const Color.fromRGBO(26, 26, 26, 1),
          receivedMessageBodyTextStyle: TextStyle(
            color: themeProvider.currentThemeName == 'light'
                ? Colors.black
                : Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
          sentMessageBodyTextStyle: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
          inputBackgroundColor: themeProvider.currentThemeName == 'light'
              ? Colors.grey.shade300
              : const Color.fromRGBO(26, 26, 26, 1),
          inputTextColor: themeProvider.currentThemeName == 'light'
              ? Colors.black
              : Colors.white,
          inputMargin: const EdgeInsets.all(20),
          inputBorderRadius: BorderRadius.circular(20),
          inputTextCursorColor: AppTheme.primaryColor,
        ),
      ),
    );
  }
}
