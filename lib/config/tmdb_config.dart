/// Guarda as configurações fixas para conversar com a API da TMDB
/// (o site de filmes de onde buscamos título, capa e ano).
///
/// Tudo aqui é `static const`: são valores que nunca mudam enquanto
/// o app roda, e você acessa direto pela classe, sem criar um objeto
/// (ex: `TmdbConfig.baseUrl`).
class TmdbConfig {
  // O token (a "senha" da API) NÃO fica escrito no código.
  // `String.fromEnvironment` lê o valor na hora de compilar o app,
  // vindo do arquivo secrets.json, quando você roda:
  //   flutter run --dart-define-from-file=secrets.json
  // Se você esquecer esse parâmetro, o valor vira uma string vazia ('').
  static const readAccessToken = String.fromEnvironment('TMDB_READ_ACCESS_TOKEN');

  // Endereço base de todas as chamadas à API da TMDB.
  static const baseUrl = 'https://api.themoviedb.org/3';

  // Endereço base das imagens de capa. A TMDB só devolve o "final" do
  // caminho da imagem (ex: /abc123.jpg), então juntamos com este início.
  // O "w500" significa imagem com 500 pixels de largura.
  static const imageBaseUrl = 'https://image.tmdb.org/t/p/w500';
}
