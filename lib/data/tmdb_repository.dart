// `dart:convert` traz o `jsonDecode`, que transforma o texto JSON
// devolvido pela API em Maps e Lists do Dart.
import 'dart:convert';

// O pacote `http` faz as requisições para a internet.
// `as http` dá um apelido: chamamos as funções como `http.Client`, etc.
import 'package:http/http.dart' as http;

import '../config/tmdb_config.dart';

/// Um resultado da busca na TMDB: só os dados que nos interessam
/// de cada filme encontrado (id, título, capa e ano).
///
/// É diferente do `Movie`: este representa "um filme que apareceu na
/// busca", enquanto o `Movie` é "um filme que está no seu backlog".
class TmdbSearchResult {
  final int id;
  final String titulo;
  final String url_da_capa;
  final int? ano;

  const TmdbSearchResult({
    required this.id,
    required this.titulo,
    required this.url_da_capa,
    this.ano,
  });

  /// Cria um resultado a partir do JSON que a TMDB devolve.
  ///
  /// A TMDB usa nomes em inglês (title, poster_path, release_date);
  /// aqui traduzimos para os nomes do nosso app.
  factory TmdbSearchResult.fromJson(Map<String, dynamic> json) {
    // `poster_path` vem só com o final do caminho (ex: /abc.jpg) ou null.
    final posterPath = json['poster_path'] as String?;
    // `release_date` vem como texto no formato "2014-11-05".
    final releaseDate = json['release_date'] as String?;
    return TmdbSearchResult(
      id: json['id'] as int,
      // Se a TMDB não mandar título, mostramos "(sem título)".
      titulo: json['title'] as String? ?? '(sem título)',
      // Se não tiver capa, guardamos texto vazio; senão, montamos a URL
      // completa juntando o endereço base com o caminho da imagem.
      url_da_capa: posterPath == null ? '' : '${TmdbConfig.imageBaseUrl}$posterPath',
      // Pegamos só os 4 primeiros caracteres da data ("2014") e
      // convertemos para número. `int.tryParse` devolve null se falhar,
      // em vez de quebrar o app.
      ano: (releaseDate != null && releaseDate.length >= 4)
          ? int.tryParse(releaseDate.substring(0, 4))
          : null,
    );
  }
}

/// Um erro específico da TMDB, com uma mensagem em português que
/// podemos mostrar direto na tela.
///
/// `implements Exception` = marca esta classe como um tipo de erro,
/// que pode ser lançado com `throw` e capturado com `try/catch`.
class TmdbException implements Exception {
  final String message;
  const TmdbException(this.message);

  // Quando o erro é convertido em texto (ex: para aparecer na tela),
  // mostramos só a mensagem.
  @override
  String toString() => message;
}

/// Responsável por conversar com a API da TMDB (buscar filmes na internet).
///
/// Um "repositório" é a classe que sabe de onde vêm os dados. As telas
/// não precisam saber como a internet funciona: elas só pedem
/// "busque filmes com esse nome" e recebem a lista pronta.
class TmdbRepository {
  // O construtor aceita um `client` opcional. No app de verdade, não
  // passamos nada e ele cria um `http.Client()` normal. Nos testes,
  // podemos passar um cliente falso para não depender da internet.
  TmdbRepository({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  /// Busca filmes na TMDB pelo nome digitado.
  ///
  /// `async` + `Future` = a função demora (vai na internet), então ela
  /// devolve uma "promessa" de resultado, e quem chama usa `await`.
  Future<List<TmdbSearchResult>> buscarFilmes(String query) async {
    // Se o texto estiver vazio (ou só espaços), nem chama a API.
    if (query.trim().isEmpty) return [];

    // Se o app foi rodado sem o secrets.json, o token está vazio.
    // Mostramos um erro claro em vez de chamar a API e receber
    // um "não autorizado" confuso.
    if (TmdbConfig.readAccessToken.isEmpty) {
      throw const TmdbException(
        'Token da TMDB não configurado. Rode com '
        '--dart-define-from-file=secrets.json (veja secrets.example.json).',
      );
    }

    // Monta o endereço completo, por exemplo:
    // https://api.themoviedb.org/3/search/movie?query=Matrix&language=pt-BR
    // `queryParameters` cuida de acentos e espaços automaticamente.
    final uri = Uri.parse('${TmdbConfig.baseUrl}/search/movie').replace(
      queryParameters: {'query': query, 'language': 'pt-BR'},
    );

    // Faz a requisição GET (pedir dados) mandando o token no cabeçalho
    // `Authorization`. É assim que a TMDB sabe que somos nós.
    final response = await _client.get(
      uri,
      headers: {
        'Authorization': 'Bearer ${TmdbConfig.readAccessToken}',
        'Accept': 'application/json',
      },
    );

    // Código 200 = deu certo. Qualquer outro (401, 404, 500...) é erro.
    if (response.statusCode != 200) {
      throw TmdbException('Falha ao buscar filmes (HTTP ${response.statusCode})');
    }

    // Transforma o texto JSON da resposta num Map do Dart.
    final body = jsonDecode(response.body) as Map<String, dynamic>;
    // Os filmes encontrados vêm dentro da chave "results".
    // Se ela não existir, usamos uma lista vazia.
    final results = body['results'] as List<dynamic>? ?? [];
    // Converte cada item do JSON num TmdbSearchResult.
    return results
        .map((r) => TmdbSearchResult.fromJson(r as Map<String, dynamic>))
        .toList();
  }
}
