import 'package:flutter/material.dart';

class HouseholdAccountsPage extends StatelessWidget {
  const HouseholdAccountsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('家計簿'),
      ),
      body: const Center(
        child: Text('家計簿の一覧を表示'),
      ),
    );
  }
}
