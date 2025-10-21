import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengaturan',
            style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          const Center(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundImage: NetworkImage(
                      'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?q=80&w=2680&auto=format&fit=crop'),
                ),
                SizedBox(height: 12),
                Text('Zidan Mirza',
                    style:
                        TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                Text('ZidanMirza27@email.com',
                    style: TextStyle(color: Colors.grey)),
              ],
            ),
          ),
          const SizedBox(height: 30),
          _buildSettingsSectionTitle('Akun'),
          _buildSettingsTile(Icons.person_outline, 'Edit Profil', () {}),
          _buildSettingsTile(Icons.lock_outline, 'Ganti Kata Sandi', () {}),
          _buildSettingsTile(
              Icons.devices_other_outlined, 'Kelola Perangkat', () {}),
          const SizedBox(height: 20),
          _buildSettingsSectionTitle('Aplikasi'),
          _buildSettingsTile(Icons.notifications_outlined, 'Notifikasi', () {}),
          _buildSettingsTile(
            Icons.dark_mode_outlined,
            'Mode Gelap',
            () {},
            trailing: Switch(
                value: true,
                onChanged: (val) {},
                activeColor: Theme.of(context).primaryColor),
          ),
          _buildSettingsTile(Icons.info_outline, 'Tentang RaptorC', () {}),
          const SizedBox(height: 30),
          Center(
            child: TextButton(
              onPressed: () {},
              child: const Text('Keluar',
                  style: TextStyle(color: Colors.redAccent, fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(title.toUpperCase(),
          style: const TextStyle(
              color: Colors.grey,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2)),
    );
  }

  Widget _buildSettingsTile(IconData icon, String title, VoidCallback onTap,
      {Widget? trailing}) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        trailing: trailing ?? const Icon(Icons.chevron_right, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }
}
