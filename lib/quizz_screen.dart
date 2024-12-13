import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';
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
  Uint8List? _capturedImageBytes;

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

  Future<void> _pickImage() async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.camera);

      if (pickedFile != null) {
        final bytes = await pickedFile.readAsBytes();
        setState(() {
          _capturedImageBytes = bytes;
        });
      } else {
        setState(() {
          _capturedImageBytes = null;
        });
      }
    } catch (e) {
      print("Erro ao capturar imagem: $e");
    }
  }

  void _showQuizEndDialog() {
    final TextEditingController usernameController = TextEditingController();

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text("Quiz Finalizado!"),
          content: SingleChildScrollView(
            child: Column(
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
                const SizedBox(height: 20),
                if (_capturedImageBytes != null)
                  Column(
                    children: [
                      Image.memory(
                        _capturedImageBytes!,
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        "Foto capturada!",
                        style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                      ),
                    ],
                  )
                else
                  const Text(
                    "Nenhuma foto capturada.",
                    style: TextStyle(color: Colors.red),
                  ),
                const SizedBox(height: 10),
                ElevatedButton.icon(
                  label: const Text("Tirar Foto"),
                  onPressed: () async {
                    await _pickImage();
                    setDialogState(() {}); // Atualiza o diálogo
                  },
                  icon: const Icon(Icons.camera_alt),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: const Text("Salvar Pontuação"),
              onPressed: () async {
                final username = usernameController.text.trim();
                if (username.isNotEmpty) {
                  await DatabaseHelper.instance.insertScoreFoto(
                    username,
                    _score,
                    _capturedImageBytes,
                  );
                  if (mounted) {
                    Navigator.of(dialogContext).pop();
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Por favor, insira um nome válido.")),
                  );
                }
              }
            ),
          ],
        ),
      ),
    ).then((_) {
      // Reseta o quiz ao sair do diálogo
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
      _capturedImageBytes = null;
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
