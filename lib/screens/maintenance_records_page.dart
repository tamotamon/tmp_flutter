import 'package:flutter/material.dart';

class MaintenanceRecordsPage extends StatelessWidget {
  const MaintenanceRecordsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('メンテ実績登録'),
      ),
      body: const Center(
        child: Text('メンテ実績登録の一覧を表示'),
      ),
    );
  }
}
