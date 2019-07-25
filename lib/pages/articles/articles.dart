import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hayat_app/pages/articles/article_card.dart';
import 'package:hayat_app/pages/articles/article_data.dart';
import 'package:hayat_app/pages/articles/article_view_page.dart';
import 'package:hayat_app/pages/basepage.dart';

const TITLE = 'title';
const MAINTITLE = 'mainTitle';
const IMG = 'img';
const TEXTCOLOR = 'textColor';
const TAGS = 'tags';
const PAGEREF = 'page';
const DATE = 'date';

const FAVS = 'favs';

const ARTICLES_HEADERS_COLLECTION = 'articles_headers';
const ARTICLES_PAGES_COLLECTION = 'articles_pages';
const USERS_COLLECTION = 'users';

/// setup the default values in case any of them is not present
DocumentSnapshot _fillNotFoundArticleData(DocumentSnapshot snapshot) {
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

  if (!snapshot.data.containsKey(DATE)) snapshot.data[DATE] = Timestamp.now();
  return snapshot;
}

DocumentSnapshot _fillNotFoundUserData(DocumentSnapshot snapshot) {
  if (!snapshot.data.containsKey(FAVS) ||
      !(snapshot.data[FAVS] is List<dynamic>))
    snapshot.data[FAVS] = List<dynamic>();

  return snapshot;
}

class ArticlesPage extends BasePage {
  ArticlesPage({Key key, String uid}) : super(key: key, uid: uid);

  _ArticlesPageState createState() => _ArticlesPageState();
}

const String _ERROR_NO_ARTICLES = "There is no articles at the moment.";

class _ArticlesPageState extends State<ArticlesPage> {
  PageController _controller;

  @override
  void initState() {
    super.initState();
    _controller = PageController(initialPage: 0);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildProgress() {
    return const Center(child: const CircularProgressIndicator());
  }

  Widget _buildArticleCardEntry(final ArticleData article, {large = false}) {
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

  List<Widget> _buildPageViews(List<ArticleData> articles, List<dynamic> favs) {
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
    return StreamBuilder<QuerySnapshot>(
      stream: Firestore.instance
          .collection(ARTICLES_HEADERS_COLLECTION)
          .snapshots(),
      builder: (BuildContext context,
          AsyncSnapshot<QuerySnapshot> articles_snapshot) {
        if (articles_snapshot.hasData) {
          int count = articles_snapshot.data.documents.length;

          if (count > 0) {
            return StreamBuilder<DocumentSnapshot>(
              stream: Firestore.instance
                  .collection(USERS_COLLECTION)
                  .document(widget.uid)
                  .snapshots(),
              builder: (BuildContext context,
                  AsyncSnapshot<DocumentSnapshot> userdata_snapshot) {
                if (userdata_snapshot.hasData) {
                  if (userdata_snapshot.data.exists) {
                    DocumentSnapshot userdata =
                        _fillNotFoundUserData(userdata_snapshot.data);

                    // handles changes on star (favorite)
                    void favChange(DocumentReference reference, bool isFav) {
                      final newMap = Map<String, dynamic>();

                      final newFAVS = List.from(userdata.data[FAVS]);

                      if (isFav) {
                        if (!newFAVS.contains(reference))
                          newFAVS.add(reference);
                      } else {
                        newFAVS.remove(reference);
                      }

                      newMap[FAVS] = newFAVS;

                      Firestore.instance
                          .collection(USERS_COLLECTION)
                          .document(widget.uid)
                          .updateData(newMap)
                          .then((e) => setState(() {}));
                    }

                    final List<ArticleData> articles =
                        articles_snapshot.data.documents.map(
                      (e) {
                        final current = _fillNotFoundArticleData(e);
                        final article = ArticleData(
                          mainTitle: current[MAINTITLE],
                          articlePage: current[PAGEREF],
                          heroTag: current.documentID,
                          title: current[TITLE],
                          textColor: current[TEXTCOLOR],
                          img: current[IMG],
                          tags: current[TAGS],
                          date: current[DATE],
                          star: userdata.data[FAVS].contains(current.reference),
                        );

                        article.star.addListener(() =>
                            favChange(current.reference, article.star.value));
                        return article;
                      },
                    ).toList();

                    final children =
                        _buildPageViews(articles, userdata.data[FAVS]);

                    return PageView(
                      controller: _controller,
                      scrollDirection: Axis.vertical,
                      children: children,
                    );
                  } else {
                    Firestore.instance
                        .collection(USERS_COLLECTION)
                        .document(widget.uid)
                        .setData(Map<String, dynamic>()).then((v) {
                          setState(() {
                          });
                        });
                  }
                }
                return _buildProgress();
              },
            );
          }

          return const Center(
              child: const Text(
            _ERROR_NO_ARTICLES,
            style: TextStyle(color: Colors.red),
          ));
        }

        return _buildProgress();
      },
    );
  }
}
