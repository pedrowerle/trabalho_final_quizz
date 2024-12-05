import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';
import 'package:html_unescape/html_unescape.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  _QuizScreenState createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int _score = 0;
  int _currentQuestionIndex = 0;
  late Future<List<Task>> _questionsFuture;

  //Unescape pra formatar as questões
  final HtmlUnescape unescape = HtmlUnescape();

  @override
  void initState() {
    super.initState();
    _loadScore();
    _questionsFuture = _fetchQuestions();
  }

  Future<void> _saveScore() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('score', _score);
  }

  Future<void> _loadScore() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _score = prefs.getInt('score') ?? 0;
    });
  }

  Future<List<Task>> _fetchQuestions() async {
    final dio = Dio();
    final client = RestClient(dio);
    final response = await client.getTasks();
    return response.results;
  }

  void _answerQuestion(bool isCorrect) {
    if (isCorrect) {
      setState(() {
        _score++;
      });
      _saveScore();
    }

    setState(() {
      if (_currentQuestionIndex < 5) {
        _currentQuestionIndex++;
      } else {
        _showQuizEndDialog();
      }
    });
  }

  void _showQuizEndDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Quiz Finalizado!"),
        content: Text("Sua pontuação final: $_score"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              setState(() {
                _currentQuestionIndex = 0;
                _score = 0;
                _saveScore();
              });
            },
            child: const Text("Reiniciar"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quiz Educacional'),
        centerTitle: true,
      ),
      body: FutureBuilder<List<Task>>(
        future: _questionsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Erro: ${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("Nenhuma pergunta encontrada!"));
          } else {
            final questions = snapshot.data!;
            final question = questions[_currentQuestionIndex];

            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      unescape.convert(question.question ?? 'Pergunta indisponível'),
                      style: const TextStyle(fontSize: 18),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () => _answerQuestion(true),
                    child: const Text('Verdadeiro'),
                  ),
                  ElevatedButton(
                    onPressed: () => _answerQuestion(false),
                    child: const Text('Falso'),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      'Pontuação: $_score',
                      style: const TextStyle(fontSize: 18),
                    ),
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}
