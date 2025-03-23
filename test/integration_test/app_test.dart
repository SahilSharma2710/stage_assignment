import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:stage_assignment/bloc/connectivity/connectivity_bloc.dart';
import 'package:stage_assignment/bloc/connectivity/connectivity_event.dart';
import 'package:stage_assignment/bloc/connectivity/connectivity_state.dart';
import 'package:stage_assignment/bloc/moviesList/movies_list_bloc.dart';
import 'package:stage_assignment/bloc/moviesList/movies_list_event.dart';
import 'package:stage_assignment/bloc/movieDetails/movie_details_bloc.dart';
import 'package:stage_assignment/screens/movie_list_screen.dart';
import 'package:stage_assignment/services/favourites/favorites_service.dart';
import 'package:stage_assignment/services/movies/movies_api_service.dart';
import 'package:stage_assignment/models/movie_data_model.dart';

// Mock classes
class MockFavoritesService extends Mock implements FavoritesService {}

class MockMovieApiService extends Mock implements MovieApiService {}

class MockConnectivityBloc extends Mock implements ConnectivityBloc {}

// Fake classes for event fallback values
class FakeConnectivityEvent extends Fake implements ConnectivityEvent {}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  // Register fallback values before all tests
  setUpAll(() {
    registerFallbackValue(FakeConnectivityEvent());
  });

  late MockFavoritesService favoritesService;
  late MockMovieApiService movieApiService;
  late MockConnectivityBloc connectivityBloc;
  late ConnectivityState connectivityState;

  setUp(() {
    favoritesService = MockFavoritesService();
    movieApiService = MockMovieApiService();
    connectivityBloc = MockConnectivityBloc();

    // Create a state for connectivity
    connectivityState =
        const ConnectivityState(status: ConnectionStatus.connected);

    // Mock the stream property
    when(() => connectivityBloc.stream)
        .thenAnswer((_) => Stream.fromIterable([connectivityState]));

    when(() => connectivityBloc.close()).thenAnswer((_) => Future.value());
    when(() => connectivityBloc.state).thenReturn(connectivityState);

    // Set up mock responses
    when(() => favoritesService.getFavoriteMovies())
        .thenAnswer((_) async => []);
    when(() => favoritesService.isMovieFavorite(any()))
        .thenAnswer((_) async => false);

    // Mock movie list response
    when(() => movieApiService.getMovies())
        .thenAnswer((_) async => List.generate(
            10,
            (index) => MovieDataModel(
                  id: index + 1,
                  title: 'Movie ${index + 1}',
                  posterPath: '/path/to/poster${index + 1}.jpg',
                  overview: 'Overview for movie ${index + 1}',
                  voteAverage: 7.5 + (index * 0.1),
                  releaseDate: '2023-01-${index + 1}',
                  adult: false,
                  backdropPath: '/path/to/backdrop${index + 1}.jpg',
                  genreIds: [1, 2, 3],
                  originalLanguage: 'en',
                  originalTitle: 'Movie ${index + 1}',
                  popularity: 100.0 + (index * 1.0),
                  video: false,
                  voteCount: 1000 + (index * 10),
                )));
  });

  Widget createTestApp() {
    return MaterialApp(
      home: MultiBlocProvider(
        providers: [
          BlocProvider<ConnectivityBloc>(
            create: (_) => connectivityBloc,
          ),
          BlocProvider<MoviesListBloc>(
            create: (_) => MoviesListBloc(
              movieApiService: movieApiService,
              favoritesService: favoritesService,
            )..add(FetchMoviesList()),
          ),
          BlocProvider<MovieDetailsBloc>(
            create: (_) => MovieDetailsBloc(
              movieApiService: movieApiService,
              favoritesService: favoritesService,
            ),
          ),
        ],
        child: const MoviesListScreen(),
      ),
    );
  }

  group('Movie App Integration Tests', () {
    testWidgets('App initializes correctly and shows movie list screen',
        (WidgetTester tester) async {
      // Mock the event addition
      when(() => connectivityBloc.add(any(that: isA<CheckConnectivity>())))
          .thenAnswer((_) {});

      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle();

      expect(find.text('Movies'), findsOneWidget);
      expect(find.byType(ListView), findsOneWidget);
    });

    testWidgets('Search functionality works', (WidgetTester tester) async {
      when(() => connectivityBloc.add(any(that: isA<CheckConnectivity>())))
          .thenAnswer((_) {});

      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'Movie 1');
      await tester.pumpAndSettle();

      expect(find.textContaining('Movie 1'), findsAtLeastNWidgets(1));
    });

    testWidgets('UI elements display correctly', (WidgetTester tester) async {
      when(() => connectivityBloc.add(any(that: isA<CheckConnectivity>())))
          .thenAnswer((_) {});

      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle();

      expect(find.byType(AppBar), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
      expect(find.byType(ListView), findsOneWidget);
    });
  });
}
