import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hayat_app/pages/articles/article_card.dart';
import 'package:hayat_app/pages/articles/article_data.dart';
import 'package:hayat_app/pages/articles/article_view_page.dart';

const TITLE = 'title';
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

  if(!snapshot.data.containsKey(PAGEREF))
    snapshot.data[PAGEREF] = Firestore.instance.collection(ARTICLES_PAGES_COLLECTION).document('default');

  if(!snapshot.data.containsKey(TAGS))
    snapshot.data[TAGS] = List<dynamic>();

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

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: Firestore.instance.collection(ARTICLES_HEADERS_COLLECTION).snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasData) {
          int count = snapshot.data.documents.length;

          if (count >= 1) {
            var first = _fillNotFoundData(snapshot.data.documents[0]);
            return CustomScrollView(slivers: <Widget>[
              SliverFillViewport(
                  delegate: SliverChildListDelegate([
                _buildArticleCardEntry(
                  ArticleData(
                    articlePage: first[PAGEREF],
                    title: first[TITLE],
                    textColor: first[TEXTCOLOR],
                    img: first[IMG],
                    tags: first[TAGS],
                    heroTag: first.documentID
                  ),
                  large: true,
                )
              ])),
              SliverPadding(
                padding: EdgeInsets.all(20),
              ),
              SliverList(
                  delegate: SliverChildBuilderDelegate(
                (_, index) {
                  var current =
                      _fillNotFoundData(snapshot.data.documents[index + 1]);
                  return _buildArticleCardEntry(
                    ArticleData(
                      articlePage: current[PAGEREF],
                      heroTag: current.documentID,
                      title: current[TITLE],
                      textColor: current[TEXTCOLOR],
                      img: current[IMG],
                      tags: current[TAGS]
                    ),
                  );
                },
                childCount: count - 1,
              ))
            ]);
          }
        }

        return const Center(child: Text(_ERROR_NO_ARTICLES));
      },
    );
  }
}
