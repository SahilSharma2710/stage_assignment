import 'package:equatable/equatable.dart';
import '../../models/movie_data_model.dart';

abstract class MoviesListEvent extends Equatable {
  const MoviesListEvent();

  @override
  List<Object> get props => [];
}

class FetchMoviesList extends MoviesListEvent {
  final String category;

  const FetchMoviesList({this.category = 'popular'});

  @override
  List<Object> get props => [category];
}

class SearchMovies extends MoviesListEvent {
  final String query;

  const SearchMovies(this.query);

  @override
  List<Object> get props => [query];
}

class ToggleFavorite extends MoviesListEvent {
  final MovieDataModel movie;
  final bool isFavorite;

  const ToggleFavorite({required this.movie, required this.isFavorite});

  @override
  List<Object> get props => [movie, isFavorite];
}

class RefreshList extends MoviesListEvent {}

class FetchOfflineFavorites extends MoviesListEvent {
  const FetchOfflineFavorites();
}
