import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:firebase_ui_oauth_google/firebase_ui_oauth_google.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';

import 'package:frontend/pages/pages.dart';
import 'package:frontend/services/services.dart';
import 'package:frontend/providers/providers.dart';
import 'package:frontend/shared_preferences/preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  FirebaseUIAuth.configureProviders(
    [
      GoogleProvider(
        clientId:
            '479934895747-jv95fudltfecpfsi0pgj9fjlaon54t5p.apps.googleusercontent.com',
        redirectUri: 'https://chat-app-492b0.firebaseapp.com/__/auth/handler',
      ),
    ],
  );

  await Preferences.init();

  initializeDateFormatting('es-ES', null);

  runApp(const AppState());
}

class AppState extends StatelessWidget {
  const AppState({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
            create: (_) => ThemeProvider(isDarkMode: Preferences.isDarkMode)),
        ChangeNotifierProvider(create: (_) => AuthService()),
        ChangeNotifierProvider(create: (_) => ChatsService()),
      ],
      child: const MyApp(),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'EIM',
      initialRoute: '/check_auth',
      routes: {
        '/check_auth': (_) => const CheckAuthPage(),
        '/login': (_) => const LoginPage(),
        '/home': (_) => const HomePage(),
        '/chat': (_) => const ChatPage(),
      },
      theme: Provider.of<ThemeProvider>(context).currentTheme,
    );
  }
}
