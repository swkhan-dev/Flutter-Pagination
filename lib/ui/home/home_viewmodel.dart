import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:pagination_flutter/core/api_service.dart';
import 'package:pagination_flutter/core/base_viewmodel.dart';
import 'package:pagination_flutter/core/movies_model.dart';

class HomeViewmodel extends BaseViewmodel {
  final ApiService _api;

  final List<Movie> _movies = [];
  int _pageIndex = 1;
  late ScrollController _scrollController;

  HomeViewmodel(this._api) {
    // Fetch Page 1 movies when the screen is built
    fetchMovies();

    _scrollController = ScrollController();

    // Adds a listner that checks if the scroll reach the bottom of list
    _scrollController.addListener(_onScroll);
  }

  // Getters
  List<Movie> get movies => _movies;
  int get pageIndex => _pageIndex;

  ScrollController get scrollController => _scrollController;

  //   Methods   //

  // Fetches movies
  fetchMovies() async {
    setstate(ViewState.loading);

    // Fecth movies from IMDB
    try {
      final response =
          await _api.get("/movie/now_playing?language=en-US&page=$_pageIndex");

      _movies.addAll(
        (response["results"] as List<dynamic>).map(
          (data) => Movie.fromJson(data),
        ),
      );
    } catch (e) {
      log(e.toString());
    }

    // Append the fetchd movies

    setstate(ViewState.idle);
  }

  _onScroll() {
    // Checks scroll to the bottom of the list
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      log("Page: $pageIndex Completed");
      _loadMore();
    }
  }

  // Loads next page movies
  _loadMore() async {
    // Get current Position
    final currentPosition = _scrollController.position.pixels;

    // Increment page to fetch the latest
    _pageIndex++;

    await fetchMovies();

    // Give a delay so that the scroll controller is attached to the listview after rebuild
    await Future.delayed(const Duration(microseconds: 5));

    // Jump to the position after list reload
    _scrollController.jumpTo(currentPosition);
  }

  // Dispose controllers to free memory
  @override
  void dispose() {
    super.dispose();
    _scrollController.dispose();
  }
}
