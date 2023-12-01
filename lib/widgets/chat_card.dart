import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:frontend/providers/providers.dart';

class ChatCard extends StatelessWidget {
  const ChatCard({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: _cardShape(themeProvider),
      child: child,
    );
  }

  BoxDecoration _cardShape(ThemeProvider themeProvider) => BoxDecoration(
        color: themeProvider.currentThemeName == 'light'
            ? Colors.white30
            : Colors.black38,
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 5,
            offset: Offset(0, 5),
          ),
        ],
      );
}
