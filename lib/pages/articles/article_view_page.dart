import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:hayat_app/pages/articles/article_card.dart';
import 'package:hayat_app/pages/articles/article_data.dart';
import 'package:hayat_app/utils.dart';

const DATAKEY = 'data';
// for markdown used '*', must keep up with firestore's 'default' entry
const _ERROR_NO_ARTICLE_PAGE_FOUND = "**no** *such article is found*";

class ArticleViewPage extends StatelessWidget {
  const ArticleViewPage(this.article, {Key key}) : super(key: key);

  final ArticleData article;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: CustomScrollView(
      slivers: <Widget>[
        SliverAppBar(
            expandedHeight: 225,
            pinned: true,
            elevation: 5,
            flexibleSpace: FlexibleSpaceBar(
              background: ArticleCard.insideArticlePage(article),
            )),
        SliverList(
          delegate: SliverChildListDelegate([
            Container(
              margin: EdgeInsets.all(10),
              child: StreamBuilder<DocumentSnapshot>(
                stream: this.article.articlePage.snapshots(),
                builder: (BuildContext context,
                    AsyncSnapshot<DocumentSnapshot> snapshot) {
                  if (snapshot.hasData &&
                      snapshot.data.exists &&
                      snapshot.data.data.containsKey(DATAKEY)) {
                    var articleData = snapshot.data.data[DATAKEY];
                    if (articleData is List<dynamic>) {
                      String article = mergeMarkdownArray(articleData);
                      return MarkdownBody(data: article);
                    }
                  }
                  return MarkdownBody(data: _ERROR_NO_ARTICLE_PAGE_FOUND);
                },
              ),
            )
          ]),
        )
      ],
    ));
  }
}
