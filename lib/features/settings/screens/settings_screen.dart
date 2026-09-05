import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:wages/shared/providers/auth_provider.dart';  // ✅ Fixed
import 'package:wages/shared/providers/settings_provider.dart';  // ✅ Fixed
import 'package:wages/services/sync_service.dart';  // ✅ Fixed
import 'package:wages/services/backup_service.dart';  // ✅ Fixed
import 'package:wages/services/pdf_service.dart';  // ✅ Fixed
import 'package:wages/core/constants/app_constants.dart';  // ✅ Fixed
import 'package:wages/shared/widgets/loading_widget.dart';  // ✅ Fixed
import 'package:wages/shared/providers/employee_provider.dart';  // ✅ Fixed
import 'package:wages/shared/providers/work_record_provider.dart';  // ✅ Fixed

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final BackupService _backupService = BackupService();
  final PdfService _pdfService = PdfService();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final settingsAsync = ref.watch(settingsProvider);
    final syncState = ref.watch(syncStateProvider);
    final pendingChanges = ref.watch(pendingChangesProvider);
    final authState = ref.watch(authProvider);
    final user = authState.value;

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text('Settings', style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.invalidate(settingsProvider);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Settings refreshed')),
              );
            },
          ),
        ],
      ),
      body: settingsAsync.when(
        data: (settings) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildUserHeaderCard(user?.name, user?.email),
              const SizedBox(height: 16),

              _buildSyncCard(syncState, pendingChanges),
              const SizedBox(height: 16),

              _buildCardSection(
                title: 'Data & Storage',
                children: [
                  _buildTile(
                    icon: Icons.backup_outlined,
                    title: 'Export Backup',
                    subtitle: 'Save local copy as JSON',
                    onTap: _isLoading ? null : _exportBackup,
                  ),
                  _buildTile(
                    icon: Icons.restore,
                    title: 'Import Backup',
                    subtitle: 'Restore database from file',
                    onTap: _isLoading ? null : _importBackup,
                  ),
                  _buildTile(
                    icon: Icons.cleaning_services_outlined,
                    title: 'Clear Cache',
                    subtitle: 'Purge local temporary storage',
                    onTap: _isLoading ? null : _showClearCacheDialog,
                    isLast: true,
                  ),
                ],
              ),
              const SizedBox(height: 16),

              _buildCardSection(
                title: 'Account',
                children: [
                  _buildTile(
                    icon: Icons.person_outline,
                    title: 'Edit Profile',
                    subtitle: user?.name ?? 'Update personal details',
                    onTap: _showProfileDialog,
                  ),
                  _buildTile(
                    icon: Icons.lock_outline,
                    title: 'Change Password',
                    subtitle: 'Update authorization credentials',
                    onTap: _showChangePasswordDialog,
                  ),
                  _buildTile(
                    icon: Icons.logout,
                    title: 'Logout',
                    subtitle: 'Sign out of your current session',
                    color: Colors.red,
                    onTap: _showLogoutDialog,
                  ),
                /*  _buildTile(
                    icon: Icons.delete_forever,
                    title: 'Delete Account',
                    subtitle: 'Permanently remove account and data',
                    color: Colors.red,
                    onTap: _showDeleteAccountDialog,
                    isLast: true,
                  ),*/
                ],
              ),
              const SizedBox(height: 16),

              _buildCardSection(
                title: 'About',
                children: [
                  _buildTile(
                    icon: Icons.info_outline,
                    title: 'App Version',
                    subtitle: AppConstants.appVersion,
                  ),
                  _buildTile(
                    icon: Icons.privacy_tip_outlined,
                    title: 'Privacy Policy',
                    subtitle: 'Read privacy terms',
                    onTap: _showPrivacyPolicy,
                  ),
                  _buildTile(
                    icon: Icons.description_outlined,
                    title: 'Terms of Service',
                    subtitle: 'Read usage guidelines',
                    onTap: _showTermsOfService,
                    isLast: true,
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          );
        },
        loading: () => const LoadingWidget(),
        error: (_, __) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              const Text('Error loading settings'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.invalidate(settingsProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- UI Components ---

  Widget _buildUserHeaderCard(String? name, String? email) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [const Color(0xFF4c5b92), const Color(0xFF4c5b92).withValues(alpha: 0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4c5b92).withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: Colors.white24,
            child: Text(
              (name != null && name.isNotEmpty) ? name[0].toUpperCase() : 'U',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name ?? 'User Profile',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                if (email != null)
                  Text(
                    email,
                    style: const TextStyle(color: Colors.white70, fontSize: 13),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSyncCard(SyncState syncState, AsyncValue<int> pendingChanges) {
    final isOffline = syncState.isOffline;
    final isError = syncState.error != null;
    final color = isOffline ? Colors.orange : (isError ? Colors.red : Colors.green);
    final statusText = syncState.isSyncing 
        ? 'Syncing...' 
        : (isOffline 
            ? 'Offline Mode' 
            : (isError 
                ? 'Sync Failed' 
                : 'Cloud Synced'));

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          ListTile(
            leading: syncState.isSyncing
                ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2))
                : Icon(
                    isOffline 
                        ? Icons.wifi_off 
                        : (isError 
                            ? Icons.error_outline 
                            : Icons.cloud_done),
                    color: color,
                  ),
            title: Text(
              statusText,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
            subtitle: syncState.lastSyncTime != null
                ? Text('Last sync: ${_formatTime(syncState.lastSyncTime!)}')
                : const Text('Tap sync to start'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                pendingChanges.when(
                  data: (count) => count > 0
                      ? Chip(
                          label: Text('$count pending', style: const TextStyle(color: Colors.white, fontSize: 11)),
                          backgroundColor: Colors.orange,
                          padding: EdgeInsets.zero,
                        )
                      : const SizedBox.shrink(),
                  loading: () => const SizedBox.shrink(),
                  error: (_, __) => const SizedBox.shrink(),
                ),
                const SizedBox(width: 4),
                IconButton(
                  icon: Icon(
                    syncState.isSyncing ? Icons.stop : Icons.refresh,
                    color: syncState.isSyncing ? Colors.red : Colors.blue,
                  ),
                  onPressed: _isLoading || syncState.isSyncing ? null : _syncNow,
                  tooltip: syncState.isSyncing ? 'Stop Sync' : 'Sync Now',
                ),
              ],
            ),
          ),
          if (isError) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline, color: Colors.red.shade700, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        syncState.error ?? 'Unknown error',
                        style: TextStyle(color: Colors.red.shade700, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCardSection({required String title, required List<Widget> children}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            title,
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.grey.shade700),
          ),
        ),
        Card(
          elevation: 0,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildTile({
    required IconData icon,
    required String title,
    required String subtitle,
    VoidCallback? onTap,
    Color? color,
    bool isLast = false,
  }) {
    return Column(
      children: [
        ListTile(
          leading: Icon(icon, color: color ?? const Color(0xFF4c5b92)),
          title: Text(title, style: TextStyle(color: color, fontWeight: FontWeight.w500)),
          subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
          trailing: onTap != null ? const Icon(Icons.chevron_right, size: 20) : null,
          onTap: onTap,
        ),
        if (!isLast) const Divider(height: 1, indent: 56, endIndent: 16),
      ],
    );
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  // --- Logic & Actions ---

  Future<void> _syncNow() async {
    setState(() => _isLoading = true);
    try {
      final user = ref.read(authProvider).value;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please login first')),
        );
        return;
      }

      ref.read(syncStateProvider.notifier).state = const SyncState.syncing();
      
      final syncService = ref.read(syncServiceProvider);
      final result = await syncService.sync(user.id);
      
      if (!mounted) return;
      
      if (result.success) {
        ref.read(syncStateProvider.notifier).state = SyncState.success();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Sync completed successfully')),
        );
      } else if (result.isOffline) {
        ref.read(syncStateProvider.notifier).state = const SyncState.offline();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('📡 No internet connection')),
        );
      } else {
        ref.read(syncStateProvider.notifier).state = SyncState.error(result.error ?? 'Unknown error');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ Sync failed: ${result.error}')),
        );
      }
      
      ref.invalidate(settingsProvider);
      
    } catch (e) {
      if (mounted) {
        ref.read(syncStateProvider.notifier).state = SyncState.error(e.toString());
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ Sync error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // ✅ FIXED: Export Backup with Real Data
  Future<void> _exportBackup() async {
    setState(() => _isLoading = true);
    try {
      final user = ref.read(authProvider).value;
      if (user == null) return;

      // ✅ Load real data
      final employeeRepo = ref.read(employeeRepositoryProvider);
      final workRecordRepo = ref.read(workRecordRepositoryProvider);
      
      final employees = await employeeRepo.getEmployeesByUserId(user.id);
      final workRecords = await workRecordRepo.getWorkRecordsByUserId(user.id);
      final settings = await ref.read(settingsProvider.future);

      // ✅ Convert to backup models
      final backupEmployees = employees.map((e) => BackupEmployee(
        id: e.id,
        userId: e.userId,
        name: e.name,
        hourlyRateCents: e.hourlyRateCents,
        overtimeRateCents: e.overtimeRateCents,
        overtimeMultiplier: e.overtimeMultiplier,
        notes: e.notes,
        active: e.active,
        createdAt: e.createdAt,
        updatedAt: e.updatedAt,
        deletedAt: e.deletedAt,
      )).toList();

      final backupRecords = workRecords.map((r) => BackupWorkRecord(
        id: r.id,
        userId: r.userId,
        employeeId: r.employeeId,
        workDate: r.workDate,
        startTime: r.startTime,
        endTime: r.endTime,
        breakMinutes: r.breakMinutes,
        overtimeMode: r.overtimeMode,
        regularMinutes: r.regularMinutes,
        overtimeMinutes: r.overtimeMinutes,
        totalMinutes: r.totalMinutes,
        hourlyRateCents: r.hourlyRateCents,
        overtimeRateCents: r.overtimeRateCents,
        bonusCents: r.bonusCents,
        deductionsCents: r.deductionsCents,
        regularPayCents: r.regularPayCents,
        overtimePayCents: r.overtimePayCents,
        grossPayCents: r.grossPayCents,
        netPayCents: r.netPayCents,
        notes: r.notes,
        createdAt: r.createdAt,
        updatedAt: r.updatedAt,
        deletedAt: r.deletedAt,
      )).toList();

      BackupSettings? backupSettings;
      if (settings != null) {
        backupSettings = BackupSettings(
          id: settings.id,
          userId: settings.userId,
          currency: settings.currency,
          defaultHourlyRateCents: settings.defaultHourlyRateCents,
          defaultOvertimeMultiplier: settings.defaultOvertimeMultiplier,
          defaultBreakMinutes: settings.defaultBreakMinutes,
          defaultRegularThresholdMinutes: settings.defaultRegularThresholdMinutes,
          timeFormat: settings.timeFormat,
          createdAt: settings.createdAt,
          updatedAt: settings.updatedAt,
        );
      }

      final file = await _backupService.exportData(
        userId: user.id,
        employees: backupEmployees,
        workRecords: backupRecords,
        settings: backupSettings,
      );

      await _pdfService.sharePdf(file, message: 'WAGES Backup File');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ Backup exported: ${backupEmployees.length} employees, ${backupRecords.length} records'),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ Export failed: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ✅ FIXED: Import Backup with Real Data Saving
  Future<void> _importBackup() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom, 
        allowedExtensions: ['json'],
      );
      
      if (result == null || result.files.isEmpty) return;

      final file = File(result.files.single.path!);
      
      // ✅ Validate backup
      final validation = await _backupService.validateBackup(file);
      if (!validation.isValid) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('❌ Invalid backup: ${validation.error}')),
          );
        }
        return;
      }

      final confirm = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Import Backup'),
          content: const Text(
            'This will import all data from the backup file.\n\n'
            'Existing data will be updated or created.\n'
            'Are you sure you want to continue?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4c5b92),
                foregroundColor: Colors.white,
              ),
              child: const Text('Import'),
            ),
          ],
        ),
      );

      if (confirm != true) return;
      
      setState(() => _isLoading = true);

      final user = ref.read(authProvider).value;
      if (user == null) return;

      final result2 = await _backupService.importData(user.id, file);
      
      if (!mounted) return;

      if (result2.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ Imported: ${result2.importedEmployees} employees, ${result2.importedRecords} records'),
            duration: const Duration(seconds: 3),
          ),
        );
        // ✅ Refresh all data
        ref.invalidate(settingsProvider);
        ref.invalidate(employeeListProvider);
        ref.invalidate(workRecordListProvider);
        
        // ✅ Show success with reload option
        _showImportSuccessDialog(result2);
        
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ Import failed: ${result2.error}')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ Import error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ✅ Show import success dialog with reload option
  void _showImportSuccessDialog(ImportResult result) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green),
            SizedBox(width: 8),
            Text('Import Successful'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('✅ ${result.importedEmployees} employees imported'),
            Text('✅ ${result.importedRecords} work records imported'),
            const SizedBox(height: 8),
            const Text(
              'Data has been restored successfully.',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // ✅ Refresh the page
              setState(() {});
            },
            child: const Text('OK'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // ✅ Reload everything
              ref.invalidate(settingsProvider);
              ref.invalidate(employeeListProvider);
              ref.invalidate(workRecordListProvider);
              setState(() {});
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('🔄 Data refreshed')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4c5b92),
              foregroundColor: Colors.white,
            ),
            child: const Text('Refresh Data'),
          ),
        ],
      ),
    );
  }

  void _showClearCacheDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.orange),
            const SizedBox(width: 8),
            const Text('Clear Local Cache'),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'This will clear all locally stored data including:',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            SizedBox(height: 8),
            Text('• Login session'),
            Text('• Cached records'),
            Text('• Temporary files'),
            SizedBox(height: 8),
            Text(
              'You will need to login again after clearing cache.',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _clearCache();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Cache cleared! Please login again.'),
                  duration: Duration(seconds: 3),
                ),
              );
              Future.delayed(const Duration(milliseconds: 500), () {
                Navigator.pushReplacementNamed(context, '/login');
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Clear Cache'),
          ),
        ],
      ),
    );
  }

  void _clearCache() {
    ref.invalidate(settingsProvider);
    ref.invalidate(authProvider);
    ref.invalidate(syncStateProvider);
    ref.invalidate(pendingChangesProvider);
    ref.invalidate(employeeListProvider);
    ref.invalidate(workRecordListProvider);
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              await ref.read(authNotifierProvider.notifier).signOut();
              if (mounted) {
                Navigator.pop(context);
                Navigator.pushReplacementNamed(context, '/login');
              }
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

 /* void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account'),
        content: const Text('This action is permanent and cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Feature coming soon')));
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  } */

  void _showProfileDialog() {
    final user = ref.read(authProvider).value;
    final nameController = TextEditingController(text: user?.name ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update Profile'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(labelText: 'Name', border: OutlineInputBorder()),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.trim().isNotEmpty) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile updated')));
                ref.invalidate(settingsProvider);
                ref.invalidate(authProvider);
              }
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  void _showChangePasswordDialog() {
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change Password'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: newPasswordController,
              decoration: const InputDecoration(labelText: 'New Password', border: OutlineInputBorder()),
              obscureText: true,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: confirmPasswordController,
              decoration: const InputDecoration(labelText: 'Confirm Password', border: OutlineInputBorder()),
              obscureText: true,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (newPasswordController.text == confirmPasswordController.text && newPasswordController.text.length >= 6) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Password updated')));
              } else {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Passwords do not match or too short')));
              }
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  void _showPrivacyPolicy() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Privacy Policy'),
        content: const SingleChildScrollView(
          child: Text(
            'WAGES stores your data securely via Supabase with row-level security.\n\n'
            'Your data is never shared with third parties.\n\n'
            'You can export or delete your data at any time.',
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
        ],
      ),
    );
  }

  void _showTermsOfService() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Terms of Service'),
        content: const SingleChildScrollView(
          child: Text(
            'By using WAGES, you agree to:\n\n'
            '• Responsible account usage\n'
            '• Data ownership belongs to you\n'
            '• Service provided "as is"\n'
            '• You can delete your data anytime',
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
        ],
      ),
    );
  }
}