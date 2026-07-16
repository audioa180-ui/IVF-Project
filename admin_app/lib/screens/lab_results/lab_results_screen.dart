import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:admin_app/providers/admin_provider.dart';
import 'package:admin_app/theme/admin_theme.dart';
import 'package:admin_app/models/lab_result.dart';
import 'package:intl/intl.dart';

class LabResultsScreen extends StatefulWidget {
  const LabResultsScreen({super.key});

  @override
  State<LabResultsScreen> createState() => _LabResultsScreenState();
}

class _LabResultsScreenState extends State<LabResultsScreen> {
  List<LabResult>? _results;
  Map<String, dynamic>? _stats;
  String? _selectedCategory;
  String? _selectedType;
  bool? _abnormalOnly;
  bool _isLoading = false;

  final List<String> _categoryOptions = ['All', 'hormone', 'genetic', 'infectious', 'semen', 'other'];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    
    final adminProvider = Provider.of<AdminProvider>(context, listen: false);
    
    try {
      final results = await Future.wait([
        adminProvider.getAllLabResults(
          testCategory: _selectedCategory == 'All' ? null : _selectedCategory,
          testType: _selectedType,
          isAbnormal: _abnormalOnly,
        ),
        adminProvider.getLabResultStats(),
      ]);

      if (mounted) {
        setState(() {
          _results = (results[0] as List).map((e) => LabResult.fromJson(e as Map<String, dynamic>)).toList();
          _stats = results[1] as Map<String, dynamic>?;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _clearFilters() {
    setState(() {
      _selectedCategory = null;
      _selectedType = null;
      _abnormalOnly = null;
    });
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lab Results'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterSheet,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _results == null
              ? _buildErrorState()
              : _buildContent(),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: AdminTheme.textLight),
          const SizedBox(height: 16),
          Text(
            'Failed to load lab results',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadData,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return RefreshIndicator(
      onRefresh: _loadData,
      child: CustomScrollView(
        slivers: [
          if (_stats != null) _buildStatsSection(),
          SliverToBoxAdapter(
            child: _buildActiveFilters(),
          ),
          if (_results!.isEmpty)
            SliverFillRemaining(
              child: _buildEmptyState(),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final result = _results![index];
                    return _buildResultCard(result, index);
                  },
                  childCount: _results!.length,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStatsSection() {
    return SliverToBoxAdapter(
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Overview',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Total',
                    _stats!['total'].toString(),
                    AdminTheme.navyPrimary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'Abnormal',
                    _stats!['abnormal'].toString(),
                    AdminTheme.error,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Follow-up',
                    _stats!['requiresFollowUp'].toString(),
                    AdminTheme.warning,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'Reviewed',
                    _stats!['reviewed'].toString(),
                    AdminTheme.success,
                  ),
                ),
              ],
            ),
          ],
        ),
      ).animate().fadeIn(),
    );
  }

  Widget _buildStatCard(String title, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AdminTheme.textMedium,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveFilters() {
    if (_selectedCategory == null && _selectedType == null && _abnormalOnly == null) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Wrap(
        spacing: 8,
        children: [
          if (_selectedCategory != null)
            _buildFilterChip('Category: $_selectedCategory', () {
              setState(() => _selectedCategory = null);
              _loadData();
            }),
          if (_selectedType != null)
            _buildFilterChip('Type: $_selectedType', () {
              setState(() => _selectedType = null);
              _loadData();
            }),
          if (_abnormalOnly == true)
            _buildFilterChip('Abnormal Only', () {
              setState(() => _abnormalOnly = null);
              _loadData();
            }),
          TextButton.icon(
            onPressed: _clearFilters,
            icon: const Icon(Icons.clear_all, size: 16),
            label: const Text('Clear All'),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, VoidCallback onDeleted) {
    return Chip(
      label: Text(label),
      deleteIcon: const Icon(Icons.close, size: 18),
      onDeleted: onDeleted,
      backgroundColor: AdminTheme.navyPale,
      labelStyle: TextStyle(
        color: AdminTheme.navyDark,
        fontSize: 12,
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.biotech_outlined, size: 64, color: AdminTheme.textLight),
          const SizedBox(height: 16),
          Text(
            'No lab results found',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your filters',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AdminTheme.textMedium,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultCard(LabResult result, int index) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: result.isAbnormal
                ? AdminTheme.error.withValues(alpha: 0.1)
                : AdminTheme.success.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            result.isAbnormal ? Icons.warning : Icons.check_circle,
            color: result.isAbnormal ? AdminTheme.error : AdminTheme.success,
          ),
        ),
        title: Text(
          result.testType,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(result.patientName),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.calendar_today, size: 14, color: AdminTheme.textMedium),
                const SizedBox(width: 4),
                Text(
                  DateFormat('MMM dd, yyyy').format(result.testDate),
                  style: TextStyle(
                    fontSize: 12,
                    color: AdminTheme.textMedium,
                  ),
                ),
                const SizedBox(width: 12),
                Icon(Icons.category, size: 14, color: AdminTheme.textMedium),
                const SizedBox(width: 4),
                Text(
                  result.testCategoryDisplay,
                  style: TextStyle(
                    fontSize: 12,
                    color: AdminTheme.textMedium,
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: result.isReviewed
                    ? AdminTheme.success.withValues(alpha: 0.1)
                    : AdminTheme.warning.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                result.isReviewed ? 'Reviewed' : 'Pending',
                style: TextStyle(
                  fontSize: 10,
                  color: result.isReviewed ? AdminTheme.success : AdminTheme.warning,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 4),
            if (result.requiresFollowUp)
              Text(
                'Follow-up',
                style: TextStyle(
                  fontSize: 10,
                  color: AdminTheme.error,
                  fontWeight: FontWeight.w500,
                ),
              ),
          ],
        ),
        onTap: () => _showResultDetails(result),
      ),
    ).animate().fadeIn(delay: (index * 50).ms).slideX();
  }

  void _showResultDetails(LabResult result) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AdminTheme.textLight,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: result.isAbnormal
                                ? AdminTheme.error.withValues(alpha: 0.1)
                                : AdminTheme.success.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            result.isAbnormal ? Icons.warning : Icons.check_circle,
                            color: result.isAbnormal ? AdminTheme.error : AdminTheme.success,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                result.testType,
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              Text(
                                result.patientName,
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: AdminTheme.textMedium,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Divider(),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(16),
                  children: [
                    _buildDetailSection('Test Information', [
                      _buildDetailRow('Test Type', result.testType),
                      _buildDetailRow('Category', result.testCategoryDisplay),
                      _buildDetailRow('Test Date', DateFormat('MMM dd, yyyy').format(result.testDate)),
                      _buildDetailRow('Report Date', result.reportDate != null ? DateFormat('MMM dd, yyyy').format(result.reportDate!) : 'N/A'),
                      _buildDetailRow('Lab Name', result.labName.isEmpty ? 'N/A' : result.labName),
                    ]),
                    const SizedBox(height: 24),
                    if (result.multipleResults.isNotEmpty)
                      _buildDetailSection('Results', [
                        ...result.multipleResults.map((r) => _buildResultRow(r.parameter, '${r.value} ${r.unit}')),
                      ])
                    else if (result.results.value != null)
                      _buildDetailSection('Results', [
                        _buildDetailRow('Value', '${result.results.value} ${result.results.unit}'),
                        _buildDetailRow('Reference Range', result.results.referenceRange),
                        _buildDetailRow('Status', result.results.status),
                      ]),
                    const SizedBox(height: 24),
                    _buildDetailSection('Review Status', [
                      _buildDetailRow('Reviewed', result.isReviewed ? 'Yes' : 'No'),
                      _buildDetailRow('Reviewed By', result.doctorName ?? 'N/A'),
                      _buildDetailRow('Review Date', result.reviewedDate != null ? DateFormat('MMM dd, yyyy').format(result.reviewedDate!) : 'N/A'),
                      _buildDetailRow('Review Notes', result.reviewNotes ?? 'N/A'),
                    ]),
                    const SizedBox(height: 24),
                    if (result.attachments.isNotEmpty)
                      _buildDetailSection('Attachments', [
                        ...result.attachments.map((a) => ListTile(
                          leading: const Icon(Icons.attach_file),
                          title: Text(a.name),
                          subtitle: Text(DateFormat('MMM dd, yyyy').format(a.uploadDate)),
                        )),
                      ]),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: AdminTheme.navyPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ...children,
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                color: AdminTheme.textMedium,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                color: AdminTheme.textMedium,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) => Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Filter Lab Results',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 24),
              
              // Category Filter
              Text(
                'Category',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: _categoryOptions.map((category) {
                  final isSelected = _selectedCategory == category;
                  return FilterChip(
                    label: Text(category),
                    selected: isSelected,
                    onSelected: (selected) {
                      setSheetState(() {
                        _selectedCategory = selected ? category : null;
                      });
                    },
                    selectedColor: AdminTheme.navyPrimary.withValues(alpha: 0.2),
                    checkmarkColor: AdminTheme.navyPrimary,
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
              
              // Test Type Filter
              Text(
                'Test Type',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              TextField(
                decoration: InputDecoration(
                  hintText: 'Search test type...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onChanged: (value) {
                  setSheetState(() => _selectedType = value.isEmpty ? null : value);
                },
              ),
              const SizedBox(height: 24),
              
              // Abnormal Only Filter
              SwitchListTile(
                title: const Text('Abnormal Results Only'),
                value: _abnormalOnly ?? false,
                onChanged: (value) {
                  setSheetState(() => _abnormalOnly = value ? true : null);
                },
              ),
              const SizedBox(height: 24),
              
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        setSheetState(() {
                          _selectedCategory = null;
                          _selectedType = null;
                          _abnormalOnly = null;
                        });
                      },
                      child: const Text('Clear'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _loadData();
                      },
                      child: const Text('Apply'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
