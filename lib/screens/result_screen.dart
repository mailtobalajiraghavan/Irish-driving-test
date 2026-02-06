import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import '../providers/quiz_provider.dart';
import '../providers/user_provider.dart';
import '../models/test_result.dart';
import 'home_screen.dart';
import 'quiz_screen.dart';

class ResultScreen extends StatefulWidget {
  const ResultScreen({super.key});

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  @override
  void initState() {
    super.initState();
    _processResults();
  }

  void _processResults() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final quizProvider = Provider.of<QuizProvider>(context, listen: false);
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      
      // Calculate XP (10 per correct answer for now)
      final xpEarned = quizProvider.score * 10;
      userProvider.addXp(xpEarned);
      userProvider.updateStreak();
      
      // Log Analytics
      quizProvider.logCompletion();
      
      // Record test result for progress tracking
      final result = TestResult(
        date: DateTime.now(),
        score: quizProvider.score,
        total: quizProvider.questions.length,
        mode: _getModeString(quizProvider),
      );
      userProvider.recordTestResult(result);
      
      // Mark module complete if passed (score >= 87.5%)
      final percentage = quizProvider.questions.isNotEmpty 
          ? quizProvider.score / quizProvider.questions.length 
          : 0.0;
      
      // Always mark as attempted
      _markModuleAttempted(quizProvider, userProvider);
      
      if (percentage >= 0.875) {
        _markModuleComplete(quizProvider, userProvider);
      }
    });
  }
  
  String _getModeString(QuizProvider provider) {
    switch (provider.currentMode) {
      case QuizMode.standard:
        return 'standard';
      case QuizMode.quick:
        return 'quick';
      case QuizMode.blitz:
        return 'blitz';
      case QuizMode.suddenDeath:
        return 'suddenDeath';
      case QuizMode.wrongAnswers:
        return 'wrongAnswers';

      case QuizMode.numbers:
        return 'numbers';
      case QuizMode.roadSigns:
        return 'roadSigns';
      case QuizMode.fines:
        return 'fines';
      case QuizMode.revision:
        return 'revision';
      case QuizMode.search:
        return 'search';
    }
  }
  
  void _markModuleComplete(QuizProvider quizProvider, UserProvider userProvider) {
    switch (quizProvider.currentMode) {
      case QuizMode.fines:
        userProvider.markModuleComplete('fines');
        break;
      case QuizMode.numbers:
        userProvider.markModuleComplete('numbers');
        break;
      case QuizMode.roadSigns:
        userProvider.markModuleComplete('roadSigns');
        break;
      case QuizMode.standard:
        userProvider.markModuleComplete('mockTest');
        break;
      case QuizMode.wrongAnswers:
        userProvider.markModuleComplete('wrongAnswers');
        break;
      case QuizMode.search:
      case QuizMode.quick:
      case QuizMode.blitz:
      case QuizMode.suddenDeath:
      case QuizMode.revision:
        // No explicit completion module for these modes yet
        break;
      default:
        break;
    }
  }

  void _markModuleAttempted(QuizProvider quizProvider, UserProvider userProvider) {
    switch (quizProvider.currentMode) {
      case QuizMode.fines:
        userProvider.markModuleAttempted('fines');
        break;
      case QuizMode.numbers:
        userProvider.markModuleAttempted('numbers');
        break;
      case QuizMode.roadSigns:
        userProvider.markModuleAttempted('roadSigns');
        break;
      case QuizMode.standard:
        userProvider.markModuleAttempted('mockTest');
        break;
      case QuizMode.wrongAnswers:
        userProvider.markModuleAttempted('wrongAnswers'); // Logic handles emptiness separately
        break;
      case QuizMode.search:
        // No module to mark for search
        break;
      case QuizMode.revision:
      case QuizMode.quick:
      case QuizMode.blitz:
      case QuizMode.suddenDeath:
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final quizProvider = Provider.of<QuizProvider>(context);
    final score = quizProvider.score;
    final total = quizProvider.questions.length;
    final percentage = total > 0 ? score / total : 0.0;
    final passed = score >= QuizProvider.passingScore || (total < QuizProvider.questionsPerQuiz && percentage >= 0.875);
    
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                passed ? "Congratulations!" : "Keep Practicing!",
                style: GoogleFonts.poppins(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: passed ? Colors.green[700] : Colors.orange[800],
                ),
              ).animate().scale().fadeIn(),
              
              const SizedBox(height: 40),
              
              CircularPercentIndicator(
                radius: 80.0,
                lineWidth: 12.0,
                percent: percentage,
                center: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "${(percentage * 100).toInt()}%",
                      style: GoogleFonts.poppins(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      "$score / $total",
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                progressColor: passed ? Colors.green : Colors.orange,
                backgroundColor: Colors.grey[100]!,
                circularStrokeCap: CircularStrokeCap.round,
                animation: true,
                animationDuration: 1500,
              ).animate().scale(delay: 200.ms),
              
              const SizedBox(height: 40),
              
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 28),
                    const SizedBox(width: 8),
                    Text(
                      "+ ${score * 10} XP Earned",
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[800],
                      ),
                    ),
                  ],
                ),
              ).animate().slideY(begin: 0.5, end: 0, delay: 500.ms).fadeIn(),
              
              const Spacer(),
              
              // Show Next Level button ALWAYS if there is a next step
              if (Provider.of<UserProvider>(context).getNextStep() != null) ...[
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () {
                      final userProvider = Provider.of<UserProvider>(context, listen: false);
                      final nextStep = userProvider.getNextStep();
                      
                      QuizMode mode = QuizMode.standard;
                      if (nextStep == 'fines') mode = QuizMode.fines;
                      if (nextStep == 'numbers') mode = QuizMode.numbers;
                      if (nextStep == 'roadSigns') mode = QuizMode.roadSigns;
                      if (nextStep == 'mockTest') mode = QuizMode.standard;
                      if (nextStep == 'wrongAnswers') mode = QuizMode.wrongAnswers;
                      
                      // Replace entire stack with home, then push quiz
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (context) => const HomeScreen()),
                        (Route<dynamic> route) => false,
                      );
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => QuizScreen(mode: mode)),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.play_arrow_rounded, color: Colors.white),
                        const SizedBox(width: 8),
                        Text(
                          "Next Level",
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ).animate().slideY(begin: 1.0, end: 0, delay: 800.ms).fadeIn(),
                const SizedBox(height: 16),
              ],
              
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    // Navigate reset to home
                     Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (context) => const HomeScreen()),
                      (Route<dynamic> route) => false,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    "Back to Home",
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
