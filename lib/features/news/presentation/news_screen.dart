import 'package:flutter/material.dart';
import 'package:weather_news_dashboard/features/news/data/news_service.dart';
import 'package:weather_news_dashboard/features/news/data/news_model.dart';
import 'dart:async';

import 'package:weather_news_dashboard/features/news/presentation/bookmarked_news_screen.dart';

import 'package:hive/hive.dart';
import 'package:weather_news_dashboard/features/news/data/news_article_hive_model.dart';

import 'package:share_plus/share_plus.dart';


class NewsScreen extends StatefulWidget {
  const NewsScreen({super.key});

  @override
  State<NewsScreen> createState() => _NewsScreenState();
}

TextEditingController _searchController = TextEditingController();
Timer? _debounce;
String _searchQuery = '';

class _NewsScreenState extends State<NewsScreen> {
  late Future<List<NewsArticle>> _newsFuture;
  String selectedCategory = 'all'; // tracks which category is selected
  final categories = ['all', 'business', 'sports', 'technology', 'weather'];

  @override
  void initState() {
    super.initState();
    _newsFuture = NewsService().fetchTopHeadlines();
  }

  Future<void> _refreshNews() async {
    setState(() {
      _newsFuture = NewsService()
          .fetchTopHeadlines(); // Or whatever your function is called
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('News'),
        actions: [
          IconButton(
            icon: Icon(Icons.bookmarks),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const BookmarkedNewsScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search articles...',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (query) {
                if (_debounce?.isActive ?? false) _debounce!.cancel();
                _debounce = Timer(const Duration(milliseconds: 500), () {
                  setState(() {
                    _searchQuery = query.toLowerCase();
                  });
                });
              },
            ),
          ),

          // CATEGORY BUTTONS
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: categories.map((cat) {
                return Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 4.0, vertical: 8.0),
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        selectedCategory = cat;
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          selectedCategory == cat ? Colors.blue : Colors.grey,
                    ),
                    child: Text(cat.toUpperCase()),
                  ),
                );
              }).toList(),
            ),
          ),

          // FILTERED NEWS LIST
          Expanded(
            child: FutureBuilder<List<NewsArticle>>(
              future: _newsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return const Center(child: Text('Failed to load news'));
                } else {
                  final articles = snapshot.data!;
                  final filteredArticles = articles.where((a) {
                    final matchCategory = selectedCategory == 'all' ||
                        a.category == selectedCategory;
                    final matchSearch =
                        a.title.toLowerCase().contains(_searchQuery);
                    return matchCategory && matchSearch;
                  }).toList();
                  return RefreshIndicator(
                    onRefresh: _refreshNews,
                    child: ListView.builder(
                      itemCount: filteredArticles.length,
                      itemBuilder: (context, index) {
                        final article = filteredArticles[index];
                        return Card(
                          margin: const EdgeInsets.all(8.0),
                          child: ListTile(
                            leading: article.urlToImage != null &&
                                    article.urlToImage!.isNotEmpty
                                ? Image.network(article.urlToImage!,
                                    width: 100, fit: BoxFit.cover)
                                : Image.asset('assets/images/news.png',
                                    width: 100, fit: BoxFit.cover),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: Icon(Icons.bookmark_add),
                                  onPressed: () async {
                                    final box = await Hive.openBox<NewsArticleHiveModel>('bookmarked_articles');

                                    final bookmarked = NewsArticleHiveModel(
                                      title: article.title,
                                      description: article.description,
                                      urlToImage: article.urlToImage,
                                      category: article.category,
                                      url: article.url
                                    );

                                    await box.add(bookmarked);

                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Article bookmarked!')),
                                    );
                                  },
                                ),
                                IconButton(
                                  icon: Icon(Icons.share),
                                  onPressed: () {
                                    Share.share('${article.title}\n${article.url}');
                                  },
                                ),
                              ],
                            ),

                          ),
                        );
                      },
                    ),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
