import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../constant.dart';
import '../models/vocabulary_item.dart';

class VocabularyCard extends StatelessWidget {
  final VocabularyItem item;
  final VoidCallback onTap;

  const VocabularyCard({
    Key? key,
    required this.item,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: item.backgroundColor,
        boxShadow: [
          BoxShadow(
            offset: const Offset(0, 10),
            blurRadius: 20,
            color: kActiveShadowColor,
          ),
        ],
      ),
      child: Material(
        type: MaterialType.transparency,
        borderRadius: BorderRadius.circular(18),
        clipBehavior: Clip.hardEdge,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: item.isSvg
                        ? SvgPicture.asset(item.assetPath, fit: BoxFit.contain)
                        : Image.asset(item.assetPath, fit: BoxFit.contain),
                  ),
                ),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.65),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text(
                    item.title,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: kTitleTextColor,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
