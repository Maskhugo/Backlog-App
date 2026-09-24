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
      ano: ano,
      foi_visto: foi_visto ?? this.foi_visto,
      favorito: favorito ?? this.favorito,
      nota: nota ?? this.nota,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'titulo': titulo,
        'url_da_capa': url_da_capa,
        'ano': ano,
        'foi_visto': foi_visto,
        'favorito': favorito,
        'nota': nota,
      };

  factory Movie.fromMap(Map<String, dynamic> map) => Movie(
        id: map['id'] as String,
        titulo: map['titulo'] as String,
        url_da_capa: map['url_da_capa'] as String,
        ano: map['ano'] as int?,
        foi_visto: map['foi_visto'] as bool? ?? false,
        favorito: map['favorito'] as bool? ?? false,
        nota: (map['nota'] as num?)?.toDouble(),
      );
}
