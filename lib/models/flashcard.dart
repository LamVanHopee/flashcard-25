import 'package:hive/hive.dart';

part 'flashcard.g.dart';

@HiveType(typeId: 0)
class Flashcard extends HiveObject {
  @HiveField(0)
  String question;

  @HiveField(1)
  String answer;

  @HiveField(2)
  String? category;

  @HiveField(3)
  int correctCount;

  @HiveField(4)
  int incorrectCount;

  @HiveField(5)
  bool isLearned;

  Flashcard({
    required this.question,
    required this.answer,
    this.category,
    this.correctCount = 0,
    this.incorrectCount = 0,
    this.isLearned = false,
  });

  double get masteryPercentage {
    if (correctCount + incorrectCount == 0) return 0;
    return (correctCount / (correctCount + incorrectCount)) * 100;
  }

  Flashcard copyWith({
    String? question,
    String? answer,
    String? category,
    int? correctCount,
    int? incorrectCount,
    bool? isLearned,
  }) {
    return Flashcard(
      question: question ?? this.question,
      answer: answer ?? this.answer,
      category: category ?? this.category,
      correctCount: correctCount ?? this.correctCount,
      incorrectCount: incorrectCount ?? this.incorrectCount,
      isLearned: isLearned ?? this.isLearned,
    );
  }
}
