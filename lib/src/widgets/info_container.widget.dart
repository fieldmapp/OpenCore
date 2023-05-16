import 'package:flutter/material.dart';

class InfoContainer extends StatelessWidget {
  final String title;
  final String subTitle;
  final IconData icon;

  const InfoContainer(
      {super.key,
      required this.title,
      required this.subTitle,
      required this.icon});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon),
            Text(
              title,
              style: TextStyle(
                  color: Colors.grey[800], fontWeight: FontWeight.w600),
            ),
            Text(
              subTitle,
              style: const TextStyle(
                  color: Colors.grey, fontWeight: FontWeight.w300),
            )
          ],
        ),
      ),
    );
  }
}
