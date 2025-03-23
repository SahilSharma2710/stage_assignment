import 'package:stage_assignment/models/movie_data_model.dart';
import 'package:stage_assignment/models/movie_details_model.dart';

import '../http/http_service.dart';
import '../env/env_service.dart';

class MovieApiService {
  final HttpService _httpService;
  final String _apiKey;
  final String _accountId;

  MovieApiService({
    required HttpService httpService,
  })  : _httpService = httpService,
        _apiKey = EnvService.apiKey,
        _accountId = EnvService.accountId;

  // Get authorization header
  Map<String, String> get _authHeader => {
        'Authorization': 'Bearer $_apiKey',
      };

  // Get list of movies (popular, upcoming, top_rated, etc.)
  Future<List<MovieDataModel>> getMovies({String category = 'popular'}) async {
    try {
      final response = await _httpService.get(
        '/movie/$category',
        headers: _authHeader,
      );

      final List<dynamic> results = response['results'] ?? [];
      return results
          .map((movieJson) => MovieDataModel.fromJson(movieJson))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch movies: $e');
    }
  }

  // Mark a movie as favorite/unfavorite
  Future<bool> toggleFavorite({
    required int movieId,
    required bool favorite,
  }) async {
    try {
      final body = {
        'media_type': 'movie',
        'media_id': movieId,
        'favorite': favorite,
      };

      final response = await _httpService.post(
        '/account/$_accountId/favorite', // Now using the account ID from env
        body,
        headers: _authHeader,
      );

      return response['success'] == true;
    } catch (e) {
      throw Exception('Failed to update favorite status: $e');
    }
  }

  // Get movie details by ID
  Future<MovieDetails> getMovieDetails(int movieId) async {
    try {
      final response = await _httpService.get(
        '/movie/$movieId',
        headers: _authHeader,
      );

      return MovieDetails.fromJson(response);
    } catch (e) {
      throw Exception('Failed to fetch movie details: $e');
    }
  }
}
