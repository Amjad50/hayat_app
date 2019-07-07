import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:hayat_app/pages/articles/article_data.dart';
import 'package:hayat_app/utils.dart';

class ArticleCard extends StatelessWidget {
  const ArticleCard(this.article, {Key key, this.large = false})
      : this._borderRadius = 10,
        super(key: key);

  const ArticleCard.insideArticlePage(this.article, {Key key})
      : this._borderRadius = 0,
        this.large = true,
        super(key: key);

  final ArticleData article;
  final bool large;
  final double _borderRadius;

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: this.article.heroTag,
      child: Container(
        padding: EdgeInsets.symmetric(
            horizontal: 15, vertical: this.large ? 25 : 15),
        child: Material(
          color: Colors.transparent,
          child: MarkdownBody(
            data: this.article.title,
            // TODO: make global styleSheet
            // TODO: fix bug overflow when transiting to article view
            styleSheet: MarkdownStyleSheet(
              p: TextStyle(
                color: hexColor(this.article.textColor),
                fontSize: this.large ? 40 : 20,
              ),
            ),
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
