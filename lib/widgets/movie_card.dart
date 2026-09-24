import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/movie.dart';
import '../state/movie_list_controller.dart';
import 'rating_dialog.dart';

class MovieCard extends StatelessWidget {
  const MovieCard({super.key, required this.movie});

  final Movie movie;

  @override
  Widget build(BuildContext context) {
    final controller = context.read<MovieListController>();

    return Dismissible(
      key: ValueKey(movie.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        color: Colors.redAccent,
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (_) => controller.removeMovie(movie.id),
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: ListTile(
          onTap: () async {
            final nota = await showRatingDialog(context, notaAtual: movie.nota);
            if (nota != null) controller.setRating(movie.id, nota);
          },
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
          subtitle: Text(movie.nota == null ? 'Sem nota' : 'Nota: ${movie.nota}'),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: Icon(
                  movie.favorito ? Icons.star : Icons.star_border,
                  color: movie.favorito ? Colors.amber : Colors.grey,
                ),
                onPressed: () => controller.toggleFavorite(movie.id),
              ),
              IconButton(
                icon: Icon(
                  movie.foi_visto ? Icons.check_circle : Icons.check_circle_outline,
                  color: movie.foi_visto ? Colors.green : Colors.grey,
                ),
                onPressed: () => controller.toggleWatched(movie.id),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
