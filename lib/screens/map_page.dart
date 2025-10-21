import 'dart:ui';
import 'package:flutter/material.dart';
import '../data/dummy_data.dart';
import '../models/pet.dart';

class MapPage extends StatelessWidget {
  const MapPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Menggunakan gambar lokal dari folder assets
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/abh-map-dummy.jpg"),
                fit: BoxFit.cover,
                // Sedikit menggelapkan gambar agar pin lebih menonjol
                colorFilter: ColorFilter.mode(Colors.black38, BlendMode.darken),
              ),
            ),
          ),

          // Menampilkan semua pin hewan
          LayoutBuilder(builder: (context, constraints) {
            return Stack(
              children: dummyPets.map((pet) {
                return Positioned(
                  left: pet.position.dx * constraints.maxWidth,
                  top: pet.position.dy * constraints.maxHeight,
                  child: _buildPetMapMarker(context, pet),
                );
              }).toList(),
            );
          }),
          
          // Kartu Info
          Positioned(
            bottom: 30,
            left: 20,
            right: 20,
            child: _buildGlassInfoCard(dummyPets.first),
          ),
          
          // Tombol Aksi
          Positioned(
            top: 60,
            right: 20,
            child: FloatingActionButton(
              mini: true,
              onPressed: () {},
              backgroundColor: const Color(0xFF1E1E1E),
              child: const Icon(Icons.my_location),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPetMapMarker(BuildContext context, Pet pet) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: pet.isSafe ? Theme.of(context).primaryColor : Colors.orange,
          ),
          child: CircleAvatar(
            radius: 20,
            backgroundImage: NetworkImage(pet.imageUrl),
          ),
        ),
        Icon(Icons.arrow_drop_down,
            color: pet.isSafe ? Theme.of(context).primaryColor : Colors.orange,
            size: 30),
      ],
    );
  }

  Widget _buildGlassInfoCard(Pet pet) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.white.withOpacity(0.15),
                Colors.white.withOpacity(0.05)
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.2)),
          ),
          child: Row(
            children: [
              CircleAvatar(
                  radius: 25, backgroundImage: NetworkImage(pet.imageUrl)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(pet.name,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontSize: 18)),
                    Text(pet.location,
                        style: TextStyle(color: Colors.white.withOpacity(0.8))),
                  ],
                ),
              ),
              Text('${(pet.batteryLevel * 100).toInt()}%',
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }
}

