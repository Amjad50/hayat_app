
import 'package:flutter/material.dart';
import 'package:hayat_app/utils.dart';

class ArticleCard extends StatelessWidget {
  const ArticleCard(
      {Key key,
      this.title,
      this.textColor,
      this.tag,
      this.img,
      this.large = false})
      : this._borderRadius = 10,
        super(key: key);

  const ArticleCard.insideArticlePage(
      {Key key, this.title, this.textColor, this.tag, this.img})
      : this._borderRadius = 0,
        this.large = true,
        super(key: key);

  final String tag;
  final String textColor;
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
                  TextStyle(color: hexColor(textColor), fontSize: this.large ? 40 : 20),
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