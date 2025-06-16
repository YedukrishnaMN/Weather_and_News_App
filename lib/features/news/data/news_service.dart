import 'dart:convert';
import 'package:http/http.dart' as http;
import 'news_model.dart';

class NewsService {
  final String apiKey = 'c4aa1515472a49aaa481746ec6a83613'; 
  final String country = 'us'; 

  Future<List<NewsArticle>> fetchTopHeadlines() async {
    final url = Uri.parse(
        'https://newsapi.org/v2/top-headlines?country=$country&apiKey=$apiKey');

    final response = await http.get(url);
    print('News API response status: ${response.statusCode}');
    print('News API response body: ${response.body}');


    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);

      final List articles = data['articles'];
      print('Fetched ${articles.length} articles');

      return articles
          .map((article) => NewsArticle(
                title: article['title'] ?? 'No title',
                description: article['description'] ?? 'No description',
                urlToImage: article['urlToImage'] ??
                    'https://via.placeholder.com/150/000000/FFFFFF/?text=No+Image',
                category: 'general',
                url: 'general'
              ))
          .toList();
    } else {
      throw Exception('Failed to load news: ${response.statusCode}');
    }
  }
}
