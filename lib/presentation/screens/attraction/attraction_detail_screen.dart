import 'package:flutter/material.dart';

/// Attraction detail screen — placeholder for UI implementation.
class AttractionDetailScreen extends StatelessWidget {
  final int id;

  const AttractionDetailScreen({super.key, required this.id});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Attraction #$id')),
      body: Center(child: Text('Attraction Detail Screen — ID: $id')),
    );
  }
}
