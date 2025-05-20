import 'package:flutter/material.dart';

class ChartScreen extends StatelessWidget {
  const ChartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Chart"),
        centerTitle: true,
      ),
      body: Center(
        child: Text("Chart Screen"),
      ),
    );
  }
}