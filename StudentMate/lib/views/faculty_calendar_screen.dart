import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../repositories/event_repository.dart';
import '../utils/app_theme.dart';
import '../utils/responsive_helper.dart';
import '../widgets/custom_widgets.dart';
import '../widgets/responsive_layout_components.dart';

class FacultyCalendarScreen extends StatefulWidget {
  const FacultyCalendarScreen({Key? key}) : super(key: key);

  @override
  State<FacultyCalendarScreen> createState() => _FacultyCalendarScreenState();
}

class _FacultyCalendarScreenState extends State<FacultyCalendarScreen> {
  final EventRepository _eventRepository = EventRepository();
  DateTime _selectedDate = DateTime.now();
  final Map<String, List<String>> _events = {};
  bool _isLoading = true;
  String? _hoveredDateStr;

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  Future<void> _loadEvents() async {
    try {
      final events = await _eventRepository.getAllCalendarEvents();
      final mapped = <String, List<String>>{};
      for (final event in events) {
        final key = DateFormat('yyyy-MM-dd').format(event.eventDate);
        mapped.putIfAbsent(key, () => []).add(event.title);
      }
      if (!mounted) return;
      setState(() {
        _events
          ..clear()
          ..addAll(mapped);
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final responsive = ResponsiveHelper(context);
    final daysInMonth =
        DateTime(_selectedDate.year, _selectedDate.month + 1, 0).day;
    final firstDayOfMonth =
        DateTime(_selectedDate.year, _selectedDate.month, 1).weekday;

    return Scaffold(
      appBar: AppBar(
        leading: const AppLogo(),
        title: const Text('Academic Calendar'),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(responsive.horizontalPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GradientCard(
                      child: Column(
                        children: [
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.arrow_back,
                                    color: AppColors.purpleDark),
                                onPressed: () => setState(() {
                                  _selectedDate = DateTime(_selectedDate.year,
                                      _selectedDate.month - 1);
                                }),
                              ),
                              Expanded(
                                child: Text(
                                  DateFormat('MMMM yyyy').format(_selectedDate),
                                  textAlign: TextAlign.center,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleLarge
                                      ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        fontSize: responsive.titleFontSize,
                                      ),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.arrow_forward,
                                    color: AppColors.purpleDark),
                                onPressed: () => setState(() {
                                  _selectedDate = DateTime(_selectedDate.year,
                                      _selectedDate.month + 1);
                                }),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.md),
                          Container(
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Color(0xFF93C5FD),
                                  Color(0xFFA78BFA),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(AppRadius.lg),
                            ),
                            padding: const EdgeInsets.all(AppSpacing.md),
                            child: Column(
                              children: [
                                GridView.count(
                                  crossAxisCount: 7,
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  childAspectRatio:
                                      responsive.isSmallPhone ? 1.15 : 1.35,
                                  children: ['M', 'T', 'W', 'T', 'F', 'S', 'S']
                                      .map((d) => Center(
                                            child: Text(d,
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.white,
                                                    fontSize: responsive
                                                        .smallFontSize)),
                                          ))
                                      .toList(),
                                ),
                                const SizedBox(height: AppSpacing.xs),
                                GridView.count(
                                  crossAxisCount: 7,
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  childAspectRatio:
                                      responsive.isSmallPhone ? 1.2 : 1,
                                  children: [
                                    ...List.generate(firstDayOfMonth - 1,
                                        (_) => const SizedBox()),
                                    ...List.generate(daysInMonth, (index) {
                                      final day = index + 1;
                                      final date = DateTime(_selectedDate.year,
                                          _selectedDate.month, day);
                                      final dateStr =
                                          DateFormat('yyyy-MM-dd').format(date);
                                      final hasEvent =
                                          _events.containsKey(dateStr);
                                      final isToday = date.day ==
                                              DateTime.now().day &&
                                          date.month == DateTime.now().month &&
                                          date.year == DateTime.now().year;
                                      final isSelected = _selectedDate.day ==
                                              day &&
                                          _selectedDate.month == date.month &&
                                          _selectedDate.year == date.year;
                                      final isHovered =
                                          _hoveredDateStr == dateStr;

                                      Widget cell = MouseRegion(
                                        cursor: SystemMouseCursors.click,
                                        onEnter: (_) => setState(
                                            () => _hoveredDateStr = dateStr),
                                        onExit: (_) => setState(() {
                                          if (_hoveredDateStr == dateStr) {
                                            _hoveredDateStr = null;
                                          }
                                        }),
                                        child: GestureDetector(
                                          onTap: () => setState(
                                              () => _selectedDate = date),
                                          child: AnimatedContainer(
                                            duration: const Duration(
                                                milliseconds: 120),
                                            margin: const EdgeInsets.all(2),
                                            decoration: BoxDecoration(
                                              color: isToday
                                                  ? Colors.white
                                                  : isSelected
                                                      ? Colors.white.withValues(
                                                          alpha: 0.35)
                                                      : isHovered
                                                          ? Colors.white
                                                              .withValues(
                                                                  alpha: 0.28)
                                                          : Colors.transparent,
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      AppRadius.sm),
                                              border: isToday
                                                  ? null
                                                  : (isSelected || isHovered)
                                                      ? Border.all(
                                                          color: Colors.white
                                                              .withValues(
                                                                  alpha:
                                                                      isSelected
                                                                          ? 1.0
                                                                          : 0.6),
                                                          width: 1.5)
                                                      : null,
                                              boxShadow: isHovered && !isToday
                                                  ? [
                                                      BoxShadow(
                                                        color: Colors.white
                                                            .withValues(
                                                                alpha: 0.3),
                                                        blurRadius: 6,
                                                      )
                                                    ]
                                                  : null,
                                            ),
                                            child: LayoutBuilder(
                                              builder: (context, constraints) {
                                                final compactFontSize = constraints
                                                            .maxHeight <
                                                        30
                                                    ? (responsive
                                                                .smallFontSize -
                                                            1)
                                                        .clamp(9.0, 12.0)
                                                    : responsive.bodyFontSize;
                                                return Stack(
                                                  children: [
                                                    Center(
                                                      child: Text(
                                                        '$day',
                                                        style: TextStyle(
                                                          color: isToday
                                                              ? const Color(
                                                                  0xFF7C3AED)
                                                              : Colors.white,
                                                          fontWeight: isToday ||
                                                                  hasEvent
                                                              ? FontWeight.bold
                                                              : FontWeight.w500,
                                                          fontSize:
                                                              compactFontSize,
                                                          height: 1,
                                                        ),
                                                      ),
                                                    ),
                                                    if (hasEvent)
                                                      Positioned(
                                                        bottom: 2,
                                                        left: 0,
                                                        right: 0,
                                                        child: Center(
                                                          child: Container(
                                                            width: 4,
                                                            height: 4,
                                                            decoration:
                                                                BoxDecoration(
                                                              color: isToday
                                                                  ? AppColors
                                                                      .pinkLight
                                                                  : Colors
                                                                      .white,
                                                              shape: BoxShape
                                                                  .circle,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                  ],
                                                );
                                              },
                                            ),
                                          ),
                                        ),
                                      );

                                      if (hasEvent) {
                                        final eventList = _events[dateStr]!;
                                        cell = Tooltip(
                                          message: eventList
                                              .map((e) => '• $e')
                                              .join('\n'),
                                          preferBelow: false,
                                          textStyle: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 12),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF7C3AED)
                                                .withValues(alpha: 0.92),
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          child: cell,
                                        );
                                      }

                                      return cell;
                                    }),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    Text(
                      'Events on ${DateFormat('MMM d, yyyy').format(_selectedDate)}',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    _buildEventsForDate(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildEventsForDate() {
    final responsive = ResponsiveHelper(context);
    final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate);
    final eventTitles = _events[dateStr];
    if (eventTitles == null || eventTitles.isEmpty) {
      return Text('No events on this date',
          style: Theme.of(context).textTheme.bodyMedium);
    }
    return Column(
      children: eventTitles
          .map((eventTitle) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                child: GradientCard(
                  child: Row(
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          gradient: AppColors.primaryGradient,
                          borderRadius: BorderRadius.circular(AppRadius.md),
                        ),
                        child:
                            const Icon(Icons.event_note, color: Colors.white),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              eventTitle,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    fontSize: responsive.bodyFontSize,
                                  ),
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            Text(
                              DateFormat('EEEE').format(_selectedDate),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ))
          .toList(),
    );
  }
}
