class ImageCollection {
  final String id;

  final List<String> images;

  final String title;

  ImageCollection(this.id, this.images, this.title);

  ImageCollection.fromJson(Map<String, dynamic> json)
      : this.id = json["id"],
        this.images = json["images"].cast<String>(),
        this.title = json["title"];

  Map<String, dynamic> toJson() => {"id": id, "images": images, "title": title};

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ImageCollection &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          images == other.images;

  @override
  int get hashCode => id.hashCode ^ images.hashCode;
}
