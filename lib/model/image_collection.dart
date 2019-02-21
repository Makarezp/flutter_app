class ImageCollection {
  final String id;

  final List<ImageEntity> images;

  final String title;

  ImageCollection(this.id, this.images, this.title);

  ImageCollection.fromJson(Map<String, dynamic> json)
      : this.id = json["id"],
        this.images = json["images"]
            .map((it) => ImageEntity.fromJson(it))
            .cast<ImageEntity>().toList(),
        this.title = json["title"];

  Map<String, dynamic> toJson() => {
        "id": id,
        "images": images.map((it) => it.toJson()).toList(),
        "title": title
      };

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

class ImageEntity {
  final String path;

  ImageEntity(this.path);

  ImageEntity.fromJson(Map<String, dynamic> json) : this.path = json["path"];

  Map<String, dynamic> toJson() => {"path": path};
}
