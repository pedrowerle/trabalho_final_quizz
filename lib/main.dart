import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trabalho_final/api_service.dart';
import 'theme_provider.dart'; // Importa o ThemeProvider
import 'quizz_screen.dart'; // Importa a tela do Quiz
import 'package:dio/dio.dart';


void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeProvider(), // Inicializa o ThemeProvider
      child: const QuizApp(),
    ),
  );
}

class QuizApp extends StatelessWidget {
  const QuizApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context); // Obtém o tema atual
    return MaterialApp(
      title: 'Quiz Educacional',
      theme: themeProvider.currentTheme, // Usa o tema gerenciado pelo Provider
      home: const AppTitle(), // Tela inicial do app
    );
  }
}

class AppTitle extends StatelessWidget {
  const AppTitle({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.currentTheme == ThemeData.dark();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quiz Educacional'),
        centerTitle: true,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Center(
            child: Text(
              'Bem-vindo ao Quiz Educacional!',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 20), // Espaço entre o texto e o botão
          ElevatedButton(
            onPressed: () {
              // Navega para a tela de Quiz
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const QuizScreen()),
              );
            },
            child: const Text('Iniciar Quiz'),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: themeProvider.toggleTheme, // Alterna entre os temas
        child: Icon(isDarkMode ? Icons.dark_mode : Icons.light_mode), // Ícone alternado
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat, // Posiciona no canto inferior direito
    );
  }
}
