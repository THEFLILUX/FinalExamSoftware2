import 'package:frontend/shared_preferences/preferences.dart';
import 'package:frontend/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:frontend/providers/providers.dart';
import 'package:rsa_encrypt/rsa_encrypt.dart';

class ChatsDrawer extends StatelessWidget {
  const ChatsDrawer({
    super.key,
    required this.email,
    required this.name,
    required this.profilePicture,
    required this.publicKey,
    required this.privateKey,
  });

  final String email;
  final String name;
  final String profilePicture;
  final String publicKey;
  final String privateKey;

  @override
  Widget build(BuildContext context) {
    final RsaKeyHelper rsaKeyHelper = RsaKeyHelper();

    return Drawer(
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            decoration: const BoxDecoration(
              color: AppTheme.primaryColor,
            ),
            accountName: Padding(
              padding: const EdgeInsets.only(right: 10),
              child: Text(
                name,
                style: Theme.of(context).textTheme.titleLarge,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                textAlign: TextAlign.left,
              ),
            ),
            accountEmail: Text(
              email,
              style: Theme.of(context).textTheme.titleSmall,
            ),
            currentAccountPicture: ClipRRect(
              borderRadius: BorderRadius.circular(100),
              child: Image.network(
                profilePicture,
                fit: BoxFit.cover,
              ),
            ),
          ),
          SizedBox(
            height: 500,
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                child: Column(
                  children: [
                    Text(
                      'Llave pública',
                      textAlign: TextAlign.left,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      rsaKeyHelper.removePemHeaderAndFooter(publicKey),
                      textAlign: TextAlign.justify,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 50),
                    Text(
                      'Llave privada',
                      textAlign: TextAlign.left,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      rsaKeyHelper.removePemHeaderAndFooter(privateKey),
                      textAlign: TextAlign.justify,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ],
                ),
              ),
            ),
          ),
          const Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                _ThemeSwitch(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ThemeSwitch extends StatefulWidget {
  const _ThemeSwitch();

  @override
  State<_ThemeSwitch> createState() => _ThemeSwitchState();
}

class _ThemeSwitchState extends State<_ThemeSwitch> {
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Center(
          child: Column(
            children: [
              const Text(
                'Modo oscuro',
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
              Switch(
                value: Preferences.isDarkMode,
                activeColor: AppTheme.primaryColor,
                onChanged: (value) {
                  setState(() {
                    Preferences.isDarkMode = value;
                    if (themeProvider.currentThemeName == 'light') {
                      themeProvider.setDarkMode();
                    } else {
                      themeProvider.setLightMode();
                    }
                  });
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}
