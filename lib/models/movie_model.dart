class Movie {
  final int id;
  final String title;
  final String? posterPath;
  final String overview;
  final double voteAverage;
  String? userNote;
  final String mediaType; // 'movie' or 'tv'
  bool isFavorite;
  String? listName;
  final String? releaseDate; // 'release_date' or 'first_air_date'

  Movie({
    required this.id,
    required this.title,
    this.posterPath,
    required this.overview,
    required this.voteAverage,
    this.userNote,
    this.mediaType = 'movie',
    this.isFavorite = false,
    this.listName,
    this.releaseDate,
  });

  factory Movie.fromJson(Map<String, dynamic> json) {
    // TMDB often returns 'original_title' for movies and 'original_name' for TV
    // But usually 'title' or 'name' is the display one.
    final String title = json['title'] ?? json['name'] ?? 'Unknown Title';

    // Explicitly handle media_type. Default to 'movie' only if strictly necessary.
    String mediaType = (json['media_type'] ?? 'movie').toString().toLowerCase();
    // Normalize just in case
    if (mediaType != 'movie' && mediaType != 'tv') {
      // If it looks like a TV show (has name but no title), lean towards tv?
      // But safer to default to movie as per previous logic, just ensuring string consistency.
      mediaType = 'movie';
    }

    final String? releaseDate = json['release_date'] ?? json['first_air_date'];

    return Movie(
      id: json['id'],
      title: title,
      posterPath: json['poster_path'],
      overview: json['overview'] ?? 'No overview available.',
      voteAverage: (json['vote_average'] as num?)?.toDouble() ?? 0.0,
      userNote: json['user_note'],
      mediaType: mediaType,
      isFavorite: json['is_favorite'] ?? false,
      listName: json['list_name'],
      releaseDate: releaseDate,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      // For consistency when saving back, we might want to store 'name' too if we were strict,
      // but 'title' covers our usage.
      'poster_path': posterPath,
      'overview': overview,
      'vote_average': voteAverage,
      'user_note': userNote,
      'media_type': mediaType,
      'is_favorite': isFavorite,
      'list_name': listName,
      'release_date': releaseDate,
      'first_air_date': releaseDate, // For compatibility if needed
    };
  }
}
