import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'screens/search_screen.dart';
import 'state/movie_list_controller.dart';
import 'widgets/movie_card.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => MovieListController(),
      child: MaterialApp(
        title: 'Backlog App',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: const HomeScreen(),
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final movies = context.watch<MovieListController>().movies;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Backlog App'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: movies.length,
        itemBuilder: (context, index) => MovieCard(movie: movies[index]),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const SearchScreen()),
        ),
        child: const Icon(Icons.add),
      ),
    );
  }
}
