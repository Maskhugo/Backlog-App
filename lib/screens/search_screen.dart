import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/tmdb_repository.dart';
import '../state/movie_list_controller.dart';

/// Tela de busca: você digita o nome de um filme, o app procura na TMDB
/// e, ao tocar num resultado, o filme entra no seu backlog.
///
/// `StatefulWidget` = um widget que guarda estado próprio (dados que
/// mudam enquanto a tela está aberta, como "está carregando?" e a lista
/// de resultados). O estado fica na classe `_SearchScreenState` abaixo.
class SearchScreen extends StatefulWidget {
  // O repositório é opcional: no app normal criamos um de verdade;
  // nos testes passamos um falso que não usa a internet.
  const SearchScreen({super.key, TmdbRepository? repository})
      : _repository = repository;

  final TmdbRepository? _repository;

  // Diz ao Flutter qual classe guarda o estado desta tela.
  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

/// O estado da tela de busca. Tudo que muda na tela fica aqui.
class _SearchScreenState extends State<SearchScreen> {
  // `late` = o valor só é calculado na primeira vez que for usado.
  // `widget._repository` acessa o que foi passado para o SearchScreen.
  late final TmdbRepository _repository = widget._repository ?? TmdbRepository();

  // Controla o campo de texto: permite ler o que o usuário digitou.
  final _queryController = TextEditingController();

  // Os três "estados" possíveis da tela:
  bool _carregando = false; // está buscando na internet?
  String? _erro; // mensagem de erro (null = sem erro)
  List<TmdbSearchResult> _resultados = const []; // filmes encontrados

  /// Faz a busca na TMDB com o texto digitado.
  Future<void> _buscar(String query) async {
    // `setState` avisa o Flutter: "mudei o estado, redesenhe a tela".
    // Sem ele, a variável muda mas a tela continua igual.
    setState(() {
      _carregando = true; // mostra a rodinha de carregando
      _erro = null; // limpa erro de uma busca anterior
    });
    // `try/catch/finally`:
    //   try     = tenta fazer algo que pode dar erro;
    //   catch   = se der erro, cai aqui;
    //   finally = roda SEMPRE no final, dando certo ou errado.
    try {
      final resultados = await _repository.buscarFilmes(query);
      setState(() => _resultados = resultados);
    } catch (e) {
      // Guarda a mensagem do erro para mostrar na tela.
      setState(() => _erro = e.toString());
    } finally {
      // Terminou (com sucesso ou erro): tira a rodinha.
      setState(() => _carregando = false);
    }
  }

  /// Adiciona o filme escolhido ao backlog e volta para a tela principal.
  void _adicionarAoBacklog(TmdbSearchResult resultado) {
    // `context.read` pega o controller SEM ficar ouvindo mudanças.
    // Usamos `read` (e não `watch`) porque aqui só queremos chamar uma
    // ação, não redesenhar esta tela quando a lista mudar.
    context.read<MovieListController>().addMovie(
          titulo: resultado.titulo,
          url_da_capa: resultado.url_da_capa,
          ano: resultado.ano,
        );
    // Fecha esta tela e volta para a anterior (a lista de filmes).
    Navigator.of(context).pop();
  }

  // `dispose` roda quando a tela é fechada. Liberamos o controller do
  // campo de texto para não desperdiçar memória.
  @override
  void dispose() {
    _queryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // O campo de busca fica dentro da barra do topo, no lugar do título.
        title: TextField(
          controller: _queryController,
          // Já abre o teclado assim que a tela aparece.
          autofocus: true,
          // Faz o botão "Enter" do teclado virar uma lupa de busca.
          textInputAction: TextInputAction.search,
          decoration: const InputDecoration(
            hintText: 'Buscar filme na TMDB...',
            border: InputBorder.none,
          ),
          // Quando o usuário aperta Enter/lupa, chama `_buscar` com o texto.
          onSubmitted: _buscar,
        ),
      ),
      body: _buildBody(),
    );
  }

  /// Decide o que mostrar no corpo da tela, conforme o estado atual.
  /// A ordem dos `if`s importa: o primeiro que for verdadeiro vence.
  Widget _buildBody() {
    if (_carregando) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_erro != null) {
      // O `!` depois de `_erro` diz ao Dart: "tenho certeza que não é null"
      // (acabamos de checar isso no `if`).
      return Center(child: Padding(padding: const EdgeInsets.all(16), child: Text(_erro!)));
    }
    if (_resultados.isEmpty) {
      return const Center(child: Text('Digite um título e busque.'));
    }
    // Se chegou aqui, temos resultados: mostra a lista.
    return ListView.builder(
      itemCount: _resultados.length,
      itemBuilder: (context, index) {
        final resultado = _resultados[index];
        // `ListTile` é uma linha pronta com imagem à esquerda (leading),
        // título, subtítulo e ação ao tocar.
        return ListTile(
          leading: SizedBox(
            width: 48,
            height: 72,
            // Se não tem capa, mostra um ícone de filme num fundo cinza.
            // Se tem, baixa a imagem da internet com `Image.network`.
            child: resultado.url_da_capa.isEmpty
                ? const ColoredBox(
                    color: Colors.black12,
                    child: Icon(Icons.movie_outlined),
                  )
                : Image.network(resultado.url_da_capa, fit: BoxFit.cover),
          ),
          title: Text(resultado.titulo),
          // Só mostra o ano se ele existir.
          subtitle: resultado.ano == null ? null : Text('${resultado.ano}'),
          onTap: () => _adicionarAoBacklog(resultado),
        );
      },
    );
  }
}
