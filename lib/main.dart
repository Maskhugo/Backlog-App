import 'package:flutter/material.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

import 'data/hive_movie_repository.dart';
import 'data/movie_repository.dart';
import 'screens/search_screen.dart';
import 'state/movie_list_controller.dart';
import 'widgets/movie_card.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, MovieRepository? repository}) : _repository = repository;

  final MovieRepository? _repository;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => MovieListController(_repository ?? HiveMovieRepository())..carregar(),
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
    final controller = context.watch<MovieListController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Backlog App'),
      ),
      body: controller.carregado
          ? ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: controller.movies.length,
              itemBuilder: (context, index) => MovieCard(movie: controller.movies[index]),
            )
          : const Center(child: CircularProgressIndicator()),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const SearchScreen()),
        ),
        child: const Icon(Icons.add),
      ),
    );
  }
}
