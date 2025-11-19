import 'package:flutter/material.dart';
import '../services/pet_service.dart';
import '../models/pet.dart';
import 'notification_page.dart';
import 'analytics_dashboard_page.dart';
import 'activity_monitoring_page.dart';
import 'health_tracking_page.dart';

class HomePage extends StatefulWidget {
  final PetService petService;
  const HomePage({Key? key, required this.petService}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
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
    final theme = Theme.of(context);
    final pets = widget.petService.pets;
    final selectedPet = pets.isNotEmpty ? widget.petService.selectedPet : null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('RaptorC',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.bar_chart),
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const AnalyticsDashboardPage()));
            },
          ),
          IconButton(
            icon: const Icon(Icons.notifications_none),
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const NotificationPage()));
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          // Simulate refresh
          await Future.delayed(const Duration(seconds: 1));
        },
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            if (selectedPet != null) ...[
              _buildMainStatusCard(context, selectedPet),
              const SizedBox(height: 24),
            ],
            Text('Dasbor Cepat',
                style: theme.textTheme.headlineSmall
                    ?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              children: [
                _buildDashboardCard(context, 'Pagar Virtual', Icons.shield_outlined,
                    'Aktif', theme.primaryColor, null),
                _buildDashboardCard(
                    context,
                    selectedPet != null 
                      ? 'Baterai ${selectedPet.name}'
                      : 'Baterai',
                    Icons.battery_charging_full,
                    selectedPet != null
                        ? '${(selectedPet.batteryLevel * 100).toInt()}%'
                        : 'N/A',
                    Colors.green,
                    null),
                _buildDashboardCard(context, 'Riwayat Lokasi', Icons.history,
                    'Lihat Semua', Colors.orange, () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const ActivityMonitoringPage()));
                }),
                _buildDashboardCard(context, 'Aktivitas Hari Ini', Icons.trending_up,
                    'Normal', Colors.purpleAccent, () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const ActivityMonitoringPage()));
                }),
              ],
            ),
            const SizedBox(height: 24),
            
            // Health Summary Card
            _buildHealthSummaryCard(context),
            const SizedBox(height: 24),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Peliharaan Saya',
                    style: theme.textTheme.headlineSmall
                        ?.copyWith(fontWeight: FontWeight.bold)),
                if (pets.length > 1)
                  TextButton(
                    onPressed: () {
                      _showPetSelector(context);
                    },
                    child: const Text('Lihat Semua'),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            pets.isEmpty
                ? _buildEmptyPetsCard(context)
                : SizedBox(
                    height: 120,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: pets.length,
                      itemBuilder: (context, index) {
                        final pet = pets[index];
                        final isSelected = widget.petService.selectedPetIndex == index;
                        return GestureDetector(
                          onTap: () {
                            widget.petService.selectPet(index);
                          },
                          child: _buildPetAvatar(pet, isSelected),
                        );
                      },
                    ),
                  ),
          ],
        ),
      ),
    );
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
                'Pilih Peliharaan',
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

  Widget _buildEmptyPetsCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            Icon(Icons.pets, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              'Belum ada peliharaan',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tambahkan peliharaan pertama Anda',
              style: TextStyle(
                color: Colors.grey.shade500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainStatusCard(BuildContext context, Pet pet) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: [Theme.of(context).primaryColor, const Color(0xFF00BFA5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('${pet.name} is ${pet.isSafe ? "Aman" : "Di Luar Area"}!',
              style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black)),
          const SizedBox(height: 8),
          Text('Lokasi terakhir di ${pet.location}, ${pet.lastSeen}.',
              style:
                  TextStyle(color: Colors.black.withOpacity(0.8), fontSize: 16)),
        ],
      ),
    );
  }

  Widget _buildDashboardCard(BuildContext context, String title, IconData icon,
      String value, Color color, VoidCallback? onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CircleAvatar(
                  backgroundColor: color.withOpacity(0.2),
                  child: Icon(icon, color: color)),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                  Text(value,
                      style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHealthSummaryCard(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const HealthTrackingPage()),
        );
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.pink.withOpacity(0.6),
              Colors.purple.withOpacity(0.6),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.favorite, color: Colors.white, size: 24),
                      const SizedBox(width: 8),
                      const Text(
                        'Health Status',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Skor Kesehatan: 85/100',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        padding:
                            const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          '2 Vaksin Upcoming',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding:
                            const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'Berat: 12.5 kg',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.arrow_forward,
                color: Colors.white,
                size: 32,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPetAvatar(Pet pet, bool isSelected) {
    return Padding(
      padding: const EdgeInsets.only(right: 16.0),
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected
                    ? Theme.of(context).primaryColor
                    : Colors.transparent,
                width: 3,
              ),
            ),
            child: CircleAvatar(
              radius: 35,
              backgroundImage: NetworkImage(pet.imageUrl),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            pet.name,
            style: TextStyle(
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected
                  ? Theme.of(context).primaryColor
                  : null,
            ),
          ),
        ],
      ),
    );
  }
}
