import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class LiveClassesScreen extends StatefulWidget {
  const LiveClassesScreen({super.key});

  @override
  State<LiveClassesScreen> createState() => _LiveClassesScreenState();
}

class _LiveClassesScreenState extends State<LiveClassesScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final String _selectedFilter = 'All';

  final List<Map<String, dynamic>> liveClasses = [
    {
      'id': 'LC001',
      'title': 'Mathematics - Grade 12',
      'tutor': 'Ms Dlamini',
      'subject': 'Mathematics',
      'time': '14:00 - 15:00',
      'date': 'Today',
      'students': 24,
      'maxStudents': 30,
      'status': 'Live',
      'color': AppColors.blue,
      'avatar': 'MD',
      'meetingLink': 'https://meet.google.com/abc-defg-hij',
      'description': 'Algebra and Calculus review for upcoming exams.',
    },
    {
      'id': 'LC002',
      'title': 'Physical Sciences - Physics',
      'tutor': 'Mr Nkosi',
      'subject': 'Physical Sciences',
      'time': '16:00 - 17:30',
      'date': 'Today',
      'students': 18,
      'maxStudents': 25,
      'status': 'Upcoming',
      'color': AppColors.blue,
      'avatar': 'MN',
      'meetingLink': 'https://meet.google.com/klm-nopq-rst',
      'description': 'Newton\'s Laws and Mechanics.',
    },
    {
      'id': 'LC003',
      'title': 'Accounting - Financial Statements',
      'tutor': 'Ms Patel',
      'subject': 'Accounting',
      'time': '10:00 - 11:30',
      'date': 'Tomorrow',
      'students': 12,
      'maxStudents': 20,
      'status': 'Upcoming',
      'color': AppColors.yellow,
      'avatar': 'MP',
      'meetingLink': 'https://meet.google.com/uvw-xyz-abcd',
      'description': 'Understanding balance sheets and income statements.',
    },
    {
      'id': 'LC004',
      'title': 'English Literature - Poetry',
      'tutor': 'Mr Williams',
      'subject': 'English',
      'time': '09:00 - 10:00',
      'date': 'Tomorrow',
      'students': 8,
      'maxStudents': 15,
      'status': 'Upcoming',
      'color': AppColors.blue,
      'avatar': 'MW',
      'meetingLink': 'https://meet.google.com/efgh-ijkl-mnop',
      'description': 'Analysis of modern poetry.',
    },
    {
      'id': 'LC005',
      'title': 'Life Sciences - Biology',
      'tutor': 'Mrs Khumalo',
      'subject': 'Life Sciences',
      'time': '13:00 - 14:30',
      'date': '15 Aug 2026',
      'students': 15,
      'maxStudents': 25,
      'status': 'Scheduled',
      'color': AppColors.blue,
      'avatar': 'MK',
      'meetingLink': 'https://meet.google.com/qrst-uvwx-yzab',
      'description': 'Cell division and genetics.',
    },
    {
      'id': 'LC006',
      'title': 'Mathematics - Trigonometry',
      'tutor': 'Ms Dlamini',
      'subject': 'Mathematics',
      'time': '11:00 - 12:30',
      'date': '16 Aug 2026',
      'students': 20,
      'maxStudents': 30,
      'status': 'Scheduled',
      'color': AppColors.blue,
      'avatar': 'MD',
      'meetingLink': 'https://meet.google.com/cdef-ghij-klmn',
      'description': 'Trigonometric functions and identities.',
    },
  ];

  List<String> get filterOptions => ['All', 'Live', 'Upcoming', 'Scheduled', 'Completed'];

  List<Map<String, dynamic>> get filteredClasses {
    if (_selectedFilter == 'All') {
      return liveClasses;
    }
    return liveClasses.where((c) => c['status'] == _selectedFilter).toList();
  }

  int get liveCount => liveClasses.where((c) => c['status'] == 'Live').length;
  int get upcomingCount => liveClasses.where((c) => c['status'] == 'Upcoming').length;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _joinClass(BuildContext context, Map<String, dynamic> classData) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text(
          'Join Live Class',
          style: TextStyle(
            color: AppColors.blue,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.blueSoft,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: AppColors.blueSoft,
                    child: Text(
                      classData['avatar'],
                      style: TextStyle(
                        color: AppColors.blue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          classData['title'],
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${classData['tutor']} • ${classData['subject']}',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.blueSoft,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.blueLine),
              ),
              child: Row(
                children: [
                  const Icon(Icons.video_call_rounded, color: AppColors.blue),
                  const SizedBox(width: 8),
                  const Text(
                    'You are about to join the meeting',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Meeting Link: ${classData['meetingLink']}',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textMuted,
              ),
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
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      const Icon(Icons.video_call_rounded, color: Colors.white),
                      const SizedBox(width: 12),
                      Text('Joining ${classData['title']}...'),
                    ],
                  ),
                  backgroundColor: AppColors.blue,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.blue,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Join Now',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        title: const Text(
          'Live Classes',
          style: TextStyle(
            color: AppColors.blue,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.blue),
          onPressed: () => Navigator.pop(context),
        ),
        iconTheme: const IconThemeData(color: AppColors.blue),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                color: AppColors.blue,
                borderRadius: BorderRadius.circular(20),
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              labelColor: Colors.white,
              unselectedLabelColor: AppColors.textMuted,
              tabs: const [
                Tab(text: 'All'),
                Tab(text: 'Live'),
                Tab(text: 'Upcoming'),
              ],
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildClassList('All'),
          _buildClassList('Live'),
          _buildClassList('Upcoming'),
        ],
      ),
    );
  }

  Widget _buildClassList(String filter) {
    List<Map<String, dynamic>> classes = liveClasses;
    if (filter != 'All') {
      classes = liveClasses.where((c) => c['status'] == filter).toList();
    }

    return classes.isEmpty
        ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.video_library_rounded,
                  size: 64,
                  color: AppColors.border,
                ),
                const SizedBox(height: 16),
                Text(
                  'No ${filter.toLowerCase()} classes',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textMuted,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Check back later for scheduled classes',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.blueSoft,
                  ),
                ),
              ],
            ),
          )
        : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: classes.length,
            itemBuilder: (context, index) {
              final classData = classes[index];
              return _classCard(context, classData);
            },
          );
  }

  Widget _classCard(BuildContext context, Map<String, dynamic> classData) {
    Color chipBg;
    Color chipFg;
    IconData statusIcon;
    switch (classData['status']) {
      case 'Live':
        chipBg = AppColors.yellow;
        chipFg = AppColors.navy;
        statusIcon = Icons.live_tv_rounded;
        break;
      case 'Upcoming':
        chipBg = AppColors.blue;
        chipFg = AppColors.white;
        statusIcon = Icons.schedule_rounded;
        break;
      case 'Scheduled':
        chipBg = AppColors.blueSoft;
        chipFg = AppColors.blue;
        statusIcon = Icons.event_rounded;
        break;
      default:
        chipBg = AppColors.border;
        chipFg = AppColors.textMuted;
        statusIcon = Icons.check_circle_rounded;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0x140B2A66),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: classData['status'] == 'Live' ? AppColors.blueLine : AppColors.border,
          width: 1,
        ),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: classData['status'] == 'Live' ? AppColors.blueSoft : AppColors.blueSoft,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.blue,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      classData['avatar'],
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        classData['title'],
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: AppColors.blue,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        '${classData['tutor']} • ${classData['subject']}',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: chipBg,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(statusIcon, size: 12, color: chipFg),
                      const SizedBox(width: 4),
                      Text(
                        classData['status'],
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: chipFg,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Body
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    const Icon(Icons.calendar_today_rounded, size: 14, color: AppColors.textMuted),
                    const SizedBox(width: 6),
                    Text(
                      classData['date'],
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textMuted,
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Icon(Icons.access_time_rounded, size: 14, color: AppColors.textMuted),
                    const SizedBox(width: 6),
                    Text(
                      classData['time'],
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.people_rounded, size: 14, color: AppColors.textMuted),
                    const SizedBox(width: 6),
                    Text(
                      '${classData['students']}/${classData['maxStudents']} students enrolled',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textMuted,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Container(
                      width: 80,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.border,
                        borderRadius: BorderRadius.circular(2),
                      ),
                      child: FractionallySizedBox(
                        widthFactor: classData['students'] / classData['maxStudents'],
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppColors.blue,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  classData['description'],
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textMuted,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (classData['status'] == 'Live')
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.blueSoft,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.blueLine),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: AppColors.navy,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            const Text(
                              'LIVE NOW',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: AppColors.navy,
                              ),
                            ),
                          ],
                        ),
                      ),
                    const Spacer(),
                    if (classData['status'] == 'Live' || classData['status'] == 'Upcoming')
                      ElevatedButton.icon(
                        onPressed: () => _joinClass(context, classData),
                        icon: const Icon(Icons.video_call_rounded, size: 16, color: Colors.white),
                        label: Text(
                          classData['status'] == 'Live' ? 'Join Now' : 'Join',
                          style: const TextStyle(color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: classData['status'] == 'Live'
                              ? AppColors.navy
                              : AppColors.blue,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          elevation: 0,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}