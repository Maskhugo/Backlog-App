import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/movie.dart';
import '../state/movie_list_controller.dart';
import 'rating_dialog.dart';

/// O "cartão" de um filme na lista da tela principal.
///
/// Mostra a capa, o título, a nota e dois botões (favoritar e marcar
/// como visto). Também reage a gestos:
/// - tocar no cartão abre a janela para dar nota;
/// - arrastar para a esquerda exclui o filme.
///
/// Um "widget" é qualquer peça visual do Flutter. Telas inteiras são
/// widgets feitos de widgets menores, como este cartão.
class MovieCard extends StatelessWidget {
  const MovieCard({super.key, required this.movie});

  // O filme que este cartão vai mostrar.
  final Movie movie;

  @override
  Widget build(BuildContext context) {
    // Pegamos o controller com `read` (sem ouvir mudanças) porque o
    // cartão só dispara ações. Quem redesenha a lista é a HomeScreen.
    final controller = context.read<MovieListController>();

    // `Dismissible` deixa o usuário arrastar o item para o lado para excluir.
    return Dismissible(
      // A `key` identifica este item de forma única. O Flutter usa ela
      // para saber QUAL cartão foi arrastado.
      key: ValueKey(movie.id),
      // Só permite arrastar da direita para a esquerda.
      direction: DismissDirection.endToStart,
      // O que aparece "por baixo" enquanto você arrasta: fundo vermelho
      // com uma lixeira.
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        color: Colors.redAccent,
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      // Quando o arraste termina, remove o filme da lista.
      onDismissed: (_) => controller.removeMovie(movie.id),
      child: Card(
        // Corta o conteúdo nas bordas arredondadas do cartão.
        clipBehavior: Clip.antiAlias,
        child: ListTile(
          // Ao tocar no cartão: abre a janela de nota e ESPERA (`await`)
          // o usuário responder. Se ele salvar uma nota, atualizamos o filme.
          // Se cancelar, `nota` vem null e nada acontece.
          onTap: () async {
            final nota = await showRatingDialog(context, notaAtual: movie.nota);
            if (nota != null) controller.setRating(movie.id, nota);
          },
          // A capa, à esquerda.
          leading: SizedBox(
            width: 48,
            height: 72,
            child: Image.network(
              movie.url_da_capa,
              fit: BoxFit.cover,
              // Se a imagem não carregar (sem internet, URL quebrada),
              // mostra um ícone de filme no lugar em vez de um erro.
              errorBuilder: (context, error, stackTrace) => const ColoredBox(
                color: Colors.black12,
                child: Icon(Icons.movie_outlined),
              ),
            ),
          ),
          title: Text(movie.titulo),
          // Mostra a nota, ou "Sem nota" se ainda não tiver.
          // O `${...}` coloca o valor de uma variável dentro do texto.
          subtitle: Text(movie.nota == null ? 'Sem nota' : 'Nota: ${movie.nota}'),
          // Os botões à direita, lado a lado numa linha (`Row`).
          trailing: Row(
            // Faz a linha ocupar só o espaço dos botões, não a largura toda.
            mainAxisSize: MainAxisSize.min,
            children: [
              // Botão de favorito: estrela cheia e amarela se for favorito,
              // estrela vazia e cinza se não for.
              IconButton(
                icon: Icon(
                  movie.favorito ? Icons.star : Icons.star_border,
                  color: movie.favorito ? Colors.amber : Colors.grey,
                ),
                onPressed: () => controller.toggleFavorite(movie.id),
              ),
              // Botão de visto: check verde se já viu, contorno cinza se não.
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
