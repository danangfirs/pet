import 'package:flutter/material.dart';
import 'home_page.dart';
import 'pets_page.dart';
import 'gps_map_page.dart';
import 'settings_page.dart';
import '../services/theme_service.dart';
import '../services/pet_service.dart';
import '../services/profile_service.dart';

class MainScreen extends StatefulWidget {
  final ThemeService themeService;
  const MainScreen({Key? key, required this.themeService}) : super(key: key);

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  late final PetService _petService;
  late final ProfileService _profileService;
  late List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _petService = PetService();
    _profileService = ProfileService();
    _pages = [
      HomePage(petService: _petService),
      PetsPage(petService: _petService),
      GpsMapPage(petService: _petService),
      SettingsPage(
        themeService: widget.themeService,
        profileService: _profileService,
      ),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: theme.cardColor,
        selectedItemColor: theme.primaryColor,
        unselectedItemColor: theme.textTheme.bodyMedium?.color,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
              icon: Icon(Icons.dashboard_outlined),
              activeIcon: Icon(Icons.dashboard),
              label: 'Beranda'),
          BottomNavigationBarItem(
              icon: Icon(Icons.pets_outlined),
              activeIcon: Icon(Icons.pets),
              label: 'Peliharaan'),
          BottomNavigationBarItem(
              icon: Icon(Icons.map_outlined),
              activeIcon: Icon(Icons.map),
              label: 'Peta'),
          BottomNavigationBarItem(
              icon: Icon(Icons.settings_outlined),
              activeIcon: Icon(Icons.settings),
              label: 'Pengaturan'),
        ],
      ),
    );
  }
}
