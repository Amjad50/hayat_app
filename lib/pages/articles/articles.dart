import 'package:flutter/material.dart';

class ExpandableArticleImage extends StatelessWidget {
  const ExpandableArticleImage(
      {Key key,
      this.title,
      this.textColor,
      this.tag,
      this.img,
      this.large = false})
      : this._borderRadius = 0,
        super(key: key);

  const ExpandableArticleImage.withBorderRadius(
      {Key key,
      this.title,
      this.textColor,
      this.tag,
      this.img,
      this.large = false})
      : this._borderRadius = 10,
        super(key: key);

  final String tag;
  final Color textColor;
  final String title;
  final String img;
  final bool large;
  final double _borderRadius;

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: this.tag,
      child: Container(
        child: Padding(
          padding: EdgeInsets.symmetric(
              horizontal: 15, vertical: this.large ? 25 : 15),
          child: Material(
            color: Colors.transparent,
            child: Text(
              title,
              style:
                  TextStyle(color: textColor, fontSize: this.large ? 40 : 20),
              textAlign: TextAlign.center,
            ),
          ),
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(this._borderRadius),
          image: DecorationImage(
            image: NetworkImage(this.img),
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}

class Article extends StatelessWidget {
  const Article(
      {Key key,
      this.title = "",
      this.large = false,
      this.textColor = Colors.white,
      @required this.img})
      : super(key: key);

  final String title;
  final bool large;
  final Color textColor;
  final String img;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(6),
      child: InkWell(
        child: ExpandableArticleImage.withBorderRadius(
          title: this.title,
          textColor: this.textColor,
          tag: this.title,
          img: this.img,
          large: this.large,
        ),
        onTap: () {
          Navigator.of(context).push(MaterialPageRoute(builder: (context) {
            return Scaffold(
              appBar: AppBar(
                title: Text(this.title),
              ),
              body: Container(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    ExpandableArticleImage(
                        title: this.title,
                        textColor: this.textColor,
                        tag: this.title,
                        img: this.img,
                        large: true),
                    // TODO change the text to the article content
                    Text("paragraph")
                  ],
                ),
              ),
            );
          }));
        },
      ),
    );
  }
}

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
    articles.addAll(["first", "second"]);
  }

  @override
  Widget build(BuildContext context) {
    // TODO use dynamic images
    if (articles.length >= 1) {
      return CustomScrollView(
        slivers: <Widget>[
          SliverFillViewport(
            delegate: SliverChildListDelegate([
              Article(
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
                  .map((e) => Article(
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
