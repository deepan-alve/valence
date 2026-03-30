// client/lib/screens/home/habit_form_screen.dart
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:valence/models/habit.dart';
import 'package:valence/providers/home_provider.dart';
import 'package:valence/theme/valence_spacing.dart';
import 'package:valence/theme/valence_tokens.dart';
import 'package:valence/utils/constants.dart';
import 'package:valence/widgets/core/valence_button.dart';

class HabitFormScreen extends StatefulWidget {
  /// null = create mode, non-null = edit mode.
  final Habit? habit;

  const HabitFormScreen({super.key, this.habit});

  @override
  State<HabitFormScreen> createState() => _HabitFormScreenState();
}

class _HabitFormScreenState extends State<HabitFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _subtitleCtrl;
  late final TextEditingController _redirectCtrl;

  late HabitIntensity _intensity;
  late TrackingType _trackingType;
  late HabitVisibility _visibility;
  late Color _color;
  late String _iconName;
  String _pluginName = 'LeetCode';

  bool get _isEditing => widget.habit != null;

  static const List<String> _iconNames = [
    'star',
    'fire',
    'heart',
    'lightning',
    'code',
    'barbell',
    'book-open',
    'brain',
    'globe',
    'pencil-simple',
    'git-branch',
  ];

  @override
  void initState() {
    super.initState();
    final h = widget.habit;
    _nameCtrl = TextEditingController(text: h?.name ?? '');
    _subtitleCtrl = TextEditingController(text: h?.subtitle ?? '');
    _redirectCtrl = TextEditingController(text: h?.redirectUrl ?? '');
    _intensity = h?.intensity ?? HabitIntensity.moderate;
    _trackingType = h?.trackingType ?? TrackingType.manual;
    _visibility = h?.visibility ?? HabitVisibility.full;
    _color = h?.color ?? HabitColors.blue;
    _iconName = h?.iconName ?? 'star';
    if (h?.pluginName != null) _pluginName = h!.pluginName!;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _subtitleCtrl.dispose();
    _redirectCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final colors = tokens.colors;
    final typography = tokens.typography;

    return Scaffold(
      backgroundColor: colors.surfacePrimary,
      appBar: AppBar(
        backgroundColor: colors.surfacePrimary,
        elevation: 0,
        leading: IconButton(
          icon: PhosphorIcon(PhosphorIcons.x(), color: colors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          _isEditing ? 'Edit Habit' : 'New Habit',
          style: typography.h3.copyWith(color: colors.textPrimary),
        ),
        actions: [
          if (_isEditing)
            IconButton(
              icon: PhosphorIcon(
                PhosphorIcons.trash(),
                color: colors.accentError,
              ),
              onPressed: _onDelete,
              tooltip: 'Delete habit',
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(ValenceSpacing.md),
          children: [
            // --- Habit name ---
            _SectionLabel(label: 'Habit name', colors: colors, typography: typography),
            const SizedBox(height: ValenceSpacing.sm),
            TextFormField(
              controller: _nameCtrl,
              style: typography.body.copyWith(color: colors.textPrimary),
              maxLength: 50,
              decoration: InputDecoration(
                hintText: 'e.g. Solve 1 LeetCode problem',
                hintStyle: typography.body.copyWith(color: colors.textSecondary),
                filled: true,
                fillColor: colors.surfaceSunken,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.all(ValenceSpacing.smMd),
                counterStyle: typography.caption.copyWith(color: colors.textSecondary),
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Habit name is required' : null,
            ),
            const SizedBox(height: ValenceSpacing.md),

            // --- Daily subtitle (optional) ---
            _SectionLabel(label: 'Daily goal (optional)', colors: colors, typography: typography),
            const SizedBox(height: ValenceSpacing.sm),
            TextFormField(
              controller: _subtitleCtrl,
              style: typography.body.copyWith(color: colors.textPrimary),
              maxLength: 80,
              decoration: InputDecoration(
                hintText: 'e.g. Solve 1 problem, 30 min workout',
                hintStyle: typography.body.copyWith(color: colors.textSecondary),
                filled: true,
                fillColor: colors.surfaceSunken,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.all(ValenceSpacing.smMd),
                counterStyle: typography.caption.copyWith(color: colors.textSecondary),
              ),
            ),
            const SizedBox(height: ValenceSpacing.md),

            // --- Intensity ---
            _SectionLabel(label: 'Intensity', colors: colors, typography: typography),
            const SizedBox(height: ValenceSpacing.sm),
            Row(
              children: HabitIntensity.values.map((intensity) {
                final isSelected = _intensity == intensity;
                final label = switch (intensity) {
                  HabitIntensity.light => 'Light\n5 XP',
                  HabitIntensity.moderate => 'Moderate\n10 XP',
                  HabitIntensity.intense => 'Intense\n20 XP',
                };
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _intensity = intensity),
                    child: Container(
                      margin: const EdgeInsets.only(right: ValenceSpacing.sm),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: isSelected ? colors.accentPrimary : colors.surfaceSunken,
                        borderRadius: BorderRadius.circular(8),
                        border: isSelected
                            ? null
                            : Border.all(color: colors.borderDefault),
                      ),
                      child: Text(
                        label,
                        textAlign: TextAlign.center,
                        style: typography.caption.copyWith(
                          color: isSelected ? colors.textInverse : colors.textPrimary,
                          fontWeight: FontWeight.w600,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: ValenceSpacing.md),

            // --- Tracking method ---
            _SectionLabel(label: 'Tracking method', colors: colors, typography: typography),
            const SizedBox(height: ValenceSpacing.sm),
            ..._buildTrackingOptions(colors, typography),
            const SizedBox(height: ValenceSpacing.md),

            // --- Redirect URL (only for redirect tracking) ---
            if (_trackingType == TrackingType.redirect) ...[
              _SectionLabel(
                label: 'App link (opens when you tap the habit)',
                colors: colors,
                typography: typography,
              ),
              const SizedBox(height: ValenceSpacing.sm),
              TextFormField(
                controller: _redirectCtrl,
                style: typography.body.copyWith(color: colors.textPrimary),
                keyboardType: TextInputType.url,
                decoration: InputDecoration(
                  hintText: 'https://leetcode.com/problems/...',
                  hintStyle: typography.body.copyWith(color: colors.textSecondary),
                  filled: true,
                  fillColor: colors.surfaceSunken,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.all(ValenceSpacing.smMd),
                ),
              ),
              const SizedBox(height: ValenceSpacing.md),
            ],

            // --- Plugin selector (only for plugin tracking) ---
            if (_trackingType == TrackingType.plugin) ...[
              _SectionLabel(label: 'Plugin', colors: colors, typography: typography),
              const SizedBox(height: ValenceSpacing.sm),
              Container(
                decoration: BoxDecoration(
                  color: colors.surfaceSunken,
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: ValenceSpacing.smMd,
                  vertical: ValenceSpacing.xs,
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _pluginName,
                    isExpanded: true,
                    style: typography.body.copyWith(color: colors.textPrimary),
                    dropdownColor: colors.surfaceSunken,
                    items: ['LeetCode', 'GitHub', 'Google Fit', 'Duolingo']
                        .map(
                          (p) => DropdownMenuItem(value: p, child: Text(p)),
                        )
                        .toList(),
                    onChanged: (v) => setState(() => _pluginName = v ?? _pluginName),
                  ),
                ),
              ),
              const SizedBox(height: ValenceSpacing.md),
            ],

            // --- Color picker ---
            _SectionLabel(label: 'Color', colors: colors, typography: typography),
            const SizedBox(height: ValenceSpacing.sm),
            _buildColorPicker(colors),
            const SizedBox(height: ValenceSpacing.md),

            // --- Icon picker ---
            _SectionLabel(label: 'Icon', colors: colors, typography: typography),
            const SizedBox(height: ValenceSpacing.sm),
            _buildIconPicker(colors),
            const SizedBox(height: ValenceSpacing.md),

            // --- Visibility toggle ---
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: ValenceSpacing.smMd,
                vertical: ValenceSpacing.sm,
              ),
              decoration: BoxDecoration(
                color: colors.surfaceSunken,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Group visibility',
                          style: typography.caption.copyWith(
                            color: colors.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _visibility == HabitVisibility.full
                              ? 'Group sees habit name + completion'
                              : 'Group only sees done / not done',
                          style: typography.caption.copyWith(
                            color: colors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Switch.adaptive(
                    value: _visibility == HabitVisibility.full,
                    activeThumbColor: colors.accentPrimary,
                    onChanged: (v) => setState(
                      () => _visibility =
                          v ? HabitVisibility.full : HabitVisibility.minimal,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: ValenceSpacing.xl),

            ValenceButton(
              label: _isEditing ? 'Save changes' : 'Add habit',
              onPressed: _onSave,
              fullWidth: true,
            ),

            const SizedBox(height: ValenceSpacing.lg),
          ],
        ),
      ),
    );
  }

  Widget _buildColorPicker(dynamic colors) {
    return Wrap(
      spacing: ValenceSpacing.sm,
      runSpacing: ValenceSpacing.sm,
      children: HabitColors.all.map((c) {
        final isSelected = _color == c;
        return GestureDetector(
          onTap: () => setState(() => _color = c),
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: c,
              shape: BoxShape.circle,
              border: isSelected
                  ? Border.all(color: colors.textPrimary, width: 2.5)
                  : null,
            ),
            child: isSelected
                ? PhosphorIcon(
                    PhosphorIcons.check(PhosphorIconsStyle.bold),
                    color: Colors.white,
                    size: 16,
                  )
                : null,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildIconPicker(dynamic colors) {
    return Wrap(
      spacing: ValenceSpacing.sm,
      runSpacing: ValenceSpacing.sm,
      children: _iconNames.map((name) {
        final isSelected = _iconName == name;
        return GestureDetector(
          onTap: () => setState(() => _iconName = name),
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: isSelected ? _color : colors.surfaceSunken,
              borderRadius: BorderRadius.circular(8),
              border: isSelected
                  ? null
                  : Border.all(color: colors.borderDefault),
            ),
            child: Center(
              child: PhosphorIcon(
                _resolveIcon(name),
                color: isSelected ? Colors.white : colors.textSecondary,
                size: 20,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  IconData _resolveIcon(String name) {
    return switch (name) {
      'code' => PhosphorIcons.code(),
      'barbell' => PhosphorIcons.barbell(),
      'book-open' => PhosphorIcons.bookOpen(),
      'brain' => PhosphorIcons.brain(),
      'git-branch' => PhosphorIcons.gitBranch(),
      'globe' => PhosphorIcons.globe(),
      'lightning' => PhosphorIcons.lightning(),
      'pencil-simple' => PhosphorIcons.pencilSimple(),
      'heart' => PhosphorIcons.heart(),
      'fire' => PhosphorIcons.fire(),
      'star' => PhosphorIcons.star(),
      _ => PhosphorIcons.question(),
    };
  }

  List<Widget> _buildTrackingOptions(dynamic colors, dynamic typography) {
    final options = [
      (TrackingType.manual, 'One-tap', 'Manually mark done'),
      (TrackingType.manualPhoto, 'Photo proof', 'Upload a photo as proof'),
      (TrackingType.redirect, 'App redirect', 'Opens the target app/site'),
      (TrackingType.plugin, 'Auto-track', 'Verified via plugin API'),
    ];
    return options.map((o) {
      final (type, label, description) = o;
      final isSelected = _trackingType == type;
      return GestureDetector(
        onTap: () => setState(() => _trackingType = type),
        child: Container(
          margin: const EdgeInsets.only(bottom: ValenceSpacing.sm),
          padding: const EdgeInsets.symmetric(
            horizontal: ValenceSpacing.smMd,
            vertical: 10,
          ),
          decoration: BoxDecoration(
            color: isSelected
                ? colors.accentPrimary.withValues(alpha: 0.1)
                : colors.surfaceSunken,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? colors.accentPrimary : colors.borderDefault,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: typography.body.copyWith(
                        color: colors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      description,
                      style: typography.caption.copyWith(
                        color: colors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              if (isSelected)
                PhosphorIcon(
                  PhosphorIcons.checkCircle(PhosphorIconsStyle.fill),
                  color: colors.accentPrimary,
                  size: 20,
                ),
            ],
          ),
        ),
      );
    }).toList();
  }

  void _onSave() {
    if (!_formKey.currentState!.validate()) return;
    final provider = context.read<HomeProvider>();
    final subtitleText = _subtitleCtrl.text.trim();

    if (_isEditing) {
      // Build a new Habit directly to allow clearing nullable fields.
      final updated = Habit(
        id: widget.habit!.id,
        name: _nameCtrl.text.trim(),
        subtitle: subtitleText,
        intensity: _intensity,
        trackingType: _trackingType,
        redirectUrl:
            _trackingType == TrackingType.redirect ? _redirectCtrl.text.trim() : null,
        pluginName: _trackingType == TrackingType.plugin ? _pluginName : null,
        visibility: _visibility,
        color: _color,
        iconName: _iconName,
        isCompleted: widget.habit!.isCompleted,
        streakDays: widget.habit!.streakDays,
      );
      provider.updateHabit(updated);
    } else {
      provider.addHabit(
        Habit(
          id: 'habit_${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(1000)}',
          name: _nameCtrl.text.trim(),
          subtitle: subtitleText,
          intensity: _intensity,
          trackingType: _trackingType,
          redirectUrl:
              _trackingType == TrackingType.redirect ? _redirectCtrl.text.trim() : null,
          pluginName: _trackingType == TrackingType.plugin ? _pluginName : null,
          visibility: _visibility,
          color: _color,
          iconName: _iconName,
          isCompleted: false,
          streakDays: 0,
        ),
      );
    }
    Navigator.of(context).pop();
  }

  void _onDelete() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete habit?'),
        content: Text(
          'This will remove "${widget.habit!.name}" and its history.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.read<HomeProvider>().deleteHabit(widget.habit!.id);
              Navigator.pop(ctx); // close dialog
              Navigator.pop(context); // close form
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Helper widget
// ---------------------------------------------------------------------------

class _SectionLabel extends StatelessWidget {
  final String label;
  final dynamic colors;
  final dynamic typography;

  const _SectionLabel({
    required this.label,
    required this.colors,
    required this.typography,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: typography.caption.copyWith(
        color: colors.textSecondary,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}
