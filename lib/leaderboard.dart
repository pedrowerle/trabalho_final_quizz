import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'database.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  _LeaderboardScreenState createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  late Future<List<Map<String, dynamic>>> _scoresFuture;

  @override
  void initState() {
    super.initState();
    _loadScores();
  }

  void _loadScores() {
    setState(() {
      _scoresFuture = DatabaseHelper.instance.getScores();
    });
  }

  void _showImageDialog(Uint8List imageBytes) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.memory(imageBytes),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text("Fechar"),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Leaderboard'),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              showDialog(
                context: context,
                barrierDismissible: true,
                builder: (dialogContext) => AlertDialog(
                  title: const Text("Apagar todos os registros!"),
                  content: const Text("Você tem certeza que deseja apagar todos os registros?"),
                  actions: [
                    TextButton(
                      onPressed: () async {
                        await DatabaseHelper.instance.limparBanco();
                        if (mounted) {
                          Navigator.of(dialogContext).pop();
                        }
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Todos os registros foram apagados!")),
                        );
                        _loadScores();
                      },
                      child: const Text("Confirmar"),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(dialogContext).pop();
                      },
                      child: const Text("Cancelar"),
                    ),
                  ],
                ),
              );
            },
            icon: const Icon(Icons.delete_outline),
          ),
        ],
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _scoresFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text('Erro ao carregar o leaderboard.'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Nenhum registro encontrado.'));
          } else {
            final scores = snapshot.data!;
            return ListView.builder(
              itemCount: scores.length,
              itemBuilder: (context, index) {
                final score = scores[index];
                final imageBytes = score['foto'] as Uint8List?;

                return ListTile(
                  leading: imageBytes != null
                      ? GestureDetector(
                    onTap: () => _showImageDialog(imageBytes),
                    child: ClipOval(
                      child: Image.memory(
                        imageBytes,
                        width: 40,
                        height: 40,
                        fit: BoxFit.cover,
                      ),
                    ),
                  )
                      : const Icon(Icons.person),
                  title: Text(score['username']),
                  trailing: Text('Pontuação: ${score['score']}'),
                );
              },
            );
          }
        },
      ),
    );
  }
}
