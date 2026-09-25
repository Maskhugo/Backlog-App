import '../models/movie.dart';

// "Mock" quer dizer "de mentira" / "de exemplo".
//
// Esta lista é usada só na PRIMEIRA vez que o app abre no celular,
// quando ainda não tem nada salvo. Assim a tela não começa vazia.
// Depois disso, o app usa sempre os filmes que você salvou.
//
// `final` = a variável não pode apontar para outra lista depois.
// `const Movie(...)` = cada filme é criado em tempo de compilação,
// o que economiza memória.
final List<Movie> mock_movies = [
  const Movie(
    id: '1',
    titulo: 'Duna: Parte Dois',
    url_da_capa: 'https://image.tmdb.org/t/p/w500/8b8R8l88Qje9dn9OE8PY05Nxl1X.jpg',
    foi_visto: true,
    nota: 8.5,
  ),
  const Movie(
    id: '2',
    titulo: 'Oppenheimer',
    url_da_capa: 'https://image.tmdb.org/t/p/w500/fm6KqXpk3M2HVveHwCrBSSBaO0V.jpg',
    foi_visto: true,
    nota: 8.9,
  ),
  const Movie(
    id: '3',
    titulo: 'Poor Things',
    url_da_capa: 'https://image.tmdb.org/t/p/w500/kCGlIMHnOm8JPXq3rXM6c5wMxcT.jpg',
    foi_visto: false,
  ),
  const Movie(
    id: '4',
    titulo: 'The Bear',
    url_da_capa: 'https://image.tmdb.org/t/p/w500/zPyB2SVQ2WEWDbmXpJvOFVe83sD.jpg',
    foi_visto: false,
  ),
];
