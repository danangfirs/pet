import 'package:flutter/material.dart';

class AddPetPage extends StatelessWidget {
  const AddPetPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tambah Peliharaan Baru',
            style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24.0),
        children: [
          Center(
            child: Container(
              height: 120,
              width: 120,
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(60),
                border: Border.all(color: Colors.grey.shade700, width: 2),
              ),
              child:
                  const Icon(Icons.camera_alt_outlined, color: Colors.grey, size: 40),
            ),
          ),
          const SizedBox(height: 8),
          const Text('Unggah Foto',
              textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 32),
          const Text('Nama Peliharaan',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 8),
          const TextField(decoration: InputDecoration(hintText: 'Contoh: Milo')),
          const SizedBox(height: 24),
          const Text('Jenis / Ras',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 8),
          const TextField(
              decoration: InputDecoration(hintText: 'Contoh: Golden Retriever')),
          const SizedBox(height: 24),
          const Text('ID Perangkat GPS',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 8),
          const TextField(
              decoration:
                  InputDecoration(hintText: 'Masukkan ID dari perangkat Anda')),
          const SizedBox(height: 48),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.primaryColor,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Simpan Peliharaan',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black)),
          ),
        ],
      ),
    );
  }
}
