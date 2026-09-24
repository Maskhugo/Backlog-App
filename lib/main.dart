import 'package:flutter/material.dart';

import 'data/mock_movies.dart';
import 'widgets/movie_card.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Backlog App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Backlog App'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: mock_movies.length,
        itemBuilder: (context, index) => MovieCard(movie: mock_movies[index]),
      ),
    );
  }
}
