import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/date_utils.dart';
import '../data/hair_wash_settings_repository.dart';
import '../domain/hair_wash_models.dart';
import '../services/widget_bridge.dart';

class HairWashHomePage extends StatefulWidget {
  const HairWashHomePage({super.key});

  @override
  State<HairWashHomePage> createState() => _HairWashHomePageState();
}

class _HairWashHomePageState extends State<HairWashHomePage> {
  static const String _asciiBanner = '''
 _   _ _____    _    ____    __        ___    ____  _   _
| | | | ____|  / \\  |  _ \\   \\ \\      / / \\  / ___|| | | |
| |_| |  _|   / _ \\ | | | |   \\ \\ /\\ / / _ \\ \\___ \\| |_| |
|  _  | |___ / ___ \\| |_| |    \\ V  V / ___ \\ ___) |  _  |
|_| |_|_____/_/   \\_\\____/      \\_/\\_/_/   \\_\\____/|_| |_|
''';

  final HairWashSettingsRepository _repository = HairWashSettingsRepository();
  final WidgetBridge _widgetBridge = WidgetBridge();
  final TextEditingController _titleController = TextEditingController();

  HairWashSettings _settings = HairWashSettings.defaults();
  HairWashStatus _status = buildHairWashStatus(
    HairWashSettings.defaults(),
    DateTime.now(),
  );
  bool _loading = true;
  bool _saving = false;
  bool _fallbackHintVisible = false;
  Timer? _titleDebounce;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  @override
  void dispose() {
    _titleDebounce?.cancel();
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _loadSettings() async {
    final settings = await _repository.load();
    if (!mounted) {
      return;
    }
    setState(() {
      _settings = settings;
      _status = buildHairWashStatus(settings, DateTime.now());
      _titleController.text = settings.widgetTitle;
      _loading = false;
    });
  }

  Future<void> _persistSettings(
    HairWashSettings nextSettings, {
    bool showSavedSnackBar = false,
  }) async {
    setState(() {
      _settings = nextSettings;
      _status = buildHairWashStatus(nextSettings, DateTime.now());
      _saving = true;
    });

    await _repository.save(nextSettings);
    await _widgetBridge.refreshWidget();

    if (!mounted) {
      return;
    }

    setState(() {
      _saving = false;
    });

    if (showSavedSnackBar) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('[ok] config saved')));
    }
  }

  void _onTitleChanged(String value) {
    _titleDebounce?.cancel();
    _titleDebounce = Timer(const Duration(milliseconds: 450), () {
      final trimmed = value.trim().isEmpty
          ? HairWashSettings.defaults().widgetTitle
          : value.trim();
      if (trimmed == _settings.widgetTitle) {
        return;
      }
      _persistSettings(_settings.copyWith(widgetTitle: trimmed));
    });
  }

  Future<void> _pickLastWashDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _settings.lastWashDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked == null) {
      return;
    }
    await _persistSettings(
      _settings.copyWith(lastWashDate: dateOnly(picked)),
      showSavedSnackBar: true,
    );
  }

  Future<void> _setTodayAsLastWash() async {
    await _persistSettings(
      _settings.copyWith(lastWashDate: dateOnly(DateTime.now())),
      showSavedSnackBar: true,
    );
  }

  Future<void> _changeInterval(double value) async {
    final nextValue = value.round().clamp(1, 14).toInt();
    if (nextValue == _settings.washIntervalDays) {
      return;
    }
    await _persistSettings(_settings.copyWith(washIntervalDays: nextValue));
  }

  Future<void> _requestPinWidget() async {
    final pinned = await _widgetBridge.requestPinWidget();
    if (!mounted) {
      return;
    }

    if (pinned) {
      setState(() {
        _fallbackHintVisible = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('[ok] widget pin request sent')),
      );
      return;
    }

    setState(() {
      _fallbackHintVisible = true;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('[warn] launcher auto-pin is unavailable')),
    );
  }

  Future<void> _refreshWidgetOnly() async {
    await _widgetBridge.refreshWidget();
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('[ok] widget refreshed')));
  }

  Color _statusColor(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return switch (_status.kind) {
      HairWashStatusKind.dueToday => scheme.primary,
      HairWashStatusKind.dueTomorrow => const Color(0xFFFDE68A),
      HairWashStatusKind.upcoming => scheme.secondary,
      HairWashStatusKind.overdue => scheme.error,
      HairWashStatusKind.unknown => scheme.onSurfaceVariant,
    };
  }

  String get _lastWashLabel => _settings.lastWashDate == null
      ? '--'
      : formatDateIso(_settings.lastWashDate!);

  String get _nextWashLabel => _status.nextWashDate == null
      ? '--'
      : formatDateIso(_status.nextWashDate!);

  String get _deltaLabel {
    final delta = _status.daysDelta;
    if (delta == null) {
      return '--';
    }
    if (delta == 0) {
      return 'due now';
    }
    if (delta > 0) {
      return 'in $delta day(s)';
    }
    return 'late by ${delta.abs()} day(s)';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: _loading
            ? Center(
                child: CircularProgressIndicator(
                  color: theme.colorScheme.primary,
                ),
              )
            : RefreshIndicator(
                color: theme.colorScheme.primary,
                backgroundColor: theme.colorScheme.surface,
                onRefresh: _loadSettings,
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                  children: [
                    _TerminalBanner(
                      banner: _asciiBanner,
                      footer: _saving
                          ? '[sync] writing config to storage...'
                          : '[ready] terminal online',
                    ),
                    const SizedBox(height: 12),
                    _TerminalSection(
                      title: 'status',
                      child: Column(
                        children: [
                          _TerminalLine(
                            label: 'profile',
                            value: _settings.widgetTitle,
                          ),
                          _TerminalLine(
                            label: 'state',
                            value: _status.message,
                            valueColor: _statusColor(context),
                          ),
                          _TerminalLine(
                            label: 'last_wash',
                            value: _lastWashLabel,
                          ),
                          _TerminalLine(
                            label: 'next_wash',
                            value: _nextWashLabel,
                          ),
                          _TerminalLine(
                            label: 'interval',
                            value: '${_settings.washIntervalDays} day(s)',
                          ),
                          _TerminalLine(label: 'delta', value: _deltaLabel),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    _TerminalSection(
                      title: 'config',
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextField(
                            controller: _titleController,
                            decoration: const InputDecoration(
                              labelText: 'widget_title',
                              prefixText: '> ',
                              helperText: 'used in app and home widget',
                            ),
                            onChanged: _onTitleChanged,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'interval_days :: ${_settings.washIntervalDays}',
                            style: theme.textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          Slider(
                            value: _settings.washIntervalDays.toDouble(),
                            min: 1,
                            max: 14,
                            divisions: 13,
                            label: '${_settings.washIntervalDays}',
                            onChanged: (value) {
                              setState(() {
                                _settings = _settings.copyWith(
                                  washIntervalDays: value.round(),
                                );
                                _status = buildHairWashStatus(
                                  _settings,
                                  DateTime.now(),
                                );
                              });
                            },
                            onChangeEnd: _changeInterval,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '> choose the last wash date or log today immediately',
                            style: theme.textTheme.bodyMedium,
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 12,
                            runSpacing: 12,
                            children: [
                              OutlinedButton(
                                onPressed: _pickLastWashDate,
                                child: const Text('[ set date ]'),
                              ),
                              FilledButton(
                                onPressed: _setTodayAsLastWash,
                                child: const Text('[ log today ]'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    _TerminalSection(
                      title: 'home_widget',
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '> pin the widget from launcher support or refresh it manually',
                            style: theme.textTheme.bodyMedium,
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 12,
                            runSpacing: 12,
                            children: [
                              FilledButton(
                                onPressed: _requestPinWidget,
                                child: const Text('[ pin widget ]'),
                              ),
                              OutlinedButton(
                                onPressed: _refreshWidgetOnly,
                                child: const Text('[ refresh widget ]'),
                              ),
                            ],
                          ),
                          if (_fallbackHintVisible) ...[
                            const SizedBox(height: 12),
                            Text(
                              'manual :: long press desktop -> widgets -> SHAM',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.secondary,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    _TerminalSection(
                      title: 'command_map',
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text('[ set date ]      pick the last wash date'),
                          SizedBox(height: 8),
                          Text('[ log today ]     use today as the last wash'),
                          SizedBox(height: 8),
                          Text(
                            '[ pin widget ]    ask launcher to add the widget',
                          ),
                          SizedBox(height: 8),
                          Text('[ refresh widget ] force home widget redraw'),
                          SizedBox(height: 8),
                          Text('pull down         reload data from storage'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}

class _TerminalBanner extends StatelessWidget {
  const _TerminalBanner({required this.banner, required this.footer});

  final String banner;
  final String footer;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border.all(color: theme.colorScheme.primary.withAlpha(140)),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Text(
              banner,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.primary,
                height: 1.1,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '> sham cli / hair wash reminder / android widget node',
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 6),
          Text(
            footer,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.secondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _TerminalSection extends StatelessWidget {
  const _TerminalSection({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border.all(color: theme.colorScheme.primary.withAlpha(110)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withAlpha(24),
              border: Border(
                bottom: BorderSide(
                  color: theme.colorScheme.primary.withAlpha(90),
                ),
              ),
            ),
            child: Text(
              '[ $title ]',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.primary,
              ),
            ),
          ),
          Padding(padding: const EdgeInsets.all(14), child: child),
        ],
      ),
    );
  }
}

class _TerminalLine extends StatelessWidget {
  const _TerminalLine({
    required this.label,
    required this.value,
    this.valueColor,
  });

  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 104,
            child: Text(
              '$label ::',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: valueColor ?? theme.colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
