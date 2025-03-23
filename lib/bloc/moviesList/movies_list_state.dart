import 'package:equatable/equatable.dart';
import '../../models/movie_data_model.dart';

enum MoviesListStatus { initial, loading, success, failure }

class MoviesListState extends Equatable {
  final MoviesListStatus status;
  final List<MovieDataModel> movies;
  final List<MovieDataModel> favoriteMovies;
  final String message;
  final bool isSearching;

  const MoviesListState({
    this.status = MoviesListStatus.initial,
    this.movies = const [],
    this.favoriteMovies = const [],
    this.message = '',
    this.isSearching = false,
  });

  MoviesListState copyWith({
    MoviesListStatus? status,
    List<MovieDataModel>? movies,
    List<MovieDataModel>? favoriteMovies,
    String? message,
    bool? isSearching,
  }) {
    return MoviesListState(
      status: status ?? this.status,
      movies: movies ?? this.movies,
      favoriteMovies: favoriteMovies ?? this.favoriteMovies,
      message: message ?? this.message,
      isSearching: isSearching ?? this.isSearching,
    );
  }

  @override
  List<Object> get props =>
      [status, movies, favoriteMovies, message, isSearching];
}
