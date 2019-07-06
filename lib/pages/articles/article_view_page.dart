import 'package:flutter/material.dart';
import 'package:hayat_app/pages/articles/article_card.dart';
import 'package:hayat_app/pages/articles/article_data.dart';
import 'package:hayat_app/utils.dart';

class ArticleViewPage extends StatelessWidget {
  const ArticleViewPage(this.article, {Key key}) : super(key: key);

  final ArticleData article;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: makeAppBarHeroFix(AppBar(
        title: Text(this.article.title),
      )),
      body: Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            ArticleCard.insideArticlePage(article),
            // TODO change the text to the article content
            Text("paragraph")
          ],
        ),
      ),
    );
  }
}
