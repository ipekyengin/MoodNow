class Movie {
  final int id;
  final String title;
  final String? posterPath;
  final String overview;
  final double voteAverage;
  String? userNote;

  Movie({
    required this.id,
    required this.title,
    this.posterPath,
    required this.overview,
    required this.voteAverage,
    this.userNote,
  });

  factory Movie.fromJson(Map<String, dynamic> json) {
    return Movie(
      id: json['id'],
      title: json['title'] ?? 'Unknown Title',
      posterPath: json['poster_path'],
      overview: json['overview'] ?? 'No overview available.',
      voteAverage: (json['vote_average'] as num?)?.toDouble() ?? 0.0,
      userNote: json['user_note'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'poster_path': posterPath,
      'overview': overview,
      'vote_average': voteAverage,
      'user_note': userNote,
    };
  }
}
