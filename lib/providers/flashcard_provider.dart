import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/flashcard.dart';

class CategoryAlreadyExistsException implements Exception {
  final String message;
  CategoryAlreadyExistsException(this.message);

  @override
  String toString() => 'CategoryAlreadyExistsException: $message';
}

class FlashcardProvider with ChangeNotifier {
  List<Flashcard> _flashcards = [];
  String _currentCategory = 'All';
  final List<String> _categories = ['General', 'Math', 'Science', 'Language'];

  List<Flashcard> get flashcards => _currentCategory == 'All'
      ? _flashcards.where((card) => !card.isLearned).toList()
      : _flashcards
          .where((card) => card.category == _currentCategory && !card.isLearned)
          .toList();

  List<String> get categories => _categories;

  String get currentCategory => _currentCategory;

  Set<String> get categoriesSet {
    Set<String> cats = {'All'};
    cats.addAll(_flashcards
        .where((card) => card.category != null)
        .map((card) => card.category!)
        .toSet());
    return cats;
  }

  Future<void> loadFlashcards() async {
    var box = await Hive.openBox<Flashcard>('flashcards');
    _flashcards = box.values.toList();
    notifyListeners();
  }

  Future<void> addFlashcard(Flashcard flashcard) async {
    var box = await Hive.openBox<Flashcard>('flashcards');
    await box.add(flashcard);
    _flashcards.add(flashcard);
    notifyListeners();
  }

  Future<void> updateFlashcard(Flashcard flashcard) async {
    await flashcard.save();
    int index = _flashcards.indexWhere((f) => f.key == flashcard.key);
    if (index != -1) {
      _flashcards[index] = flashcard;
      notifyListeners();
    }
  }

  Future<void> deleteFlashcard(Flashcard flashcard) async {
    await flashcard.delete();
    _flashcards.removeWhere((f) => f.key == flashcard.key);
    notifyListeners();
  }

  void setCategory(String category) {
    _currentCategory = category;
    notifyListeners();
  }

  void markAsRemembered(Flashcard flashcard) {
    final index = _flashcards.indexOf(flashcard);
    if (index != -1) {
      _flashcards[index] = flashcard.copyWith(
        correctCount: flashcard.correctCount + 1,
        isLearned: true,
      );
      notifyListeners();
    }
  }

  void markAsForgotten(Flashcard flashcard) {
    final index = _flashcards.indexOf(flashcard);
    if (index != -1) {
      _flashcards[index] = flashcard.copyWith(
        incorrectCount: flashcard.incorrectCount + 1,
      );
      notifyListeners();
    }
  }

  void addCategory(String category) {
    if (_categories.contains(category)) {
      throw CategoryAlreadyExistsException(
          'Category "$category" already exists.');
    }
    _categories.add(category);
    notifyListeners();
  }

  void removeCategory(String category) {
    if (category != 'General') {
      _categories.remove(category);
      notifyListeners();
    }
  }
}
