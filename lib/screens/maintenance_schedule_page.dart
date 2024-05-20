import 'package:flutter/material.dart';

class MaintenanceSchedulePage extends StatelessWidget {
  const MaintenanceSchedulePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('メンテ予定登録'),
      ),
      body: const Center(
        child: Text('メンテ予定登録の一覧を表示'),
      ),
    );
  }
}
