import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/flashcard.dart';
import '../providers/flashcard_provider.dart';
import '../widgets/flashcard_widget.dart';
import 'package:card_swiper/card_swiper.dart';

class QuizScreen extends StatefulWidget {
  final Flashcard initialFlashcard;

  const QuizScreen({
    Key? key,
    required this.initialFlashcard,
  }) : super(key: key);

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  late List<Flashcard> _flashcards;
  late int _currentIndex;
  bool _showAnswer = false;

  @override
  void initState() {
    super.initState();
    _flashcards = context.read<FlashcardProvider>().flashcards;
    _currentIndex = _flashcards.indexOf(widget.initialFlashcard);
  }

  void _removeCard(int index) {
    setState(() {
      _flashcards.removeAt(index);
      _flashcards.removeAt(index);
      if (_flashcards.isEmpty) {
        Navigator.pop(context);
      } else {
        _currentIndex = (_currentIndex + 1) % _flashcards.length;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Flashcards',
          style: TextStyle(
            color: Colors.grey[800],
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          // Progress indicator
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Progress',
                      style: TextStyle(
                        color: Colors.grey[800],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${_currentIndex + 1}/$_currentIndex',
                      style: TextStyle(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: _flashcards.isNotEmpty
                      ? (_currentIndex + 1) / _flashcards.length
                      : 0,
                  backgroundColor: Colors.grey[300],
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                ),
              ],
            ),
          ),
          // Flashcard stack
          Expanded(
            child: Swiper(
              itemBuilder: (BuildContext context, int index) {
                Flashcard flashcard = _flashcards[index];
                return FlashcardWidget(
                  flashcard: flashcard,
                  isInQuizMode: true,
                  onFlip: () {
                    setState(() {
                      _showAnswer = !_showAnswer;
                    });
                  },
                  onSwipeLeft: () {
                    context
                        .read<FlashcardProvider>()
                        .markAsForgotten(flashcard);
                    _removeCard(index);
                  },
                  onSwipeRight: () {
                    context
                        .read<FlashcardProvider>()
                        .markAsRemembered(flashcard);
                    _removeCard(index);
                  },
                );
              },
              itemCount: _flashcards.length,
              itemWidth: MediaQuery.of(context).size.width - 40,
              layout: SwiperLayout.STACK,
              onIndexChanged: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              onTap: (index) {
                setState(() {
                  _showAnswer = !_showAnswer;
                });
              },
            ),
          ),
        ],
      ),
    );
  }
}
