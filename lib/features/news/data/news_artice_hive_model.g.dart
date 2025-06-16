// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'news_article_hive_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class NewsArticleHiveModelAdapter extends TypeAdapter<NewsArticleHiveModel> {
  @override
  final int typeId = 0;

  @override
  NewsArticleHiveModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return NewsArticleHiveModel(
      title: fields[0] as String,
      description: fields[1] as String,
      urlToImage: fields[2] as String,
      category: fields[3] as String,
      url: fields[4] as String,
    );
  }

  @override
  void write(BinaryWriter writer, NewsArticleHiveModel obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.title)
      ..writeByte(1)
      ..write(obj.description)
      ..writeByte(2)
      ..write(obj.urlToImage)
      ..writeByte(3)
      ..write(obj.category)
      ..writeByte(4)
      ..write(obj.url);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NewsArticleHiveModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
