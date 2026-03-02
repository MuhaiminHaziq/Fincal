import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class Header extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showNavigation;

  const Header({
    super.key,
    this.title = 'Accounting Calculator',
    this.showNavigation = false,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
      ),
      centerTitle: true,
      backgroundColor: Colors.white,
      elevation: 1,
      bottom: showNavigation
          ? PreferredSize(
              preferredSize: const Size.fromHeight(80),
              child: Column(
                children: [
                  // Navigation buttons
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        TextButton(
                          onPressed: () {
                            Navigator.pushNamed(context, '/about-us');
                          },
                          child: const Text('About us'),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pushNamed(context, '/help');
                          },
                          child: const Text('Help'),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pushNamed(context, '/user-manual');
                          },
                          child: const Text('User manual'),
                        ),
                        TextButton(
                          onPressed: () {},
                          child: const Text('Settings'),
                        ),
                      ],
                    ),
                  ),
                  // User info and logout
                  Consumer<AuthProvider>(
                    builder: (context, authProvider, child) {
                      if (authProvider.user != null) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 24,
                                    height: 24,
                                    decoration: BoxDecoration(
                                      color: Colors.grey[400],
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Icon(
                                      Icons.person,
                                      size: 16,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    authProvider.user!.companyName,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                              TextButton(
                                onPressed: () {
                                  authProvider.logout();
                                  Navigator.of(context).pushNamedAndRemoveUntil(
                                    '/login',
                                    (route) => false,
                                  );
                                },
                                child: const Text(
                                  'Logout',
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ],
              ),
            )
          : null,
    );
  }

  @override
  Size get preferredSize =>
      Size.fromHeight(kToolbarHeight + (showNavigation ? 80 : 0));
}
