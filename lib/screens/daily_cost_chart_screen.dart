import 'package:flutter/material.dart';

import '../services/database_service.dart';

class DailyCostChartScreen extends StatefulWidget {
  const DailyCostChartScreen({super.key});

  @override
  State<DailyCostChartScreen> createState() => _DailyCostChartScreenState();
}

class _DailyCostChartScreenState extends State<DailyCostChartScreen> {
  String _formatDay(String isoDay) {
    final date = DateTime.tryParse(isoDay);
    if (date == null) return isoDay;
    return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}';
  }

  String _formatCost(double cost) {
    return cost < 0.001 ? '0.001' : cost.toStringAsFixed(3);
  }

  String _formatCurrency(double cost) {
    return '\$${_formatCost(cost)}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Расходы')),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: DatabaseService().getDailyCostStats(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(
              child: Text(
                'Не удалось загрузить график расходов',
                style: TextStyle(color: Colors.white70),
              ),
            );
          }

          final data = snapshot.data ?? [];
          final maxCost = data.isEmpty
              ? 0.0
              : data
                  .map((e) => (e['total_cost'] as double?) ?? 0.0)
                  .fold<double>(0.0, (prev, value) => value > prev ? value : prev);

          if (data.isEmpty) {
            return const Center(
              child: Text(
                'Пока нет расходов для отображения',
                style: TextStyle(color: Colors.white70),
              ),
            );
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const Text(
                'График расходов по дням',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                data.length == 1
                    ? 'Пока есть только один день, поэтому график показывает один столбец.'
                    : 'Показаны последние 7 дней. При новых сообщениях появятся новые столбцы.',
                style: const TextStyle(color: Colors.white54, fontSize: 12),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF2A2A2A),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white10),
                ),
                child: SizedBox(
                  height: 300,
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      const leftAxisWidth = 56.0;
                      const barSlotWidth = 88.0;
                      final chartWidth =
                          data.length * barSlotWidth < constraints.maxWidth - leftAxisWidth
                              ? constraints.maxWidth - leftAxisWidth
                              : data.length * barSlotWidth;

                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          SizedBox(
                            width: leftAxisWidth,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _formatCurrency(maxCost),
                                  style: const TextStyle(
                                    color: Colors.white54,
                                    fontSize: 11,
                                  ),
                                ),
                                Text(
                                  _formatCurrency(maxCost * 0.5),
                                  style: const TextStyle(
                                    color: Colors.white54,
                                    fontSize: 11,
                                  ),
                                ),
                                const Text(
                                  '\$0.00',
                                  style: TextStyle(
                                    color: Colors.white54,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: SizedBox(
                                width: chartWidth,
                                child: Stack(
                                  children: [
                                    Positioned.fill(
                                      child: CustomPaint(
                                        painter: _GridPainter(),
                                      ),
                                    ),
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        for (final item in data)
                                          SizedBox(
                                            width: barSlotWidth,
                                            child: Padding(
                                              padding: const EdgeInsets.symmetric(horizontal: 8),
                                              child: Column(
                                                mainAxisAlignment: MainAxisAlignment.end,
                                                children: [
                                                  Text(
                                                    _formatCurrency((item['total_cost'] as double?) ?? 0.0),
                                                    style: const TextStyle(
                                                      color: Colors.white70,
                                                      fontSize: 11,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 8),
                                                  Container(
                                                    height: maxCost <= 0
                                                        ? 6
                                                        : (((item['total_cost'] as double?) ?? 0.0) /
                                                                maxCost *
                                                                170)
                                                            .clamp(6.0, 170.0),
                                                    decoration: BoxDecoration(
                                                      gradient: const LinearGradient(
                                                        colors: [
                                                          Color(0xFF1A73E8),
                                                          Color(0xFF33CC33),
                                                        ],
                                                        begin: Alignment.topCenter,
                                                        end: Alignment.bottomCenter,
                                                      ),
                                                      borderRadius: BorderRadius.circular(10),
                                                    ),
                                                  ),
                                                  const SizedBox(height: 8),
                                                  Text(
                                                    _formatDay(item['day'] as String),
                                                    style: const TextStyle(
                                                      color: Colors.white54,
                                                      fontSize: 11,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ...data.map(
                (item) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    _formatDay(item['day'] as String),
                    style: const TextStyle(color: Colors.white),
                  ),
                  trailing: Text(
                    '${_formatCost((item['total_cost'] as double?) ?? 0.0)}\$',
                    style: const TextStyle(color: Colors.white70),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white12
      ..strokeWidth = 1;

    const lines = 4;
    for (var i = 0; i <= lines; i++) {
      final y = size.height / lines * i;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
