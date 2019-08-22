import 'package:flutter/material.dart';
import 'package:hayat_app/DB/db_article.dart';
import 'package:hayat_app/DB/db_user.dart';
import 'package:hayat_app/DB/firestore_handler.dart';
import 'package:hayat_app/pages/articles/article_card.dart';
import 'package:hayat_app/pages/articles/article_view_page.dart';
import 'package:hayat_app/pages/basepage.dart';

class ArticlesPage extends BasePage {
  ArticlesPage({Key key}) : super(key: key);

  _ArticlesPageState createState() => _ArticlesPageState();
}

const String _ERROR_NO_ARTICLES = "There is no articles at the moment.";

class _ArticlesPageState extends State<ArticlesPage> {
  PageController _controller;
  DBUser user;

  @override
  void initState() {
    super.initState();
    _controller = PageController(initialPage: 0);
    user = FireStoreHandler.instance.user;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildArticleCardEntry(final DBArticle article, {large = false}) {
    return Container(
      margin: EdgeInsets.all(6),
      child: InkWell(
        child: ArticleCard(
          article,
          large: large,
        ),
        onTap: () {
          Navigator.of(context).push(MaterialPageRoute(builder: (context) {
            return ArticleViewPage(article);
          }));
        },
      ),
    );
  }

  List<Widget> _buildPageViews(List<DBArticle> articles) {
    // the best size for Nexus 5X is '6'
    const _EACH_PAGE_COUNT = 4;

    final list = <Widget>[];
    if (articles.length >= 1) {
      list.add(_buildArticleCardEntry(articles[0], large: true));

      int _generatePage(int oldIndex, int max) {
        var childList = <Widget>[];
        int i = oldIndex;
        for (; i < max; i++) {
          childList.add(_buildArticleCardEntry(articles[i]));
        }
        if (max - oldIndex < _EACH_PAGE_COUNT) {
          for (int i = max - oldIndex; i < _EACH_PAGE_COUNT; i++) {
            // Padding for the last page
            childList.add(Container());
          }
        }
        list.add(Column(
            children: childList
                .map((e) => Expanded(
                      child: e,
                      flex: 1,
                    ))
                .toList()));
        return i;
      }

      var currentI = 1;
      for (var _ = 0; _ < (articles.length - 1) ~/ _EACH_PAGE_COUNT; _++) {
        currentI = _generatePage(currentI, currentI + _EACH_PAGE_COUNT);
      }

      if (currentI < articles.length) {
        _generatePage(currentI, articles.length);
      }
    }

    return list;
  }

  @override
  Widget build(BuildContext context) {
    return FireStoreHandler.instance.articlesHeadersStreamBuilder(
        builder: (BuildContext context, List<DBArticle> articles) {
      int count = articles.length;

      if (count > 0) {
        final children = _buildPageViews(articles);

        return PageView(
          controller: _controller,
          scrollDirection: Axis.vertical,
          children: children,
        );
      }

      return const Center(
          child: const Text(
        _ERROR_NO_ARTICLES,
        style: TextStyle(color: Colors.red),
      ));
    });
  }
}
