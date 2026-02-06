import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/quiz_provider.dart';
import '../providers/user_provider.dart';
import '../models/question.dart';
import '../services/analytics_service.dart';
import 'result_screen.dart';

class QuizScreen extends StatefulWidget {
  final QuizMode mode;
  final String? category;
  final String? searchQuery;
  const QuizScreen({super.key, this.mode = QuizMode.standard, this.category, this.searchQuery});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int? _selectedOptionIndex;
  bool _answered = false;
  
  // Timer for Mock Test (45 minutes = 2700 seconds)
  Timer? _timer;
  int _remainingSeconds = 45 * 60;
  
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      Provider.of<QuizProvider>(context, listen: false).startQuiz(
        mode: widget.mode,
        wrongIds: userProvider.wrongQuestions,
        category: widget.category,
        searchQuery: widget.searchQuery,
      );
      
      // Log analytics event for quiz mode selection
      AnalyticsService().logQuizStart(
        mode: widget.mode.name,
        category: widget.category,
      );
      
      // Start timer only for Mock Test mode
      if (widget.mode == QuizMode.standard) {
        _startTimer();
      }
    });
  }
  
  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() {
          _remainingSeconds--;
        });
      } else {
        _timer?.cancel();
        // Time's up - navigate to results
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const ResultScreen()),
          );
        }
      }
    });
  }
  
  @override
  void dispose() {
    _timer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }
  
  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  void _handleOptionSelect(int index, Question question) {
    if (_answered) return;

    setState(() {
      _selectedOptionIndex = index;
      _answered = true;
    });

    // Submit answer to provider
    final quizProvider = Provider.of<QuizProvider>(context, listen: false);
    quizProvider.submitAnswer(index);
    
    // Gamification & Tracking
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final question = quizProvider.currentQuestion!;
    
    if (question.correctIndex != index) {
      userProvider.recordWrongAnswer(question.id);
    } else {
      userProvider.addXp(question.xpReward);
    }
    
    // Auto scroll to explanation ONLY IF WRONG
    if (index != question.correctIndex && question.explanation != null) {
      Future.delayed(const Duration(milliseconds: 300), () {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 1500),
            curve: Curves.easeOutCubic,
          );
        }
      });
    }

    // Auto navigate after delay ONLY IF CORRECT
    if (index == question.correctIndex) {
      Future.delayed(const Duration(milliseconds: 1000), () {
        if (mounted) {
           _advanceToNextQuestion();
        }
      });
    }
    // If WRONG, we wait for manual "Next" button click (defined in build method)
  }

  void _advanceToNextQuestion() {
    // Kept merely as internal helper or if we re-add button later, 
    // but main flow is now auto-driven again.
     final quizProvider = Provider.of<QuizProvider>(context, listen: false);
    if (quizProvider.isLastQuestion) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const ResultScreen()),
      );
    } else {
      setState(() {
        _selectedOptionIndex = null;
        _answered = false;
      });
      quizProvider.nextQuestion();
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(0);
      }
    }
  }

  String _getQuizTitle(QuizMode mode) {
    switch (mode) {
      case QuizMode.standard:
        return "Mock Test";
      case QuizMode.quick:
        return "Quick Mode";
      case QuizMode.blitz:
        return "Blitz Mode";
      case QuizMode.suddenDeath:
        return "Sudden Death";
      case QuizMode.wrongAnswers:
        return "Wrong Questions";

      case QuizMode.numbers:
        return "Numbers & Facts";
      case QuizMode.roadSigns:
        return "Road Signs";
      case QuizMode.fines:
        return "Fines & Penalties";
      case QuizMode.revision:
        return "Revision";
      case QuizMode.search:
        return "Search: ${widget.searchQuery ?? ''}";
    }
  }

  @override
  Widget build(BuildContext context) {
    final quizProvider = Provider.of<QuizProvider>(context);
    final question = quizProvider.currentQuestion;

    if (quizProvider.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (question == null) {
      return const Scaffold(body: Center(child: Text("No questions loaded")));
    }

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          "Question ${quizProvider.currentIndex + 1}/${quizProvider.questions.length}",
          style: GoogleFonts.poppins(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (widget.mode == QuizMode.standard) 
            Container(
              margin: const EdgeInsets.only(right: 16),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _remainingSeconds < 300 
                    ? Colors.red.withOpacity(0.1) 
                    : Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: _remainingSeconds < 300 
                      ? Colors.red.withOpacity(0.3) 
                      : Colors.blue.withOpacity(0.3),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.timer_outlined,
                    size: 18,
                    color: _remainingSeconds < 300 ? Colors.red[700] : Colors.blue[700],
                  ),
                  const SizedBox(width: 6),
                  Text(
                    _formatTime(_remainingSeconds),
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: _remainingSeconds < 300 ? Colors.red[700] : Colors.blue[700],
                    ),
                  ),
                ],
              ),
            ).animate(
              target: _remainingSeconds < 60 ? 1 : 0,
            ).shake(hz: 2, duration: 500.ms),
        ],
      ),
      body: GestureDetector(
        onTap: () {
          // Allow tap to advance only when answered and answer is wrong
          if (_answered && _selectedOptionIndex != question.correctIndex) {
            _advanceToNextQuestion();
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            key: ValueKey(question.id), // Force rebuild on new question
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
            // Progress Bar
            LinearProgressIndicator(
              value: (quizProvider.currentIndex + 1) / quizProvider.questions.length,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),
              minHeight: 6,
              borderRadius: BorderRadius.circular(10),
            ),
            const SizedBox(height: 32),
            
            // Question Text
            Text(
              question.text,
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ).animate().fadeIn().slideX(),
            
            if (question.image != null) ...[
              const SizedBox(height: 20),
              Container(
                height: 150,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    question.image!,
                    fit: BoxFit.contain,
                  ),
                ),
              ).animate().fadeIn().scale(),
            ],
            
            const SizedBox(height: 32),
            
            // Options
            Expanded(
              child: ListView(
                controller: _scrollController,
                physics: const BouncingScrollPhysics(),
                children: [
                  ...List.generate(question.options.length, (index) {
                    final isSelected = _selectedOptionIndex == index;
                    final isCorrect = index == question.correctIndex;
                    
                    Color borderColor = Colors.black12;
                    Color backgroundColor = Colors.white;
                    Color textColor = Colors.black87;
                    IconData? icon;

                    if (_answered) {
                      if (isSelected) {
                        borderColor = isCorrect ? Colors.green : Colors.red;
                        backgroundColor = isCorrect ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1);
                        textColor = isCorrect ? Colors.green[800]! : Colors.red[800]!;
                        icon = isCorrect ? Icons.check_circle : Icons.cancel;
                      } else if (isCorrect) {
                        // Show correct answer if wrong one selected
                        borderColor = Colors.green;
                        backgroundColor = Colors.green.withOpacity(0.1);
                        textColor = Colors.green[800]!;
                        icon = Icons.check_circle;
                      }
                    }

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: GestureDetector(
                        onTap: () => _handleOptionSelect(index, question),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: backgroundColor,
                            border: Border.all(color: borderColor, width: isSelected || (_answered && isCorrect) ? 2 : 1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  question.options[index],
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    color: textColor,
                                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                                  ),
                                ),
                              ),
                              if (icon != null) ...[
                                const SizedBox(width: 8),
                                Icon(icon, color: textColor),
                              ]
                            ],
                          ),
                        ),
                      ).animate().fadeIn(delay: (index * 100).ms).slideX(begin: 0.1, end: 0),
                    );
                  }),
                  

                    // Show explanation only if answered and WRONG
                    if (_answered && _selectedOptionIndex != question.correctIndex && question.explanation != null) ...[
                      const SizedBox(height: 16),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.blue[50],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.blue[100]!),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.info_outline_rounded, size: 20, color: Colors.blue),
                                const SizedBox(width: 8),
                                Text(
                                  "Explanation",
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue[800],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              question.explanation!,
                              style: GoogleFonts.poppins(
                                color: Colors.blue[900],
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
