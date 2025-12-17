import 'dart:ui';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../services/location_service.dart';
import '../services/pet_service.dart';
import '../models/pet.dart';

class GpsMapPage extends StatefulWidget {
  final PetService petService;
  const GpsMapPage({Key? key, required this.petService}) : super(key: key);

  @override
  State<GpsMapPage> createState() => _GpsMapPageState();
}

class _GpsMapPageState extends State<GpsMapPage> with TickerProviderStateMixin {
  final LocationService _locationService = LocationService();
  late AnimationController _pulseController;
  
  @override
  void initState() {
    super.initState();
    _locationService.addListener(_onLocationChanged);
    _locationService.startTracking();
    
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _locationService.removeListener(_onLocationChanged);
    _locationService.stopTracking();
    _pulseController.dispose();
    super.dispose();
  }

  void _onLocationChanged() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final location = _locationService.currentLocation;
    final selectedPet = widget.petService.pets.isNotEmpty 
        ? widget.petService.selectedPet 
        : null;

    return Scaffold(
      body: Stack(
        children: [
          // Background peta dengan grid
          _buildMapBackground(),
          
          // Location marker
          if (location != null)
            Center(
              child: _buildAnimatedMarker(selectedPet),
            ),
          
          // Header dengan info GPS
          _buildHeader(location),
          
          // Info card di bawah
          if (location != null)
            Positioned(
              bottom: 100,
              left: 20,
              right: 20,
              child: _buildLocationCard(location, selectedPet),
            ),
          
          // Status dan tombol refresh
          Positioned(
            top: 120,
            right: 20,
            child: Column(
              children: [
                _buildStatusBadge(),
                const SizedBox(height: 8),
                FloatingActionButton(
                  mini: true,
                  onPressed: _locationService.fetchLatestLocation,
                  backgroundColor: Theme.of(context).cardColor,
                  child: _locationService.isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Icon(Icons.refresh, color: Theme.of(context).primaryColor),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMapBackground() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFF1a1a2e),
            const Color(0xFF16213e),
            const Color(0xFF0f3460),
          ],
        ),
      ),
      child: CustomPaint(
        painter: GridPainter(),
        child: Container(),
      ),
    );
  }

  Widget _buildHeader(LocationData? location) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black.withOpacity(0.7),
            Colors.transparent,
          ],
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.satellite_alt, color: Colors.greenAccent, size: 28),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'GPS Pet Tracker',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                location != null
                    ? 'Lat: ${location.latitude.toStringAsFixed(4)}, Lng: ${location.longitude.toStringAsFixed(4)}'
                    : 'Menunggu sinyal GPS...',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedMarker(Pet? pet) {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        final scale = 1.0 + (_pulseController.value * 0.3);
        final opacity = 1.0 - _pulseController.value;
        
        return Stack(
          alignment: Alignment.center,
          children: [
            // Pulse effect
            Transform.scale(
              scale: scale,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.greenAccent.withOpacity(opacity * 0.3),
                ),
              ),
            ),
            // Inner pulse
            Transform.scale(
              scale: 1.0 + (_pulseController.value * 0.15),
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.greenAccent.withOpacity(opacity * 0.5),
                ),
              ),
            ),
            // Main marker
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.greenAccent,
                boxShadow: [
                  BoxShadow(
                    color: Colors.greenAccent.withOpacity(0.5),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: pet != null
                  ? ClipOval(
                      child: Image.network(
                        pet.imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Icon(
                          Icons.pets,
                          color: Colors.white,
                          size: 30,
                        ),
                      ),
                    )
                  : const Icon(Icons.pets, color: Colors.white, size: 30),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatusBadge() {
    final isConnected = _locationService.currentLocation != null;
    final hasError = _locationService.error != null;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: hasError
            ? Colors.red.withOpacity(0.8)
            : isConnected
                ? Colors.green.withOpacity(0.8)
                : Colors.orange.withOpacity(0.8),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            hasError
                ? Icons.error_outline
                : isConnected
                    ? Icons.check_circle
                    : Icons.sync,
            color: Colors.white,
            size: 16,
          ),
          const SizedBox(width: 4),
          Text(
            hasError
                ? 'Error'
                : isConnected
                    ? 'Live'
                    : 'Connecting',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationCard(LocationData location, Pet? pet) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.white.withOpacity(0.15),
                Colors.white.withOpacity(0.05),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.2)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  // Pet avatar
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.greenAccent, width: 2),
                    ),
                    child: pet != null
                        ? ClipOval(
                            child: Image.network(
                              pet.imageUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => const Icon(
                                Icons.pets,
                                color: Colors.white,
                              ),
                            ),
                          )
                        : const Icon(Icons.pets, color: Colors.white),
                  ),
                  const SizedBox(width: 12),
                  
                  // Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          pet?.name ?? 'Pet Tracker',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Device: ${location.deviceId}',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Battery
                  Column(
                    children: [
                      Icon(
                        _getBatteryIcon(location.battery),
                        color: _getBatteryColor(location.battery),
                        size: 28,
                      ),
                      Text(
                        '${location.battery.toInt()}%',
                        style: TextStyle(
                          color: _getBatteryColor(location.battery),
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Coordinates
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildCoordItem('LAT', location.latitude.toStringAsFixed(6)),
                    Container(width: 1, height: 30, color: Colors.white24),
                    _buildCoordItem('LNG', location.longitude.toStringAsFixed(6)),
                  ],
                ),
              ),
              
              const SizedBox(height: 12),
              
              // Last update
              Text(
                'Update terakhir: ${_formatTimestamp(location.timestamp)}',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.5),
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCoordItem(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.5),
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontFamily: 'monospace',
          ),
        ),
      ],
    );
  }

  IconData _getBatteryIcon(double level) {
    if (level > 80) return Icons.battery_full;
    if (level > 60) return Icons.battery_5_bar;
    if (level > 40) return Icons.battery_4_bar;
    if (level > 20) return Icons.battery_2_bar;
    return Icons.battery_alert;
  }

  Color _getBatteryColor(double level) {
    if (level > 60) return Colors.greenAccent;
    if (level > 20) return Colors.orange;
    return Colors.red;
  }

  String _formatTimestamp(String timestamp) {
    try {
      final dt = DateTime.parse(timestamp);
      return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}:${dt.second.toString().padLeft(2, '0')}';
    } catch (_) {
      return 'N/A';
    }
  }
}

// Custom painter untuk grid background
class GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.05)
      ..strokeWidth = 1;

    const spacing = 30.0;
    
    // Vertical lines
    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    
    // Horizontal lines
    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
