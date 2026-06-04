import 'package:flutter/material.dart';

class ProviderSettingsScreen extends StatelessWidget {
  const ProviderSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Провайдер')),
      body: Center(
        child: Text('Настройки OpenRouter / VSEGPT и API-ключей'),
      ),
    );
  }
}