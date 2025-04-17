import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:isocial/controller/dashboard_auto_refresh_controller.dart';
import 'package:isocial/module/ticket/view/ticket_list_view.dart';
import 'package:isocial/notification_services.dart';
import 'package:isocial/view/LabelChart.dart';
import 'package:isocial/view/RealTimeData.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../auth/Logout.dart';
import '../components/AppTitleField.dart';
import '../components/DrawerMenu.dart';
import '../data/localData.dart';
import '../model/MenuItem.dart';
import '../model/MenuItems.dart';
import '/constants/constants.dart';
import 'BarChart.dart';
import 'PostAndPageCounter.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class DashBoardScreen extends StatefulWidget {
  const DashBoardScreen({Key? key}) : super(key: key);

  @override
  State<DashBoardScreen> createState() => _DashBoardScreenState();
}

class _DashBoardScreenState extends State<DashBoardScreen> {
  String userName = "";
  String role = "";
  String email = "";

  List counterValue = [];
  List counterKey = [];
  bool isLoading = false;
  bool isAutoRefreshing = false;

  // References to child widgets using generic GlobalKey
  final postPageCounterKey = GlobalKey();
  final realTimeDataKey = GlobalKey();
  final labelChartKey = GlobalKey();
  final barChartKey = GlobalKey();

  // Auto-refresh controller
  late DashboardAutoRefreshController autoRefreshController;

  NotificationServices notificationServices = NotificationServices();
  Color appBarContainerColor = Colors.grey; // Default color

  @override
  void initState() {
    notificationServices.requestNotificationPermission();
    super.initState();
    getUserNameAndEmail();

    // Initialize auto-refresh controller
    autoRefreshController = DashboardAutoRefreshController(
      refreshPostPageCounter: _refreshPostPageCounter,
      refreshRealTimeData: _refreshRealTimeData,
      refreshLabelChart: _refreshLabelChart,
      refreshBarChart: _refreshBarChart,
    );

    // Start auto-refresh
    autoRefreshController.startAutoRefresh(intervalSeconds: 30);
  }

  @override
  void dispose() {
    // Clean up resources
    autoRefreshController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: onBackPressed,
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          title: const AppTitleField(),
          actions: [
            // Manual refresh button
            IconButton(
              icon: const Icon(Icons.refresh),
              tooltip: 'Refresh dashboard',
              onPressed: () {
                // Show snackbar to indicate manual refresh
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Refreshing dashboard data...'),
                    duration: Duration(seconds: 1),
                  ),
                );
                autoRefreshController.refreshNow();
              },
            ),
            SizedBox(width: 10.w),
            PopupMenuButton<DropMenuItem>(
              position: PopupMenuPosition.under,
              padding: const EdgeInsets.only(right: 15, top: 10, bottom: 10),
              icon: Image.asset(
                "assets/images/person.png",
                color: Colors.blueGrey,
                fit: BoxFit.cover,
                width: 25.w,
              ),
              itemBuilder: (context) => [
                ...MenuItems.itemsFirst.map(buildItem).toList(),
              ],
            ),
          ],
          automaticallyImplyLeading: true,
        ),
        backgroundColor: bgColor,
        drawer: DrawerMenu(onContainerColorChanged: (color) {
          appBarContainerColor = color;
        }),
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: RefreshIndicator(
                  onRefresh: _handleRefresh,
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: <Widget>[
                      SizedBox(height: 10.h),
                      Center(
                        child: Container(
                          height: 120.h,
                          margin: const EdgeInsets.only(left: 5, right: 5),
                          decoration: BoxDecoration(
                            boxShadow: const [
                              BoxShadow(
                                  color: Colors.white12,
                                  offset: Offset(0, 2),
                                  blurRadius: 6.0)
                            ],
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.all(10),
                          child: const PostAndPageCounter(),
                        ),
                      ),
                      SizedBox(height: 5.h),
                      Center(
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const TicketList(),
                                ));
                          },
                          child: Container(
                            height: LocalData.dashBoardRealTimeCounterHeight,
                            margin: const EdgeInsets.only(left: 5, right: 5),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: const EdgeInsets.all(10),
                            child: const RealTimeData(),
                          ),
                        ),
                      ),
                      SizedBox(
                          height: 60.h,
                          child: Center(
                              child: Text("Sentiment Chart",
                                  style: TextStyle(
                                      fontWeight: FontWeight.w400,
                                      fontSize: 20.sp,
                                      color: Colors.black)))),
                      const Center(child: LabelChart()),
                      SizedBox(
                          height: 90.h,
                          child: Center(
                              child: Text("Ticket Count",
                                  style: TextStyle(
                                      fontWeight: FontWeight.w400,
                                      fontSize: 20.sp,
                                      color: Colors.black)))),
                      const Center(child: BarChartShow()),
                      SizedBox(height: 10.h),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<bool> onBackPressed() async {
    return (await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Are you sure?'),
            content: const Text('Do you want to exit?'),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('No'),
              ),
              TextButton(
                onPressed: () => SystemNavigator.pop(),
                child: const Text('Yes'),
              ),
            ],
          ),
        )) ??
        false;
  }

  PopupMenuItem<DropMenuItem> buildItem(DropMenuItem item) => PopupMenuItem(
        value: item,
        child: showDropDownData(item),
      );

  Widget showDropDownData(DropMenuItem item) {
    if (item.text == "Sign Out") {
      return Row(
        children: [
          Icon(item.icon, color: Colors.black, size: 20.sp),
          SizedBox(width: 12.w),
          TextButton(
            child: Text(item.text),
            onPressed: () {
              Logout log = Logout(context);
              log.logout();
            },
          ),
        ],
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
            height: 80.h,
            width: 80.w,
            child: Image.asset("assets/images/person.png", color: Colors.grey)),
        SizedBox(height: 10.h),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(userName,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            Text("($role)",
                style:
                    const TextStyle(fontSize: 12, fontWeight: FontWeight.w300)),
          ],
        ),
        SizedBox(height: 5.h),
        Text(email,
            style:
                const TextStyle(fontSize: 13, fontWeight: FontWeight.normal)),
        Container(
            height: 1.h,
            color: Colors.grey,
            margin: const EdgeInsets.only(top: 20)),
      ],
    );
  }

  void getUserNameAndEmail() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    setState(() {
      userName = sharedPreferences.getString("username") ?? "";
      role = sharedPreferences.getString("role") ?? "";
      email = sharedPreferences.getString("email") ?? "";
    });
  }

  Future<void> _handleRefresh() async {
    // Show a snackbar to indicate refresh is happening
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Refreshing dashboard data...'),
        duration: Duration(seconds: 1),
      ),
    );

    // Trigger manual refresh of all components
    autoRefreshController.refreshNow();

    // Wait a moment to allow the refresh indicator to show properly
    await Future.delayed(const Duration(seconds: 1));
  }

  // Helper methods to refresh individual components
  void _refreshPostPageCounter() {
    // Force rebuild of the entire dashboard
    setState(() {
      // This will trigger a rebuild of all widgets
    });
  }

  void _refreshRealTimeData() {
    developer.log('🔄 DASHBOARD: Forcing refresh of RealTimeData');
    // Call the static refresh method with silent=true for auto-refresh, silent=false for manual refresh
    bool isManualRefresh = !autoRefreshController.isAutoRefreshing;

    // Always force a refresh of RealTimeData to ensure API is called
    RealTimeData.refreshAll(silent: !isManualRefresh);

    // For manual refresh, we want to show the loading indicator
    // For auto-refresh, we want to silently update in the background
    if (isManualRefresh) {
      // Force rebuild of the entire dashboard to refresh RealTimeData
      setState(() {
        // This will trigger a rebuild of the RealTimeData widget
        // We need to force the RealTimeData widget to fetch new data
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation1, animation2) =>
                const DashBoardScreen(),
            transitionDuration: Duration.zero,
            maintainState: true,
          ),
        );
      });
    } else {
      // For auto-refresh, just trigger a setState to refresh the UI with new data
      // This is important to ensure the UI updates with new data
      setState(() {
        developer.log('🔄 DASHBOARD: Auto-refresh setState triggered');
      });
    }
  }

  void _refreshLabelChart() {
    setState(() {
      // This will trigger a rebuild of all widgets
    });
  }

  void _refreshBarChart() {
    setState(() {
      // This will trigger a rebuild of all widgets
    });
  }
}
