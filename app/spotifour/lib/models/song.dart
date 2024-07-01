class Song {
  String id;
  String title;
  String album;
  String artist;
  String source;
  String image;
  int duration;

  Song({
    required this.id,
    required this.title,
    required this.album,
    required this.artist,
    required this.source,
    required this.image,
    required this.duration,
  });

  factory Song.fromJson(Map<String, dynamic> json) {
    return Song(
      id: json["id"],
      title: json["title"],
      album: json["album"],
      artist: json["artist"],
      source: json["source"],
      image: json["image"],
      duration: json["duration"],
    );
  }

  factory Song.fromRTDB(Map<dynamic, dynamic> data) {
    return Song(
      id: data["id"],
      title: data["title"],
      album: data["album"],
      artist: data["artist"],
      source: data["source"],
      image: data["image"],
      duration: data["duration"],
    );
  }

  @override
  bool operator ==(Object other) => identical(this, other) || other is Song && runtimeType == other.runtimeType;

  @override
  int get hashCode => 0;

  @override
  String toString() {
    return 'Song{id: $id, title: $title, album: $album, artist: $artist, source: $source, image: $image, duration: $duration}';
  }
}
