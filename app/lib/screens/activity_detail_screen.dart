// lib/screens/activity_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../models/activity.dart';
import '../providers/activity_provider.dart';
import '../services/auth_service.dart';

class ActivityDetailScreen extends StatelessWidget {
  final Activity activity;
  final bool isFromHistory;

  const ActivityDetailScreen({
    Key? key,
    required this.activity,
    this.isFromHistory = false,
  }) : super(key: key);

  void _showQrDialog(
      BuildContext context, String activityId, String activityName) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'QR Điểm danh',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  activityName,
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Theme.of(context).dividerColor,
                      width: 2,
                    ),
                  ),
                  child: QrImageView(
                    data: activityId,
                    version: QrVersions.auto,
                    size: 240.0,
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Đóng'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _handleToggleRegistration(
    BuildContext context,
    ActivityProvider provider,
    Activity activity,
  ) async {
    try {
      await provider.toggleRegistration(activity);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              activity.isRegistered
                  ? 'Hủy đăng ký thành công'
                  : 'Đăng ký thành công',
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: ${e.toString().replaceAll("Exception: ", "")}'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    }
  }

  String _formatDateRange(DateTime start, DateTime end) {
    final DateFormat dayFormat = DateFormat('dd/MM/yyyy');
    final DateFormat timeFormat = DateFormat('HH:mm');
    if (start.year == end.year &&
        start.month == end.month &&
        start.day == end.day) {
      return '${dayFormat.format(start.toLocal())} (${timeFormat.format(start.toLocal())} - ${timeFormat.format(end.toLocal())})';
    } else {
      return '${dayFormat.format(start.toLocal())} ${timeFormat.format(start.toLocal())} - ${dayFormat.format(end.toLocal())} ${timeFormat.format(end.toLocal())}';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final userRole =
        Provider.of<AuthService>(context, listen: false).currentUser?.role;

    return Consumer<ActivityProvider>(
      builder: (context, provider, child) {
        final List<Activity> sourceList =
            isFromHistory ? provider.history : provider.activities;
        final liveActivity = sourceList.firstWhere(
          (a) => a.id == activity.id,
          orElse: () => activity,
        );

        return Scaffold(
          body: CustomScrollView(
            slivers: [
              // === MODERN APP BAR WITH GRADIENT ===
              _buildSliverAppBar(context, theme, liveActivity),

              // === CONTENT ===
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Info Cards
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildInfoCard(theme, liveActivity, userRole),

                          const SizedBox(height: 20),

                          // Description Section
                          Text(
                            'Mô tả hoạt động',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surface,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: theme.dividerColor,
                                width: 1,
                              ),
                            ),
                            child: Text(
                              liveActivity.description,
                              style: theme.textTheme.bodyLarge?.copyWith(
                                height: 1.6,
                              ),
                            ),
                          ),

                          const SizedBox(
                              height: 100), // Space for bottom button
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // === BOTTOM ACTION BUTTON ===
          bottomNavigationBar: _buildBottomAction(
            context,
            theme,
            liveActivity,
            provider,
            userRole,
          ),
        );
      },
    );
  }

  Widget _buildSliverAppBar(
      BuildContext context, ThemeData theme, Activity activity) {
    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      backgroundColor: theme.scaffoldBackgroundColor,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                theme.colorScheme.primary,
                theme.colorScheme.primary.withOpacity(0.8),
                theme.colorScheme.secondary,
              ],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    activity.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      height: 1.2,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.of(context).pop(),
      ),
    );
  }

  Widget _buildInfoCard(ThemeData theme, Activity activity, String? userRole) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.dividerColor,
          width: 1,
        ),
      ),
      child: Column(
        children: [
          _buildInfoRow(theme, Icons.calendar_today_outlined, 'Thời gian',
              _formatDateRange(activity.startDate, activity.endDate)),
          const SizedBox(height: 12),
          Divider(color: theme.dividerColor),
          const SizedBox(height: 12),
          _buildInfoRow(
              theme,
              Icons.timer_off_outlined,
              'Hạn chót ĐK',
              DateFormat('dd/MM/yyyy HH:mm')
                  .format(activity.registrationDeadline.toLocal())),
          const SizedBox(height: 12),
          Divider(color: theme.dividerColor),
          const SizedBox(height: 12),
          _buildInfoRow(
              theme, Icons.location_on_outlined, 'Địa điểm', activity.location),
          if (userRole == 'admin' || activity.maxParticipants > 0) ...[
            const SizedBox(height: 12),
            Divider(color: theme.dividerColor),
            const SizedBox(height: 12),
            _buildInfoRow(theme, Icons.people_outline, 'Số lượng',
                '${activity.participantCount} / ${activity.maxParticipants > 0 ? activity.maxParticipants : 'Không giới hạn'}'),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow(
      ThemeData theme, IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: theme.colorScheme.primary, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBottomAction(
    BuildContext context,
    ThemeData theme,
    Activity activity,
    ActivityProvider provider,
    String? userRole,
  ) {
    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 12,
        bottom: MediaQuery.of(context).padding.bottom + 12,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: userRole == 'admin'
            ? _buildAdminAction(context, theme, activity)
            : _buildStudentAction(context, theme, activity, provider),
      ),
    );
  }

  Widget _buildAdminAction(
      BuildContext context, ThemeData theme, Activity activity) {
    return SizedBox(
      height: 56,
      child: ElevatedButton.icon(
        icon: const Icon(Icons.qr_code_2_sharp, size: 24),
        label: const Text(
          'HIỆN QR ĐIỂM DANH',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
        onPressed: () => _showQrDialog(context, activity.id, activity.name),
      ),
    );
  }

  Widget _buildStudentAction(
    BuildContext context,
    ThemeData theme,
    Activity activity,
    ActivityProvider provider,
  ) {
    if (isFromHistory) {
      return _buildStatusChip(
        theme,
        text: activity.attended ? 'ĐÃ ĐIỂM DANH' : 'CHƯA ĐIỂM DANH',
        color: activity.attended ? Colors.green : Colors.orange,
        icon: activity.attended ? Icons.check_circle : Icons.pending,
      );
    }

    final now = DateTime.now();
    final isRegistrationClosed = now.isAfter(activity.registrationDeadline);
    final isActivityFinished = now.isAfter(activity.endDate);
    final isFull = activity.maxParticipants > 0 &&
        activity.participantCount >= activity.maxParticipants;
    final isLoading = provider.isActivityLoading(activity.id);

    final showUnregisterButton = activity.isRegistered;
    bool isDisabled = isLoading;
    String? disabledReason;

    if (!showUnregisterButton) {
      if (isRegistrationClosed) {
        isDisabled = true;
        disabledReason = 'Đã quá hạn đăng ký';
      } else if (isFull) {
        isDisabled = true;
        disabledReason = 'Đã đủ số lượng';
      }
    } else {
      if (isRegistrationClosed) {
        isDisabled = true;
        disabledReason = 'Đã quá hạn hủy đăng ký';
      }
    }
    if (isActivityFinished) {
      isDisabled = true;
      disabledReason = 'Hoạt động đã kết thúc';
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: 56,
          child: ElevatedButton(
            onPressed: isDisabled
                ? null
                : () => _handleToggleRegistration(context, provider, activity),
            style: ElevatedButton.styleFrom(
              backgroundColor: showUnregisterButton
                  ? Colors.red.shade600
                  : theme.colorScheme.primary,
            ),
            child: isLoading
                ? const SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 3),
                  )
                : Text(
                    showUnregisterButton ? 'HỦY ĐĂNG KÝ' : 'ĐĂNG KÝ',
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w700),
                  ),
          ),
        ),
        if (isDisabled && disabledReason != null && !isLoading)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              disabledReason,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.red.shade700,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildStatusChip({
    required ThemeData theme,
    required String text,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      height: 56,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.white, size: 24),
          const SizedBox(width: 8),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
