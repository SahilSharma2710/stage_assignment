import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stage_assignment/services/favourites/favorites_service.dart';
import '../../services/movies/movies_api_service.dart';
import 'movies_list_event.dart';
import 'movies_list_state.dart';

class MoviesListBloc extends Bloc<MoviesListEvent, MoviesListState> {
  final MovieApiService movieApiService;
  final FavoritesService favoritesService;

  MoviesListBloc({
    required this.movieApiService,
    required this.favoritesService,
  }) : super(const MoviesListState()) {
    on<FetchMoviesList>(_onFetchMoviesList);
    on<SearchMovies>(_onSearchMovies);
    on<ToggleFavorite>(_onToggleFavorite);
    on<RefreshList>(_onRefreshList);
    on<FetchOfflineFavorites>(_onFetchOfflineFavorites);
  }

  Future<void> _onFetchMoviesList(
    FetchMoviesList event,
    Emitter<MoviesListState> emit,
  ) async {
    emit(state.copyWith(status: MoviesListStatus.loading));

    try {
      final movies = await movieApiService.getMovies(category: event.category);
      final favorites = await favoritesService.getFavoriteMovies();

      emit(state.copyWith(
        status: MoviesListStatus.success,
        movies: movies,
        favoriteMovies: favorites,
        isSearching: false,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: MoviesListStatus.failure,
        message: 'Failed to fetch movies: $e',
      ));
    }
  }

  Future<void> _onSearchMovies(
    SearchMovies event,
    Emitter<MoviesListState> emit,
  ) async {
    if (event.query.isEmpty) {
      add(const FetchMoviesList());
      return;
    }

    emit(state.copyWith(status: MoviesListStatus.loading, isSearching: true));

    try {
      final results = state.movies
          .where((movie) =>
              movie.title.toLowerCase().contains(event.query.toLowerCase()))
          .toList();

      emit(state.copyWith(
        status: MoviesListStatus.success,
        movies: results,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: MoviesListStatus.failure,
        message: 'Search failed: $e',
      ));
    }
  }

  Future<void> _onToggleFavorite(
    ToggleFavorite event,
    Emitter<MoviesListState> emit,
  ) async {
    try {
      // Update remote (API)
      final success = await movieApiService.toggleFavorite(
        movieId: event.movie.id,
        favorite: event.isFavorite,
      );

      if (success) {
        // Update local storage
        if (event.isFavorite) {
          await favoritesService.addFavoriteMovie(event.movie);
        } else {
          await favoritesService.removeFavoriteMovie(event.movie.id);
        }

        // Update state
        final favorites = await favoritesService.getFavoriteMovies();
        emit(state.copyWith(
          favoriteMovies: favorites,
          message: event.isFavorite
              ? 'Added to favorites'
              : 'Removed from favorites',
        ));
      } else {
        emit(state.copyWith(
          message: 'Failed to update favorite status',
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        message: 'Error toggling favorite: $e',
      ));
    }
  }

  Future<void> _onRefreshList(
    RefreshList event,
    Emitter<MoviesListState> emit,
  ) async {
    add(const FetchMoviesList());
  }

  Future<void> _onFetchOfflineFavorites(
    FetchOfflineFavorites event,
    Emitter<MoviesListState> emit,
  ) async {
    emit(state.copyWith(status: MoviesListStatus.loading));
    try {
      // Load favorites from Hive
      final favorites = await favoritesService.getFavoriteMovies();
      emit(state.copyWith(
        status: MoviesListStatus.success,
        movies: [], // Empty list for regular movies when offline
        favoriteMovies: favorites,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: MoviesListStatus.failure,
        message: 'Failed to load favorite movies: ${e.toString()}',
      ));
    }
  }
}
