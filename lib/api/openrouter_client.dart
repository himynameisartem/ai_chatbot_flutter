import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../services/settings_service.dart';

class OpenRouterClient {
  static final OpenRouterClient _instance = OpenRouterClient._internal();

  factory OpenRouterClient() {
    return _instance;
  }

  OpenRouterClient._internal();

  Future<String> _getApiKey() async {
    final savedApiKey = await SettingsService().getApiKey();

    if (savedApiKey != null && savedApiKey.isNotEmpty) {
      return savedApiKey;
    }

    return '';
  }

  Future<String> _getBaseUrl() async {
    final savedProvider = await SettingsService().getProvider();

    if (savedProvider == 'VSEGPT') {
      return 'https://api.vsegpt.ru/v1';
    }

    return 'https://openrouter.ai/api/v1';
  }

  Future<List<Map<String, dynamic>>> getModels() async {
    try {
      final apiKey = await _getApiKey();
      if (apiKey.isEmpty) {
        return [];
      }
      final baseUrl = await _getBaseUrl();

      final response = await http.get(
        Uri.parse('$baseUrl/models'),
        headers: {
          'Authorization': 'Bearer $apiKey',
          'Content-Type': 'application/json',
          'X-Title': 'AI Chat Flutter',
        },
      );

      if (kDebugMode) {
        print('Models response status: ${response.statusCode}');
        print('Models response body: ${response.body}');
      }

      if (response.statusCode == 200) {
        final modelsData = json.decode(response.body);

        if (modelsData['data'] != null) {
          return (modelsData['data'] as List)
              .map(
                (model) => {
                  'id': model['id'] as String,
                  'name': model['name'] as String,
                  'pricing': {
                    'prompt': model['pricing']?['prompt']?.toString() ?? '0',
                    'completion':
                        model['pricing']?['completion']?.toString() ?? '0',
                  },
                  'context_length': (model['context_length'] ??
                          model['top_provider']?['context_length'] ??
                          0)
                      .toString(),
                },
              )
              .toList();
        }

        throw Exception('Invalid API response format');
      }

      return [];
    } catch (e) {
      if (kDebugMode) {
        print('Error getting models: $e');
      }

      return [];
    }
  }

  Future<Map<String, dynamic>> sendMessage(String message, String model) async {
    try {
      final baseUrl = await _getBaseUrl();
      final apiKey = await _getApiKey();

      if (apiKey.isEmpty) {
        return {'error': 'API ключ не указан'};
      }

      final data = {
        'model': model,
        'messages': [
          {'role': 'user', 'content': message},
        ],
        'max_tokens': 1000,
        'temperature': 0.7,
        'stream': false,
      };

      if (kDebugMode) {
        print('Sending message to API: ${json.encode(data)}');
      }

      final response = await http.post(
        Uri.parse('$baseUrl/chat/completions'),
        headers: {
          'Authorization': 'Bearer $apiKey',
          'Content-Type': 'application/json',
          'X-Title': 'AI Chat Flutter',
        },
        body: json.encode(data),
      );

      if (kDebugMode) {
        print('Message response status: ${response.statusCode}');
        print('Message response body: ${response.body}');
      }

      if (response.statusCode == 200) {
        return json.decode(utf8.decode(response.bodyBytes));
      }

      final errorData = json.decode(utf8.decode(response.bodyBytes));

      return {
        'error': errorData['error']?['message'] ?? 'Unknown error occurred',
      };
    } catch (e) {
      if (kDebugMode) {
        print('Error sending message: $e');
      }

      return {'error': e.toString()};
    }
  }

  Future<String> getBalance() async {
    try {
      final baseUrl = await _getBaseUrl();
      final isVsegpt = baseUrl.contains('vsegpt.ru');
      final apiKey = await _getApiKey();

      if (apiKey.isEmpty) {
        return isVsegpt ? '0.00₽' : '\$0.00';
      }

      final response = await http.get(
        Uri.parse(isVsegpt ? '$baseUrl/balance' : '$baseUrl/credits'),
        headers: {
          'Authorization': 'Bearer $apiKey',
          'Content-Type': 'application/json',
          'X-Title': 'AI Chat Flutter',
        },
      );

      if (kDebugMode) {
        print('Balance response status: ${response.statusCode}');
        print('Balance response body: ${response.body}');
      }

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data != null && data['data'] != null) {
          if (isVsegpt) {
            final credits =
                double.tryParse(data['data']['credits'].toString()) ?? 0.0;

            return '${credits.toStringAsFixed(2)}₽';
          }

          final credits = data['data']['total_credits'] ?? 0;
          final usage = data['data']['total_usage'] ?? 0;

          return '\$${(credits - usage).toStringAsFixed(2)}';
        }
      }

      return isVsegpt ? '0.00₽' : '\$0.00';
    } catch (e) {
      if (kDebugMode) {
        print('Error getting balance: $e');
      }

      return '\$0.00';
    }
  }

  Future<String?> get baseUrl async {
    return _getBaseUrl();
  }

  String formatPricing(double pricing) {
    return '\$${(pricing * 1000000).toStringAsFixed(3)}/M';
  }
}
