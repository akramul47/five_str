import 'package:flutter/material.dart';

/// Business detail screen — placeholder for UI implementation.
class BusinessDetailScreen extends StatelessWidget {
  final int id;

  const BusinessDetailScreen({super.key, required this.id});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Business #$id')),
      body: Center(child: Text('Business Detail Screen — ID: $id')),
    );
  }
}
