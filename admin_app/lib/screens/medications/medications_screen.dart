import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:admin_app/providers/admin_provider.dart';
import 'package:admin_app/theme/admin_theme.dart';
import 'package:admin_app/models/medication.dart';
import 'package:intl/intl.dart';

class MedicationsScreen extends StatefulWidget {
  const MedicationsScreen({super.key});

  @override
  State<MedicationsScreen> createState() => _MedicationsScreenState();
}

class _MedicationsScreenState extends State<MedicationsScreen> {
  List<Medication>? _medications;
  Map<String, dynamic>? _stats;
  String? _selectedCategory;
  bool? _activeOnly;
  bool? _lowStockOnly;
  bool _isLoading = false;

  final List<String> _categoryOptions = ['All', 'fertility', 'hormone', 'antibiotic', 'painkiller', 'supplement', 'other'];

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
        adminProvider.getAllMedications(
          category: _selectedCategory == 'All' ? null : _selectedCategory,
          isActive: _activeOnly,
          lowStock: _lowStockOnly,
        ),
        adminProvider.getMedicationStats(),
      ]);

      if (mounted) {
        setState(() {
          _medications = (results[0] as List).map((e) => Medication.fromJson(e as Map<String, dynamic>)).toList();
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
      _activeOnly = null;
      _lowStockOnly = null;
    });
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Medications'),
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
          : _medications == null
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
            'Failed to load medications',
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
          if (_medications!.isEmpty)
            SliverFillRemaining(
              child: _buildEmptyState(),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final medication = _medications![index];
                    return _buildMedicationCard(medication, index);
                  },
                  childCount: _medications!.length,
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
                    'Active',
                    _stats!['active'].toString(),
                    AdminTheme.success,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Low Stock',
                    _stats!['lowStock'].toString(),
                    AdminTheme.error,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'Expiring Soon',
                    _stats!['expiringSoon'].toString(),
                    AdminTheme.warning,
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
    if (_selectedCategory == null && _activeOnly == null && _lowStockOnly == null) {
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
          if (_activeOnly == true)
            _buildFilterChip('Active Only', () {
              setState(() => _activeOnly = null);
              _loadData();
            }),
          if (_lowStockOnly == true)
            _buildFilterChip('Low Stock', () {
              setState(() => _lowStockOnly = null);
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
          Icon(Icons.medication_outlined, size: 64, color: AdminTheme.textLight),
          const SizedBox(height: 16),
          Text(
            'No medications found',
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

  Widget _buildMedicationCard(Medication medication, int index) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: medication.isLowStock
                ? AdminTheme.error.withValues(alpha: 0.1)
                : medication.isActive
                    ? AdminTheme.success.withValues(alpha: 0.1)
                    : AdminTheme.textLight.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            medication.isLowStock ? Icons.warning : medication.isActive ? Icons.check_circle : Icons.block,
            color: medication.isLowStock
                ? AdminTheme.error
                : medication.isActive
                    ? AdminTheme.success
                    : AdminTheme.textMedium,
          ),
        ),
        title: Text(
          medication.name,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(medication.genericName.isEmpty ? medication.name : medication.genericName),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.category, size: 14, color: AdminTheme.textMedium),
                const SizedBox(width: 4),
                Text(
                  medication.categoryDisplay,
                  style: TextStyle(
                    fontSize: 12,
                    color: AdminTheme.textMedium,
                  ),
                ),
                const SizedBox(width: 12),
                Icon(Icons.science, size: 14, color: AdminTheme.textMedium),
                const SizedBox(width: 4),
                Text(
                  medication.strength.isEmpty ? 'N/A' : medication.strength,
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
                color: medication.isLowStock
                    ? AdminTheme.error.withValues(alpha: 0.1)
                    : AdminTheme.navyPale,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Stock: ${medication.stock}',
                style: TextStyle(
                  fontSize: 10,
                  color: medication.isLowStock ? AdminTheme.error : AdminTheme.navyDark,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 4),
            if (medication.isExpiringSoon)
              Text(
                'Expiring',
                style: TextStyle(
                  fontSize: 10,
                  color: AdminTheme.warning,
                  fontWeight: FontWeight.w500,
                ),
              ),
          ],
        ),
        onTap: () => _showMedicationDetails(medication),
      ),
    ).animate().fadeIn(delay: (index * 50).ms).slideX();
  }

  void _showMedicationDetails(Medication medication) {
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
                            color: medication.isLowStock
                                ? AdminTheme.error.withValues(alpha: 0.1)
                                : medication.isActive
                                    ? AdminTheme.success.withValues(alpha: 0.1)
                                    : AdminTheme.textLight.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            medication.isLowStock ? Icons.warning : medication.isActive ? Icons.check_circle : Icons.block,
                            color: medication.isLowStock
                                ? AdminTheme.error
                                : medication.isActive
                                    ? AdminTheme.success
                                    : AdminTheme.textMedium,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                medication.name,
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              Text(
                                medication.genericName.isEmpty ? medication.name : medication.genericName,
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
                    _buildDetailSection('Basic Information', [
                      _buildDetailRow('Category', medication.categoryDisplay),
                      _buildDetailRow('Strength', medication.strength.isEmpty ? 'N/A' : medication.strength),
                      _buildDetailRow('Manufacturer', medication.manufacturer.isEmpty ? 'N/A' : medication.manufacturer),
                      _buildDetailRow('Price', '\$${medication.price.toStringAsFixed(2)}'),
                      _buildDetailRow('Status', medication.isActive ? 'Active' : 'Inactive'),
                    ]),
                    const SizedBox(height: 24),
                    _buildDetailSection('Stock Information', [
                      _buildDetailRow('Current Stock', '${medication.stock} units'),
                      _buildDetailRow('Min Stock Level', '${medication.minStockLevel} units'),
                      _buildDetailRow('Batch Number', medication.batchNumber.isEmpty ? 'N/A' : medication.batchNumber),
                      _buildDetailRow('Expiry Date', medication.expiryDate != null ? DateFormat('MMM dd, yyyy').format(medication.expiryDate!) : 'N/A'),
                      _buildDetailRow('Storage', medication.storageConditions.isEmpty ? 'N/A' : medication.storageConditions),
                    ]),
                    const SizedBox(height: 24),
                    if (medication.dosageForms.isNotEmpty)
                      _buildDetailSection('Dosage Forms', [
                        ...medication.dosageForms.map((form) => ListTile(
                          leading: const Icon(Icons.medication),
                          title: Text(form),
                        )),
                      ]),
                    const SizedBox(height: 24),
                    if (medication.sideEffects.isNotEmpty)
                      _buildDetailSection('Side Effects', [
                        ...medication.sideEffects.map((effect) => ListTile(
                          leading: const Icon(Icons.warning),
                          title: Text(effect),
                        )),
                      ]),
                    const SizedBox(height: 24),
                    if (medication.contraindications.isNotEmpty)
                      _buildDetailSection('Contraindications', [
                        ...medication.contraindications.map((contra) => ListTile(
                          leading: const Icon(Icons.block),
                          title: Text(contra),
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
                'Filter Medications',
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
              
              // Active Only Filter
              SwitchListTile(
                title: const Text('Active Medications Only'),
                value: _activeOnly ?? false,
                onChanged: (value) {
                  setSheetState(() => _activeOnly = value ? true : null);
                },
              ),
              const SizedBox(height: 8),
              
              // Low Stock Filter
              SwitchListTile(
                title: const Text('Low Stock Only'),
                value: _lowStockOnly ?? false,
                onChanged: (value) {
                  setSheetState(() => _lowStockOnly = value ? true : null);
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
                          _activeOnly = null;
                          _lowStockOnly = null;
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
