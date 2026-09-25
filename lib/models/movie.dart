/// Representa UM filme do seu backlog.
///
/// Um "modelo" é só uma forma organizada de guardar dados. Pense nele
/// como uma ficha com campos preenchidos: título, capa, se já viu, etc.
///
/// Todos os campos são `final`, ou seja, depois de criado, o filme não
/// muda. Para "alterar" algo, criamos uma cópia nova com o campo
/// diferente (veja o método `copyWith` mais abaixo). Isso evita bugs
/// em que uma parte do app muda um dado sem as outras perceberem.
///
/// Os nomes dos campos usam snake_case (com _), uma escolha deste
/// projeto (o padrão do Dart seria camelCase, ex: urlDaCapa).
class Movie {
  // Identificador único do filme. Serve para achar o filme certo
  // na lista quando você favorita, exclui, etc.
  final String id;

  // Nome do filme.
  final String titulo;

  // Endereço (URL) da imagem da capa na internet.
  final String url_da_capa;

  // Ano de lançamento. O `?` depois do tipo quer dizer que o campo
  // pode ficar vazio (null), caso a TMDB não informe o ano.
  final int? ano;

  // Se você já assistiu (true) ou não (false).
  final bool foi_visto;

  // Se o filme está nos seus favoritos.
  final bool favorito;

  // Sua nota para o filme (ex: 8.5). Pode ser null se você ainda não deu nota.
  final double? nota;

  /// Construtor: é a "receita" para criar um filme.
  ///
  /// `required` = você é obrigado a informar esse campo.
  /// Campos com `= false` já vêm com um valor padrão se você não informar.
  const Movie({
    required this.id,
    required this.titulo,
    required this.url_da_capa,
    this.ano,
    this.foi_visto = false,
    this.favorito = false,
    this.nota,
  });

  /// Cria uma CÓPIA deste filme, trocando só os campos que você passar.
  ///
  /// Exemplo: `filme.copyWith(favorito: true)` devolve um filme igual,
  /// mas marcado como favorito. Os campos que você não passar continuam
  /// iguais ao original.
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
      // O operador `??` significa "se o da esquerda for null, use o da direita".
      // Ou seja: se você passou um valor novo, usa ele; senão, mantém o atual.
      foi_visto: foi_visto ?? this.foi_visto,
      favorito: favorito ?? this.favorito,
      nota: nota ?? this.nota,
    );
  }

  /// Transforma o filme num `Map` (um dicionário de "chave: valor").
  ///
  /// Usamos isso para SALVAR o filme no celular com o Hive, que sabe
  /// guardar Maps mas não sabe guardar a nossa classe Movie diretamente.
  Map<String, dynamic> toMap() => {
        'id': id,
        'titulo': titulo,
        'url_da_capa': url_da_capa,
        'ano': ano,
        'foi_visto': foi_visto,
        'favorito': favorito,
        'nota': nota,
      };

  /// Faz o caminho inverso do `toMap`: recebe um Map salvo no celular
  /// e reconstrói o filme a partir dele.
  ///
  /// `factory` é um tipo especial de construtor que pode rodar lógica
  /// antes de criar o objeto (aqui, ler cada campo do Map).
  factory Movie.fromMap(Map<String, dynamic> map) => Movie(
        // `as String` diz ao Dart: "confie em mim, esse valor é um texto".
        id: map['id'] as String,
        titulo: map['titulo'] as String,
        url_da_capa: map['url_da_capa'] as String,
        ano: map['ano'] as int?,
        // Se o campo não existir no Map salvo (dado antigo), usa false.
        foi_visto: map['foi_visto'] as bool? ?? false,
        favorito: map['favorito'] as bool? ?? false,
        // `num` aceita tanto int quanto double; `.toDouble()` garante
        // que vira double (ex: nota 8 salva como 8.0).
        nota: (map['nota'] as num?)?.toDouble(),
      );
}
