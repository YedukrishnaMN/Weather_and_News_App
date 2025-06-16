class NewsArticle {
  final String title;
  final String description;
  final String urlToImage;
  final String category;
  final String url;

  NewsArticle({
    required this.title,
    required this.description,
    required this.urlToImage,
    required this.category,
    required this.url,

  });

  factory NewsArticle.fromJson(Map<String, dynamic> json) {
    return NewsArticle(
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      urlToImage: json['urlToImage'] ?? '',
      category: json['category'] ?? 'general',
      url: json['url'] ?? '',// fallback
    );
  }
}
