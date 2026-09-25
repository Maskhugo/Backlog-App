// Importações: trazemos código de outros arquivos e pacotes para usar aqui.
// `material.dart` tem todos os componentes visuais do Flutter (botões, textos...).
import 'package:flutter/material.dart';
// Hive: o banco de dados que salva os filmes no celular.
import 'package:hive_ce_flutter/hive_flutter.dart';
// Provider: o pacote que compartilha o controller com todas as telas.
import 'package:provider/provider.dart';

import 'data/hive_movie_repository.dart';
import 'data/movie_repository.dart';
import 'screens/search_screen.dart';
import 'state/movie_list_controller.dart';
import 'widgets/movie_card.dart';

/// Ponto de partida do app: é a primeira função que roda quando ele abre.
///
/// É `async` porque precisa esperar o Hive ficar pronto antes de
/// mostrar qualquer tela.
Future<void> main() async {
  // Garante que o Flutter está pronto antes de usarmos recursos do
  // celular (como o armazenamento). É obrigatório antes de `await`s aqui.
  WidgetsFlutterBinding.ensureInitialized();
  // Prepara o Hive: descobre em qual pasta do celular ele vai salvar
  // os arquivos. Ainda não lê nenhum filme, só se prepara.
  await Hive.initFlutter();
  // Desenha o app na tela, começando pelo widget MyApp.
  runApp(const MyApp());
}

/// O widget "raiz" do app: tudo o que aparece na tela fica dentro dele.
///
/// `StatelessWidget` = um widget que não guarda estado próprio; ele só
/// desenha com base no que recebe.
class MyApp extends StatelessWidget {
  // `repository` é opcional. No app normal ninguém passa nada e usamos o
  // Hive. Os testes passam um repositório falso, para não mexer no celular.
  const MyApp({super.key, MovieRepository? repository}) : _repository = repository;

  final MovieRepository? _repository;

  // `build` é o método que diz "como esse widget aparece na tela".
  // O Flutter chama ele sempre que precisa desenhar de novo.
  @override
  Widget build(BuildContext context) {
    // `ChangeNotifierProvider` cria o controller UMA vez e disponibiliza
    // ele para todas as telas abaixo (que o acessam com `context.watch`
    // ou `context.read`).
    return ChangeNotifierProvider(
      // Cria o controller com o repositório do Hive (ou o falso, nos testes).
      // O `..carregar()` já manda ler os filmes salvos logo em seguida.
      // Os dois pontos (`..`) chamam o método e devolvem o próprio controller.
      create: (_) => MovieListController(_repository ?? HiveMovieRepository())..carregar(),
      // `MaterialApp` configura o app: título, cores e primeira tela.
      child: MaterialApp(
        title: 'Backlog App',
        theme: ThemeData(
          // Gera uma paleta de cores inteira a partir de um roxo.
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        // A primeira tela que aparece.
        home: const HomeScreen(),
      ),
    );
  }
}

/// A tela principal: mostra a lista de filmes do seu backlog.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // `context.watch` pega o controller E passa a "ouvir" ele. Sempre que
    // o controller chamar `notifyListeners()`, este build roda de novo e
    // a tela mostra os dados atualizados.
    final controller = context.watch<MovieListController>();

    // `Scaffold` é a estrutura básica de uma tela: barra no topo,
    // corpo e botão flutuante.
    return Scaffold(
      // A barra do topo com o título.
      appBar: AppBar(
        title: const Text('Backlog App'),
      ),
      // O corpo da tela. O `? :` é um "if" curto:
      //   condição ? (se verdadeiro) : (se falso)
      // Se os filmes já carregaram, mostra a lista; senão, a rodinha de carregando.
      body: controller.carregado
          // `ListView.builder` monta a lista sob demanda: só desenha os
          // itens que estão aparecendo na tela, o que deixa tudo mais leve.
          ? ListView.builder(
              padding: const EdgeInsets.all(8),
              // Quantos itens a lista tem.
              itemCount: controller.movies.length,
              // Como desenhar cada item: um MovieCard para cada filme.
              itemBuilder: (context, index) => MovieCard(movie: controller.movies[index]),
            )
          : const Center(child: CircularProgressIndicator()),
      // O botão redondo com "+" no canto inferior direito.
      floatingActionButton: FloatingActionButton(
        // Ao tocar, abre a tela de busca por cima desta.
        // `Navigator.push` = "empilha" uma tela nova; o botão de voltar
        // tira ela da pilha e você volta para cá.
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const SearchScreen()),
        ),
        child: const Icon(Icons.add),
      ),
    );
  }
}
