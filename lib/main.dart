import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stage_assignment/bloc/connectivity/connectivity_bloc.dart';
import 'package:stage_assignment/bloc/connectivity/connectivity_event.dart';
import 'package:stage_assignment/bloc/movieDetails/movie_details_bloc.dart';
import 'package:stage_assignment/bloc/moviesList/movies_list_bloc.dart';
import 'package:stage_assignment/bloc/moviesList/movies_list_event.dart';
import 'package:stage_assignment/screens/movie_list_screen.dart';
import 'package:stage_assignment/services/favourites/favorites_service.dart';
import 'services/env/env_service.dart';
import 'services/http/http_service.dart';
import 'services/movies/movies_api_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize environment variables
  await EnvService.initialize();

  // Initialize favorites service
  final favoritesService = FavoritesService();
  await favoritesService.initialize();

  // Initialize HTTP and API services
  final httpService = HttpService(baseUrl: EnvService.apiBaseUrl);
  final movieApiService = MovieApiService(httpService: httpService);

  runApp(MyApp(
    favoritesService: favoritesService,
    movieApiService: movieApiService,
  ));
}

class MyApp extends StatelessWidget {
  final FavoritesService favoritesService;
  final MovieApiService movieApiService;

  const MyApp({
    super.key,
    required this.favoritesService,
    required this.movieApiService,
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<ConnectivityBloc>(
          create: (context) => ConnectivityBloc()..add(CheckConnectivity()),
        ),
        BlocProvider<MoviesListBloc>(
          create: (context) => MoviesListBloc(
            movieApiService: movieApiService,
            favoritesService: favoritesService,
          )..add(const FetchMoviesList()),
        ),
        BlocProvider<MovieDetailsBloc>(
          create: (context) => MovieDetailsBloc(
            movieApiService: movieApiService,
            favoritesService: favoritesService,
          ),
        ),
      ],
      child: MaterialApp(
        title: 'Movie App',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: const MoviesListScreen(),
      ),
    );
  }
}
