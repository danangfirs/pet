import 'package:flutter/material.dart';
import '../models/pet.dart';
import '../services/pet_service.dart';

class AddPetPage extends StatefulWidget {
  final PetService petService;
  const AddPetPage({Key? key, required this.petService}) : super(key: key);

  @override
  State<AddPetPage> createState() => _AddPetPageState();
}

class _AddPetPageState extends State<AddPetPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _breedController = TextEditingController();
  final _deviceIdController = TextEditingController();
  String _imageUrl = 'https://images.unsplash.com/photo-1568572933382-74d440642117?q=80&w=2574&auto=format&fit=crop';

  @override
  void dispose() {
    _nameController.dispose();
    _breedController.dispose();
    _deviceIdController.dispose();
    super.dispose();
  }

  void _savePet() {
    if (_formKey.currentState!.validate()) {
      final newPet = Pet(
        id: 'p${DateTime.now().millisecondsSinceEpoch}',
        name: _nameController.text.trim(),
        breed: _breedController.text.trim(),
        imageUrl: _imageUrl,
        batteryLevel: 1.0,
        isSafe: true,
        lastSeen: 'Baru saja',
        location: 'Lokasi belum terdeteksi',
        position: const Offset(0.5, 0.5),
      );

      widget.petService.addPet(newPet);
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Peliharaan berhasil ditambahkan!'),
          backgroundColor: Colors.green,
        ),
      );
      
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tambah Peliharaan Baru',
            style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(24.0),
          children: [
            Center(
              child: GestureDetector(
                onTap: () {
                  // TODO: Implement image picker
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Fitur upload foto akan segera hadir')),
                  );
                },
                child: Container(
                  height: 120,
                  width: 120,
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    borderRadius: BorderRadius.circular(60),
                    border: Border.all(
                      color: theme.brightness == Brightness.dark 
                        ? Colors.grey.shade700 
                        : Colors.grey.shade300, 
                      width: 2
                    ),
                    image: _imageUrl.isNotEmpty 
                      ? DecorationImage(
                          image: NetworkImage(_imageUrl),
                          fit: BoxFit.cover,
                        )
                      : null,
                  ),
                  child: _imageUrl.isEmpty
                    ? const Icon(Icons.camera_alt_outlined, color: Colors.grey, size: 40)
                    : null,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text('Unggah Foto',
                textAlign: TextAlign.center, 
                style: TextStyle(color: theme.textTheme.bodyMedium?.color)),
            const SizedBox(height: 32),
            Text('Nama Peliharaan',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(hintText: 'Contoh: Milo'),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Nama peliharaan harus diisi';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
            Text('Jenis / Ras',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            TextFormField(
              controller: _breedController,
              decoration: const InputDecoration(hintText: 'Contoh: Golden Retriever'),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Jenis/Ras harus diisi';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
            Text('ID Perangkat GPS',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            TextFormField(
              controller: _deviceIdController,
              decoration: const InputDecoration(hintText: 'Masukkan ID dari perangkat Anda'),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'ID perangkat harus diisi';
                }
                return null;
              },
            ),
            const SizedBox(height: 48),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.primaryColor,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: _savePet,
              child: const Text('Simpan Peliharaan',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black)),
            ),
          ],
        ),
      ),
    );
  }
}
