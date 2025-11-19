import 'package:flutter/material.dart';
import '../services/theme_service.dart';
import '../services/profile_service.dart';
import 'edit_profile_page.dart';

class SettingsPage extends StatefulWidget {
  final ThemeService themeService;
  final ProfileService profileService;
  const SettingsPage({
    Key? key,
    required this.themeService,
    required this.profileService,
  }) : super(key: key);

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  void initState() {
    super.initState();
    widget.themeService.addListener(_onThemeChanged);
    widget.profileService.addListener(_onProfileChanged);
  }

  @override
  void dispose() {
    widget.themeService.removeListener(_onThemeChanged);
    widget.profileService.removeListener(_onProfileChanged);
    super.dispose();
  }

  void _onThemeChanged() {
    setState(() {});
  }

  void _onProfileChanged() {
    setState(() {});
  }

  void _showEditProfileDialog() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditProfilePage(
          profileService: widget.profileService,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final profile = widget.profileService;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengaturan',
            style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Center(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundImage: NetworkImage(profile.imageUrl),
                ),
                const SizedBox(height: 12),
                Text(
                  profile.name,
                  style: const TextStyle(
                      fontSize: 22, fontWeight: FontWeight.bold),
                ),
                Text(
                  profile.email,
                  style: TextStyle(color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),
          _buildSettingsSectionTitle('Akun'),
          _buildSettingsTile(
            Icons.person_outline,
            'Edit Profil',
            _showEditProfileDialog,
          ),
          _buildSettingsTile(Icons.lock_outline, 'Ganti Kata Sandi', () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Fitur ganti kata sandi akan segera hadir')),
            );
          }),
          _buildSettingsTile(
              Icons.devices_other_outlined, 'Kelola Perangkat', () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Fitur kelola perangkat akan segera hadir')),
            );
          }),
          const SizedBox(height: 20),
          _buildSettingsSectionTitle('Aplikasi'),
          _buildSettingsTile(Icons.notifications_outlined, 'Notifikasi', () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Pengaturan notifikasi akan segera hadir')),
            );
          }),
          _buildSettingsTile(
            Icons.dark_mode_outlined,
            'Mode Gelap',
            () {},
            trailing: Switch(
              value: widget.themeService.isDarkMode,
              onChanged: (val) {
                widget.themeService.toggleTheme();
              },
              activeColor: Theme.of(context).primaryColor,
            ),
          ),
          _buildSettingsTile(Icons.info_outline, 'Tentang RaptorC', () {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Tentang RaptorC'),
                content: const Text(
                  'RaptorC adalah aplikasi pelacakan peliharaan yang memungkinkan Anda untuk memantau lokasi dan kesehatan hewan peliharaan Anda secara real-time.',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Tutup'),
                  ),
                ],
              ),
            );
          }),
          const SizedBox(height: 30),
          Center(
            child: TextButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Keluar'),
                    content: const Text('Apakah Anda yakin ingin keluar?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Batal'),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          Navigator.pop(context);
                        },
                        child: const Text(
                          'Keluar',
                          style: TextStyle(color: Colors.redAccent),
                        ),
                      ),
                    ],
                  ),
                );
              },
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
