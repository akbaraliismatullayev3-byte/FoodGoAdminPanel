import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';
import '../constants.dart';
import '../main.dart';
import 'dashboard_content.dart';
import 'products_screen.dart';
import 'orders_screen.dart';
import 'users_screen.dart';
import 'categories_screen.dart';
import 'coupons_screen.dart';
import 'reviews_screen.dart';
import 'common_components.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  int _selectedIndex = 0;

  final List<Map<String, dynamic>> _menuItems = [
    {'icon': Icons.dashboard, 'label': 'Dashboard'},
    {'icon': Icons.inventory_2_outlined, 'label': 'Products'},
    {'icon': Icons.shopping_bag_outlined, 'label': 'Orders'},
    {'icon': Icons.people_outline, 'label': 'Users'},
    {'icon': Icons.delivery_dining_outlined, 'label': 'Delivery'},
    {'icon': Icons.category_outlined, 'label': 'Categories'},
    {'icon': Icons.local_offer_outlined, 'label': 'Coupons'},
    {'icon': Icons.star_border, 'label': 'Reviews'},
    {'icon': Icons.bar_chart, 'label': 'Reports'},
    {'icon': Icons.settings_outlined, 'label': 'Settings'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Sidebar
          Container(
            width: 250,
            color: AppColors.sidebarBg,
            child: Column(
              children: [
                // Logo
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
                  child: Row(
                    children: [
                      const Icon(Icons.room_service, color: AppColors.primary, size: 28),
                      const SizedBox(width: 10),
                      Text("FoodGo", style: inter.copyWith(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                
                // Menu List
                Expanded(
                  child: ListView.builder(
                    itemCount: _menuItems.length,
                    itemBuilder: (context, index) {
                      final item = _menuItems[index];
                      final isSelected = _selectedIndex == index;
                      
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        child: InkWell(
                          onTap: () => setState(() => _selectedIndex = index),
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            decoration: BoxDecoration(
                              color: isSelected ? AppColors.primary : Colors.transparent,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            child: Row(
                              children: [
                                Icon(item['icon'], color: isSelected ? Colors.white : Colors.white70, size: 22),
                                const SizedBox(width: 16),
                                Text(
                                  item['label'],
                                  style: inter.copyWith(
                                    color: isSelected ? Colors.white : Colors.white70,
                                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                
                // Admin Profile & Logout
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const CircleAvatar(
                              radius: 20,
                              backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=11'),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text("Admin", style: inter.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
                                      const SizedBox(width: 5),
                                      Container(
                                        width: 8, height: 8,
                                        decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle),
                                      )
                                    ],
                                  ),
                                  Text("Super Admin", style: inter.copyWith(color: Colors.white54, fontSize: 12)),
                                ],
                              ),
                            ),
                            const Icon(Icons.keyboard_arrow_down, color: Colors.white54),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      InkWell(
                        onTap: () {
                          ref.read(authServiceProvider).signOut();
                        },
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.white24),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.logout, color: Colors.white70, size: 20),
                              const SizedBox(width: 8),
                              Text("Logout", style: inter.copyWith(color: Colors.white70)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Main Content
          Expanded(
            child: Column(
              children: [
                // Top Header
                Container(
                  height: 80,
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  color: AppColors.background,
                  child: Row(
                    children: [
                      const Icon(Icons.menu, color: AppColors.textDark),
                      const SizedBox(width: 20),
                      Text("Dashboard", style: inter.copyWith(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textDark)),
                      const Spacer(),
                      // Search
                      Container(
                        width: 300,
                        height: 45,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.search, color: AppColors.textLight, size: 20),
                            const SizedBox(width: 10),
                            Expanded(
                              child: TextField(
                                decoration: InputDecoration(
                                  hintText: "Search anything...",
                                  hintStyle: inter.copyWith(color: AppColors.textLight, fontSize: 14),
                                  border: InputBorder.none,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 20),
                      // Notifications
                      Stack(
                        children: [
                          const Icon(Icons.notifications_none, color: AppColors.textDark, size: 28),
                          Positioned(
                            right: 0,
                            top: 0,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(color: AppColors.danger, shape: BoxShape.circle),
                              child: Text("8", style: inter.copyWith(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                            ),
                          )
                        ],
                      ),
                      const SizedBox(width: 20),
                      // Theme toggle
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.wb_sunny_outlined, size: 18, color: AppColors.textLight),
                            const SizedBox(width: 8),
                            Container(width: 24, height: 14, decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(10))),
                            const SizedBox(width: 8),
                            const Icon(Icons.nightlight_round, size: 18, color: AppColors.textLight),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
                
                // Dashboard Content Area
                Expanded(
                  child: _getSelectedScreen(),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _getSelectedScreen() {
    switch (_selectedIndex) {
      case 0: return const DashboardContentWidget();
      case 1: return const ProductsScreen();
      case 2: return const OrdersScreen();
      case 3: return const UsersScreen();
      case 4: return const PlaceholderScreen(title: "Delivery Management", icon: Icons.delivery_dining);
      case 5: return const CategoriesScreen();
      case 6: return const CouponsScreen();
      case 7: return const ReviewsScreen();
      case 8: return const PlaceholderScreen(title: "Analytics & Reports", icon: Icons.bar_chart);
      case 9: return const PlaceholderScreen(title: "Settings", icon: Icons.settings);
      default: return const DashboardContentWidget();
    }
  }
}

