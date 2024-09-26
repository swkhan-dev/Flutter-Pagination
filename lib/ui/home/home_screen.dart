import 'package:flutter/material.dart';
import 'package:pagination_flutter/core/api_service.dart';
import 'package:pagination_flutter/core/base_viewmodel.dart';
import 'package:pagination_flutter/core/movies_model.dart';
import 'package:pagination_flutter/ui/home/home_viewmodel.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<HomeViewmodel>(
      create: (context) => HomeViewmodel(ApiService()),
      child: Consumer<HomeViewmodel>(
        builder: (context, model, child) {
          return Scaffold(
            appBar: _buildAppbar(),
            body: (model.state == ViewState.loading && model.pageIndex == 1)
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : _buildMoviesList(model),
          );
        },
      ),
    );
  }

  AppBar _buildAppbar() {
    return AppBar(
      title: const Text("Flutter Pagination"),
    );
  }

  Stack _buildMoviesList(HomeViewmodel model) {
    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: ListView.separated(
            controller: model.scrollController,
            itemCount: model.movies.length,
            separatorBuilder: (context, index) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final movie = model.movies[index];
              return MovieTile(movie: movie);
            },
          ),
        ),
        model.state == ViewState.loading && model.pageIndex != 1
            ? _buildMoreFetchLoader()
            : const SizedBox.shrink()
      ],
    );
  }

  Align _buildMoreFetchLoader() {
    return const Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: EdgeInsets.only(bottom: 80),
        child:
            SizedBox(height: 35, width: 35, child: CircularProgressIndicator()),
      ),
    );
  }
}

class MovieTile extends StatelessWidget {
  const MovieTile({super.key, required this.movie});

  final Movie movie;
  static String imdbImageUrlPrefix = "https://image.tmdb.org/t/p/w500";

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(5),
          child: Image.network(
            "$imdbImageUrlPrefix${movie.posterPath}",
            height: 90,
            width: 70,
            fit: BoxFit.fill,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(
              movie.title!,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              "${movie.overview}",
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            )
          ]),
        ),
        const SizedBox(width: 10),
        Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const Text(
              "Release:",
              style: TextStyle(fontSize: 12),
            ),
            Text(
              "${movie.releaseDate}",
              style: const TextStyle(fontSize: 12),
            ),
            const Text(
              "Ratings:",
              style: TextStyle(fontSize: 12),
            ),
            Text(
              "${movie.voteAverage!.toStringAsFixed(2)}/10",
              style: const TextStyle(fontSize: 12),
            ),
          ],
        )
      ],
    );
  }
}
