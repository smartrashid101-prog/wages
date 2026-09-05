import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:connectivity_plus/connectivity_plus.dart';  // ✅ ADD
import 'package:wages/features/calculator/screens/calculator_screen.dart';
import 'package:wages/features/reports/screens/reports_screen.dart';
import 'package:wages/features/history/screens/history_screen.dart';
import 'package:wages/features/employees/screens/employees_screen.dart';
import 'package:wages/features/settings/screens/settings_screen.dart';
import 'package:wages/services/sync_service.dart';
import 'package:wages/shared/providers/auth_provider.dart';
import 'package:wages/shared/providers/employee_provider.dart';
import 'package:wages/shared/providers/work_record_provider.dart';
import 'package:wages/shared/providers/settings_provider.dart';

class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key});

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> with WidgetsBindingObserver {
  int _selectedIndex = 0;
  Timer? _syncTimer;
  Timer? _debounceTimer;
  bool _isSyncing = false;
  
  // ✅ Track if user has been inactive
  DateTime? _lastSyncTime;

  final List<Widget> _screens = const [
    CalculatorScreen(),
    ReportsScreen(),
    HistoryScreen(),
    EmployeesScreen(),
    SettingsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _setupProfessionalSync();
  }

  // ✅ PROFESSIONAL SYNC STRATEGY
  void _setupProfessionalSync() {
    // 1. Sync on app start
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _performAutoSync('App Start');
    });

    // 2. Sync every 15 minutes (not 10)
    _syncTimer = Timer.periodic(const Duration(minutes: 15), (timer) {
      _performAutoSync('Periodic (15 min)');
    });

    // 3. Sync when internet connects
    Connectivity().onConnectivityChanged.listen((result) {
      if (result != ConnectivityResult.none) {
        _performAutoSync('Internet Connected');
      }
    });
  }

  // ✅ SYNC ON APP RESUME (User comes back)
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Check if last sync was more than 5 minutes ago
      final now = DateTime.now();
      if (_lastSyncTime == null || 
          now.difference(_lastSyncTime!) > const Duration(minutes: 5)) {
        _performAutoSync('App Resumed');
      }
    }
  }

  // ✅ PERFORM SYNC WITH DEBOUNCE
  Future<void> _performAutoSync(String reason) async {
    // Prevent multiple syncs at the same time
    if (_isSyncing) return;
    
    // Debounce: Don't sync more than once per 30 seconds
    if (_debounceTimer?.isActive ?? false) return;
    
    _debounceTimer = Timer(const Duration(seconds: 30), () {});

    _isSyncing = true;
    
    try {
      final user = ref.read(authProvider).value;
      if (user == null) return;
      
      final syncService = ref.read(syncServiceProvider);
      final result = await syncService.sync(user.id);
      
      if (result.success && mounted) {
        // Refresh providers
        ref.invalidate(employeeListProvider);
        ref.invalidate(workRecordListProvider);
        ref.invalidate(settingsProvider);
        
        _lastSyncTime = DateTime.now();
        print('🔄 Auto sync completed: $reason at ${DateTime.now()}');
      } else if (result.isOffline) {
        print('📡 Auto sync skipped: Offline');
      }
    } catch (e) {
      print('❌ Auto sync error: $e');
    } finally {
      _isSyncing = false;
    }
  }

  @override
  void dispose() {
    _syncTimer?.cancel();
    _debounceTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.calculate),
            label: 'Calculator',
          ),
          NavigationDestination(
            icon: Icon(Icons.assessment),
            label: 'Reports',
          ),
          NavigationDestination(
            icon: Icon(Icons.history),
            label: 'History',
          ),
          NavigationDestination(
            icon: Icon(Icons.people),
            label: 'Employees',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}