import 'package:flutter/material.dart';

class SideBarPage extends StatelessWidget {
  const SideBarPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          DrawerHeader(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 65,
                  height: 24,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage(
                        'images/logo.png',
                      ),
                    ),
                  ),
                ),
                Container(
                  width: 24,
                  height: 24,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage(
                        'images/icon_close.png',
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: Container(
              width: 24,
              height: 24,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(
                    'images/icon_bookmark.png',
                  ),
                ),
              ),
            ),
            title: const Text("Bookmark"),
            trailing: Container(
              width: 24,
              height: 24,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(
                    'images/icon_arrow_right.png',
                  ),
                ),
              ),
            ),
          ),
          ListTile(
            leading: Container(
              width: 24,
              height: 24,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(
                    'images/icon_profile.png',
                  ),
                ),
              ),
            ),
            title: const Text("Account"),
            trailing: Container(
              width: 24,
              height: 24,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(
                    'images/icon_arrow_right.png',
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
