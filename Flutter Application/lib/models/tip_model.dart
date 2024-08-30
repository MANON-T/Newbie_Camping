class TipModel {
  String topic;
  String description;
  String imageURL;
  TipModel({required this.topic, required this.description, required this.imageURL});

  factory TipModel.fromMap(Map<String, dynamic>? tip) {
    if (tip != null) {
      String topic = tip['topic'];
      String description = tip['description'];
      String imageURL = tip['imageURL'];
      return TipModel(topic: topic, description: description, imageURL: imageURL);
    } else {
      throw ArgumentError('Unexpected type for product');
    }
  }
  Map<String, dynamic> toMap() {
    return {'topic': topic, 'description': description , 'imageURL': imageURL};
  }
}
