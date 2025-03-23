import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stage_assignment/bloc/connectivity/connectivity_bloc.dart';
import 'package:stage_assignment/bloc/connectivity/connectivity_event.dart';
import 'package:stage_assignment/bloc/connectivity/connectivity_state.dart';
import 'package:stage_assignment/bloc/moviesList/movies_list_bloc.dart';
import 'package:stage_assignment/bloc/moviesList/movies_list_event.dart';
import 'package:stage_assignment/bloc/moviesList/movies_list_state.dart';
import 'package:stage_assignment/screens/movie_details_screen.dart';
import 'package:stage_assignment/widgets/movie_error_widget.dart';
import 'package:stage_assignment/widgets/movie_loading_widget.dart';
import 'package:stage_assignment/widgets/movie_grid_item.dart';

class MoviesListScreen extends StatefulWidget {
  const MoviesListScreen({super.key});

  @override
  State<MoviesListScreen> createState() => _MoviesListScreenState();
}

class _MoviesListScreenState extends State<MoviesListScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Check connectivity when screen loads
    context.read<ConnectivityBloc>().add(CheckConnectivity());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          scrolledUnderElevation: 0,
          elevation: 0,
          centerTitle: false,
          title: const Text(
            'Movies',
            style: TextStyle(
              color: Colors.black,
              fontSize: 36,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: BlocListener<ConnectivityBloc, ConnectivityState>(
          listener: (context, connectivityState) {
            // Load appropriate data based on connectivity
            if (connectivityState.isConnected) {
              // Online: Load from API
              context.read<MoviesListBloc>().add(const FetchMoviesList());
            } else {
              // Offline: Explicitly load favorites from local storage
              context.read<MoviesListBloc>().add(const FetchOfflineFavorites());
            }
          },
          child: Column(
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: SizedBox(
                  height: 35,
                  child: TextField(
                    controller: _searchController,
                    cursorHeight: 16,
                    cursorColor: Colors.black,
                    textAlign: TextAlign.center,
                    decoration: InputDecoration(
                      hintText: 'Search movies...',
                      hintStyle: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ),
                      alignLabelWithHint: true,
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 10.0, horizontal: 50.0),
                      prefixIcon: const Icon(Icons.search, size: 18),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: () {
                          _searchController.clear();
                          context
                              .read<MoviesListBloc>()
                              .add(const FetchMoviesList());
                        },
                      ),
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey.shade500),
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onChanged: (query) {
                      if (query.isNotEmpty) {
                        context.read<MoviesListBloc>().add(SearchMovies(query));
                      } else {
                        context
                            .read<MoviesListBloc>()
                            .add(const FetchMoviesList());
                      }
                    },
                  ),
                ),
              ),
              BlocBuilder<ConnectivityBloc, ConnectivityState>(
                builder: (context, connectivityState) {
                  if (!connectivityState.isConnected) {
                    return Expanded(
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            color: Colors.amber.shade100,
                            width: double.infinity,
                            child: Row(
                              children: [
                                const Icon(Icons.wifi_off, size: 20),
                                const SizedBox(width: 8),
                                const Expanded(
                                  child: Text(
                                    'You are in offline mode. Only favorite movies are available.',
                                    style: TextStyle(fontSize: 14),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: BlocBuilder<MoviesListBloc, MoviesListState>(
                              builder: (context, state) {
                                // Show loading indicator when first loading
                                if (state.status == MoviesListStatus.loading &&
                                    state.favoriteMovies.isEmpty) {
                                  return const MovieLoadingWidget();
                                } else if (state.favoriteMovies.isEmpty) {
                                  return const Center(
                                    child: Text(
                                      'No favorite movies found',
                                      style: TextStyle(fontSize: 18),
                                    ),
                                  );
                                }

                                return GridView.builder(
                                  padding: const EdgeInsets.all(16),
                                  gridDelegate:
                                      const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 3,
                                    childAspectRatio: 0.7,
                                    crossAxisSpacing: 12,
                                    mainAxisSpacing: 12,
                                  ),
                                  itemCount: state.favoriteMovies.length,
                                  itemBuilder: (context, index) {
                                    final movie = state.favoriteMovies[index];
                                    return MovieGridItem(
                                      movie: movie,
                                      isFavorite: true,
                                      onFavoriteToggle: (movie, isFavorite) {
                                        context.read<MoviesListBloc>().add(
                                              ToggleFavorite(
                                                movie: movie,
                                                isFavorite: isFavorite,
                                              ),
                                            );
                                      },
                                      onTap: () {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                                'Movie details unavailable in offline mode'),
                                            duration: Duration(seconds: 2),
                                          ),
                                        );
                                      },
                                    );
                                  },
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  return Expanded(
                    child: BlocBuilder<MoviesListBloc, MoviesListState>(
                      builder: (context, state) {
                        if (state.status == MoviesListStatus.loading &&
                            state.movies.isEmpty) {
                          return const MovieLoadingWidget();
                        } else if (state.status == MoviesListStatus.failure) {
                          return MovieErrorWidget(
                            message: state.message,
                            onRetry: () => context
                                .read<MoviesListBloc>()
                                .add(const FetchMoviesList()),
                          );
                        } else if (state.movies.isEmpty) {
                          return const Center(
                            child: Text(
                              'No movies found',
                              style: TextStyle(fontSize: 18),
                            ),
                          );
                        }

                        return RefreshIndicator(
                          onRefresh: () async {
                            context.read<MoviesListBloc>().add(RefreshList());
                            return;
                          },
                          child: GridView.builder(
                            padding: const EdgeInsets.all(16),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              childAspectRatio: 0.5,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                            ),
                            itemCount: state.movies.length,
                            itemBuilder: (context, index) {
                              final movie = state.movies[index];
                              final isFavorite = state.favoriteMovies
                                  .any((fav) => fav.id == movie.id);

                              return MovieGridItem(
                                movie: movie,
                                isFavorite: isFavorite,
                                onFavoriteToggle: (movie, isFavorite) {
                                  context.read<MoviesListBloc>().add(
                                        ToggleFavorite(
                                          movie: movie,
                                          isFavorite: isFavorite,
                                        ),
                                      );
                                },
                                onTap: () async {
                                  await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => MovieDetailScreen(
                                        movie: movie,
                                        isFavorite: isFavorite,
                                      ),
                                    ),
                                  );
                                  // Refresh the list after returning from details
                                  context
                                      .read<MoviesListBloc>()
                                      .add(RefreshList());
                                },
                              );
                            },
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
