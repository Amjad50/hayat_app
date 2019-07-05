import 'package:flutter/material.dart';
import 'package:hayat_app/pages/articles/article_card.dart';
import 'package:hayat_app/utils.dart';

class ArticleViewPage extends StatelessWidget {
  const ArticleViewPage(this.topCard, {Key key}) : super(key: key);

  final ArticleCard topCard;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: makeAppBarHeroFix(AppBar(
        title: Text(this.topCard.title),
      )),
      body: Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            this.topCard,
            // TODO change the text to the article content
            Text("paragraph")
          ],
        ),
      ),
    );
  }
}
