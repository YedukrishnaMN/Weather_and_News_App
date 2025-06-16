import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:weather_news_dashboard/features/news/data/news_article_hive_model.dart';

class BookmarkedNewsScreen extends StatelessWidget {
  const BookmarkedNewsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final Box<NewsArticleHiveModel> box = Hive.box<NewsArticleHiveModel>('bookmarks');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bookmarked Articles'),
      ),
      body: ValueListenableBuilder(
        valueListenable: box.listenable(),
        builder: (context, Box<NewsArticleHiveModel> box, _) {
          if (box.isEmpty) {
            return const Center(child: Text('No bookmarks yet.'));
          }

          return ListView.builder(
            itemCount: box.length,
            itemBuilder: (context, index) {
              final article = box.getAt(index);

              return Card(
                margin: const EdgeInsets.all(8.0),
                child: ListTile(
                  leading: Image.asset(
                    'assets/images/bookmark.png',
                    width: 100,
                    fit: BoxFit.cover,
                  ),
                  title: Text(article?.title ?? ''),
                  subtitle: Text(article?.description ?? ''),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () {
                      box.deleteAt(index);
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
