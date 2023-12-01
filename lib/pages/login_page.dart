// ignore_for_file: use_build_context_synchronously

import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:frontend/models/models.dart';
import 'package:frontend/services/auth_service.dart';
import 'package:frontend/shared_preferences/preferences.dart';
import 'package:frontend/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:pointycastle/export.dart' as crypto;
import 'package:provider/provider.dart';

import 'package:frontend/widgets/widgets.dart';
import 'package:frontend/providers/providers.dart';
import 'package:rsa_encrypt/rsa_encrypt.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: AuthBackground(
        child: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          child: Column(
            children: [
              SizedBox(height: 250),
              CardContainer(
                child: Column(
                  children: [
                    SizedBox(height: 10),
                    GoogleSignInButton(),
                    SizedBox(height: 10),
                  ],
                ),
              ),
              SizedBox(height: 100),
              _ThemeSwitch(),
            ],
          ),
        ),
      ),
    );
  }
}

class GoogleSignInButton extends StatelessWidget {
  const GoogleSignInButton({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 250,
      child: SignInScreen(
        actions: [
          AuthStateChangeAction<SignedIn>((context, signedIn) async {
            debugPrint('User: ${signedIn.user}');

            // Enviar datos a backend
            final authService =
                Provider.of<AuthService>(context, listen: false);
            final userModel = UserModel(
              email: signedIn.user!.email,
              password: signedIn.user!.uid,
            );
            final String? errorMessage =
                await authService.getCredentialsLogin(userModel);

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  '¡Bienvenido! ${signedIn.user!.displayName}',
                  textAlign: TextAlign.center,
                ),
                duration: const Duration(seconds: 3),
              ),
            );

            if (errorMessage == null) {
              Navigator.pushReplacementNamed(context, '/home');
            }
          }),
          AuthStateChangeAction<UserCreated>((context, signedUp) async {
            debugPrint('User: ${signedUp.credential.user}');

            // Crear llaves pública y privada
            Future<crypto.AsymmetricKeyPair> futureKeyPair = generateKeyPair();
            crypto.AsymmetricKeyPair keyPair = await futureKeyPair;

            // Convertir llaves pública y privada a strings
            RsaKeyHelper rsaKeyHelper = RsaKeyHelper();
            String publicKey = rsaKeyHelper.encodePublicKeyToPemPKCS1(
                keyPair.publicKey as crypto.RSAPublicKey);
            String privateKey = rsaKeyHelper.encodePrivateKeyToPemPKCS1(
                keyPair.privateKey as crypto.RSAPrivateKey);

            // Enviar datos a backend
            final authService =
                Provider.of<AuthService>(context, listen: false);
            final userModel = UserModel(
              id: signedUp.credential.user!.uid,
              name: signedUp.credential.user!.displayName,
              email: signedUp.credential.user!.email,
              password: signedUp.credential.user!.uid,
              publicKey: publicKey,
              privateKey: privateKey,
            );
            final String? errorMessage =
                await authService.saveCredentialsRegister(userModel);

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  '¡Bienvenido! ${signedUp.credential.user!.displayName}',
                  textAlign: TextAlign.center,
                ),
                duration: const Duration(seconds: 3),
              ),
            );

            if (errorMessage == null) {
              Navigator.pushReplacementNamed(context, '/home');
            }
          }),
          AuthStateChangeAction<AuthFailed>((context, error) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Error ${error.exception}',
                  textAlign: TextAlign.center,
                ),
                duration: const Duration(seconds: 3),
              ),
            );
          }),
        ],
      ),
    );
  }

  Future<crypto.AsymmetricKeyPair<crypto.PublicKey, crypto.PrivateKey>>
      generateKeyPair() {
    var helper = RsaKeyHelper();
    return helper.computeRSAKeyPair(helper.getSecureRandom());
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
