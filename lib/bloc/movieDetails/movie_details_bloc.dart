import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stage_assignment/services/favourites/favorites_service.dart';
import '../../services/movies/movies_api_service.dart';
import 'movie_details_event.dart';
import 'movie_details_state.dart';

class MovieDetailsBloc extends Bloc<MovieDetailsEvent, MovieDetailsState> {
  final MovieApiService movieApiService;
  final FavoritesService favoritesService;

  MovieDetailsBloc({
    required this.movieApiService,
    required this.favoritesService,
  }) : super(const MovieDetailsState()) {
    on<FetchMovieDetails>(_onFetchMovieDetails);
    on<ToggleFavoriteInDetails>(_onToggleFavorite);
  }

  Future<void> _onFetchMovieDetails(
    FetchMovieDetails event,
    Emitter<MovieDetailsState> emit,
  ) async {
    emit(state.copyWith(status: MovieDetailsStatus.loading));

    try {
      final movie = await movieApiService.getMovieDetails(event.movieId);
      final isFavorite = await favoritesService.isMovieFavorite(event.movieId);

      emit(state.copyWith(
        status: MovieDetailsStatus.success,
        movie: movie,
        isFavorite: isFavorite,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: MovieDetailsStatus.failure,
        message: 'Failed to fetch movie details: $e',
      ));
    }
  }

  Future<void> _onToggleFavorite(
    ToggleFavoriteInDetails event,
    Emitter<MovieDetailsState> emit,
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
        emit(state.copyWith(
          isFavorite: event.isFavorite,
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
}
