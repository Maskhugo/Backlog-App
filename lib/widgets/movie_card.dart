import 'package:flutter/material.dart';

import '../models/movie.dart';

class MovieCard extends StatelessWidget {
  const MovieCard({super.key, required this.movie});

  final Movie movie;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        leading: SizedBox(
          width: 48,
          height: 72,
          child: Image.network(
            movie.url_da_capa,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => const ColoredBox(
              color: Colors.black12,
              child: Icon(Icons.movie_outlined),
            ),
          ),
        ),
        title: Text(movie.titulo),
        trailing: Icon(
          movie.foi_visto ? Icons.check_circle : Icons.check_circle_outline,
          color: movie.foi_visto ? Colors.green : Colors.grey,
        ),
      ),
    );
  }
}
