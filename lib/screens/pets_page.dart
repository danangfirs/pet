import 'package:flutter/material.dart';
import '../data/dummy_data.dart';
import 'add_pet_page.dart';

class PetsPage extends StatelessWidget {
  const PetsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Peliharaan Saya',
            style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: dummyPets.length,
        itemBuilder: (context, index) {
          final pet = dummyPets[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            child: ListTile(
              leading: CircleAvatar(
                  radius: 30, backgroundImage: NetworkImage(pet.imageUrl)),
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
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => const AddPetPage()));
        },
        backgroundColor: Theme.of(context).primaryColor,
        child: const Icon(Icons.add, color: Colors.black),
      ),
    );
  }
}
