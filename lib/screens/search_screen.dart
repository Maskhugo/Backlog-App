import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/tmdb_repository.dart';
import '../state/movie_list_controller.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key, TmdbRepository? repository})
      : _repository = repository;

  final TmdbRepository? _repository;

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  late final TmdbRepository _repository = widget._repository ?? TmdbRepository();
  final _queryController = TextEditingController();

  bool _carregando = false;
  String? _erro;
  List<TmdbSearchResult> _resultados = const [];

  Future<void> _buscar(String query) async {
    setState(() {
      _carregando = true;
      _erro = null;
    });
    try {
      final resultados = await _repository.buscarFilmes(query);
      setState(() => _resultados = resultados);
    } catch (e) {
      setState(() => _erro = e.toString());
    } finally {
      setState(() => _carregando = false);
    }
  }

  void _adicionarAoBacklog(TmdbSearchResult resultado) {
    context.read<MovieListController>().addMovie(
          titulo: resultado.titulo,
          url_da_capa: resultado.url_da_capa,
          ano: resultado.ano,
        );
    Navigator.of(context).pop();
  }

  @override
  void dispose() {
    _queryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _queryController,
          autofocus: true,
          textInputAction: TextInputAction.search,
          decoration: const InputDecoration(
            hintText: 'Buscar filme na TMDB...',
            border: InputBorder.none,
          ),
          onSubmitted: _buscar,
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_carregando) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_erro != null) {
      return Center(child: Padding(padding: const EdgeInsets.all(16), child: Text(_erro!)));
    }
    if (_resultados.isEmpty) {
      return const Center(child: Text('Digite um título e busque.'));
    }
    return ListView.builder(
      itemCount: _resultados.length,
      itemBuilder: (context, index) {
        final resultado = _resultados[index];
        return ListTile(
          leading: SizedBox(
            width: 48,
            height: 72,
            child: resultado.url_da_capa.isEmpty
                ? const ColoredBox(
                    color: Colors.black12,
                    child: Icon(Icons.movie_outlined),
                  )
                : Image.network(resultado.url_da_capa, fit: BoxFit.cover),
          ),
          title: Text(resultado.titulo),
          subtitle: resultado.ano == null ? null : Text('${resultado.ano}'),
          onTap: () => _adicionarAoBacklog(resultado),
        );
      },
    );
  }
}
