import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'api_service.dart';
import 'package:html_unescape/html_unescape.dart';
import 'database.dart';
import 'main.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  QuizScreenState createState() => QuizScreenState();
}

class QuizScreenState extends State<QuizScreen> {
  int _score = 0;
  int _currentQuestionIndex = 0;
  late Future<List<Task>> _questionsFuture;

  //Unescape pra formatar as questões
  final HtmlUnescape unescape = HtmlUnescape();

  @override
  void initState() {
    super.initState();
    _questionsFuture = _fetchQuestions();
  }

  Future<List<Task>> _fetchQuestions() async {
    final dio = Dio();
    final client = RestClient(dio);
    final response = await client.getTasks();
    return response.results;
  }

  void _answerQuestion(String resposta, String? respostaCorreta) {
    print(resposta);
    print(respostaCorreta);
    if (resposta == respostaCorreta) {
      setState(() {
        _score++;
      });
    }

    setState(() {
      if (_currentQuestionIndex < 2) {
        _currentQuestionIndex++;
      } else {
        _showQuizEndDialog();
      }
    });
  }

  void _showQuizEndDialog() {
    final TextEditingController usernameController = TextEditingController();

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) => AlertDialog(
        title: const Text("Quiz Finalizado!"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Sua pontuação final: $_score"),
            const SizedBox(height: 20),
            TextField(
              controller: usernameController,
              decoration: const InputDecoration(
                labelText: "Digite seu nome",
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () async {
              final username = usernameController.text.trim();
              if (username.isNotEmpty) {
                await DatabaseHelper.instance.insertScore(username, _score);
                if (mounted) {
                  Navigator.of(dialogContext).pop();
                }
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Por favor, insira um nome válido.")),
                );
              }
            },
            child: const Text("Salvar Pontuação"),
          ),
        ],
      ),
    ).then((_) {
      // Reseta o quiz se sair do dialog
      _resetQuiz();
    });
  }

  void _resetQuiz() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const QuizApp()),
          (Route<dynamic> route) => false,
    );
    setState(() {
      _currentQuestionIndex = 0;
      _score = 0;
    });
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
                    onPressed: () => _answerQuestion('True', question.correct_answer),
                    child: const Text('Verdadeiro'),
                  ),
                  ElevatedButton(
                    onPressed: () => _answerQuestion('False', question.correct_answer),
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
