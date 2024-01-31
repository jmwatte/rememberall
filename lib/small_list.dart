import 'package:flutter/material.dart';
import 'package:rememberall2/poem_model.dart';

class SmallList extends StatelessWidget {
  final List<Poem> poems;

  const SmallList({super.key, required this.poems});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return Column(
          children: poems.map((poem) {
            return ListTile(
              leading: CircleAvatar(
                backgroundColor: poem.level(),
                child: poem.favourite ? const Icon(Icons.star) : null,
              ),
              title: Text(
                poem.poemTitle().toString(),
                style: const TextStyle(
                    fontSize: 16), // Adjust the font size as needed
              ),
              subtitle: Text(
                poem.poemText(),
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
