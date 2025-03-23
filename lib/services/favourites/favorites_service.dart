import 'package:hive_flutter/hive_flutter.dart';
import '../../models/movie_data_model.dart';

class FavoritesService {
  static const String _favoritesBoxName = 'favorites';
  late Box<Map> _favoritesBox;

  Future<void> initialize() async {
    await Hive.initFlutter();
    _favoritesBox = await Hive.openBox<Map>(_favoritesBoxName);
  }

  Future<void> addFavoriteMovie(MovieDataModel movie) async {
    await _favoritesBox.put(movie.id.toString(), movie.toJson());
  }

  Future<void> removeFavoriteMovie(int movieId) async {
    await _favoritesBox.delete(movieId.toString());
  }

  Future<bool> isMovieFavorite(int movieId) async {
    return _favoritesBox.containsKey(movieId.toString());
  }

  Future<List<MovieDataModel>> getFavoriteMovies() async {
    final favorites = _favoritesBox.values.toList();
    return favorites
        .map((json) => MovieDataModel.fromJson(Map<String, dynamic>.from(json)))
        .toList();
  }
}
