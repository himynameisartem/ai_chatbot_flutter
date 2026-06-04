import 'package:flutter/material.dart';

class ProviderSettingsScreen extends StatelessWidget {
  const ProviderSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Провайдер')),
  body: Padding(
    padding: const EdgeInsets.all(16.0),
    child: Column(
      children: [
        DropdownButtonFormField<String>(
          decoration: InputDecoration(labelText: 'Провайдер'),
          items: ['OpenRouter', 'VSEGPT'].map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
          onChanged: (String? newValue) {
            // TODO: Handle provider change
          },
        ),
        SizedBox(height: 16),
        TextFormField(
          decoration: InputDecoration(labelText: 'API ключ'),
          obscureText: true,
          // TODO: Handle API key input
        ),
      ],
    ),
  ),
    );
  }
}