import 'package:flutter/material.dart';

class TokenStatsScreen extends StatelessWidget {
  const TokenStatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Статистика')),
      body: Center(
        child: Text('Статистика использования токенов по моделям'),
      ),
    );
  }
}