import 'package:flutter/material.dart';
import 'package:rememberall/lyricschanger_base.dart';

class SmallList extends StatelessWidget {
  final List<LyricsTransformer> items;

  const SmallList({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return Column(
          children: items.map((item) {
            return ListTile(
              leading: CircleAvatar(
                backgroundColor: item.level(),
                child: item.favourite ? const Icon(Icons.star) : null,
              ),
              title: Text(
                item.title().toString(),
                style: const TextStyle(
                    fontSize: 16), // Adjust the font size as needed
              ),
              subtitle: Text(
                item.lyrics(),
                maxLines: 1,
                overflow: TextOverflow.fade,
              ),
            );
          }).toList(),
        );
      },
    );
  }
}
