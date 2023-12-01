// ignore_for_file: use_build_context_synchronously

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import 'package:frontend/providers/providers.dart';
import 'package:frontend/theme/app_theme.dart';
import 'package:frontend/widgets/widgets.dart';
import 'package:frontend/services/services.dart';
import 'package:frontend/shared_preferences/preferences.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      Provider.of<ChatsService>(context, listen: false).loadChats();
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final chatsService = Provider.of<ChatsService>(context);

    if (chatsService.isLoadingChats) {
      return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          backgroundColor: AppTheme.primaryColor,
          title: Text(
            'Chats',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
          ),
          elevation: 0,
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () async {
                _showErrorDialog(context, '¿Seguro que quieres cerrar sesión?');
              },
            ),
          ],
        ),
        drawer: ChatsDrawer(
          name: Preferences.userName,
          email: Preferences.userEmail,
          profilePicture: FirebaseAuth.instance.currentUser!.photoURL!,
          publicKey: Preferences.userPublicKey,
          privateKey: Preferences.userPrivateKey,
        ),
        body: const Center(
          child: CircularProgressIndicator(color: AppTheme.primaryColor),
        ),
      );
    }

    if (chatsService.chats.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          backgroundColor: AppTheme.primaryColor,
          title: Text(
            'Chats',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
          ),
          elevation: 0,
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () async {
                _showErrorDialog(context, '¿Seguro que quieres cerrar sesión?');
              },
            ),
          ],
        ),
        drawer: ChatsDrawer(
          name: Preferences.userName,
          email: Preferences.userEmail,
          profilePicture: FirebaseAuth.instance.currentUser!.photoURL!,
          publicKey: Preferences.userPublicKey,
          privateKey: Preferences.userPrivateKey,
        ),
        body: const Center(
          child: Center(
            child: Text(
              'Aún no hay más usuarios',
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: AppTheme.primaryColor,
        title: Text(
          'Chats',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
        ),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              _showErrorDialog(context, '¿Seguro que quieres cerrar sesión?');
            },
          ),
        ],
      ),
      drawer: ChatsDrawer(
        name: Preferences.userName,
        email: Preferences.userEmail,
        profilePicture: FirebaseAuth.instance.currentUser!.photoURL!,
        publicKey: Preferences.userPublicKey,
        privateKey: Preferences.userPrivateKey,
      ),
      body: ListView.builder(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(20),
        itemCount: chatsService.chats.length,
        itemBuilder: (BuildContext context, int index) => GestureDetector(
          onTap: () {
            chatsService.selectedChat = chatsService.chats[index].copy();
            Navigator.pushNamed(context, '/chat');
          },
          child: Column(
            children: [
              _ChatCardTile(
                themeProvider: themeProvider,
                name: chatsService.chats[index].name!,
                email: chatsService.chats[index].email!,
              ),
              (index < chatsService.chats.length - 1)
                  ? const SizedBox(height: 20)
                  : Container(),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showErrorDialog(BuildContext context, String errorText) async {
    final authService = Provider.of<AuthService>(context, listen: false);

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
          title: const Center(
            child: Text('Cerrar sesión'),
          ),
          content: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(errorText),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () async {
                await authService.logout();
                await FirebaseAuth.instance.signOut();
                Navigator.of(context).pop();
                Navigator.of(context).pushReplacementNamed('/login');
              },
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(
                  AppTheme.primaryColor,
                ),
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              child: Text(
                'Si',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(
                  AppTheme.primaryColor,
                ),
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              child: Text(
                'No',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
          ],
          actionsAlignment: MainAxisAlignment.center,
        );
      },
    );
  }
}

class _ChatCardTile extends StatelessWidget {
  const _ChatCardTile({
    required this.themeProvider,
    required this.name,
    required this.email,
  });

  final ThemeProvider themeProvider;
  final String name;
  final String email;

  @override
  Widget build(BuildContext context) {
    return ChatCard(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SvgPicture.asset(
            'assets/user_icon.svg',
            height: 50,
            colorFilter: ColorFilter.mode(
                themeProvider.currentThemeName == 'light'
                    ? Colors.black
                    : Colors.white,
                BlendMode.srcIn),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 17,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  email,
                  style: const TextStyle(
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          const Icon(Icons.arrow_forward_ios, size: 30),
        ],
      ),
    );
  }
}
