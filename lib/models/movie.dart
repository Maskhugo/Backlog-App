class Movie {
  final String id;
  final String titulo;
  final String url_da_capa;
  final bool foi_visto;
  final double? nota;

  const Movie({
    required this.id,
    required this.titulo,
    required this.url_da_capa,
    this.foi_visto = false,
    this.nota,
  });
}
