import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'activity_monitoring_page.dart';
import 'health_tracking_page.dart';

class AnalyticsDashboardPage extends StatelessWidget {
  const AnalyticsDashboardPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics Dashboard',
            style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () {
              _showExportDialog(context);
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Quick Stats Overview
          _buildQuickStats(context),
          const SizedBox(height: 24),

          // Activity Overview
          _buildSectionHeader(
            context,
            'Ringkasan Aktivitas',
            Icons.trending_up,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const ActivityMonitoringPage()),
              );
            },
          ),
          const SizedBox(height: 16),
          _buildActivityOverview(context),
          const SizedBox(height: 24),

          // Health Overview
          _buildSectionHeader(
            context,
            'Ringkasan Kesehatan',
            Icons.favorite,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const HealthTrackingPage()),
              );
            },
          ),
          const SizedBox(height: 16),
          _buildHealthOverview(context),
          const SizedBox(height: 24),

          // Comparison Chart
          _buildComparisonChart(context),
          const SizedBox(height: 24),

          // Heatmap
          _buildHeatmap(context),
          const SizedBox(height: 24),

          // Weekly Summary
          _buildWeeklySummary(context),
          const SizedBox(height: 24),

          // Insights & Recommendations
          _buildInsights(context),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(
    BuildContext context,
    String title,
    IconData icon, {
    VoidCallback? onTap,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(icon, color: Theme.of(context).primaryColor),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        if (onTap != null)
          TextButton(
            onPressed: onTap,
            child: Row(
              children: [
                Text(
                  'Lihat Detail',
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(Icons.arrow_forward,
                    color: Theme.of(context).primaryColor, size: 16),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildQuickStats(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.5,
      children: [
        _buildStatCard(
          context,
          'Total Aktivitas',
          '156 jam',
          Icons.directions_run,
          Colors.blue,
          '+12%',
        ),
        _buildStatCard(
          context,
          'Jarak Total',
          '142 km',
          Icons.route,
          Colors.orange,
          '+8%',
        ),
        _buildStatCard(
          context,
          'Kalori Terbakar',
          '4,850 kcal',
          Icons.local_fire_department,
          Colors.red,
          '+15%',
        ),
        _buildStatCard(
          context,
          'Skor Kesehatan',
          '85/100',
          Icons.favorite,
          Colors.pink,
          '+3%',
        ),
      ],
    );
  }

  Widget _buildStatCard(BuildContext context, String title, String value,
      IconData icon, Color color, String change) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: color, size: 28),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  change,
                  style: const TextStyle(
                    color: Colors.green,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActivityOverview(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Aktivitas 7 Hari Terakhir',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 150,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 2,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: Colors.white.withOpacity(0.1),
                      strokeWidth: 1,
                    );
                  },
                ),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 25,
                      interval: 1,
                      getTitlesWidget: (double value, TitleMeta meta) {
                        const days = ['S', 'S', 'R', 'K', 'J', 'S', 'M'];
                        if (value.toInt() >= 0 && value.toInt() < days.length) {
                          return Text(
                            days[value.toInt()],
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                            ),
                          );
                        }
                        return const Text('');
                      },
                    ),
                  ),
                  leftTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                borderData: FlBorderData(show: false),
                minX: 0,
                maxX: 6,
                minY: 0,
                maxY: 8,
                lineBarsData: [
                  LineChartBarData(
                    spots: const [
                      FlSpot(0, 3),
                      FlSpot(1, 4.5),
                      FlSpot(2, 3.8),
                      FlSpot(3, 5.5),
                      FlSpot(4, 4.2),
                      FlSpot(5, 6.5),
                      FlSpot(6, 5.8),
                    ],
                    isCurved: true,
                    gradient: LinearGradient(
                      colors: [
                        Theme.of(context).primaryColor,
                        Colors.blue,
                      ],
                    ),
                    barWidth: 3,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          Theme.of(context).primaryColor.withOpacity(0.3),
                          Theme.of(context).primaryColor.withOpacity(0.0),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHealthOverview(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).primaryColor,
                  Colors.blue,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                const Text(
                  'Skor Kesehatan',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),
                Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 100,
                      height: 100,
                      child: CircularProgressIndicator(
                        value: 0.85,
                        strokeWidth: 10,
                        backgroundColor: Colors.white.withOpacity(0.3),
                        valueColor:
                            const AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                    const Column(
                      children: [
                        Text(
                          '85',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        Text(
                          'Sangat Sehat',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 3,
          child: Column(
            children: [
              _buildHealthMetric(
                  context, 'Berat Badan', '12.5 kg', 'Normal', Colors.green),
              const SizedBox(height: 8),
              _buildHealthMetric(context, 'Vaksinasi', '2 Upcoming',
                  '25 hari lagi', Colors.orange),
              const SizedBox(height: 8),
              _buildHealthMetric(
                  context, 'Check-up', 'Terjadwal', '15 Nov', Colors.blue),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHealthMetric(BuildContext context, String title, String value,
      String subtitle, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.check_circle, color: color, size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Colors.grey,
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 10,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComparisonChart(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Perbandingan Mingguan',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  children: [
                    Text('vs Minggu Lalu', style: TextStyle(fontSize: 11)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: 100,
                barTouchData: BarTouchData(enabled: false),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (double value, TitleMeta meta) {
                        const categories = ['Aktivitas', 'Jarak', 'Kalori', 'Tidur'];
                        if (value.toInt() >= 0 &&
                            value.toInt() < categories.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              categories[value.toInt()],
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 11,
                              ),
                            ),
                          );
                        }
                        return const Text('');
                      },
                      reservedSize: 35,
                    ),
                  ),
                  leftTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 25,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: Colors.white.withOpacity(0.1),
                      strokeWidth: 1,
                    );
                  },
                ),
                borderData: FlBorderData(show: false),
                barGroups: [
                  _buildComparisonBarGroup(0, 75, 85),
                  _buildComparisonBarGroup(1, 70, 80),
                  _buildComparisonBarGroup(2, 65, 78),
                  _buildComparisonBarGroup(3, 80, 75),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLegend('Minggu Lalu', Colors.grey.withOpacity(0.5)),
              const SizedBox(width: 16),
              _buildLegend(
                  'Minggu Ini', Theme.of(context).primaryColor),
            ],
          ),
        ],
      ),
    );
  }

  BarChartGroupData _buildComparisonBarGroup(int x, double y1, double y2) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y1,
          color: Colors.grey.withOpacity(0.5),
          width: 15,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
        ),
        BarChartRodData(
          toY: y2,
          gradient: const LinearGradient(
            colors: [Color(0xFF00F5D4), Colors.blue],
          ),
          width: 15,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
        ),
      ],
      barsSpace: 4,
    );
  }

  Widget _buildLegend(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildHeatmap(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Heatmap Aktivitas',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Pola aktivitas per jam',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildHeatmapColumn('00:00', [0.2, 0.3, 0.1, 0.2, 0.3, 0.2, 0.1]),
              _buildHeatmapColumn('04:00', [0.1, 0.1, 0.2, 0.1, 0.2, 0.1, 0.2]),
              _buildHeatmapColumn('08:00', [0.6, 0.7, 0.8, 0.9, 0.7, 0.8, 0.9]),
              _buildHeatmapColumn('12:00', [0.8, 0.9, 0.7, 0.8, 0.9, 0.8, 0.7]),
              _buildHeatmapColumn('16:00', [0.9, 0.8, 0.9, 0.7, 0.8, 0.9, 0.8]),
              _buildHeatmapColumn('20:00', [0.5, 0.6, 0.4, 0.5, 0.6, 0.5, 0.4]),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text('Sen', style: TextStyle(fontSize: 10, color: Colors.grey)),
              Text('Sel', style: TextStyle(fontSize: 10, color: Colors.grey)),
              Text('Rab', style: TextStyle(fontSize: 10, color: Colors.grey)),
              Text('Kam', style: TextStyle(fontSize: 10, color: Colors.grey)),
              Text('Jum', style: TextStyle(fontSize: 10, color: Colors.grey)),
              Text('Sab', style: TextStyle(fontSize: 10, color: Colors.grey)),
              Text('Min', style: TextStyle(fontSize: 10, color: Colors.grey)),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Rendah', style: TextStyle(fontSize: 10, color: Colors.grey)),
              const SizedBox(width: 8),
              ...List.generate(
                5,
                (index) => Container(
                  width: 20,
                  height: 12,
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  decoration: BoxDecoration(
                    color: Color.lerp(
                      Colors.blue.withOpacity(0.2),
                      const Color(0xFF00F5D4),
                      index / 4,
                    ),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              const Text('Tinggi', style: TextStyle(fontSize: 10, color: Colors.grey)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeatmapColumn(String time, List<double> values) {
    return Column(
      children: [
        Text(
          time,
          style: const TextStyle(
            fontSize: 9,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 8),
        ...values.map((value) => Container(
              width: 35,
              height: 12,
              margin: const EdgeInsets.only(bottom: 4),
              decoration: BoxDecoration(
                color: Color.lerp(
                  Colors.blue.withOpacity(0.2),
                  const Color(0xFF00F5D4),
                  value,
                ),
                borderRadius: BorderRadius.circular(2),
              ),
            )),
      ],
    );
  }

  Widget _buildWeeklySummary(BuildContext context) {
    final summaries = [
      {
        'day': 'Senin',
        'activity': '3.5 jam',
        'distance': '6.2 km',
        'status': 'good'
      },
      {
        'day': 'Selasa',
        'activity': '4.2 jam',
        'distance': '7.5 km',
        'status': 'excellent'
      },
      {
        'day': 'Rabu',
        'activity': '2.8 jam',
        'distance': '4.8 km',
        'status': 'low'
      },
      {
        'day': 'Kamis',
        'activity': '5.0 jam',
        'distance': '8.2 km',
        'status': 'excellent'
      },
      {
        'day': 'Jumat',
        'activity': '3.8 jam',
        'distance': '6.0 km',
        'status': 'good'
      },
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Ringkasan Mingguan',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ...summaries.map((summary) => _buildDaySummaryItem(
                context,
                summary['day'] as String,
                summary['activity'] as String,
                summary['distance'] as String,
                summary['status'] as String,
              )),
        ],
      ),
    );
  }

  Widget _buildDaySummaryItem(BuildContext context, String day,
      String activity, String distance, String status) {
    Color statusColor;
    String statusText;
    IconData statusIcon;

    switch (status) {
      case 'excellent':
        statusColor = Colors.green;
        statusText = 'Excellent';
        statusIcon = Icons.sentiment_very_satisfied;
        break;
      case 'good':
        statusColor = Colors.blue;
        statusText = 'Good';
        statusIcon = Icons.sentiment_satisfied;
        break;
      case 'low':
        statusColor = Colors.orange;
        statusText = 'Low';
        statusIcon = Icons.sentiment_neutral;
        break;
      default:
        statusColor = Colors.grey;
        statusText = 'N/A';
        statusIcon = Icons.help;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            alignment: Alignment.centerLeft,
            child: Text(
              day,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            child: Row(
              children: [
                Icon(Icons.access_time, size: 14, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  activity,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(width: 12),
                Icon(Icons.route, size: 14, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  distance,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(statusIcon, size: 14, color: statusColor),
                const SizedBox(width: 4),
                Text(
                  statusText,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInsights(BuildContext context) {
    final insights = [
      {
        'icon': Icons.trending_up,
        'color': Colors.green,
        'title': 'Peningkatan Aktivitas',
        'description':
            'Milo 15% lebih aktif minggu ini dibanding minggu lalu. Pertahankan!',
      },
      {
        'icon': Icons.warning,
        'color': Colors.orange,
        'title': 'Perhatian Pola Tidur',
        'description':
            'Pola tidur Milo sedikit tidak teratur. Pertimbangkan jadwal lebih konsisten.',
      },
      {
        'icon': Icons.lightbulb,
        'color': Colors.blue,
        'title': 'Rekomendasi',
        'description':
            'Waktu terbaik untuk jalan-jalan adalah pukul 08:00-10:00 berdasarkan pola aktivitas.',
      },
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Insights & Rekomendasi',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ...insights.map((insight) => Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: (insight['color'] as Color).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: (insight['color'] as Color).withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: (insight['color'] as Color).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        insight['icon'] as IconData,
                        color: insight['color'] as Color,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            insight['title'] as String,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            insight['description'] as String,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.withOpacity(0.9),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  void _showExportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).cardColor,
        title: const Text('Export Data'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.picture_as_pdf, color: Colors.red),
              title: const Text('Export ke PDF'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Exporting to PDF...')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.table_chart, color: Colors.green),
              title: const Text('Export ke Excel'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Exporting to Excel...')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.share, color: Colors.blue),
              title: const Text('Share Report'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Sharing report...')),
                );
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
        ],
      ),
    );
  }
}

