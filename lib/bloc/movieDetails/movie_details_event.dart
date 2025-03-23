import 'package:equatable/equatable.dart';
import '../../models/movie_data_model.dart';

abstract class MovieDetailsEvent extends Equatable {
  const MovieDetailsEvent();

  @override
  List<Object> get props => [];
}

class FetchMovieDetails extends MovieDetailsEvent {
  final int movieId;

  const FetchMovieDetails(this.movieId);

  @override
  List<Object> get props => [movieId];
}

class ToggleFavoriteInDetails extends MovieDetailsEvent {
  final MovieDataModel movie;
  final bool isFavorite;

  const ToggleFavoriteInDetails({
    required this.movie,
    required this.isFavorite,
  });

  @override
  List<Object> get props => [movie, isFavorite];
}
