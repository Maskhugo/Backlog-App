import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/tmdb_config.dart';

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

  factory TmdbSearchResult.fromJson(Map<String, dynamic> json) {
    final posterPath = json['poster_path'] as String?;
    final releaseDate = json['release_date'] as String?;
    return TmdbSearchResult(
      id: json['id'] as int,
      titulo: json['title'] as String? ?? '(sem título)',
      url_da_capa: posterPath == null ? '' : '${TmdbConfig.imageBaseUrl}$posterPath',
      ano: (releaseDate != null && releaseDate.length >= 4)
          ? int.tryParse(releaseDate.substring(0, 4))
          : null,
    );
  }
}

class TmdbException implements Exception {
  final String message;
  const TmdbException(this.message);

  @override
  String toString() => message;
}

class TmdbRepository {
  TmdbRepository({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  Future<List<TmdbSearchResult>> buscarFilmes(String query) async {
    if (query.trim().isEmpty) return [];

    if (TmdbConfig.readAccessToken.isEmpty) {
      throw const TmdbException(
        'Token da TMDB não configurado. Rode com '
        '--dart-define-from-file=secrets.json (veja secrets.example.json).',
      );
    }

    final uri = Uri.parse('${TmdbConfig.baseUrl}/search/movie').replace(
      queryParameters: {'query': query, 'language': 'pt-BR'},
    );

    final response = await _client.get(
      uri,
      headers: {
        'Authorization': 'Bearer ${TmdbConfig.readAccessToken}',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode != 200) {
      throw TmdbException('Falha ao buscar filmes (HTTP ${response.statusCode})');
    }

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final results = body['results'] as List<dynamic>? ?? [];
    return results
        .map((r) => TmdbSearchResult.fromJson(r as Map<String, dynamic>))
        .toList();
  }
}
