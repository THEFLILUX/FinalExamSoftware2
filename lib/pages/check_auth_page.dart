import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:frontend/services/services.dart';
import 'package:frontend/pages/pages.dart';

class CheckAuthPage extends StatelessWidget {
  const CheckAuthPage({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context, listen: false);

    return Scaffold(
      body: Center(
        child: FutureBuilder(
          future: authService.readPrivateKey(),
          builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
            if (!snapshot.hasData) {
              return const Text('');
            }

            if (snapshot.data == '') {
              Future.microtask(() {
                Navigator.pushReplacement(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (_, __, ___) => const LoginPage(),
                      transitionDuration: const Duration(seconds: 0),
                    ));
              });
              // Future.microtask(() {
              //   Navigator.pushReplacement(context, PageRouteBuilder(
              //     pageBuilder: (_, __, ___) => const HomePage(),
              //     transitionDuration: const Duration(seconds: 0),
              //   ));
              // });
            } else {
              Future.microtask(() {
                Navigator.pushReplacement(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (_, __, ___) => const HomePage(),
                      transitionDuration: const Duration(seconds: 0),
                    ));
              });
            }

            return Container();
          },
        ),
      ),
    );
  }
}
