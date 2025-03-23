import 'package:equatable/equatable.dart';
import 'package:stage_assignment/models/movie_details_model.dart';

enum MovieDetailsStatus { initial, loading, success, failure }

class MovieDetailsState extends Equatable {
  final MovieDetailsStatus status;
  final MovieDetails? movie;
  final bool isFavorite;
  final String message;

  const MovieDetailsState({
    this.status = MovieDetailsStatus.initial,
    this.movie,
    this.isFavorite = false,
    this.message = '',
  });

  MovieDetailsState copyWith({
    MovieDetailsStatus? status,
    MovieDetails? movie,
    bool? isFavorite,
    String? message,
  }) {
    return MovieDetailsState(
      status: status ?? this.status,
      movie: movie ?? this.movie,
      isFavorite: isFavorite ?? this.isFavorite,
      message: message ?? this.message,
    );
  }

  @override
  List<Object?> get props => [status, movie, isFavorite, message];
}
