import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class StudyMaterialsScreen extends StatefulWidget {
  const StudyMaterialsScreen({super.key});

  @override
  State<StudyMaterialsScreen> createState() => _StudyMaterialsScreenState();
}

class _StudyMaterialsScreenState extends State<StudyMaterialsScreen> {
  String _searchQuery = '';
  String _selectedCategory = 'All';

  final List<Map<String, dynamic>> allMaterials = [
    {
      'title': 'Mathematics Grade 12 Notes',
      'subject': 'Mathematics',
      'type': 'PDF',
      'size': '2.4 MB',
      'date': '12 Aug 2026',
      'icon': Icons.picture_as_pdf,
      'color': AppColors.navy,
      'category': 'Mathematics',
    },
    {
      'title': 'Physics Formula Sheet',
      'subject': 'Physical Sciences',
      'type': 'PDF',
      'size': '1.8 MB',
      'date': '10 Aug 2026',
      'icon': Icons.picture_as_pdf,
      'color': AppColors.blue,
      'category': 'Science',
    },
    {
      'title': 'Accounting Study Guide',
      'subject': 'Accounting',
      'type': 'DOC',
      'size': '3.1 MB',
      'date': '8 Aug 2026',
      'icon': Icons.description,
      'color': AppColors.blue,
      'category': 'Accounting',
    },
    {
      'title': 'English Essay Examples',
      'subject': 'English',
      'type': 'PDF',
      'size': '1.2 MB',
      'date': '5 Aug 2026',
      'icon': Icons.picture_as_pdf,
      'color': AppColors.blue,
      'category': 'English',
    },
    {
      'title': 'Biology Revision Notes',
      'subject': 'Life Sciences',
      'type': 'DOC',
      'size': '2.0 MB',
      'date': '1 Aug 2026',
      'icon': Icons.description,
      'color': AppColors.yellow,
      'category': 'Science',
    },
    {
      'title': 'Calculus Practice Problems',
      'subject': 'Mathematics',
      'type': 'PDF',
      'size': '3.2 MB',
      'date': '28 Jul 2026',
      'icon': Icons.picture_as_pdf,
      'color': AppColors.blue,
      'category': 'Mathematics',
    },
    {
      'title': 'Chemistry Lab Manual',
      'subject': 'Physical Sciences',
      'type': 'DOC',
      'size': '1.5 MB',
      'date': '25 Jul 2026',
      'icon': Icons.description,
      'color': AppColors.blue,
      'category': 'Science',
    },
  ];

  List<String> get categories {
    List<String> allCategories = ['All'];
    for (var material in allMaterials) {
      if (!allCategories.contains(material['category'])) {
        allCategories.add(material['category']);
      }
    }
    return allCategories;
  }

  List<Map<String, dynamic>> get filteredMaterials {
    return allMaterials.where((material) {
      bool matchesCategory = _selectedCategory == 'All' || material['category'] == _selectedCategory;
      bool matchesSearch = material['title'].toLowerCase().contains(_searchQuery.toLowerCase()) ||
          material['subject'].toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesCategory && matchesSearch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        centerTitle: false,
        title: const Text(
          'Study Materials',
          style: TextStyle(
            color: AppColors.blue,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.blue),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.upload, color: AppColors.blue),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Upload feature coming soon!'),
                  backgroundColor: AppColors.blue,
                ),
              );
            },
          ),
        ],
        iconTheme: const IconThemeData(color: AppColors.blue),
      ),
      body: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
        ),
        child: Column(
          children: [
            // Search Bar with Background
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
            color: const Color(0x140B2A66),
            blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.blue, width: 1),
                ),
                child: TextField(
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                  decoration: InputDecoration(
                    hintText: 'Search study materials...',
                    prefixIcon: const Icon(Icons.search, color: AppColors.blue),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, color: AppColors.blue),
                            onPressed: () {
                              setState(() {
                                _searchQuery = '';
                              });
                            },
                          )
                        : null,
                    contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ),

            // Categories
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              color: Colors.white,
              child: SizedBox(
                height: 40,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    String category = categories[index];
                    bool isSelected = category == _selectedCategory;
                    return Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: FilterChip(
                        label: Text(category),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            _selectedCategory = category;
                          });
                        },
                        backgroundColor: Colors.white,
                        selectedColor: AppColors.blue,
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : AppColors.blue,
                          fontWeight: FontWeight.w500,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: BorderSide(
                            color: isSelected ? AppColors.blue : AppColors.blue,
                            width: 1,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

            // Results Count
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${filteredMaterials.length} materials found',
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textMuted,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (_searchQuery.isNotEmpty)
                    Text(
                      'Showing results for: "$_searchQuery"',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.blue,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                ],
              ),
            ),

            // Materials List
            Expanded(
              child: filteredMaterials.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.search_off,
                            size: 64,
                            color: AppColors.textMuted,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No materials found',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textMuted,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Try adjusting your search or filter',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: filteredMaterials.length,
                      itemBuilder: (context, index) {
                        var material = filteredMaterials[index];
                        return _materialCard(context, material);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _materialCard(BuildContext context, Map<String, dynamic> material) {
    final bool isDoc = material['type'] == 'DOC';
    final Color tint = isDoc ? AppColors.yellowSoft : AppColors.blueSoft;
    final Color fg = isDoc ? AppColors.navy : AppColors.blue;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0x140B2A66),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: AppColors.border,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: tint,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              material['icon'],
              color: fg,
              size: 30,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  material['title'],
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.blue,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: tint,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        material['subject'],
                        style: TextStyle(
                          fontSize: 10,
                          color: fg,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${material['type']} • ${material['size']}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                material['date'],
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textMuted,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.blue,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: IconButton(
                  icon: const Icon(Icons.download, color: Colors.white, size: 18),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Downloads are coming soon'),
                        duration: Duration(seconds: 1),
                        backgroundColor: AppColors.blue,
                      ),
                    );
                  },
                  padding: const EdgeInsets.all(8),
                  constraints: const BoxConstraints(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}