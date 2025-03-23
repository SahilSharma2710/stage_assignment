import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stage_assignment/bloc/movieDetails/movie_details_bloc.dart';
import 'package:stage_assignment/bloc/movieDetails/movie_details_event.dart';
import 'package:stage_assignment/bloc/movieDetails/movie_details_state.dart';
import 'package:stage_assignment/models/movie_data_model.dart';
import 'package:stage_assignment/models/movie_details_model.dart';

class MovieDetailScreen extends StatefulWidget {
  final MovieDataModel movie;
  final bool isFavorite;

  const MovieDetailScreen({
    super.key,
    required this.movie,
    required this.isFavorite,
  });

  @override
  State<MovieDetailScreen> createState() => _MovieDetailScreenState();
}

class _MovieDetailScreenState extends State<MovieDetailScreen> {
  late bool isFavorite;

  @override
  void initState() {
    super.initState();
    isFavorite = widget.isFavorite;
    context.read<MovieDetailsBloc>().add(FetchMovieDetails(widget.movie.id));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: BlocBuilder<MovieDetailsBloc, MovieDetailsState>(
        builder: (context, state) {
          if (state.status == MovieDetailsStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state.status == MovieDetailsStatus.failure) {
            return Center(child: Text('Error: ${state.message}'));
          } else if (state.movie != null) {
            return _buildMovieDetailContent(context, state.movie!);
          } else {
            return const Center(child: Text('No movie details found'));
          }
        },
      ),
    );
  }

  Widget _buildMovieDetailContent(BuildContext context, MovieDetails movie) {
    final screenHeight = MediaQuery.of(context).size.height;

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: screenHeight * 0.45,
          pinned: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          actions: [
            IconButton(
              icon: Icon(
                isFavorite ? Icons.favorite : Icons.favorite_border,
                color: isFavorite ? Colors.red : Colors.white,
              ),
              onPressed: () {
                setState(() {
                  isFavorite = !isFavorite;
                });
                context.read<MovieDetailsBloc>().add(
                      ToggleFavoriteInDetails(
                        movie: widget.movie,
                        isFavorite: isFavorite,
                      ),
                    );
              },
            ),
          ],
          flexibleSpace: FlexibleSpaceBar(
            background: CachedNetworkImage(
              imageUrl: movie.posterPath.isNotEmpty
                  ? 'https://image.tmdb.org/t/p/original${movie.posterPath}'
                  : 'https://via.placeholder.com/500x750?text=No+Image',
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                color: Colors.grey[900],
                child: const Center(child: CircularProgressIndicator()),
              ),
              errorWidget: (context, url, error) => Container(
                color: Colors.grey[900],
                child: const Icon(Icons.error, color: Colors.white),
              ),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Movie title
                  Expanded(
                    child: Text(
                      movie.title,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  // Rating and year
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Row(
                        children: [
                          Text(
                            movie.originalLanguage,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                            ),
                          ),
                          const Icon(
                            Icons.star,
                            color: Colors.amber,
                            size: 20,
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          movie.releaseDate.substring(0, 4),
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Overview
              Text(
                movie.overview,
                style: const TextStyle(
                  fontSize: 16,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 8),
            ]),
          ),
        ),
      ],
    );
  }
}
