import 'dart:ui';
import 'package:flutter/material.dart';
import '../services/pet_service.dart';
import '../models/pet.dart';

class MapPage extends StatefulWidget {
  final PetService petService;
  const MapPage({Key? key, required this.petService}) : super(key: key);

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  @override
  void initState() {
    super.initState();
    widget.petService.addListener(_onPetsChanged);
  }

  @override
  void dispose() {
    widget.petService.removeListener(_onPetsChanged);
    super.dispose();
  }

  void _onPetsChanged() {
    setState(() {});
  }

  void _showPetSelector(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Pilih Peliharaan untuk Ditampilkan',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              ...widget.petService.pets.asMap().entries.map((entry) {
                final index = entry.key;
                final pet = entry.value;
                final isSelected = widget.petService.selectedPetIndex == index;
                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(pet.imageUrl),
                  ),
                  title: Text(pet.name),
                  subtitle: Text(pet.breed),
                  trailing: isSelected
                      ? Icon(Icons.check_circle, color: Theme.of(context).primaryColor)
                      : null,
                  onTap: () {
                    widget.petService.selectPet(index);
                    Navigator.pop(context);
                  },
                );
              }),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final pets = widget.petService.pets;
    final selectedPet = pets.isNotEmpty ? widget.petService.selectedPet : null;

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

          // Menampilkan semua pin hewan (highlight selected)
          LayoutBuilder(builder: (context, constraints) {
            return Stack(
              children: pets.map((pet) {
                final isSelected = selectedPet?.id == pet.id;
                return Positioned(
                  left: pet.position.dx * constraints.maxWidth,
                  top: pet.position.dy * constraints.maxHeight,
                  child: GestureDetector(
                    onTap: () {
                      final index = pets.indexOf(pet);
                      widget.petService.selectPet(index);
                    },
                    child: _buildPetMapMarker(context, pet, isSelected),
                  ),
                );
              }).toList(),
            );
          }),
          
          // Kartu Info
          if (selectedPet != null)
            Positioned(
              bottom: 30,
              left: 20,
              right: 20,
              child: _buildGlassInfoCard(selectedPet),
            ),
          
          // Tombol Aksi
          Positioned(
            top: 60,
            right: 20,
            child: Column(
              children: [
                FloatingActionButton(
                  mini: true,
                  onPressed: () {
                    _showPetSelector(context);
                  },
                  backgroundColor: Theme.of(context).cardColor,
                  child: Icon(Icons.pets, color: Theme.of(context).primaryColor),
                ),
                const SizedBox(height: 8),
                FloatingActionButton(
                  mini: true,
                  onPressed: () {},
                  backgroundColor: Theme.of(context).cardColor,
                  child: Icon(Icons.my_location, color: Theme.of(context).primaryColor),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPetMapMarker(BuildContext context, Pet pet, bool isSelected) {
    final markerColor = pet.isSafe ? Theme.of(context).primaryColor : Colors.orange;
    final borderWidth = isSelected ? 4.0 : 2.0;
    
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(borderWidth),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: markerColor,
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: markerColor.withOpacity(0.5),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ]
                : null,
          ),
          child: CircleAvatar(
            radius: isSelected ? 22 : 20,
            backgroundImage: NetworkImage(pet.imageUrl),
          ),
        ),
        Icon(Icons.arrow_drop_down,
            color: markerColor,
            size: isSelected ? 35 : 30),
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

