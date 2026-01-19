import 'package:flutter/material.dart';

class Pet {
  final String id;
  final String name;
  final String breed;
  final String imageUrl;
  final double batteryLevel;
  final bool isSafe;
  final String lastSeen;
  final String location;
  final Offset position;

  Pet({
    required this.id,
    required this.name,
    required this.breed,
    required this.imageUrl,
    required this.batteryLevel,
    required this.isSafe,
    required this.lastSeen,
    required this.location,
    required this.position,
  });
}
