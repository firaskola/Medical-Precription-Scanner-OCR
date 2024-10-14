import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      iconTheme: IconThemeData(
        color: Theme.of(context).primaryColorLight, // Set the color you want
      ),
      backgroundColor: Theme.of(context).primaryColor,
      actions: [
        IconButton(
          onPressed: () {},
          icon: Icon(
            CupertinoIcons.bell,
            color: Theme.of(context).primaryColorLight,
          ),
        ),
        IconButton(
          onPressed: () {},
          icon: Icon(
            CupertinoIcons.ellipsis_vertical,
            color: Theme.of(context).primaryColorLight,
          ),
        ),
      ],
      title: Text(
        'Medicare',
        style: TextStyle(
          fontWeight: FontWeight.w900,
          fontSize: 21,
          color: Theme.of(context).primaryColorLight,
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
