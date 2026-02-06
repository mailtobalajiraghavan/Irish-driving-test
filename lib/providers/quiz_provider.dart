import 'package:flutter/material.dart';
import '../models/question.dart';
import '../services/question_repository.dart';
import '../services/analytics_service.dart';

enum QuizMode { standard, quick, blitz, suddenDeath, wrongAnswers, numbers, roadSigns, fines, revision, search }

class QuizProvider with ChangeNotifier {
  List<Question> _questions = [];
  List<Question> _allQuestions = []; // Store all loaded questions
  int _currentIndex = 0;
  int _score = 0;
  bool _isLoading = false;
  QuizMode _currentMode = QuizMode.standard;
  List<String> _wrongIds = [];
  String? _selectedCategory;
  String? _searchQuery;

  List<Question> get questions => _questions;
  int get currentIndex => _currentIndex;
  int get score => _score;
  bool get isLoading => _isLoading;
  QuizMode get currentMode => _currentMode;
  Question get currentQuestion => _questions[_currentIndex];

  bool get isLastQuestion => _currentIndex == _questions.length - 1;

  // Official Test Rules
  static const int questionsPerQuiz = 40;
  static const int passingScore = 35;

  Future<void> loadQuestions() async {
    _isLoading = true;
    notifyListeners();
    try {
      final allQuestions = await QuestionRepository.loadQuestions();
      _allQuestions = allQuestions; // Keep a copy
      
      List<Question> filteredQuestions = [];

      switch (_currentMode) {
        case QuizMode.standard:
          allQuestions.shuffle();
          filteredQuestions = allQuestions.take(questionsPerQuiz).toList();
          break;
        case QuizMode.quick:
          allQuestions.shuffle();
          filteredQuestions = allQuestions.take(20).toList(); // Reduced count for Quick Mode
          break;
        case QuizMode.blitz:
          allQuestions.shuffle();
          filteredQuestions = allQuestions.take(10).toList(); // Micro-learning (10 Qs)
          break;
        case QuizMode.suddenDeath:
          allQuestions.shuffle();
          filteredQuestions = allQuestions.toList(); // Infinite (until wrong)
          break;
        case QuizMode.wrongAnswers:
          filteredQuestions = allQuestions.where((q) => _wrongIds.contains(q.id.toString())).toList();
          filteredQuestions.shuffle(); // Optional: shuffle mistakes
          break;

        case QuizMode.numbers:
          // Heuristic: Contains digits in text or answers
          filteredQuestions = allQuestions.where((q) {
            final text = q.text.toLowerCase();
            final numberRegex = RegExp(r'\d');
            
            // 1. Must check for numbers
            final hasNumber = numberRegex.hasMatch(q.text) || q.options.any((opt) => numberRegex.hasMatch(opt));
            
            if (!hasNumber) return false;

            // 2. Exclude Signs (Match RoadSigns logic)
            final isSign = (q.image != null && q.image!.isNotEmpty) || 
                           text.contains("sign") || 
                           text.contains("marking") || 
                           text.contains("line") ||
                           text.contains("yellow box");
            
            if (isSign) return false;

            // 3. Exclude Fines/Penalties (Match Fines logic exactly)
            final category = q.category.toLowerCase();
            final finesKeywords = ['fine', 'penalty', 'penalties', 'disqualification', 
                            'penalty points', 'offence', 'fixed charge', 
                            'conviction', 'prison', 'jail', 'alcohol', 'drugs'];
            
            final isFine = finesKeywords.any((k) => text.contains(k) || category.contains(k));
                           
            if (isFine) return false;

            // 4. Exclude "2-plus-1 road"
            if (text.contains("2-plus-1") || text.contains("2 plus 1")) return false;

            return true;
          }).take(questionsPerQuiz).toList();
          filteredQuestions.shuffle();
          break;
        case QuizMode.roadSigns:
          // Filter questions with images OR text keywords
          filteredQuestions = allQuestions.where((q) {
            final hasImage = q.image != null && q.image!.isNotEmpty;
            final text = q.text.toLowerCase();
            final isSignText = text.contains("sign") || 
                             text.contains("marking") || 
                             text.contains("line") ||
                             text.contains("yellow box");
            return hasImage || isSignText;
          }).toList();
          filteredQuestions.shuffle();
          filteredQuestions = filteredQuestions.take(questionsPerQuiz).toList();
          break;
        case QuizMode.fines:
          // Filter questions about fines, penalties, points, etc.
          filteredQuestions = allQuestions.where((q) {
            final text = q.text.toLowerCase();
            final category = q.category.toLowerCase();
            
            final keywords = ['fine', 'penalty', 'penalties', 'disqualification', 
                            'penalty points', 'offence', 'fixed charge', 
                            'conviction', 'prison', 'jail', 'alcohol', 'drugs'];
                            
            final hasKeyword = keywords.any((k) => text.contains(k) || category.contains(k));
            return hasKeyword;
          }).toList();
          filteredQuestions.shuffle();
          filteredQuestions = filteredQuestions.take(questionsPerQuiz).toList();
          break;
        case QuizMode.revision:
          // Filter by selected category
          if (_selectedCategory != null) {
            filteredQuestions = allQuestions.where((q) => q.category == _selectedCategory).toList();
            filteredQuestions.shuffle();
          }
          break;
        case QuizMode.revision:
          // Filter by selected category
          if (_selectedCategory != null) {
            filteredQuestions = allQuestions.where((q) => q.category == _selectedCategory).toList();
            filteredQuestions.shuffle();
          }
          break;
        case QuizMode.search:
          // Filter by search query
          if (_searchQuery != null && _searchQuery!.isNotEmpty) {
            final query = _searchQuery!.toLowerCase();
            filteredQuestions = allQuestions.where((q) {
              return q.text.toLowerCase().contains(query);
            }).toList();
          }
          break;
      }

      if (filteredQuestions.isEmpty && _currentMode != QuizMode.standard) {
          // Fallback if empty (e.g. no mistakes)
          // Ideally UI handles this, but here let's valid state
      }

      _questions = filteredQuestions;
    } catch (e) {
      debugPrint("Error loading questions: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void startQuiz({QuizMode mode = QuizMode.standard, List<String> wrongIds = const [], String? category, String? searchQuery}) {
    _currentMode = mode;
    _wrongIds = wrongIds;
    _selectedCategory = category;
    _searchQuery = searchQuery;
    _currentIndex = 0;
    _score = 0;
    
    // Log start
    AnalyticsService().logQuizStart(
      mode: mode.toString().split('.').last,
      category: category,
    );
    
    loadQuestions(); // Reload/Reshuffle for a new game
  }

  Future<void> logCompletion() async {
    await AnalyticsService().logQuizComplete(
      mode: _currentMode.toString().split('.').last,
      score: _score,
      totalQuestions: _questions.length,
      category: _selectedCategory,
    );
  }

  void submitAnswer(int selectedIndex) {
    if (questions[_currentIndex].correctIndex == selectedIndex) {
      _score++;
    }
    // Note: handling of "next question" is usually done by UI calling nextQuestion after delay
  }

  void nextQuestion() {
    if (_currentIndex < _questions.length - 1) {
      _currentIndex++;
      notifyListeners();
    }
  }
}
