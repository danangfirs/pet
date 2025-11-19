import 'package:flutter/material.dart';
import '../services/pet_service.dart';
import 'add_pet_page.dart';

class PetsPage extends StatefulWidget {
  final PetService petService;
  const PetsPage({Key? key, required this.petService}) : super(key: key);

  @override
  State<PetsPage> createState() => _PetsPageState();
}

class _PetsPageState extends State<PetsPage> {
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

  @override
  Widget build(BuildContext context) {
    final pets = widget.petService.pets;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Peliharaan Saya',
            style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: pets.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.pets, size: 80, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  Text(
                    'Belum ada peliharaan',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tambahkan peliharaan pertama Anda',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: pets.length,
              itemBuilder: (context, index) {
                final pet = pets[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)),
                  child: ListTile(
                    leading: CircleAvatar(
                        radius: 30,
                        backgroundImage: NetworkImage(pet.imageUrl)),
                    title: Text(pet.name,
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(pet.breed),
                    trailing: Container(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: pet.isSafe
                            ? Colors.green.withOpacity(0.2)
                            : Colors.orange.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(pet.isSafe ? 'Aman' : 'Peringatan',
                          style: TextStyle(
                              color: pet.isSafe ? Colors.green : Colors.orange,
                              fontWeight: FontWeight.bold)),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      AddPetPage(petService: widget.petService)));
        },
        backgroundColor: Theme.of(context).primaryColor,
        child: const Icon(Icons.add, color: Colors.black),
      ),
    );
  }
}
