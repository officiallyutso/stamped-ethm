import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:stamped/core/models/project_model.dart';
import 'package:stamped/core/models/photo_model.dart';
import 'package:stamped/core/models/attendance_model.dart';
import 'package:stamped/core/services/workspace_service.dart';
import 'package:stamped/core/services/firestore_report_service.dart';
import 'package:stamped/core/theme/app_colors.dart';
import 'package:stamped/features/workspace/network_photo_viewer_screen.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:url_launcher/url_launcher.dart';

class ProjectDetailsScreen extends StatefulWidget {
  final ProjectModel project;

  const ProjectDetailsScreen({super.key, required this.project});

  @override
  State<ProjectDetailsScreen> createState() => _ProjectDetailsScreenState();
}

class _ProjectDetailsScreenState extends State<ProjectDetailsScreen>
    with SingleTickerProviderStateMixin {
  final WorkspaceService _workspaceService = WorkspaceService();
  final FirestoreReportService _reportService = FirestoreReportService();
  bool _hasAttendance = false;
  bool _loading = true;
  TabController? _tabController;

  @override
  void initState() {
    super.initState();
    _checkAttendance();
  }

  Future<void> _checkAttendance() async {
    final has = await _workspaceService.hasProjectAttendance(widget.project.id);
    if (mounted) {
      setState(() {
        _hasAttendance = has;
        _loading = false;
        // Always show tabs: Photos + Reports (+ Attendance if exists)
        final tabCount = _hasAttendance ? 3 : 2;
        _tabController = TabController(
          length: tabCount,
          vsync: this,
        );
      });
    }
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  List<Tab> _buildTabs() {
    final tabs = <Tab>[
      const Tab(text: 'Photos'),
    ];
    if (_hasAttendance) {
      tabs.add(const Tab(text: 'Attendance'));
    }
    tabs.add(const Tab(text: 'Reports'));
    return tabs;
  }

  List<Widget> _buildTabViews() {
    final views = <Widget>[
      _buildPhotosTab(),
    ];
    if (_hasAttendance) {
      views.add(_buildAttendanceTab());
    }
    views.add(_buildReportsTab());
    return views;
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(title: Text(widget.project.name), backgroundColor: Colors.white, foregroundColor: Colors.black, elevation: 0),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(widget.project.name),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primaryRed,
          unselectedLabelColor: Colors.grey,
          indicatorColor: AppColors.primaryRed,
          indicatorWeight: 3,
          tabs: _buildTabs(),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.project.latitude != null && widget.project.longitude != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                children: [
                  const Icon(LucideIcons.mapPin, size: 14, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    '${widget.project.latitude!.toStringAsFixed(4)}, ${widget.project.longitude!.toStringAsFixed(4)}',
                    style: const TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          const Divider(height: 1),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: _buildTabViews(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotosTab() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('photos')
          .where('projectId', isEqualTo: widget.project.id)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: AppColors.primaryRed));
        }

        final docs = snapshot.data?.docs ?? [];
        if (docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(LucideIcons.image, size: 48, color: Colors.grey.shade300),
                const SizedBox(height: 16),
                const Text('No photos in this project.', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w600)),
              ],
            ),
          );
        }

        final photos = docs.map((doc) => PhotoModel.fromFirestore(doc)).toList();
        photos.sort((a, b) => b.timestamp.compareTo(a.timestamp));

        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemCount: photos.length,
          itemBuilder: (context, index) {
            final photo = photos[index];
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => NetworkPhotoViewerScreen(photo: photo),
                  ),
                );
              },
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: CachedNetworkImage(
                      imageUrl: photo.cloudinaryUrl,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(color: Colors.grey.shade100),
                      errorWidget: (context, url, error) => const Icon(Icons.error),
                    ),
                  ),
                  if (photo.txId != null && photo.txId!.isNotEmpty)
                    Positioned(
                      top: 4,
                      left: 4,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: AppColors.primaryRed,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 1.5),
                        ),
                        child: const Icon(LucideIcons.check, size: 12, color: Colors.white),
                      ),
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildAttendanceTab() {
    return StreamBuilder<List<AttendanceModel>>(
      stream: _workspaceService.getProjectAttendance(widget.project.id),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: AppColors.primaryRed));
        }

        final records = snapshot.data ?? [];
        if (records.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(LucideIcons.clipboardCheck, size: 48, color: Colors.grey.shade300),
                const SizedBox(height: 16),
                const Text('No attendance records yet.', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w600)),
              ],
            ),
          );
        }

        // Group by date
        final Map<String, List<AttendanceModel>> grouped = {};
        for (final record in records) {
          final dateKey = DateFormat('yyyy-MM-dd').format(record.timestamp);
          grouped.putIfAbsent(dateKey, () => []);
          grouped[dateKey]!.add(record);
        }

        final dates = grouped.keys.toList()..sort((a, b) => b.compareTo(a));

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: dates.length,
          itemBuilder: (context, index) {
            final dateKey = dates[index];
            final dayRecords = grouped[dateKey]!;
            dayRecords.sort((a, b) => a.timestamp.compareTo(b.timestamp));

            // Calculate duration
            final duration = _calculateDayDuration(dayRecords);
            final dateLabel = DateFormat('EEEE, MMM d, yyyy').format(dayRecords.first.timestamp);

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Date Header
                Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        dateLabel,
                        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: Colors.black87),
                      ),
                      if (duration != null)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.primaryRed,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            duration.toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                              fontSize: 10,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

                // Timeline entries
                ...dayRecords.map((record) => _buildTimelineEntry(record)),

                const SizedBox(height: 12),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildTimelineEntry(AttendanceModel record) {
    final color = _getTypeColor(record.type);
    final icon = _getTypeIcon(record.type);
    final time = DateFormat('hh:mm a').format(record.timestamp);

    return Padding(
      padding: const EdgeInsets.only(bottom: 0),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Timeline indicator
            Column(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, size: 16, color: Colors.white),
                ),
                Expanded(
                  child: Container(
                    width: 2,
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    color: Colors.grey.shade200,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 16),

            // Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          record.typeLabel.toUpperCase(),
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 11,
                            color: color,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          time,
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Photo thumbnail
                    if (record.photoUrl != null && record.photoUrl!.isNotEmpty)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: GestureDetector(
                          onTap: () {
                            // Can reuse generic viewer or create one for attendance
                            // For now just show in the same one
                          },
                          child: SizedBox(
                            height: 100,
                            width: 160,
                            child: CachedNetworkImage(
                              imageUrl: record.photoUrl!,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Container(color: Colors.grey.shade100),
                              errorWidget: (context, url, error) => Container(
                                color: Colors.grey.shade100,
                                child: const Icon(LucideIcons.imageOff, color: Colors.grey, size: 20),
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getTypeColor(AttendanceType type) {
    switch (type) {
      case AttendanceType.timeIn:
        return AppColors.primaryRed;
      case AttendanceType.timeOut:
        return AppColors.textGreen;
      case AttendanceType.breakStart:
        return Colors.orange;
      case AttendanceType.breakEnd:
        return AppColors.primaryRed;
    }
  }

  IconData _getTypeIcon(AttendanceType type) {
    switch (type) {
      case AttendanceType.timeIn:
        return LucideIcons.clock;
      case AttendanceType.timeOut:
        return LucideIcons.logOut;
      case AttendanceType.breakStart:
        return LucideIcons.coffee;
      case AttendanceType.breakEnd:
        return LucideIcons.play;
    }
  }

  String? _calculateDayDuration(List<AttendanceModel> dayRecords) {
    // Find first timeIn and last timeOut
    DateTime? firstIn;
    DateTime? lastOut;

    for (final r in dayRecords) {
      if (r.type == AttendanceType.timeIn && (firstIn == null || r.timestamp.isBefore(firstIn))) {
        firstIn = r.timestamp;
      }
      if (r.type == AttendanceType.timeOut && (lastOut == null || r.timestamp.isAfter(lastOut))) {
        lastOut = r.timestamp;
      }
    }

    if (firstIn != null && lastOut != null) {
      final dur = lastOut.difference(firstIn);
      final h = dur.inHours;
      final m = dur.inMinutes % 60;
      if (h > 0) return '${h}H ${m}M';
      return '${m}M';
    }
    return null;
  }

  Widget _buildReportsTab() {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: _reportService.getProjectReports(widget.project.id),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final reports = snapshot.data ?? [];
        if (reports.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(LucideIcons.fileText, size: 48, color: Colors.grey[300]),
                const SizedBox(height: 16),
                Text(
                  'No reports here',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[600],
                  ),
                ),
                Text(
                  'Upload a report from the Reports History tab',
                  style: TextStyle(color: Colors.grey[400], fontSize: 13),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: reports.length,
          itemBuilder: (context, index) {
            final report = reports[index];
            final title = report['reportTitle'] ?? 'Report';
            final link = report['fileverseLink'] ?? '';
            final uploaderName = report['uploaderName'] ?? 'Unknown User';
            
            String dateText = 'Unknown date';
            if (report['uploadedAt'] != null && report['uploadedAt'] is Timestamp) {
              dateText = DateFormat('MMM d, yyyy').format((report['uploadedAt'] as Timestamp).toDate());
            }

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: AppColors.primaryRed.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            LucideIcons.fileText,
                            color: AppColors.primaryRed,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                title,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 15,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(LucideIcons.user, size: 12, color: Colors.grey[500]),
                                  const SizedBox(width: 4),
                                  Text(
                                    uploaderName,
                                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                                  ),
                                  const SizedBox(width: 12),
                                  Icon(LucideIcons.calendar, size: 12, color: Colors.grey[500]),
                                  const SizedBox(width: 4),
                                  Text(
                                    dateText,
                                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    if (link.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      InkWell(
                        onTap: () => launchUrl(Uri.parse(link)),
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: Row(
                            children: [
                              const Icon(LucideIcons.externalLink, size: 14, color: AppColors.primaryRed),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  link,
                                  style: const TextStyle(
                                    color: AppColors.primaryRed,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
