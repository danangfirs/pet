import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/location_service.dart';

class GpsStatisticsPage extends StatefulWidget {
  const GpsStatisticsPage({Key? key}) : super(key: key);

  @override
  State<GpsStatisticsPage> createState() => _GpsStatisticsPageState();
}

class _GpsStatisticsPageState extends State<GpsStatisticsPage> {
  final LocationService _locationService = LocationService();
  bool _isLoading = true;
  
  // Statistics
  double _totalDistance = 0;
  double _avgSpeed = 0;
  double _maxSpeed = 0;
  int _activeMinutes = 0;
  int _restMinutes = 0;
  List<double> _dailyDistances = [];
  List<double> _hourlyActivity = [];
  
  @override
  void initState() {
    super.initState();
    _loadStatistics();
  }
  
  Future<void> _loadStatistics() async {
    setState(() => _isLoading = true);
    
    await _locationService.fetchLocationHistory(results: 500);
    _calculateStatistics();
    
    setState(() => _isLoading = false);
  }
  
  void _calculateStatistics() {
    final history = _locationService.locationHistory;
    
    if (history.isEmpty) {
      return;
    }
    
    // Calculate total distance using Haversine formula
    double totalDist = 0;
    List<double> speeds = [];
    
    for (int i = 0; i < history.length - 1; i++) {
      final p1 = history[i];
      final p2 = history[i + 1];
      
      // Calculate distance between consecutive points
      final dist = _haversineDistance(
        p1.latitude, p1.longitude,
        p2.latitude, p2.longitude,
      );
      
      totalDist += dist;
      speeds.add(p1.speed);
    }
    
    // Add last point's speed
    if (history.isNotEmpty) {
      speeds.add(history.last.speed);
    }
    
    // Calculate statistics
    _totalDistance = totalDist;
    _avgSpeed = speeds.isEmpty ? 0 : speeds.reduce((a, b) => a + b) / speeds.length;
    _maxSpeed = speeds.isEmpty ? 0 : speeds.reduce((a, b) => a > b ? a : b);
    
    // Calculate active/rest time (speed > 0.5 km/h = active)
    _activeMinutes = speeds.where((s) => s > 0.5).length * 20 ~/ 60; // Assuming 20 sec intervals
    _restMinutes = speeds.where((s) => s <= 0.5).length * 20 ~/ 60;
    
    // Calculate daily distances (last 7 days)
    _dailyDistances = _calculateDailyDistances(history);
    
    // Calculate hourly activity pattern (24 hours)
    _hourlyActivity = _calculateHourlyActivity(history);
  }
  
  // Haversine formula to calculate distance between two GPS points
  double _haversineDistance(double lat1, double lon1, double lat2, double lon2) {
    const R = 6371.0; // Earth's radius in km
    
    final dLat = _toRadians(lat2 - lat1);
    final dLon = _toRadians(lon2 - lon1);
    
    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_toRadians(lat1)) * math.cos(_toRadians(lat2)) *
        math.sin(dLon / 2) * math.sin(dLon / 2);
    
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    
    return R * c;
  }
  
  double _toRadians(double degree) {
    return degree * math.pi / 180;
  }
  
  List<double> _calculateDailyDistances(List<LocationData> history) {
    // Group by day and sum distances
    final Map<int, double> dailyDist = {};
    final now = DateTime.now();
    
    for (int i = 0; i < 7; i++) {
      dailyDist[i] = 0;
    }
    
    for (int i = 0; i < history.length - 1; i++) {
      try {
        final timestamp = DateTime.parse(history[i].timestamp);
        final daysAgo = now.difference(timestamp).inDays;
        
        if (daysAgo >= 0 && daysAgo < 7) {
          final dist = _haversineDistance(
            history[i].latitude, history[i].longitude,
            history[i + 1].latitude, history[i + 1].longitude,
          );
          dailyDist[daysAgo] = (dailyDist[daysAgo] ?? 0) + dist;
        }
      } catch (_) {}
    }
    
    return List.generate(7, (i) => dailyDist[6 - i] ?? 0);
  }
  
  List<double> _calculateHourlyActivity(List<LocationData> history) {
    final Map<int, int> hourlyCount = {};
    
    for (int i = 0; i < 24; i++) {
      hourlyCount[i] = 0;
    }
    
    for (final loc in history) {
      try {
        final timestamp = DateTime.parse(loc.timestamp);
        hourlyCount[timestamp.hour] = (hourlyCount[timestamp.hour] ?? 0) + 1;
      } catch (_) {}
    }
    
    final maxCount = hourlyCount.values.reduce((a, b) => a > b ? a : b);
    
    return List.generate(24, (i) {
      if (maxCount == 0) return 0.0;
      return (hourlyCount[i] ?? 0) / maxCount;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('GPS Statistics', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadStatistics,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadStatistics,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Quick Stats Cards
                  _buildQuickStats(),
                  const SizedBox(height: 24),
                  
                  // Distance Chart
                  _buildDistanceChart(),
                  const SizedBox(height: 24),
                  
                  // Activity Time
                  _buildActivityTime(),
                  const SizedBox(height: 24),
                  
                  // Hourly Activity Pattern
                  _buildHourlyPattern(),
                  const SizedBox(height: 24),
                  
                  // Speed Stats
                  _buildSpeedStats(),
                ],
              ),
            ),
    );
  }

  Widget _buildQuickStats() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.5,
      children: [
        _buildStatCard(
          'Jarak Total',
          '${_totalDistance.toStringAsFixed(2)} km',
          Icons.route,
          Colors.blue,
        ),
        _buildStatCard(
          'Kecepatan Rata-rata',
          '${_avgSpeed.toStringAsFixed(1)} km/h',
          Icons.speed,
          Colors.orange,
        ),
        _buildStatCard(
          'Kecepatan Max',
          '${_maxSpeed.toStringAsFixed(1)} km/h',
          Icons.flash_on,
          Colors.red,
        ),
        _buildStatCard(
          'Data Points',
          '${_locationService.locationHistory.length}',
          Icons.data_usage,
          Colors.purple,
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[400],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDistanceChart() {
    final maxY = _dailyDistances.isEmpty 
        ? 1.0 
        : _dailyDistances.reduce((a, b) => a > b ? a : b) * 1.2;
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.show_chart, color: Colors.blue),
              SizedBox(width: 8),
              Text(
                'Jarak 7 Hari Terakhir',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: maxY,
                barTouchData: BarTouchData(
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      return BarTooltipItem(
                        '${rod.toY.toStringAsFixed(2)} km',
                        const TextStyle(color: Colors.white),
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final days = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];
                        final now = DateTime.now();
                        final dayIndex = (now.weekday - 7 + value.toInt()) % 7;
                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            days[dayIndex < 0 ? dayIndex + 7 : dayIndex],
                            style: const TextStyle(fontSize: 11, color: Colors.grey),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                gridData: const FlGridData(show: false),
                barGroups: List.generate(7, (i) {
                  return BarChartGroupData(
                    x: i,
                    barRods: [
                      BarChartRodData(
                        toY: _dailyDistances.length > i ? _dailyDistances[i] : 0,
                        gradient: LinearGradient(
                          colors: [Colors.blue[300]!, Colors.blue[600]!],
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                        ),
                        width: 20,
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                      ),
                    ],
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityTime() {
    final totalMinutes = _activeMinutes + _restMinutes;
    final activePercent = totalMinutes > 0 ? _activeMinutes / totalMinutes : 0.0;
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.timer, color: Colors.green),
              SizedBox(width: 8),
              Text(
                'Waktu Aktif vs Istirahat',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              // Pie Chart
              SizedBox(
                width: 120,
                height: 120,
                child: PieChart(
                  PieChartData(
                    sectionsSpace: 2,
                    centerSpaceRadius: 30,
                    sections: [
                      PieChartSectionData(
                        value: _activeMinutes.toDouble(),
                        color: Colors.green,
                        title: '',
                        radius: 25,
                      ),
                      PieChartSectionData(
                        value: _restMinutes.toDouble(),
                        color: Colors.grey[600],
                        title: '',
                        radius: 25,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 24),
              // Legend
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildActivityRow(
                      'Aktif',
                      '${_activeMinutes} menit',
                      Colors.green,
                      '${(activePercent * 100).toStringAsFixed(0)}%',
                    ),
                    const SizedBox(height: 12),
                    _buildActivityRow(
                      'Istirahat',
                      '${_restMinutes} menit',
                      Colors.grey[600]!,
                      '${((1 - activePercent) * 100).toStringAsFixed(0)}%',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActivityRow(String label, String value, Color color, String percent) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(color: Colors.grey[400], fontSize: 12)),
              Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
        ),
        Text(percent, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildHourlyPattern() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.access_time, color: Colors.orange),
              SizedBox(width: 8),
              Text(
                'Pola Aktivitas per Jam',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 80,
            child: Row(
              children: List.generate(24, (hour) {
                final activity = _hourlyActivity.length > hour ? _hourlyActivity[hour] : 0.0;
                return Expanded(
                  child: Column(
                    children: [
                      Expanded(
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 1),
                          decoration: BoxDecoration(
                            color: Color.lerp(
                              Colors.grey[800],
                              Colors.orange,
                              activity,
                            ),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      if (hour % 6 == 0)
                        Text(
                          '${hour.toString().padLeft(2, '0')}',
                          style: TextStyle(fontSize: 8, color: Colors.grey[500]),
                        )
                      else
                        const SizedBox(height: 10),
                    ],
                  ),
                );
              }),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(width: 12, height: 12, color: Colors.grey[800]),
              const SizedBox(width: 4),
              Text('Rendah', style: TextStyle(fontSize: 10, color: Colors.grey[500])),
              const SizedBox(width: 16),
              Container(width: 12, height: 12, color: Colors.orange),
              const SizedBox(width: 4),
              Text('Tinggi', style: TextStyle(fontSize: 10, color: Colors.grey[500])),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSpeedStats() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.purple[900]!, Colors.blue[900]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          const Row(
            children: [
              Icon(Icons.speed, color: Colors.white),
              SizedBox(width: 8),
              Text(
                'Speed Analysis',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildSpeedItem('Avg', _avgSpeed, Colors.blue[300]!),
              Container(width: 1, height: 50, color: Colors.white24),
              _buildSpeedItem('Max', _maxSpeed, Colors.orange[300]!),
              Container(width: 1, height: 50, color: Colors.white24),
              _buildSpeedItem('Current', 
                  _locationService.currentLocation?.speed ?? 0, Colors.green[300]!),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSpeedItem(String label, double value, Color color) {
    return Column(
      children: [
        Text(
          '${value.toStringAsFixed(1)}',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const Text(
          'km/h',
          style: TextStyle(fontSize: 12, color: Colors.white54),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 14, color: Colors.white70),
        ),
      ],
    );
  }
}
