import 'dart:async';
import 'dart:developer' as developer;

class DashboardAutoRefreshController {
  // Timer for auto-refreshing
  Timer? _refreshTimer;

  // Callback functions for refreshing different components
  final Function? refreshPostPageCounter;
  final Function? refreshRealTimeData;
  final Function? refreshLabelChart;
  final Function? refreshBarChart;

  // Flag to track if auto-refresh is active
  bool isAutoRefreshing = false;

  // Constructor with optional callback functions
  DashboardAutoRefreshController({
    this.refreshPostPageCounter,
    this.refreshRealTimeData,
    this.refreshLabelChart,
    this.refreshBarChart,
  });

  // Start auto-refreshing
  void startAutoRefresh({int intervalSeconds = 10}) {
    developer.log(
        '🔄 DASHBOARD: Starting auto-refresh every $intervalSeconds seconds');

    // Cancel any existing timer
    stopAutoRefresh();

    // Create a new timer
    _refreshTimer = Timer.periodic(
      Duration(seconds: intervalSeconds),
      (timer) {
        final now = DateTime.now();
        developer.log('\n\n==================================================');
        developer.log('⏰ DASHBOARD AUTO-REFRESH CYCLE #${timer.tick}');
        developer.log('🕒 TIME: ${now.toString()}');
        developer.log('==================================================');
        _refreshAllComponents();
      },
    );

    isAutoRefreshing = true;
  }

  // Stop auto-refreshing
  void stopAutoRefresh() {
    if (_refreshTimer != null && _refreshTimer!.isActive) {
      developer.log('⏹ DASHBOARD: Stopping auto-refresh');
      _refreshTimer!.cancel();
      isAutoRefreshing = false;
    }
  }

  // Refresh all components
  void _refreshAllComponents() {
    final now = DateTime.now();
    developer.log(
        '🔄 DASHBOARD: Auto-refreshing all components at ${now.toString()}');

    // Set flag to indicate we're auto-refreshing (for silent updates)
    isAutoRefreshing = true;

    // Call each refresh function if provided
    if (refreshPostPageCounter != null) {
      developer.log('📊 DASHBOARD: Refreshing post and page counter');
      refreshPostPageCounter!();
    }

    if (refreshRealTimeData != null) {
      developer.log('📊 DASHBOARD: Refreshing real-time data');
      refreshRealTimeData!();
    }

    if (refreshLabelChart != null) {
      developer.log('📊 DASHBOARD: Refreshing label chart');
      refreshLabelChart!();
    }

    if (refreshBarChart != null) {
      developer.log('📊 DASHBOARD: Refreshing bar chart');
      refreshBarChart!();
    }

    developer.log('✅ DASHBOARD: Completed auto-refresh cycle');
    isAutoRefreshing = false; // Reset flag after refresh is complete
  }

  // Manual refresh of all components
  void refreshNow() {
    developer.log('👤 DASHBOARD: Manual refresh triggered by user');
    // Make sure isAutoRefreshing is false for manual refreshes
    isAutoRefreshing = false;
    _refreshAllComponents();
  }

  // Dispose resources
  void dispose() {
    stopAutoRefresh();
  }
}
