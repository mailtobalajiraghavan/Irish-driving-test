import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/user_provider.dart';
import '../providers/quiz_provider.dart';
import '../widgets/xp_bar.dart';
import 'quiz_screen.dart';
import 'revision_screen.dart';
import 'learning_path_screen.dart';
import 'progress_screen.dart';
import 'training_zone_screen.dart';

class HomeScreen extends StatefulWidget {
  // Rebuild trigger
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Preload questions when app starts/home loads
    Future.microtask(() => 
      Provider.of<QuizProvider>(context, listen: false).loadQuestions()
    );
  }

  // Dynamic time-based greeting
  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return "Good morning";
    if (hour < 17) return "Good afternoon";
    return "Good evening";
  }
  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8F9), // Light grey/blue tint
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            // 1. Green Welcome Header
            _buildWelcomeHeader(userProvider),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                   const SizedBox(height: 20),
                   // 2. Mastery Challenge Card
                   _buildMasteryChallengeCard(context, userProvider),
                   
                   const SizedBox(height: 20),
                   
                   // 3. Feature Grid (2x2)
                   _buildFeatureGrid(context),
                   
                   const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeHeader(UserProvider userProvider) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 60, 24, 30), // Top padding for status bar
      decoration: const BoxDecoration(
        color: Color(0xFF00897B), // Teal 600
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Row(
        children: [
          // Car Icon Circle
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: const Text("🚗", style: TextStyle(fontSize: 24)),
          ),
          const SizedBox(width: 16),
          
          // Welcome Text
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getGreeting(),
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.teal[50], // Light teal
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  "Welcome back!", 
                  style: GoogleFonts.poppins(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          
          // Level Pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFFFC107), // Amber
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              "LVL ${userProvider.level}",
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                fontSize: 12,
                color: Colors.black87,
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Progress Icon
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (c) => const ProgressScreen())),
              icon: const Icon(Icons.bar_chart_rounded, color: Colors.white),
              tooltip: "My Progress",
              constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
              iconSize: 20,
              padding: EdgeInsets.zero,
            ),
          ),
        ],
      ),
    ).animate().fadeIn().slideY(begin: -0.2);
  }

  Widget _buildMasteryChallengeCard(BuildContext context, UserProvider userProvider) {
    final nextStepKey = userProvider.getNextStep();
    final steps = [
      {'key': 'fines', 'label': 'Fines', 'icon': Icons.request_quote_rounded, 'color': const Color(0xFF009688)},
      {'key': 'numbers', 'label': 'Numbers', 'icon': Icons.format_list_numbered_rounded, 'color': const Color(0xFF009688)},
      {'key': 'roadSigns', 'label': 'Signs', 'icon': Icons.directions_rounded, 'color': const Color(0xFF009688)},
      {'key': 'mockTest', 'label': 'Mock', 'icon': Icons.assignment_turned_in_rounded, 'color': const Color(0xFF009688)},
      {'key': 'wrongAnswers', 'label': 'Review', 'icon': Icons.history_rounded, 'color': const Color(0xFF009688)},
    ];

    return Container(
      clipBehavior: Clip.none,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "40/40 Mastery Challenge",
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      "Complete all 5 steps for test readiness",
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFE0F2F1), // Teal 50
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  "${userProvider.shortcutProgress} / 5",
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF00695C), // Teal 800
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Icons Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(steps.length, (index) {
              final step = steps[index];
              final isComplete = userProvider.isModuleComplete(step['key'] as String);
              final isNext = nextStepKey == step['key'];
              
              Color bgColor = Colors.grey[100]!;
              Color iconColor = Colors.grey[400]!;
              
              if (isComplete || isNext) {
                bgColor = (step['color'] as Color).withOpacity(0.1); // Light tint
                iconColor = step['color'] as Color; // Full color
                if (isComplete) {
                   bgColor = step['color'] as Color;
                   iconColor = Colors.white;
                }
              }

              return Expanded(
                child: Column(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: bgColor,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        step['icon'] as IconData,
                        size: 20,
                        color: iconColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      step['label'] as String,
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: (isComplete || isNext) ? Colors.teal[800] : Colors.grey[400],
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
          
          const SizedBox(height: 24),
          
          // Progress Road
          ProgressRoad(
            backgroundColor: Colors.grey[200],
            progressColor: const Color(0xFF00897B), // Teal
          ),
          
          const SizedBox(height: 24),
          
          // Next Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: nextStepKey == null ? null : () => _handleNextStep(context, nextStepKey),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00897B),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                   Text(
                    nextStepKey == null ? "Goal Achieved!" : "Next: ${_getStepLabel(nextStepKey)}",
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    nextStepKey == null ? Icons.celebration_rounded : Icons.arrow_forward_rounded,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.1);
  }

  Widget _buildFeatureGrid(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 0.85,
      children: [
        _buildFeatureCard(
          context,
          title: "Learning Path",
          description: "Guided journey through all driving topics.",
          icon: Icons.alt_route_rounded,
          color: const Color(0xFF26A69A), // Teal
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (c) => const LearningPathScreen())),
        ),
        _buildFeatureCard(
          context,
          title: "Mock Test",
          description: "Full 40-question standard test simulation.",
          icon: Icons.play_arrow_rounded,
          color: const Color(0xFF66BB6A), // Green
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (c) => const QuizScreen(mode: QuizMode.standard))),
        ),
        _buildFeatureCard(
          context,
          title: "All Questions",
          description: "Browse and revise the complete question bank.",
          icon: Icons.menu_book_rounded,
          color: const Color(0xFF5C6BC0), // Indigo
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (c) => const RevisionScreen())),
        ),
        _buildFeatureCard(
          context,
          title: "Training Zone",
          description: "Arcade modes, drills, and focus areas.",
          icon: Icons.fitness_center_rounded,
          color: const Color(0xFFFF7043), // Orange
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (c) => const TrainingZoneScreen())),
        ),
      ],
    ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1);
  }

  Widget _buildFeatureCard(BuildContext context, {
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 32, color: color),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              description,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 11,
                color: Colors.grey,
                height: 1.3,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  // Navigation helper for Mastery Flow
  void _handleNextStep(BuildContext context, String stepKey) {
    switch (stepKey) {
      case 'fines':
        // Navigate to Fines module (using LearningPath for now or specific screen if exists)
        // Ideally pass a focus/tab, but for now just open LearningPath
        Navigator.push(context, MaterialPageRoute(builder: (c) => const LearningPathScreen()));
        break;
      case 'numbers':
        Navigator.push(context, MaterialPageRoute(builder: (c) => const LearningPathScreen()));
        break;
      case 'roadSigns':
        Navigator.push(context, MaterialPageRoute(builder: (c) => const LearningPathScreen()));
        break;
      case 'mockTest':
        Navigator.push(context, MaterialPageRoute(builder: (c) => const QuizScreen(mode: QuizMode.standard)));
        break;
      case 'wrongAnswers':
        Navigator.push(context, MaterialPageRoute(builder: (c) => const RevisionScreen()));
        break;
    }
  }

  String _getStepLabel(String stepKey) {
    switch (stepKey) {
      case 'fines': return "Fines & Penalties";
      case 'numbers': return "Numbers & Data";
      case 'roadSigns': return "Road Signs";
      case 'mockTest': return "Mock Test";
      case 'wrongAnswers': return "Review Mistakes";
      default: return stepKey;
    }
  }
}
