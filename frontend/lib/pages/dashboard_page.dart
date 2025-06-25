import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config/app_constants.dart';
import '../providers/dashboard_provider.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer(
        builder: (_, wiRef, __) {
          int navIndex = wiRef.watch(dashboardNavIndexProvider);
          return AppConstants.navMenuDashboard[navIndex]['view'] as Widget;
        },
      ),
      extendBody: true,
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        child: Consumer(
          builder: (_, wiRef, __) {
            int navIndex = wiRef.watch(dashboardNavIndexProvider);
            return Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 16,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: BottomNavigationBar(
                  currentIndex: navIndex,
                  elevation: 0,
                  backgroundColor: Colors.white,
                  iconSize: 24,
                  type: BottomNavigationBarType.fixed,
                  onTap: (value) {
                    wiRef.read(dashboardNavIndexProvider.notifier).state =
                        value;
                  },
                  showSelectedLabels: false,
                  showUnselectedLabels: false,
                  selectedItemColor: Colors.green,
                  unselectedItemColor: Colors.grey[400],
                  items: AppConstants.navMenuDashboard.map((e) {
                    return BottomNavigationBarItem(
                      icon: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: navIndex ==
                                  AppConstants.navMenuDashboard.indexOf(e)
                              ? Colors.green.withOpacity(0.1)
                              : Colors.transparent,
                        ),
                        child: Icon(e['icon'] as IconData),
                      ),
                      label: e['label'],
                    );
                  }).toList(),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
