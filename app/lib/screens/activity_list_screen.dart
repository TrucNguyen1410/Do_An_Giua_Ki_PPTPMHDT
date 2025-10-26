// lib/screens/activity_list_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/activity_provider.dart';
import '../models/activity.dart';
import 'activity_detail_screen.dart';

class ActivityListScreen extends StatefulWidget {
  const ActivityListScreen({Key? key}) : super(key: key);

  @override
  State<ActivityListScreen> createState() => _ActivityListScreenState();
}

class _ActivityListScreenState extends State<ActivityListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ActivityProvider>(context, listen: false).fetchActivities();
    });
  }

  String _formatSimpleDate(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date.toLocal());
  }

  String _formatTime(DateTime date) {
    return DateFormat('HH:mm').format(date.toLocal());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          // === MODERN APP BAR ===
          _buildSliverAppBar(theme),

          // === CONTENT ===
          Consumer<ActivityProvider>(
            builder: (context, activityProvider, child) {
              if (activityProvider.isLoadingActivities) {
                return const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              if (activityProvider.activitiesError != null) {
                return SliverFillRemaining(
                  child: _buildErrorState(
                      theme, activityProvider.activitiesError!),
                );
              }

              if (activityProvider.activities.isEmpty) {
                return SliverFillRemaining(
                  child: _buildEmptyState(theme),
                );
              }

              return SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final activity = activityProvider.activities[index];
                      return _buildActivityCard(context, theme, activity);
                    },
                    childCount: activityProvider.activities.length,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar(ThemeData theme) {
    return SliverAppBar(
      expandedHeight: 120,
      floating: false,
      pinned: true,
      backgroundColor: theme.scaffoldBackgroundColor,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          'Hoạt động',
          style: TextStyle(
            color: theme.colorScheme.onSurface,
            fontWeight: FontWeight.w700,
            fontSize: 24,
          ),
        ),
        titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
      ),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => Navigator.of(context).pop(),
      ),
    );
  }

  Widget _buildActivityCard(
      BuildContext context, ThemeData theme, Activity activity) {
    final now = DateTime.now();
    final isUpcoming = now.isBefore(activity.startDate);
    final isOngoing =
        now.isAfter(activity.startDate) && now.isBefore(activity.endDate);
    final isPast = now.isAfter(activity.endDate);
    final isRegistrationOpen = now.isBefore(activity.registrationDeadline);

    Color statusColor;
    String statusText;
    IconData statusIcon;

    if (isPast) {
      statusColor = const Color(0xFF6B7280);
      statusText = 'Đã kết thúc';
      statusIcon = Icons.history;
    } else if (isOngoing) {
      statusColor = const Color(0xFF10B981);
      statusText = 'Đang diễn ra';
      statusIcon = Icons.play_circle_filled;
    } else if (isUpcoming) {
      statusColor = const Color(0xFF3B82F6);
      statusText = 'Sắp diễn ra';
      statusIcon = Icons.schedule;
    } else {
      statusColor = const Color(0xFF6B7280);
      statusText = 'Chưa xác định';
      statusIcon = Icons.help_outline;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ActivityDetailScreen(activity: activity),
              ),
            );
          },
          borderRadius: BorderRadius.circular(16),
          child: Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: theme.dividerColor,
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // === HEADER WITH STATUS ===
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.08),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                  ),
                  child: Row(
                    children: [
                      // Status Badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: statusColor,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(statusIcon, color: Colors.white, size: 14),
                            const SizedBox(width: 4),
                            Text(
                              statusText,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const Spacer(),

                      // Registration Status
                      if (!isRegistrationOpen)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEF4444).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: const Color(0xFFEF4444).withOpacity(0.3),
                            ),
                          ),
                          child: const Text(
                            'Hết hạn ĐK',
                            style: TextStyle(
                              color: Color(0xFFEF4444),
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

                // === CONTENT ===
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      Text(
                        activity.name,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                          height: 1.2,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),

                      const SizedBox(height: 12),

                      // Details
                      _buildDetailRow(
                        theme,
                        icon: Icons.calendar_today_outlined,
                        text: _formatSimpleDate(activity.startDate),
                      ),

                      const SizedBox(height: 8),

                      _buildDetailRow(
                        theme,
                        icon: Icons.access_time_outlined,
                        text:
                            '${_formatTime(activity.startDate)} - ${_formatTime(activity.endDate)}',
                      ),

                      const SizedBox(height: 8),

                      _buildDetailRow(
                        theme,
                        icon: Icons.location_on_outlined,
                        text: activity.location,
                      ),

                      if (activity.maxParticipants > 0) ...[
                        const SizedBox(height: 8),
                        _buildDetailRow(
                          theme,
                          icon: Icons.people_outline,
                          text:
                              '${activity.participantCount}/${activity.maxParticipants} người',
                        ),
                      ],
                    ],
                  ),
                ),

                // === FOOTER ===
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    border: Border(
                      top: BorderSide(color: theme.dividerColor, width: 1),
                    ),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(16),
                      bottomRight: Radius.circular(16),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 16,
                        color: theme.colorScheme.onSurface.withOpacity(0.5),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Nhấn để xem chi tiết',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.5),
                        ),
                      ),
                      const Spacer(),
                      Icon(
                        Icons.arrow_forward_ios,
                        size: 14,
                        color: theme.colorScheme.onSurface.withOpacity(0.3),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(ThemeData theme,
      {required IconData icon, required String text}) {
    return Row(
      children: [
        Icon(
          icon,
          size: 18,
          color: theme.colorScheme.primary,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: theme.textTheme.bodyMedium,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.event_busy_outlined,
              size: 60,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Chưa có hoạt động nào',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Hãy quay lại sau để cập nhật hoạt động mới',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(ThemeData theme, String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: theme.colorScheme.error.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline,
                size: 60,
                color: theme.colorScheme.error,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Đã xảy ra lỗi',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                Provider.of<ActivityProvider>(context, listen: false)
                    .fetchActivities();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Thử lại'),
            ),
          ],
        ),
      ),
    );
  }
}
