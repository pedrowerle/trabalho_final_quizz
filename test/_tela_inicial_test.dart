import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:trabalho_final/leaderboard.dart';
import 'package:trabalho_final/main.dart';
import 'package:trabalho_final/quizz_screen.dart';
import 'package:trabalho_final/theme_provider.dart';

void main() {
  group('Tela Inicial - QuizApp', () {
    testWidgets('Renderiza corretamente a tela inicial', (WidgetTester tester) async {
      await tester.pumpWidget(
        ChangeNotifierProvider(
          create: (_) => ThemeProvider(),
          child: const QuizApp(),
        ),
      );

      // Verifica se o título está na tela
      expect(find.text('Quiz Educacional'), findsOneWidget);

      // Verifica se o botão "Iniciar Quiz" existe
      expect(find.text('Iniciar Quiz'), findsOneWidget);

      // Verifica se a mensagem de boas-vindas está correta
      expect(find.text('Bem-vindo ao Quiz Educacional!'), findsOneWidget);

      // Verifica se os botões flutuantes estão presentes
      expect(find.byIcon(Icons.emoji_events), findsOneWidget);
      expect(find.byIcon(Icons.dark_mode), findsOneWidget);
    });

    testWidgets('Navega para a tela de Quiz ao clicar no botão "Iniciar Quiz"', (WidgetTester tester) async {
      await tester.pumpWidget(
        ChangeNotifierProvider(
          create: (_) => ThemeProvider(),
          child: const MaterialApp(home: AppTitle()),
        ),
      );

      // Simula clique no botão "Iniciar Quiz"
      await tester.tap(find.text('Iniciar Quiz'));
      await tester.pumpAndSettle();

      // Verifica se a tela de Quiz é exibida
      expect(find.byType(QuizScreen), findsOneWidget);
    });

    testWidgets('Navega para a tela de Leaderboard ao clicar no botão de troféu', (WidgetTester tester) async {
      await tester.pumpWidget(
        ChangeNotifierProvider(
          create: (_) => ThemeProvider(),
          child: const MaterialApp(home: AppTitle()),
        ),
      );

      // Simula clique no botão de troféu
      await tester.tap(find.byIcon(Icons.emoji_events));
      await tester.pumpAndSettle();

      // Verifica se a tela de Leaderboard é exibida
      expect(find.byType(LeaderboardScreen), findsOneWidget);
    });

    testWidgets('Altera o tema ao clicar no botão de alternância de tema', (WidgetTester tester) async {
      final themeProvider = ThemeProvider();

      await tester.pumpWidget(
        ChangeNotifierProvider(
          create: (_) => themeProvider,
          child: const MaterialApp(home: AppTitle()),
        ),
      );

      // Verifica o estado inicial (tema claro)
      expect(themeProvider.currentTheme, ThemeData.light());

      // Simula clique no botão de alternância de tema
      await tester.tap(find.byIcon(Icons.dark_mode));
      await tester.pumpAndSettle();

      // Verifica se o tema foi alterado para escuro
      expect(themeProvider.currentTheme, ThemeData.dark());
    });

    testWidgets('Verifica layout e alinhamento dos botões flutuantes', (WidgetTester tester) async {
      await tester.pumpWidget(
        ChangeNotifierProvider(
          create: (_) => ThemeProvider(),
          child: const MaterialApp(home: AppTitle()),
        ),
      );

      // Verifica alinhamento e presença dos botões flutuantes
      final leftFab = tester.getRect(find.byIcon(Icons.emoji_events));
      final rightFab = tester.getRect(find.byIcon(Icons.dark_mode));

      // Verifica alinhamento horizontal
      expect(leftFab.center.dy, closeTo(rightFab.center.dy, 0.01));
      // Verifica alinhamento à esquerda e à direita
      expect(leftFab.left < rightFab.left, true);
    });
  });
}
