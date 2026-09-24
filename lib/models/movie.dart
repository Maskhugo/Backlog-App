class Movie {
  final String id;
  final String titulo;
  final String url_da_capa;
  final int? ano;
  final bool foi_visto;
  final bool favorito;
  final double? nota;

  const Movie({
    required this.id,
    required this.titulo,
    required this.url_da_capa,
    this.ano,
    this.foi_visto = false,
    this.favorito = false,
    this.nota,
  });

  Movie copyWith({
    bool? foi_visto,
    bool? favorito,
    double? nota,
  }) {
    return Movie(
      id: id,
      titulo: titulo,
      url_da_capa: url_da_capa,
      foi_visto: foi_visto ?? this.foi_visto,
      favorito: favorito ?? this.favorito,
      nota: nota ?? this.nota,
    );
  }
}
