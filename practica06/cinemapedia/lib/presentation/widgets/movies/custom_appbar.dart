import 'package:flutter/material.dart';

class CustomAppbar extends StatelessWidget {
  const CustomAppbar({super.key});

  @override
  Widget build(BuildContext context) {
    final titleStyle = Theme.of(context).textTheme.titleMedium;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          children: [
            Icon(Icons.movie_outlined, color: Theme.of(context).primaryColor),
            const SizedBox(width: 5),
            Text('CINEMAPEDIA - 230389', style: titleStyle),
          ],
        ),
      ),
    );
  }
}
