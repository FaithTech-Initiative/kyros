
import 'package:flutter/material.dart';

class BiblePanel extends StatelessWidget {
  const BiblePanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      decoration: BoxDecoration(
        border: Border(left: BorderSide(color: Theme.of(context).dividerColor)),
      ),
      child: const Center(
        child: Text('Bible Panel'),
      ),
    );
  }
}
