import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:hayat_app/pages/articles/article_data.dart';
import 'package:hayat_app/utils.dart';

class ArticleCard extends StatefulWidget {
  const ArticleCard(this.article, {Key key, this.large = false})
      : this._borderRadius = 10,
        this._isInsideArticle = false,
        super(key: key);

  const ArticleCard.insideArticlePage(this.article, {Key key})
      : this._borderRadius = 0,
        this.large = true,
        this._isInsideArticle = true,
        super(key: key);

  final ArticleData article;
  final bool large;
  final double _borderRadius;
  final bool _isInsideArticle;

  _ArticleCardState createState() => _ArticleCardState(article: article);
}

class _ArticleCardState extends State<ArticleCard> {
  _ArticleCardState({this.article});

  final ArticleData article;

  @override
  Widget build(BuildContext context) {
    return Hero(
      flightShuttleBuilder: (flightContext, animation, flightDirection,
          fromHeroContext, toHeroContext) {
        return toHeroContext.widget;
      },
      tag: this.article.heroTag,
      child: Material(
        color: Colors.transparent,
        child: Container(
          padding: EdgeInsets.symmetric(
              horizontal: 15, vertical: this.widget.large ? 25 : 15),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: Column(
                  children: <Widget>[
                    MarkdownBody(
                      data: mergeMarkdownArray(this.article.mainTitle),
                      // TODO: make global styleSheet
                      // TODO: fix bug overflow when transiting to article view
                      styleSheet: MarkdownStyleSheet(
                        p: TextStyle(
                          color: hexColor(this.article.textColor),
                          fontSize: this.widget.large ? 40 : 20,
                        ),
                      ),
                    ),
                    this.widget._isInsideArticle
                        ? Wrap(
                            children: this
                                .article
                                .tags
                                .map((e) => Padding(
                                      padding: const EdgeInsets.all(2.0),
                                      child: ActionChip(
                                          label: Text(e),
                                          //TODO: choose color?
                                          onPressed: () {
                                            //TODO implement a search based on tag?
                                          }),
                                    ))
                                .toList(),
                          )
                        : Container(),
                    this.widget._isInsideArticle
                        ? Container()
                        : Spacer(
                            flex: 1,
                          ),
                    Align(
                      alignment: Alignment.bottomLeft,
                      child: Text(
                        parseTimestamp(this.article.date),
                        style:
                            TextStyle(color: hexColor(this.article.textColor)),
                        textAlign: TextAlign.start,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(
                  this.article.star ? Icons.star : Icons.star_border,
                  color: this.article.star
                      ? Colors.yellow
                      : hexColor(this.article.textColor),
                ),
                onPressed: () {
                  setState(() => this.article.star = !this.article.star);
                },
              ),
            ],
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(this.widget._borderRadius),
            image: DecorationImage(
              image: CachedNetworkImageProvider(this.article.img),
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
    );
  }
}