import 'package:flutter/material.dart';

class DailyCostChartScreen extends StatelessWidget {
  const DailyCostChartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Расходы')),
      body: Center(
        child: Text('График расходов по дням'),
      ),
    );
  }
}