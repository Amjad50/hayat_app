import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hayat_app/pages/articles/article_card.dart';
import 'package:hayat_app/pages/articles/article_data.dart';
import 'package:hayat_app/pages/articles/article_view_page.dart';

const TITLE = 'title';
const MAINTITLE = 'mainTitle';
const IMG = 'img';
const TEXTCOLOR = 'textColor';
const TAGS = 'tags';
const PAGEREF = 'page';

const ARTICLES_HEADERS_COLLECTION = 'articles_headers';
const ARTICLES_PAGES_COLLECTION = 'articles_pages';

/// setup the default values in case any of them is not present
DocumentSnapshot _fillNotFoundData(DocumentSnapshot snapshot) {
  if (!snapshot.data.containsKey(TITLE)) snapshot.data[TITLE] = 'null';
  if (!snapshot.data.containsKey(IMG))
    snapshot.data[IMG] =
        'https://images.pexels.com/photos/949587/pexels-photo-949587.' +
            'jpeg?auto=compress&cs=tinysrgb&dpr=1&w=500';
  if (!snapshot.data.containsKey(TEXTCOLOR))
    snapshot.data[TEXTCOLOR] = "#ffffffff";

  if (!snapshot.data.containsKey(PAGEREF))
    snapshot.data[PAGEREF] = Firestore.instance
        .collection(ARTICLES_PAGES_COLLECTION)
        .document('default');

  if (!snapshot.data.containsKey(TAGS) ||
      !(snapshot.data[TAGS] is List<dynamic>))
    snapshot.data[TAGS] = List<dynamic>();

  if (!snapshot.data.containsKey(MAINTITLE) ||
      !(snapshot.data[MAINTITLE] is List<dynamic>))
    snapshot.data[MAINTITLE] = ['**no**\ntitle'];
  return snapshot;
}

class ArticlesPage extends StatefulWidget {
  ArticlesPage({Key key}) : super(key: key);

  _ArticlesPageState createState() => _ArticlesPageState();
}

const String _ERROR_NO_ARTICLES = "There is no articles at the moment.";

class _ArticlesPageState extends State<ArticlesPage> {
  Widget _buildArticleCardEntry(ArticleData article, {large = false}) {
    return Container(
      margin: EdgeInsets.all(6),
      child: InkWell(
        child: ArticleCard(article, large: large),
        onTap: () {
          Navigator.of(context).push(MaterialPageRoute(builder: (context) {
            return ArticleViewPage(article);
          }));
        },
      ),
    );
  }

  List<Widget> _buildPageViews(List<DocumentSnapshot> documents) {
    // the best size for Nexus 5X is '6'
    const _EACH_PAGE_COUNT = 8;

    final list = <Widget>[];
    if (documents.length >= 1) {
      var first = _fillNotFoundData(documents[0]);
      list.add(_buildArticleCardEntry(
        ArticleData(
            mainTitle: first[MAINTITLE],
            articlePage: first[PAGEREF],
            title: first[TITLE],
            textColor: first[TEXTCOLOR],
            img: first[IMG],
            tags: first[TAGS],
            heroTag: first.documentID),
        large: true,
      ));

      int _generatePage (int oldIndex, int max) {
        var childList = <Widget>[];
        int i = oldIndex;
        for (; i < max; i++) {
          DocumentSnapshot current = _fillNotFoundData(documents[i]);
          childList.add(_buildArticleCardEntry(
            ArticleData(
                mainTitle: current[MAINTITLE],
                articlePage: current[PAGEREF],
                heroTag: current.documentID,
                title: current[TITLE],
                textColor: current[TEXTCOLOR],
                img: current[IMG],
                tags: current[TAGS]),
          ));
        }
        if(max - oldIndex < _EACH_PAGE_COUNT){
          for (int i = max - oldIndex; i < _EACH_PAGE_COUNT; i++) {
            // Padding for the last page
            childList.add(Container());
          }
        }
        list.add(Column(children: childList.map((e) => Expanded(child: e, flex: 1,)).toList()));
        return i;
      }

      var currentI = 1;
      for (var _ = 0; _ < (documents.length - 1) ~/ _EACH_PAGE_COUNT; _++) {
        currentI = _generatePage(currentI, currentI + _EACH_PAGE_COUNT);
      }

      if (currentI < documents.length) {
        _generatePage(currentI, documents.length);
      }
    }

    return list;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: Firestore.instance
          .collection(ARTICLES_HEADERS_COLLECTION)
          .snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasData) {
          int count = snapshot.data.documents.length;

          if (count >= 1) {
            final controller = PageController(initialPage: 0);
            final children = _buildPageViews(snapshot.data.documents);

            return PageView(
              controller: controller,
              scrollDirection: Axis.vertical,
              children: children
            );
          }
        }

        return const Center(child: Text(_ERROR_NO_ARTICLES));
      },
    );
  }
}
