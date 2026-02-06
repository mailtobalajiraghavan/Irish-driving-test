import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/user_provider.dart';

class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final tests = userProvider.recentTests;
    
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          "My Progress",
          style: GoogleFonts.poppins(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Stats Cards
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    "Tests Taken",
                    "${userProvider.testHistory.length}",
                    Icons.assignment_rounded,
                    Colors.blue,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    "Best Score",
                    "${userProvider.bestMockScore}/40",
                    Icons.emoji_events_rounded,
                    Colors.amber,
                  ),
                ),
              ],
            ).animate().fadeIn().slideY(begin: -0.1, end: 0),
            
            const SizedBox(height: 12),
            
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    "Perfect 40/40",
                    "${userProvider.perfectScoreCount}x",
                    Icons.star_rounded,
                    Colors.green,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    "Current Level",
                    "Lv. ${userProvider.level}",
                    Icons.trending_up_rounded,
                    Colors.purple,
                  ),
                ),
              ],
            ).animate().fadeIn(delay: 100.ms).slideY(begin: -0.1, end: 0),
            
            const SizedBox(height: 24),
            
            // Score Graph
            Text(
              "Score History",
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            
            Container(
              height: 250,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: tests.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.bar_chart_rounded, 
                              size: 48, color: Colors.grey[300]),
                          const SizedBox(height: 12),
                          Text(
                            "No test data yet",
                            style: GoogleFonts.poppins(color: Colors.grey[500]),
                          ),
                          Text(
                            "Complete a mock test to see your progress",
                            style: GoogleFonts.poppins(
                              fontSize: 12, 
                              color: Colors.grey[400],
                            ),
                          ),
                        ],
                      ),
                    )
                  : LineChart(
                      LineChartData(
                        gridData: FlGridData(
                          show: true,
                          drawVerticalLine: false,
                          horizontalInterval: 10,
                          getDrawingHorizontalLine: (value) => FlLine(
                            color: Colors.grey[200]!,
                            strokeWidth: 1,
                          ),
                        ),
                        titlesData: FlTitlesData(
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 40,
                              interval: 10,
                              getTitlesWidget: (value, meta) => Text(
                                value.toInt().toString(),
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 30,
                              getTitlesWidget: (value, meta) {
                                if (value.toInt() >= tests.length) return const SizedBox();
                                return Text(
                                  "#${value.toInt() + 1}",
                                  style: GoogleFonts.poppins(
                                    fontSize: 10,
                                    color: Colors.grey[500],
                                  ),
                                );
                              },
                            ),
                          ),
                          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        ),
                        borderData: FlBorderData(show: false),
                        minX: 0,
                        maxX: (tests.length - 1).toDouble().clamp(0, double.infinity),
                        minY: 0,
                        maxY: 40,
                        lineBarsData: [
                          // Pass line at 35
                          LineChartBarData(
                            spots: [
                              FlSpot(0, 35),
                              FlSpot((tests.length - 1).toDouble().clamp(0, double.infinity), 35),
                            ],
                            isCurved: false,
                            color: Colors.green.withOpacity(0.3),
                            barWidth: 2,
                            dotData: const FlDotData(show: false),
                            dashArray: [5, 5],
                          ),
                          // Actual scores
                          LineChartBarData(
                            spots: tests.asMap().entries.map((e) => 
                              FlSpot(e.key.toDouble(), e.value.score.toDouble())
                            ).toList(),
                            isCurved: true,
                            color: Colors.blue,
                            barWidth: 3,
                            dotData: FlDotData(
                              show: true,
                              getDotPainter: (spot, percent, barData, index) =>
                                FlDotCirclePainter(
                                  radius: 5,
                                  color: tests[index].score >= 35 
                                      ? Colors.green 
                                      : Colors.orange,
                                  strokeWidth: 2,
                                  strokeColor: Colors.white,
                                ),
                            ),
                            belowBarData: BarAreaData(
                              show: true,
                              color: Colors.blue.withOpacity(0.1),
                            ),
                          ),
                        ],
                      ),
                    ),
            ).animate().fadeIn(delay: 200.ms).scale(begin: const Offset(0.95, 0.95)),
            
            const SizedBox(height: 16),
            
            // Legend
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildLegendItem(Colors.green, "Pass (35+)"),
                const SizedBox(width: 24),
                _buildLegendItem(Colors.orange, "Needs Practice"),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Module Completion
            Text(
              "Module Progress",
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            
            _buildModuleProgress(userProvider),
            
            const SizedBox(height: 24),
            
            // Clear Wrong Questions Button
            if (userProvider.wrongQuestions.isNotEmpty) ...[
              Text(
                "Reset Options",
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.delete_outline, 
                          color: Colors.red, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Clear Wrong Questions",
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w500,
                              color: Colors.black87,
                            ),
                          ),
                          Text(
                            "${userProvider.wrongQuestions.length} questions tracked",
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: Text(
                              "Clear All Wrong Questions?",
                              style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                            ),
                            content: Text(
                              "This will remove all ${userProvider.wrongQuestions.length} questions from your review list. This action cannot be undone.",
                              style: GoogleFonts.poppins(),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(ctx),
                                child: Text("Cancel", style: GoogleFonts.poppins()),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  Provider.of<UserProvider>(context, listen: false)
                                      .clearAllWrongQuestions();
                                  Navigator.pop(ctx);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        "Wrong questions cleared!",
                                        style: GoogleFonts.poppins(),
                                      ),
                                    ),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                ),
                                child: Text("Clear All", style: GoogleFonts.poppins(color: Colors.white)),
                              ),
                            ],
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text("Clear", style: GoogleFonts.poppins(color: Colors.white)),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildModuleProgress(UserProvider userProvider) {
    final modules = [
      {'key': 'fines', 'name': 'Fines', 'icon': Icons.gavel_rounded, 'color': Colors.red},
      {'key': 'numbers', 'name': 'Numbers', 'icon': Icons.confirmation_number_rounded, 'color': Colors.blue},
      {'key': 'roadSigns', 'name': 'Road Signs', 'icon': Icons.traffic_rounded, 'color': Colors.purple},
      {'key': 'mockTest', 'name': 'Mock Test', 'icon': Icons.play_arrow_rounded, 'color': Colors.green},
      {'key': 'wrongAnswers', 'name': 'Mistakes', 'icon': Icons.error_outline_rounded, 'color': Colors.orange},
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: modules.map((m) {
          final isComplete = userProvider.moduleCompleted[m['key']] == true;
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: (m['color'] as Color).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(m['icon'] as IconData, 
                      color: m['color'] as Color, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    m['name'] as String,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                ),
                isComplete
                    ? Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.green[50],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.check_circle, 
                                color: Colors.green[700], size: 16),
                            const SizedBox(width: 4),
                            Text(
                              "Done",
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: Colors.green[700],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      )
                    : Text(
                        "Pending",
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.grey[400],
                        ),
                      ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
