import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/chat_provider.dart';
import '../services/settings_service.dart';

class ProviderSettingsScreen extends StatefulWidget {
  final Future<void> Function()? onSaved;

  const ProviderSettingsScreen({super.key, this.onSaved});

  @override
  State<ProviderSettingsScreen> createState() => _ProviderSettingsScreenState();
}

class _ProviderSettingsScreenState extends State<ProviderSettingsScreen> {
  final _settingsService = SettingsService();
  final _apiKeyController = TextEditingController();

  String _selectedProvider = 'OpenRouter';

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final provider = await _settingsService.getProvider();
    final apiKey = await _settingsService.getApiKey();

    setState(() {
      _selectedProvider = provider ?? 'OpenRouter';
      _apiKeyController.text = apiKey ?? '';
    });
  }

  Future<void> _saveSettings() async {
    await _settingsService.saveSettings(
      provider: _selectedProvider,
      apiKey: _apiKeyController.text.trim(),
    );

    if (mounted) {
      await context.read<ChatProvider>().refreshSettings();
    }

    await widget.onSaved?.call();

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Настройки сохранены')),
    );

    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
  }

  @override
  void dispose() {
    _apiKeyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Провайдер'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              initialValue: _selectedProvider,
              decoration: const InputDecoration(
                labelText: 'Провайдер',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(
                  value: 'OpenRouter',
                  child: Text('OpenRouter'),
                ),
                DropdownMenuItem(
                  value: 'VSEGPT',
                  child: Text('VSEGPT'),
                ),
              ],
              onChanged: (value) {
                if (value == null) return;
                setState(() {
                  _selectedProvider = value;
                });
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _apiKeyController,
              decoration: const InputDecoration(
                labelText: 'API ключ',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveSettings,
                child: const Text('Сохранить'),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'После сохранения экран закроется, если он открыт как отдельная страница.',
              style: TextStyle(color: Colors.white54, fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
