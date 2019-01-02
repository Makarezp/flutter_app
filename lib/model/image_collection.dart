
class ImageCollection {
  final String id;

  final List<String> images;

  ImageCollection(this.id, this.images);

  ImageCollection.fromJson(Map<String, dynamic> json)
      : this.id = json["id"],
        this.images = json["images"].cast<String>();

  Map<String, dynamic> toJson() => {"id": id, "images": images};
}
