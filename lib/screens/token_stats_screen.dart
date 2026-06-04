import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/chat_provider.dart';

class TokenStatsScreen extends StatelessWidget {
  const TokenStatsScreen({super.key});

  String _fmtNum(num? value, {int digits = 0}) {
    if (value == null) return '0';
    return value.toStringAsFixed(digits);
  }

  Widget _card({
    required String title,
    required String value,
    String? subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: Colors.white70, fontSize: 12)),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(subtitle, style: const TextStyle(color: Colors.white54, fontSize: 11)),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Статистика')),
      body: Consumer<ChatProvider>(
        builder: (context, chatProvider, child) {
          return FutureBuilder<Map<String, dynamic>>(
            future: chatProvider.exportHistory(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(
                  child: Text(
                    'Ошибка загрузки статистики',
                    style: const TextStyle(color: Colors.white70),
                  ),
                );
              }

              final data = snapshot.data ?? {};
              final analytics = (data['analytics_stats'] as Map?) ?? {};
              final dbStats = (data['database_stats'] as Map?) ?? {};
              final modelUsage =
                  (analytics['model_usage'] as Map?)?.cast<String, dynamic>() ?? {};
              final responseTime =
                  (data['response_time_stats'] as Map?)?.cast<String, dynamic>() ?? {};
              final messageLength =
                  (data['message_length_stats'] as Map?)?.cast<String, dynamic>() ?? {};

              return ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  GridView.count(
                    crossAxisCount: MediaQuery.of(context).size.width > 700 ? 3 : 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 1.55,
                    children: [
                      _card(
                        title: 'Сообщений',
                        value: _fmtNum(analytics['total_messages']),
                        subtitle: 'Всего в сессии',
                      ),
                      _card(
                        title: 'Токенов',
                        value: _fmtNum(analytics['total_tokens']),
                        subtitle: 'Всего использовано',
                      ),
                      _card(
                        title: 'Сессия',
                        value: '${_fmtNum(analytics['session_duration'])} c',
                        subtitle: 'Длительность',
                      ),
                      _card(
                        title: 'Сообщ/мин',
                        value: _fmtNum(analytics['messages_per_minute'], digits: 2),
                        subtitle: 'Скорость работы',
                      ),
                      _card(
                        title: 'Токен/сообщ',
                        value: _fmtNum(analytics['tokens_per_message'], digits: 2),
                        subtitle: 'Среднее',
                      ),
                      _card(
                        title: 'Записей в БД',
                        value: _fmtNum(dbStats['total_messages']),
                        subtitle: 'История чата',
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Использование по моделям',
                    style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  if (modelUsage.isEmpty)
                    const Text(
                      'Пока нет данных',
                      style: TextStyle(color: Colors.white54),
                    )
                  else
                    ...modelUsage.entries.map((entry) {
                      final stats = (entry.value as Map).cast<String, dynamic>();
                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2A2A2A),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: Colors.white10),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              entry.key,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Сообщений: ${_fmtNum(stats['count'])} | Токенов: ${_fmtNum(stats['tokens'])}',
                              style: const TextStyle(color: Colors.white70, fontSize: 12),
                            ),
                          ],
                        ),
                      );
                    }),
                  const SizedBox(height: 20),
                  const Text(
                    'Ответы и сообщения',
                    style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  _card(
                    title: 'Среднее время ответа',
                    value: responseTime['average'] == null
                        ? '0.00 c'
                        : '${_fmtNum(responseTime['average'], digits: 2)} c',
                    subtitle: 'min ${_fmtNum(responseTime['min'], digits: 2)} c, max ${_fmtNum(responseTime['max'], digits: 2)} c',
                  ),
                  const SizedBox(height: 12),
                  _card(
                    title: 'Средняя длина сообщения',
                    value: _fmtNum(messageLength['average_length'], digits: 1),
                    subtitle: 'Всего символов: ${_fmtNum(messageLength['total_characters'])}',
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
