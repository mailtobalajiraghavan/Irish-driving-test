import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/user_provider.dart';
import '../providers/quiz_provider.dart';
import 'quiz_screen.dart';
import 'progress_screen.dart';
import 'revision_screen.dart';

class LearningPathScreen extends StatelessWidget {
  const LearningPathScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          "Road to 40/40",
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
        actions: [
          IconButton(
            icon: const Icon(Icons.bar_chart_rounded, color: Colors.black87),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ProgressScreen()),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.green[700]!, Colors.green[500]!],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  const Icon(Icons.emoji_events, size: 48, color: Colors.amber),
                  const SizedBox(height: 12),
                  Text(
                    "Your Goal: 40/40",
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Pass your driving theory test with a perfect score!",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.white70,
                    ),
                  ),
                  if (userProvider.perfectScoreCount > 0) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.amber,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.star, color: Colors.white, size: 18),
                          const SizedBox(width: 6),
                          Text(
                            "${userProvider.perfectScoreCount}x 40/40 Achieved!",
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ).animate().fadeIn().slideY(begin: -0.1, end: 0),
            
            const SizedBox(height: 24),


            Text(
              "🚀 Shortcut Method",
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              "The fastest path to 40/40 - proven by thousands of learners",
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 16),
            
            // Progress indicator
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Text(
                    "Progress: ${userProvider.shortcutProgress}/5",
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      color: Colors.blue[800],
                    ),
                  ),
                  const Spacer(),
                  ...List.generate(5, (i) => Container(
                    margin: const EdgeInsets.only(left: 4),
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: i < userProvider.shortcutProgress 
                          ? Colors.green 
                          : Colors.grey[300],
                      shape: BoxShape.circle,
                    ),
                    child: i < userProvider.shortcutProgress
                        ? const Icon(Icons.check, color: Colors.white, size: 16)
                        : null,
                  )),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Steps
            _buildStep(context, userProvider, 1, "Memorize Fines", 
                Icons.gavel_rounded, Colors.red, 'fines', QuizMode.fines),
            _buildStep(context, userProvider, 2, "Learn Numbers", 
                Icons.confirmation_number_rounded, Colors.blue, 'numbers', QuizMode.numbers),
            _buildStep(context, userProvider, 3, "Master Road Signs", 
                Icons.traffic_rounded, Colors.purple, 'roadSigns', QuizMode.roadSigns),
            _buildStep(context, userProvider, 4, "Take Mock Test", 
                Icons.play_arrow_rounded, Colors.green, 'mockTest', QuizMode.standard),
            _buildStep(context, userProvider, 5, "Review Mistakes", 
                Icons.error_outline_rounded, Colors.orange, 'wrongAnswers', QuizMode.wrongAnswers),
            
            const SizedBox(height: 8),
            
            Center(
              child: TextButton.icon(
                onPressed: () => _showResetDialog(context, userProvider),
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text("Reset Progress"),
              ),
            ),
            
            const SizedBox(height: 32),
            
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildStep(BuildContext context, UserProvider userProvider, 
      int step, String title, IconData icon, Color color, 
      String moduleKey, QuizMode mode) {
    // Determine status
    final isCompleted = userProvider.moduleCompleted[moduleKey] == true;
    final previousCompleted = step == 1 || _isPreviousStepComplete(userProvider, step);
    final isLast = step == 5;
    final isFirst = step == 1;
    
    // "Active" means unlocked but not yet completed
    final isActive = previousCompleted && !isCompleted;
    
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Timeline Column
          SizedBox(
            width: 40,
            child: Column(
              children: [
                // Top Line
                Expanded(
                  child: Container(
                    width: 2,
                    // Top line logic:
                    // If step 1: Transparent
                    // If previous completed: Green (connected to previous)
                    // Else: Grey
                    color: isFirst 
                        ? Colors.transparent 
                        : (previousCompleted ? Colors.green.withOpacity(0.3) : Colors.grey[200]),
                  ),
                ),
                // Icon Indicator
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: isCompleted 
                        ? Colors.green 
                        : isActive 
                            ? Colors.white 
                            : Colors.grey[100],
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isCompleted 
                          ? Colors.green 
                          : isActive 
                              ? color.withOpacity(0.5) 
                              : Colors.grey[300]!,
                      width: 2,
                    ),
                    boxShadow: isActive ? [
                      BoxShadow(
                        color: color.withOpacity(0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      )
                    ] : null,
                  ),
                  child: Center(
                    child: isCompleted
                        ? const Icon(Icons.check, color: Colors.white, size: 16)
                        : Text(
                            "$step",
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: isActive ? color : Colors.grey,
                            ),
                          ),
                  ),
                ),
                // Bottom Line
                Expanded(
                  child: Container(
                    width: 2,
                    // Bottom line logic:
                    // If last step: Transparent
                    // If this step completed: Green (connected to next)
                    // Else: Grey
                    color: isLast 
                        ? Colors.transparent 
                        : (isCompleted ? Colors.green.withOpacity(0.3) : Colors.grey[200]),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Content Card
          Expanded(
            child: GestureDetector(
              onTap: previousCompleted ? () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => QuizScreen(mode: mode)),
                );
              } : null,
              child: Container(
                margin: const EdgeInsets.only(bottom: 16, top: 4),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isCompleted 
                        ? Colors.green.withOpacity(0.2)
                        : Colors.grey[200]!,
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                    if (isActive)
                      BoxShadow(
                        color: color.withOpacity(0.1),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                              color: previousCompleted ? Colors.black87 : Colors.grey,
                            ),
                          ),
                          if (isCompleted)
                            Text(
                              "Completed",
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: Colors.green[600],
                              ),
                            ),
                          if (isActive)
                             Text(
                              "In Progress",
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: color,
                              ),
                            ),
                        ],
                      ),
                    ),
                    Icon(
                      icon,
                      color: previousCompleted ? color : Colors.grey[300],
                      size: 24,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: (step * 100).ms).slideX(begin: 0.05, end: 0);
  }

  bool _isPreviousStepComplete(UserProvider userProvider, int step) {
    final steps = ['fines', 'numbers', 'roadSigns', 'mockTest', 'wrongAnswers'];
    if (step <= 1) return true;
    // Check if the previous step was ATTEMPTED (not necessarily completed)
    return userProvider.moduleAttempted[steps[step - 2]] == true;
  }



  void _showResetDialog(BuildContext context, UserProvider userProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Reset Progress?"),
        content: const Text("This will reset your Shortcut Method progress. Your test history will be kept."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              userProvider.resetShortcutProgress();
              Navigator.pop(context);
            },
            child: const Text("Reset", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
