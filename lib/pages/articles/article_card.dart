import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:hayat_app/DB/db_article.dart';
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

  final DBArticle article;
  final bool large;
  final double _borderRadius;
  final bool _isInsideArticle;

  _ArticleCardState createState() => _ArticleCardState(article: article);
}

class _ArticleCardState extends State<ArticleCard> {
  _ArticleCardState({this.article});

  final DBArticle article;

  @override
  Widget build(BuildContext context) {
    return Hero(
      flightShuttleBuilder: (flightContext, animation, flightDirection,
          fromHeroContext, toHeroContext) {
        return toHeroContext.widget;
      },
      tag: this.article.baseRef.documentID,
      child: Material(
        color: Colors.transparent,
        child: Container(
          padding: EdgeInsets.only(
            left: 15,
            right: 15,
            bottom: this.widget.large ? 25 : 15,
            top: (widget._isInsideArticle
                ? AppBar().preferredSize.height + 10.0
                : (widget.large ? 25 : 15)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: Column(
                  children: <Widget>[
                    Align(
                      alignment: Alignment.topLeft,
                      child: Text(
                        this.article.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: hexColor(this.article.textColor),
                          fontSize: this.widget._isInsideArticle
                              ? 30
                              : this.widget.large ? 40 : 20,
                        ),
                      ),
                    ),
                    this.widget._isInsideArticle
                        ? Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  children: this
                                      .article
                                      .tags
                                      .map((e) => Padding(
                                            padding: const EdgeInsets.all(2.0),
                                            child: ActionChip(
                                                label: Text(e),
                                                onPressed: () {
                                                  //TODO implement a search based on tag?
                                                }),
                                          ))
                                      .toList(),
                                )),
                          )
                        : Container(),
                    Spacer(flex: 1),
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
                  this.article.star.value ? Icons.star : Icons.star_border,
                  color: hexColor(this.article.textColor),
                ),
                onPressed: () {
                  setState(() => this.article.star.value = !this.article.star.value);
                },
              ),
            ],
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(this.widget._borderRadius),
            image: DecorationImage(
              image: CachedNetworkImageProvider(this.article.img),
              fit: BoxFit.cover,
            )
          ),
        ),
      ),
    );
  }
}