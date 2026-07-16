import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:ivf_patient_app/screens/appointments/booking_screen.dart';
import 'package:ivf_patient_app/theme/app_theme.dart';

/// A practical patient companion for the day-to-day parts of IVF care.
class IvfToolsScreen extends StatefulWidget {
  const IvfToolsScreen({super.key});

  @override
  State<IvfToolsScreen> createState() => _IvfToolsScreenState();
}

class _IvfToolsScreenState extends State<IvfToolsScreen> {
  String _category = 'All tools';
  int _waterGlasses = 5;
  final Map<String, bool> _medications = {
    'Folic acid · 08:00 AM': true,
    'Cetrotide injection · 08:00 PM': false,
    'Vitamin D · 09:00 PM': false,
  };
  final Map<String, bool> _documents = {
    'Government photo ID': true,
    'Previous test reports': false,
    'Current medication list': true,
    'Insurance / payment details': false,
  };

  @override
  Widget build(BuildContext context) {
    final tools = _tools.where((tool) {
      return _category == 'All tools' || tool.category == _category;
    }).toList();
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _header(context),
            _categoryBar(),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                itemCount: tools.length + 1,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  if (index == 0) return _summaryCard();
                  final tool = tools[index - 1];
                  return _ToolCard(
                    tool: tool,
                    onTap: () => _openTool(tool.id),
                  ).animate().fadeIn(delay: (index * 55).ms).slideY(
                        begin: .05,
                        end: 0,
                        curve: Curves.easeOutCubic,
                      );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _header(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
        child: Row(
          children: [
            IconButton(
              onPressed: () => Navigator.maybePop(context),
              icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
              style: IconButton.styleFrom(
                backgroundColor: AppColors.card,
                side: const BorderSide(color: AppColors.border),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('IVF TOOLKIT',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700)),
                  Text('Your care, organized',
                      style: Theme.of(context)
                          .textTheme
                          .displaySmall
                          ?.copyWith(fontSize: 25)),
                ],
              ),
            ),
          ],
        ),
      );

  Widget _categoryBar() {
    const categories = ['All tools', 'Treatment', 'Wellbeing', 'Planning'];
    return SizedBox(
      height: 48,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, index) {
          final label = categories[index];
          final selected = label == _category;
          return ChoiceChip(
            label: Text(label),
            selected: selected,
            onSelected: (_) => setState(() => _category = label),
            selectedColor: AppColors.primary,
            backgroundColor: AppColors.card,
            side: BorderSide(
                color: selected ? AppColors.primary : AppColors.border),
            labelStyle: TextStyle(
                color: selected ? AppColors.white : AppColors.textSecondary,
                fontWeight: FontWeight.w600),
          );
        },
      ),
    );
  }

  Widget _summaryCard() => Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(AppBorderRadius.xl),
        ),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                  color: AppColors.white.withValues(alpha: .14),
                  shape: BoxShape.circle),
              child: const Icon(Icons.auto_awesome_rounded,
                  color: AppColors.white),
            ),
            const SizedBox(width: 14),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Today’s care companion',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 16)),
                  SizedBox(height: 3),
                  Text('Small, useful tools for every step of treatment.',
                      style: TextStyle(color: Color(0xFFD8EAF0), height: 1.35)),
                ],
              ),
            ),
          ],
        ),
      );

  void _openTool(String id) {
    if (id == 'appointments') {
      Navigator.push(
          context, MaterialPageRoute(builder: (_) => const BookingScreen()));
      return;
    }
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          constraints: BoxConstraints(
              maxHeight: MediaQuery.sizeOf(context).height * .82),
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
          decoration: const BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: SingleChildScrollView(child: _toolDetail(id, setModalState)),
        ),
      ),
    );
  }

  Widget _toolDetail(String id, StateSetter setModalState) {
    if (id == 'medication') return _medicationDetail(setModalState);
    if (id == 'hydration') return _hydrationDetail(setModalState);
    if (id == 'documents') return _documentsDetail(setModalState);
    if (id == 'symptoms') return _symptomDetail();
    return _cycleDetail();
  }

  Widget _sheetTitle(String title, String subtitle, IconData icon) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
              child: Container(
                  width: 38,
                  height: 4,
                  decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius: BorderRadius.circular(10)))),
          const SizedBox(height: 20),
          Row(children: [
            Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: .1),
                    borderRadius: BorderRadius.circular(13)),
                child: Icon(icon, color: AppColors.primary)),
            const SizedBox(width: 12),
            Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Text(title, style: Theme.of(context).textTheme.titleLarge),
                  Text(subtitle, style: Theme.of(context).textTheme.bodySmall)
                ]))
          ]),
          const SizedBox(height: 18),
        ],
      );

  Widget _medicationDetail(StateSetter setModalState) =>
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _sheetTitle('Medication schedule', 'Mark each dose once it is taken.',
            Icons.medication_outlined),
        ..._medications.entries.map((entry) => Card(
            child: CheckboxListTile(
                value: entry.value,
                onChanged: (value) {
                  setState(() => _medications[entry.key] = value ?? false);
                  setModalState(() {});
                },
                title: Text(entry.key.split(' · ').first),
                subtitle: Text(entry.key.split(' · ').last),
                activeColor: AppColors.primary,
                controlAffinity: ListTileControlAffinity.trailing))),
        const SizedBox(height: 10),
        Text(
            '${_medications.values.where((value) => value).length} of ${_medications.length} doses recorded today',
            style: Theme.of(context).textTheme.bodySmall),
      ]);

  Widget _hydrationDetail(StateSetter setModalState) =>
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _sheetTitle(
            'Hydration log',
            'Aim for 8 glasses today unless your clinic advises otherwise.',
            Icons.water_drop_outlined),
        Center(
            child: Text('$_waterGlasses',
                style: Theme.of(context)
                    .textTheme
                    .displayLarge
                    ?.copyWith(color: AppColors.primary))),
        const Center(child: Text('glasses logged today')),
        const SizedBox(height: 20),
        LinearProgressIndicator(
            value: _waterGlasses / 8,
            minHeight: 10,
            borderRadius: BorderRadius.circular(10),
            color: AppColors.skyBlue,
            backgroundColor: AppColors.secondaryLight),
        const SizedBox(height: 20),
        Row(children: [
          Expanded(
              child: OutlinedButton(
                  onPressed: _waterGlasses == 0
                      ? null
                      : () {
                          setState(() => _waterGlasses--);
                          setModalState(() {});
                        },
                  child: const Text('Remove glass'))),
          const SizedBox(width: 12),
          Expanded(
              child: ElevatedButton(
                  onPressed: _waterGlasses == 12
                      ? null
                      : () {
                          setState(() => _waterGlasses++);
                          setModalState(() {});
                        },
                  child: const Text('Add glass')))
        ]),
      ]);

  Widget _documentsDetail(StateSetter setModalState) =>
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _sheetTitle(
            'Visit checklist',
            'Keep your essentials ready before your next clinic visit.',
            Icons.folder_copy_outlined),
        ..._documents.entries.map((entry) => Card(
            child: CheckboxListTile(
                value: entry.value,
                onChanged: (value) {
                  setState(() => _documents[entry.key] = value ?? false);
                  setModalState(() {});
                },
                title: Text(entry.key),
                activeColor: AppColors.primary,
                controlAffinity: ListTileControlAffinity.trailing))),
      ]);

  Widget _symptomDetail() {
    const options = [
      'Calm',
      'Tired',
      'Cramping',
      'Bloating',
      'Headache',
      'Nausea'
    ];
    return _SimpleChoiceTool(
      title: 'Symptom check-in',
      subtitle: 'Choose anything you would like to record for today.',
      icon: Icons.favorite_border_rounded,
      options: options,
      onSaved: () => _message('Check-in saved to your private diary.'),
    );
  }

  Widget _cycleDetail() => _SimpleChoiceTool(
        title: 'Cycle tracker',
        subtitle: 'Log the stage that best describes today.',
        icon: Icons.calendar_month_outlined,
        options: const [
          'Period',
          'Stimulation',
          'Monitoring',
          'Retrieval',
          'Transfer',
          'Two-week wait'
        ],
        onSaved: () => _message('Cycle stage updated.'),
      );

  void _message(String text) {
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }
}

class _SimpleChoiceTool extends StatefulWidget {
  const _SimpleChoiceTool(
      {required this.title,
      required this.subtitle,
      required this.icon,
      required this.options,
      required this.onSaved});
  final String title;
  final String subtitle;
  final IconData icon;
  final List<String> options;
  final VoidCallback onSaved;
  @override
  State<_SimpleChoiceTool> createState() => _SimpleChoiceToolState();
}

class _SimpleChoiceToolState extends State<_SimpleChoiceTool> {
  final Set<String> _selected = {};
  @override
  Widget build(BuildContext context) =>
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Center(
            child: Container(
                width: 38,
                height: 4,
                decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(10)))),
        const SizedBox(height: 20),
        Row(children: [
          Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: .1),
                  borderRadius: BorderRadius.circular(13)),
              child: Icon(widget.icon, color: AppColors.primary)),
          const SizedBox(width: 12),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text(widget.title,
                    style: Theme.of(context).textTheme.titleLarge),
                Text(widget.subtitle,
                    style: Theme.of(context).textTheme.bodySmall)
              ]))
        ]),
        const SizedBox(height: 20),
        Wrap(
            spacing: 8,
            runSpacing: 8,
            children: widget.options
                .map((option) => FilterChip(
                    label: Text(option),
                    selected: _selected.contains(option),
                    onSelected: (selected) => setState(() => selected
                        ? _selected.add(option)
                        : _selected.remove(option)),
                    selectedColor: AppColors.secondaryLight,
                    checkmarkColor: AppColors.primary))
                .toList()),
        const SizedBox(height: 28),
        SizedBox(
            width: double.infinity,
            child: ElevatedButton(
                onPressed: _selected.isEmpty ? null : widget.onSaved,
                child: const Text('Save today’s check-in'))),
      ]);
}

class _ToolCard extends StatelessWidget {
  const _ToolCard({required this.tool, required this.onTap});
  final _Tool tool;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Material(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppBorderRadius.lg),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppBorderRadius.lg),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
                border: Border.all(color: AppColors.border),
                borderRadius: BorderRadius.circular(AppBorderRadius.lg)),
            child: Row(children: [
              Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                      color: tool.color.withValues(alpha: .16),
                      borderRadius: BorderRadius.circular(15)),
                  child: Icon(tool.icon, color: tool.color)),
              const SizedBox(width: 14),
              Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    Text(tool.category.toUpperCase(),
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w700)),
                    const SizedBox(height: 3),
                    Text(tool.title,
                        style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 2),
                    Text(tool.subtitle,
                        style: Theme.of(context).textTheme.bodySmall)
                  ])),
              const Icon(Icons.chevron_right_rounded,
                  color: AppColors.textLight)
            ]),
          ),
        ),
      );
}

class _Tool {
  const _Tool(
      this.id, this.title, this.subtitle, this.category, this.icon, this.color);
  final String id, title, subtitle, category;
  final IconData icon;
  final Color color;
}

const _tools = [
  _Tool('medication', 'Medication schedule', 'Track tablets and injections',
      'Treatment', Icons.medication_outlined, AppColors.mauve),
  _Tool('cycle', 'Cycle tracker', 'Record your current treatment phase',
      'Treatment', Icons.calendar_month_outlined, AppColors.primary),
  _Tool('symptoms', 'Symptom check-in', 'Log symptoms, energy and mood',
      'Wellbeing', Icons.favorite_border_rounded, AppColors.accent),
  _Tool('hydration', 'Hydration log', 'Build a gentle daily water habit',
      'Wellbeing', Icons.water_drop_outlined, AppColors.skyBlue),
  _Tool('appointments', 'Appointment planner', 'Book your next clinic visit',
      'Planning', Icons.event_available_outlined, AppColors.secondary),
  _Tool('documents', 'Visit checklist', 'Prepare records and essentials',
      'Planning', Icons.folder_copy_outlined, AppColors.peach),
];
