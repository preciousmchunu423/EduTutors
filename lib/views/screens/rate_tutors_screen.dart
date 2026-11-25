import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class RateTutorsScreen extends StatefulWidget {
  const RateTutorsScreen({super.key});

  @override
  State<RateTutorsScreen> createState() => _RateTutorsScreenState();
}

class _RateTutorsScreenState extends State<RateTutorsScreen> {
  String _selectedFilter = 'All';
  
  final List<Map<String, dynamic>> tutors = [
    {
      'id': 'T001',
      'name': 'Ms Dlamini',
      'subject': 'Mathematics',
      'rating': 4.9,
      'totalRatings': 127,
      'students': 45,
      'price': 'R150/hr',
      'avatar': 'MD',
      'color': AppColors.blue,
      'reviews': [
        {'student': 'John M.', 'rating': 5, 'comment': 'Excellent tutor! Very patient and clear.', 'date': '12 Aug 2026'},
        {'student': 'Sarah K.', 'rating': 5, 'comment': 'Helped me understand complex concepts easily.', 'date': '10 Aug 2026'},
        {'student': 'Mike P.', 'rating': 4, 'comment': 'Good tutor, explains well.', 'date': '8 Aug 2026'},
      ],
    },
    {
      'id': 'T002',
      'name': 'Mr Nkosi',
      'subject': 'Physical Sciences',
      'rating': 4.8,
      'totalRatings': 98,
      'students': 38,
      'price': 'R180/hr',
      'avatar': 'MN',
      'color': AppColors.blue,
      'reviews': [
        {'student': 'Lisa T.', 'rating': 5, 'comment': 'Best physics tutor ever!', 'date': '11 Aug 2026'},
        {'student': 'David R.', 'rating': 4, 'comment': 'Very knowledgeable.', 'date': '9 Aug 2026'},
      ],
    },
    {
      'id': 'T003',
      'name': 'Ms Patel',
      'subject': 'Accounting',
      'rating': 4.7,
      'totalRatings': 156,
      'students': 52,
      'price': 'R160/hr',
      'avatar': 'MP',
      'color': AppColors.yellow,
      'reviews': [
        {'student': 'Amy W.', 'rating': 5, 'comment': 'Made accounting fun and easy!', 'date': '10 Aug 2026'},
        {'student': 'Tom H.', 'rating': 4, 'comment': 'Good explanation of concepts.', 'date': '7 Aug 2026'},
        {'student': 'Emma L.', 'rating': 5, 'comment': 'Very helpful for exams.', 'date': '5 Aug 2026'},
      ],
    },
    {
      'id': 'T004',
      'name': 'Mr Williams',
      'subject': 'English',
      'rating': 4.6,
      'totalRatings': 83,
      'students': 30,
      'price': 'R140/hr',
      'avatar': 'MW',
      'color': AppColors.blue,
      'reviews': [
        {'student': 'Kate S.', 'rating': 5, 'comment': 'Improved my essay writing significantly.', 'date': '8 Aug 2026'},
        {'student': 'James B.', 'rating': 4, 'comment': 'Good tutor.', 'date': '6 Aug 2026'},
      ],
    },
  ];

  List<String> get filterOptions => ['All', 'Mathematics', 'Physical Sciences', 'Accounting', 'English'];

  List<Map<String, dynamic>> get filteredTutors {
    if (_selectedFilter == 'All') {
      return tutors;
    }
    return tutors.where((t) => t['subject'] == _selectedFilter).toList();
  }

  void _showRateDialog(BuildContext context, Map<String, dynamic> tutor) {
    double rating = 0;
    // ignore: unused_local_variable
    String comment = '';
    bool isSubmitting = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            title: Row(
              children: [
                CircleAvatar(
                  backgroundColor: AppColors.blueSoft,
                  child: Text(
                    tutor['avatar'],
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
                        tutor['name'],
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        tutor['subject'],
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Rating Stars
                const Text(
                  'How would you rate this tutor?',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (index) {
                    return IconButton(
                      onPressed: () {
                        setStateDialog(() {
                          rating = index + 1;
                        });
                      },
                      icon: Icon(
                        index < rating ? Icons.star_rounded : Icons.star_border_rounded,
                        color: index < rating ? AppColors.yellow : AppColors.border,
                        size: 40,
                      ),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    );
                  }),
                ),
                if (rating > 0)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      _getRatingLabel(rating),
                      style: TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 14,
                      ),
                    ),
                  ),
                const SizedBox(height: 16),
                // Comment Field
                TextField(
                  onChanged: (value) {
                    comment = value;
                  },
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: 'Share your experience...',
                    filled: true,
                    fillColor: AppColors.blueSoft,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.all(16),
                  ),
                ),
                if (isSubmitting)
                  const Padding(
                    padding: EdgeInsets.only(top: 16),
                    child: CircularProgressIndicator(),
                  ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: isSubmitting ? null : () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: isSubmitting
                    ? null
                    : () async {
                        if (rating == 0) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Please select a rating'),
                              backgroundColor: AppColors.navy,
                            ),
                          );
                          return;
                        }
                        setStateDialog(() {
                          isSubmitting = true;
                        });
                        
                        // Simulate submission
                        await Future.delayed(const Duration(seconds: 1));
                        
                        if (context.mounted) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Row(
                                children: [
                                  const Icon(Icons.check_circle_rounded, color: Colors.white),
                                  const SizedBox(width: 12),
                                  Text('Thank you for rating ${tutor['name']}!'),
                                ],
                              ),
                              backgroundColor: AppColors.blue,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          );
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: isSubmitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        'Submit Rating',
                        style: TextStyle(color: Colors.white),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  String _getRatingLabel(double rating) {
    switch (rating.toInt()) {
      case 1:
        return 'Poor - Needs improvement';
      case 2:
        return 'Fair - Could be better';
      case 3:
        return 'Good - Satisfactory';
      case 4:
        return 'Very Good - Impressive';
      case 5:
        return 'Excellent - Outstanding!';
      default:
        return '';
    }
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
          'Rate Tutors',
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
      ),
      body: Column(
        children: [
          // Filter Chips
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: SizedBox(
              height: 40,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: filterOptions.length,
                itemBuilder: (context, index) {
                  final filter = filterOptions[index];
                  final isSelected = filter == _selectedFilter;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(filter),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          _selectedFilter = filter;
                        });
                      },
                      backgroundColor: Colors.white,
                      selectedColor: AppColors.blue,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : AppColors.textMuted,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                      shape: StadiumBorder(
                        side: BorderSide(
                          color: isSelected ? AppColors.blue : AppColors.border,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          // Tutors List
          Expanded(
            child: filteredTutors.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off_rounded,
                          size: 64,
                          color: AppColors.border,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No tutors found',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredTutors.length,
                    itemBuilder: (context, index) {
                      final tutor = filteredTutors[index];
                      return _tutorCard(context, tutor);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _tutorCard(BuildContext context, Map<String, dynamic> tutor) {
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
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                // Avatar
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: AppColors.blue,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      tutor['avatar'],
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                // Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tutor['name'],
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.blue,
                        ),
                      ),
                      Text(
                        tutor['subject'],
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.textMuted,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.star_rounded, color: AppColors.yellow, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            tutor['rating'].toString(),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '(${tutor['totalRatings']} ratings)',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Price
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      tutor['price'],
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.blue,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.blue,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: ElevatedButton(
                        onPressed: () => _showRateDialog(context, tutor),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          elevation: 0,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.star_rounded,
                              color: Colors.white,
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            const Text(
                              'Rate',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            // Recent Reviews
            if (tutor['reviews'].isNotEmpty) ...[
              const Divider(height: 20),
              Row(
                children: [
                  const Icon(
                    Icons.comment_rounded,
                    size: 16,
                    color: AppColors.textMuted,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Recent Reviews',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ...tutor['reviews'].take(2).map((review) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 6),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.blueSoft,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: AppColors.blueLine,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            review['student'][0],
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppColors.blue,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  review['student'],
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Row(
                                  children: List.generate(5, (index) {
                                    return Icon(
                                      index < review['rating']
                                          ? Icons.star_rounded
                                          : Icons.star_border_rounded,
                                      color: AppColors.yellow,
                                      size: 12,
                                    );
                                  }),
                                ),
                              ],
                            ),
                            Text(
                              review['comment'],
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.textMuted,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      Text(
                        review['date'],
                        style: TextStyle(
                          fontSize: 10,
                          color: AppColors.border,
                        ),
                      ),
                    ],
                  ),
                );
              }),
              if (tutor['reviews'].length > 2)
                TextButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('View all ${tutor['reviews'].length} reviews'),
                        backgroundColor: AppColors.blue,
                      ),
                    );
                  },
                  child: const Text('View all reviews'),
                ),
            ],
          ],
        ),
      ),
    );
  }
}