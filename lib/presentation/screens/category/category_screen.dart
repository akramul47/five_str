import 'package:flutter/material.dart';

/// Category screen — placeholder for UI implementation.
class CategoryScreen extends StatelessWidget {
  final int id;

  const CategoryScreen({super.key, required this.id});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Category #$id')),
      body: Center(child: Text('Category Screen — ID: $id')),
    );
  }
}
