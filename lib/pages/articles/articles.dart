import 'package:flutter/material.dart';
import 'package:hayat_app/pages/articles/article_card.dart';
import 'package:hayat_app/pages/articles/article_view_page.dart';

class ArticlesPage extends StatefulWidget {
  ArticlesPage({Key key}) : super(key: key);

  _ArticlesPageState createState() => _ArticlesPageState();
}

const String _ERROR_NO_ARTICLES = "There is no articles at the moment.";

class _ArticlesPageState extends State<ArticlesPage> {
  var articles = [];

  @override
  void initState() {
    super.initState();

    // TODO change the articles and make article class holder
    articles.addAll(["first", "second", "third"]);
  }

  Widget _buildArticleCardEntry(
      {title, textColor = Colors.white, img, large = false}) {

    var _outerCard = ArticleCard(
      title: title,
      textColor: textColor,
      tag: title,
      img: img,
      large: large,
    );

    var _innerCard = ArticleCard.insideArticlePage(
      title: title,
      textColor: textColor,
      tag: title,
      img: img,
    );

    return Container(
      margin: EdgeInsets.all(6),
      child: InkWell(
        child: _outerCard,
        onTap: () {
          Navigator.of(context).push(MaterialPageRoute(builder: (context) {
            return ArticleViewPage(_innerCard);
          }));
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // TODO use dynamic images
    if (articles.length >= 1) {
      return CustomScrollView(
        slivers: <Widget>[
          SliverFillViewport(
            delegate: SliverChildListDelegate([
              _buildArticleCardEntry(
                  title: articles[0],
                  large: true,
                  img:
                      'https://images.pexels.com/photos/949587/pexels-photo-949587.jpeg?auto=compress&cs=tinysrgb&dpr=1&w=500')
            ]),
          ),
          SliverPadding(
            padding: EdgeInsets.all(20),
          ),
          SliverList(
            delegate: SliverChildListDelegate(
              articles
                  .sublist(1)
                  .map((e) => _buildArticleCardEntry(
                      title: e,
                      textColor: Colors.black,
                      img:
                          'https://img.freepik.com/free-vector/vibrant-pink-watercolor-painting-background_53876-58930.jpg?size=626&ext=jpg'))
                  .toList(),
            ),
          )
        ],
      );
    } else {
      return Center(child: Text(_ERROR_NO_ARTICLES));
    }
  }
}
