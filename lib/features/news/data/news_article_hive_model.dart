import 'package:hive/hive.dart';

part 'news_article_hive_model.g.dart';

@HiveType(typeId: 0)
class NewsArticleHiveModel extends HiveObject {
  @HiveField(0)
  String title;

  @HiveField(1)
  String description;

  @HiveField(2)
  String urlToImage;

  @HiveField(3)
  String category;

  @HiveField(4) // ✅ New field
  String url;

  NewsArticleHiveModel({
    required this.title,
    required this.description,
    required this.urlToImage,
    required this.category,
    required this.url

  });
  factory NewsArticleHiveModel.fromJson(Map<String, dynamic> json, String category) {
    return NewsArticleHiveModel(
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      urlToImage: json['urlToImage'],
      url: json['url'] ?? '',
      // ✅ Map from JSON
      category: category,
    );
  }
}
