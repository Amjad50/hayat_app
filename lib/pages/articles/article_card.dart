import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:hayat_app/pages/articles/article_data.dart';
import 'package:hayat_app/utils.dart';

class ArticleCard extends StatelessWidget {
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

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: this.article.heroTag,
      child: Container(
        padding: EdgeInsets.symmetric(
            horizontal: 15, vertical: this.large ? 25 : 15),
        child: Material(
          color: Colors.transparent,
          child: Column(
            children: <Widget>[
              MarkdownBody(
                data: mergeMarkdownArray(this.article.mainTitle),
                // TODO: make global styleSheet
                // TODO: fix bug overflow when transiting to article view
                styleSheet: MarkdownStyleSheet(
                  p: TextStyle(
                    color: hexColor(this.article.textColor),
                    fontSize: this.large ? 40 : 20,
                  ),
                ),
              ),
              if (this._isInsideArticle)
                Wrap(
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
            ],
          ),
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(this._borderRadius),
          image: DecorationImage(
            image: CachedNetworkImageProvider(this.article.img),
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}
