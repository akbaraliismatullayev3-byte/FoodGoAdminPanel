import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../constants.dart';
import '../providers/product_provider.dart';
import '../models/product_model.dart';
import '../models/order_model.dart';
import '../models/user_model.dart';
import 'add_product_dialog.dart';

class DashboardContentWidget extends ConsumerWidget {
  const DashboardContentWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsync = ref.watch(productsStreamProvider);
    final usersAsync = ref.watch(usersStreamProvider);
    final ordersAsync = ref.watch(ordersStreamProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row 1: Summary Cards
          Row(
            children: [
              Expanded(
                child: ordersAsync.when(
                  data: (orders) => _buildSummaryCard("Total Orders", orders.length.toString(), "+18.2%", AppColors.primary, Icons.shopping_bag),
                  loading: () => _buildSummaryCard("Total Orders", "...", "...", AppColors.primary, Icons.shopping_bag),
                  error: (e, st) => _buildSummaryCard("Total Orders", "Error", "", AppColors.primary, Icons.shopping_bag),
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: ordersAsync.when(
                  data: (orders) {
                    double totalRevenue = orders.fold(0, (sum, item) => sum + item.totalAmount);
                    return _buildSummaryCard("Total Revenue", "\$${totalRevenue.toStringAsFixed(2)}", "+23.5%", AppColors.success, Icons.attach_money);
                  },
                  loading: () => _buildSummaryCard("Total Revenue", "...", "...", AppColors.success, Icons.attach_money),
                  error: (e, st) => _buildSummaryCard("Total Revenue", "Error", "", AppColors.success, Icons.attach_money),
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: usersAsync.when(
                  data: (users) => _buildSummaryCard("Total Users", users.length.toString(), "+15.3%", AppColors.info, Icons.person),
                  loading: () => _buildSummaryCard("Total Users", "...", "...", AppColors.info, Icons.person),
                  error: (e, st) => _buildSummaryCard("Total Users", "Error", "", AppColors.info, Icons.person),
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: ordersAsync.when(
                  data: (orders) {
                    int active = orders.where((o) => o.status.toLowerCase() == 'cooking' || o.status.toLowerCase() == 'pending').length;
                    return _buildSummaryCard("Active Delivery", active.toString(), "+8.7%", AppColors.purple, Icons.delivery_dining);
                  },
                  loading: () => _buildSummaryCard("Active Delivery", "...", "...", AppColors.purple, Icons.delivery_dining),
                  error: (e, st) => _buildSummaryCard("Active Delivery", "Error", "", AppColors.purple, Icons.delivery_dining),
                ),
              ),
            ],
          ),
          const SizedBox(height: 30),

          // Row 2: Chart, Top Selling, Recent Orders
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 5, child: _buildOrdersChart()),
              const SizedBox(width: 20),
              Expanded(
                flex: 3, 
                child: productsAsync.when(
                  data: (products) => _buildTopSelling(products),
                  loading: () => _buildLoadingCard("Top Selling Products"),
                  error: (e, st) => _buildErrorCard("Top Selling Products"),
                )
              ),
              const SizedBox(width: 20),
              Expanded(
                flex: 3,
                child: ordersAsync.when(
                  data: (orders) => _buildRecentOrders(orders),
                  loading: () => _buildLoadingCard("Recent Orders"),
                  error: (e, st) => _buildErrorCard("Recent Orders"),
                ),
              ),
            ],
          ),
          const SizedBox(height: 30),

          // Row 3: Recent Customers, Delivery Summary, Quick Actions
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 4, 
                child: usersAsync.when(
                  data: (users) => _buildRecentCustomers(users),
                  loading: () => _buildLoadingCard("Recent Customers"),
                  error: (e, st) => _buildErrorCard("Recent Customers"),
                )
              ),
              const SizedBox(width: 20),
              Expanded(flex: 3, child: _buildDeliverySummary()),
              const SizedBox(width: 20),
              Expanded(flex: 4, child: _buildQuickActions()),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingCard(String title) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: inter.copyWith(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textDark)),
          const SizedBox(height: 20),
          const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }

  Widget _buildErrorCard(String title) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: inter.copyWith(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textDark)),
          const SizedBox(height: 20),
          const Center(child: Text("Failed to load data")),
        ],
      ),
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: AppColors.cardBg,
      borderRadius: BorderRadius.circular(15),
      border: Border.all(color: Colors.grey.withOpacity(0.05)),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.03),
          blurRadius: 15,
          offset: const Offset(0, 5),
        ),
      ],
    );
  }

  Widget _buildSummaryCard(String title, String value, String percent, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _cardDecoration(),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: inter.copyWith(color: AppColors.textLight, fontSize: 14)),
                const SizedBox(height: 4),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(value, style: inter.copyWith(color: AppColors.textDark, fontSize: 24, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis),
                    const SizedBox(width: 8),
                    if (percent.isNotEmpty)
                      Row(
                        children: [
                          const Icon(Icons.arrow_upward, color: AppColors.success, size: 14),
                          Text(percent, style: inter.copyWith(color: AppColors.success, fontSize: 12, fontWeight: FontWeight.w600)),
                        ],
                      ),
                  ],
                ),
                const SizedBox(height: 2),
                Text("vs yesterday", style: inter.copyWith(color: AppColors.textLight, fontSize: 12)),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildOrdersChart() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Orders Overview", style: inter.copyWith(fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.textDark)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.withOpacity(0.2)),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Text("This Week", style: inter.copyWith(fontSize: 12, color: AppColors.textDark)),
                    const SizedBox(width: 4),
                    const Icon(Icons.keyboard_arrow_down, size: 16, color: AppColors.textLight),
                  ],
                ),
              )
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _chartLegend("Orders", AppColors.primary),
              const SizedBox(width: 20),
              _chartLegend("Revenue", AppColors.primary.withOpacity(0.3)),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 250,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true, 
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (value) => FlLine(color: Colors.grey.withOpacity(0.1), strokeWidth: 1),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      interval: 1,
                      getTitlesWidget: (value, meta) {
                        const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                        if (value.toInt() >= 0 && value.toInt() < days.length) {
                          return SideTitleWidget(
                            axisSide: meta.axisSide,
                            child: Text(days[value.toInt()], style: inter.copyWith(color: AppColors.textLight, fontSize: 12)),
                          );
                        }
                        return const SizedBox();
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 100,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) {
                        return Text(value.toInt().toString(), style: inter.copyWith(color: AppColors.textLight, fontSize: 12));
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                minX: 0, maxX: 6, minY: 0, maxY: 500,
                lineBarsData: [
                  LineChartBarData(
                    spots: const [FlSpot(0, 200), FlSpot(1, 250), FlSpot(2, 200), FlSpot(3, 350), FlSpot(4, 250), FlSpot(5, 400), FlSpot(6, 200)],
                    isCurved: true,
                    color: AppColors.primary,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: FlDotData(show: true, getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(radius: 4, color: AppColors.primary, strokeWidth: 2, strokeColor: Colors.white)),
                    belowBarData: BarAreaData(
                      show: true,
                      color: AppColors.primary.withOpacity(0.1),
                    ),
                  ),
                  LineChartBarData(
                    spots: const [FlSpot(0, 100), FlSpot(1, 150), FlSpot(2, 100), FlSpot(3, 250), FlSpot(4, 200), FlSpot(5, 300), FlSpot(6, 150)],
                    isCurved: true,
                    color: AppColors.primary.withOpacity(0.3),
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: FlDotData(show: false),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _chartLegend(String label, Color color) {
    return Row(
      children: [
        Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 8),
        Text(label, style: inter.copyWith(color: AppColors.textLight, fontSize: 12)),
      ],
    );
  }

  Widget _buildTopSelling(List<ProductModel> products) {
    final displayProducts = products.take(5).toList();
    if (displayProducts.isEmpty) {
      return _buildErrorCard("Top Selling Products");
    }
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Top Selling Products", style: inter.copyWith(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textDark)),
              Text("View All", style: inter.copyWith(fontSize: 12, color: AppColors.textLight)),
            ],
          ),
          const SizedBox(height: 20),
          ...displayProducts.asMap().entries.map((e) {
            final idx = e.key + 1;
            final item = e.value;
            // Mocking orders count for UI
            final mockOrders = 1000 - (idx * 150);
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Row(
                children: [
                  Text(idx.toString(), style: inter.copyWith(color: AppColors.textLight, fontWeight: FontWeight.bold)),
                  const SizedBox(width: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: CachedNetworkImage(
                      imageUrl: item.imageUrl.isNotEmpty ? item.imageUrl : 'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=100', 
                      width: 40, height: 40, fit: BoxFit.cover,
                      errorWidget: (context, url, error) => Container(width: 40, height: 40, color: Colors.grey[200]),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item.name, style: inter.copyWith(fontWeight: FontWeight.w600, color: AppColors.textDark, fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis),
                        Text("$mockOrders Orders", style: inter.copyWith(color: AppColors.textLight, fontSize: 11)),
                      ],
                    ),
                  ),
                  Text("\$${item.price.toStringAsFixed(2)}", style: inter.copyWith(color: AppColors.success, fontWeight: FontWeight.w600, fontSize: 13)),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildRecentOrders(List<OrderModel> orders) {
    final recentOrders = orders.take(4).toList();
    if (recentOrders.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: _cardDecoration(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Recent Orders", style: inter.copyWith(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textDark)),
            const SizedBox(height: 20),
            Text("No orders found.", style: inter.copyWith(color: AppColors.textLight)),
          ],
        ),
      );
    }
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Recent Orders", style: inter.copyWith(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textDark)),
              Text("View All", style: inter.copyWith(fontSize: 12, color: AppColors.textLight)),
            ],
          ),
          const SizedBox(height: 20),
          ...recentOrders.map((o) {
            Color statusColor = AppColors.warning;
            if (o.status.toLowerCase() == 'delivered') statusColor = AppColors.success;
            else if (o.status.toLowerCase() == 'cooking') statusColor = AppColors.info;

            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                    child: Icon(Icons.shopping_bag_outlined, color: statusColor, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(o.id.length > 8 ? "#${o.id.substring(0,8)}" : "#${o.id}", style: inter.copyWith(fontWeight: FontWeight.bold, fontSize: 12)),
                            const Spacer(),
                            Text(o.date.split('T').first, style: inter.copyWith(color: AppColors.textLight, fontSize: 11)), // simplistic time
                          ],
                        ),
                        Text(o.userName, style: inter.copyWith(color: AppColors.textDark, fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis),
                        Text("${o.itemsCount} Items", style: inter.copyWith(color: AppColors.textLight, fontSize: 11)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text("\$${o.totalAmount.toStringAsFixed(2)}", style: inter.copyWith(fontWeight: FontWeight.bold, fontSize: 13)),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(o.status, style: inter.copyWith(color: statusColor, fontSize: 10, fontWeight: FontWeight.bold)),
                      )
                    ],
                  )
                ],
              ),
            );
          }).toList(),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary.withOpacity(0.1),
                foregroundColor: AppColors.primary,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: Text("View All Orders", style: inter.copyWith(fontWeight: FontWeight.w600)),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildRecentCustomers(List<UserModel> users) {
    final recentUsers = users.take(4).toList();
    if (recentUsers.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: _cardDecoration(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Recent Customers", style: inter.copyWith(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textDark)),
            const SizedBox(height: 20),
            Text("No customers found.", style: inter.copyWith(color: AppColors.textLight)),
          ],
        ),
      );
    }
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Recent Customers", style: inter.copyWith(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textDark)),
              Text("View All", style: inter.copyWith(fontSize: 12, color: AppColors.textLight)),
            ],
          ),
          const SizedBox(height: 20),
          // Table Header
          Row(
            children: [
              Expanded(flex: 2, child: Text("Name", style: inter.copyWith(color: AppColors.textLight, fontSize: 12))),
              Expanded(flex: 2, child: Text("Email", style: inter.copyWith(color: AppColors.textLight, fontSize: 12))),
              Expanded(flex: 1, child: Text("Orders", style: inter.copyWith(color: AppColors.textLight, fontSize: 12))),
              Expanded(flex: 1, child: Text("Total Spent", style: inter.copyWith(color: AppColors.textLight, fontSize: 12))),
              Expanded(flex: 1, child: Text("Status", style: inter.copyWith(color: AppColors.textLight, fontSize: 12))),
            ],
          ),
          const Divider(),
          ...recentUsers.asMap().entries.map((e) {
            final idx = e.key;
            final c = e.value;
            final isActive = true;
            // mock orders and spent since we don't fetch per-user orders efficiently yet
            final mockOrders = (5 - idx) * 3;
            final mockSpent = "\$${(mockOrders * 20.5).toStringAsFixed(2)}";

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Row(
                      children: [
                        CircleAvatar(radius: 12, backgroundImage: NetworkImage("https://i.pravatar.cc/150?img=${idx + 10}")),
                        const SizedBox(width: 8),
                        Expanded(child: Text(c.name.isNotEmpty ? c.name : 'Unknown User', style: inter.copyWith(color: AppColors.textDark, fontSize: 13, fontWeight: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis)),
                      ],
                    ),
                  ),
                  Expanded(flex: 2, child: Text(c.email, style: inter.copyWith(color: AppColors.textLight, fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis)),
                  Expanded(flex: 1, child: Text(mockOrders.toString(), style: inter.copyWith(color: AppColors.textDark, fontSize: 12, fontWeight: FontWeight.w600))),
                  Expanded(flex: 1, child: Text(mockSpent, style: inter.copyWith(color: AppColors.textDark, fontSize: 12, fontWeight: FontWeight.w600))),
                  Expanded(
                    flex: 1,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: isActive ? AppColors.success.withOpacity(0.1) : AppColors.danger.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        isActive ? "Active" : "Inactive", 
                        textAlign: TextAlign.center,
                        style: inter.copyWith(
                          color: isActive ? AppColors.success : AppColors.danger, 
                          fontSize: 10, 
                          fontWeight: FontWeight.bold
                        )
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildDeliverySummary() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Delivery Summary", style: inter.copyWith(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textDark)),
          const SizedBox(height: 20),
          Row(
            children: [
              SizedBox(
                width: 120,
                height: 120,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    PieChart(
                      PieChartData(
                        sectionsSpace: 0,
                        centerSpaceRadius: 40,
                        sections: [
                          PieChartSectionData(color: AppColors.success, value: 25, title: '', radius: 15),
                          PieChartSectionData(color: AppColors.info, value: 15, title: '', radius: 15),
                          PieChartSectionData(color: AppColors.primary, value: 5, title: '', radius: 15),
                        ],
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text("45", style: inter.copyWith(fontWeight: FontWeight.bold, fontSize: 20)),
                        Text("Total", style: inter.copyWith(color: AppColors.textLight, fontSize: 12)),
                      ],
                    )
                  ],
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _deliveryStatRow(AppColors.success, "Online", "25 (55%)"),
                    const SizedBox(height: 10),
                    _deliveryStatRow(AppColors.info, "On Delivery", "15 (33%)"),
                    const SizedBox(height: 10),
                    _deliveryStatRow(AppColors.primary, "Offline", "5 (12%)"),
                  ],
                ),
              )
            ],
          )
        ],
      ),
    );
  }

  Widget _deliveryStatRow(Color color, String label, String value) {
    return Row(
      children: [
        Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: inter.copyWith(color: AppColors.textLight, fontSize: 12)),
              Text(value, style: inter.copyWith(color: AppColors.textDark, fontSize: 13, fontWeight: FontWeight.bold)),
            ],
          ),
        )
      ],
    );
  }

  Widget _buildQuickActions() {
    final actions = [
      {"icon": Icons.add_circle_outline, "label": "Add Product", "color": AppColors.primary, "action": "add_product"},
      {"icon": Icons.category_outlined, "label": "Add Category", "color": AppColors.purple},
      {"icon": Icons.local_offer_outlined, "label": "New Coupon", "color": AppColors.success},
      {"icon": Icons.delivery_dining_outlined, "label": "Add Delivery", "color": AppColors.info},
      {"icon": Icons.send_outlined, "label": "Send Notification", "color": AppColors.danger},
      {"icon": Icons.bar_chart, "label": "View Reports", "color": AppColors.warning},
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Quick Actions", style: inter.copyWith(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textDark)),
          const SizedBox(height: 20),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 15,
              mainAxisSpacing: 15,
              childAspectRatio: 1.2,
            ),
            itemCount: actions.length,
            itemBuilder: (context, index) {
              final a = actions[index];
              return InkWell(
                onTap: () {
                  if (a['action'] == 'add_product') {
                    showDialog(context: context, builder: (_) => const AddProductDialog());
                  }
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.withOpacity(0.05)),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: (a['color'] as Color).withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(a['icon'] as IconData, color: a['color'] as Color, size: 24),
                      ),
                      const SizedBox(height: 8),
                      Text(a['label'] as String, style: inter.copyWith(fontSize: 11, fontWeight: FontWeight.w500, color: AppColors.textDark), textAlign: TextAlign.center),
                    ],
                  ),
                ),
              );
            },
          )
        ],
      ),
    );
  }
}
