import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/quiz_provider.dart';
import '../providers/user_provider.dart';
import 'quiz_screen.dart';

class TrainingZoneScreen extends StatelessWidget {
  const TrainingZoneScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          "Training Zone",
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // SECTION 1: ARCADE MODES
              _buildSectionHeader("Arcade Modes", Icons.gamepad_rounded, Colors.orange),
              const SizedBox(height: 16),
              _buildCard(
                context,
                title: "Quick Mode",
                icon: Icons.bolt_rounded,
                color: Colors.amber[800]!,
                description: "20 random questions for a quick refresh.",
                onTap: () => _navigateToQuiz(context, QuizMode.quick),
              ),
              const SizedBox(height: 12),
              _buildCard(
                context,
                title: "Blitz Mode",
                icon: Icons.flash_on_rounded,
                color: Colors.yellow[800]!,
                description: "10 rapid-fire questions. Done in 2 minutes!",
                onTap: () => _navigateToQuiz(context, QuizMode.blitz),
              ),
              const SizedBox(height: 12),
              _buildCard(
                context,
                title: "Sudden Death",
                icon: Icons.dangerous_rounded,
                color: Colors.deepOrangeAccent,
                description: "Keep going until you get one wrong. High stakes!",
                onTap: () => _navigateToQuiz(context, QuizMode.suddenDeath),
              ),

              const SizedBox(height: 32),

              // SECTION 2: FOCUS AREAS
              _buildSectionHeader("Focus Areas", Icons.filter_center_focus_rounded, Colors.blue),
              const SizedBox(height: 16),
              _buildCard(
                context,
                title: "Wrong Questions",
                icon: Icons.error_outline_rounded,
                color: Colors.redAccent,
                description: "Review questions you answered incorrectly.",
                onTap: () {
                  if (userProvider.wrongQuestions.isNotEmpty) {
                    _navigateToQuiz(context, QuizMode.wrongAnswers);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("No wrong answers yet! Great job!")),
                    );
                  }
                },
              ),
              const SizedBox(height: 12),
              _buildCard(
                context,
                title: "Road Signs",
                icon: Icons.traffic_rounded,
                color: Colors.purpleAccent,
                description: "Master all road signs and categories.",
                onTap: () => _navigateToQuiz(context, QuizMode.roadSigns),
              ),
              const SizedBox(height: 12),
              _buildCard(
                context,
                title: "Fines & Points",
                icon: Icons.gavel_rounded,
                color: const Color(0xFF8B0000),
                description: "Drill questions about fines and penalty points.",
                onTap: () => _navigateToQuiz(context, QuizMode.fines),
              ),
              const SizedBox(height: 12),
              _buildCard(
                context,
                title: "Numbers",
                icon: Icons.confirmation_number_rounded,
                color: Colors.blueAccent,
                description: "Focus on stopping distances and numerical facts.",
                onTap: () => _navigateToQuiz(context, QuizMode.numbers),
              ),
              
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToQuiz(BuildContext context, QuizMode mode) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => QuizScreen(mode: mode)),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    required String description,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.1), width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Colors.grey[400]),
          ],
        ),
      ),
    )
    .animate()
    .fadeIn(duration: 400.ms)
    .slideX(begin: 0.1, duration: 400.ms, curve: Curves.easeOut);
  }
}
