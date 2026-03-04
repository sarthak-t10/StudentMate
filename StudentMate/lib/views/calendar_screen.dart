import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../repositories/event_repository.dart';
import '../utils/app_theme.dart';
import '../utils/responsive_helper.dart';
import '../widgets/custom_widgets.dart';
import '../widgets/responsive_layout_components.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({Key? key}) : super(key: key);

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
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
    final daysInMonth =
        DateTime(_selectedDate.year, _selectedDate.month + 1, 0).day;
    final firstDayOfMonth =
        DateTime(_selectedDate.year, _selectedDate.month, 1).weekday;

    return Scaffold(
      appBar: AppBar(
        leading: const AppLogo(),
        title: const Text('Calendar'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : ResponsiveBuilder(
                builder: (context, responsive) {
                  return SingleChildScrollView(
                    child: Padding(
                      padding: EdgeInsets.all(responsive.horizontalPadding),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Month Navigation
                          GradientCard(
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.arrow_back,
                                          color: AppColors.purpleDark),
                                      onPressed: () {
                                        setState(() {
                                          _selectedDate = DateTime(
                                            _selectedDate.year,
                                            _selectedDate.month - 1,
                                          );
                                        });
                                      },
                                    ),
                                    Text(
                                      DateFormat('MMMM yyyy')
                                          .format(_selectedDate),
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleLarge
                                          ?.copyWith(
                                            fontWeight: FontWeight.bold,
                                            fontSize: responsive.titleFontSize,
                                          ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.arrow_forward,
                                          color: AppColors.purpleDark),
                                      onPressed: () {
                                        setState(() {
                                          _selectedDate = DateTime(
                                            _selectedDate.year,
                                            _selectedDate.month + 1,
                                          );
                                        });
                                      },
                                    ),
                                  ],
                                ),
                                SizedBox(height: responsive.spacingMedium),
                                // Calendar grid on light-blue → light-purple gradient
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
                                    borderRadius: BorderRadius.circular(
                                        responsive.radiusLarge),
                                  ),
                                  padding:
                                      EdgeInsets.all(responsive.spacingMedium),
                                  child: Column(
                                    children: [
                                      // Days Header
                                      GridView.count(
                                        crossAxisCount: 7,
                                        shrinkWrap: true,
                                        physics:
                                            const NeverScrollableScrollPhysics(),
                                        childAspectRatio: 1.4,
                                        children: [
                                          'M',
                                          'T',
                                          'W',
                                          'T',
                                          'F',
                                          'S',
                                          'S'
                                        ].map((day) {
                                          return Center(
                                            child: Text(
                                              day,
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                                fontSize:
                                                    responsive.smallFontSize,
                                              ),
                                            ),
                                          );
                                        }).toList(),
                                      ),
                                      SizedBox(height: responsive.spacingSmall),
                                      // Calendar Days
                                      GridView.count(
                                        crossAxisCount: 7,
                                        shrinkWrap: true,
                                        physics:
                                            const NeverScrollableScrollPhysics(),
                                        childAspectRatio: 1,
                                        children: [
                                          // Empty cells before first day
                                          ...List.generate(firstDayOfMonth - 1,
                                              (_) => const SizedBox()),
                                          // Days of the month
                                          ...List.generate(daysInMonth,
                                              (index) {
                                            final day = index + 1;
                                            final date = DateTime(
                                              _selectedDate.year,
                                              _selectedDate.month,
                                              day,
                                            );
                                            final dateStr =
                                                DateFormat('yyyy-MM-dd')
                                                    .format(date);
                                            final hasEvent =
                                                _events.containsKey(dateStr);
                                            final isToday = date.day ==
                                                    DateTime.now().day &&
                                                date.month ==
                                                    DateTime.now().month &&
                                                date.year ==
                                                    DateTime.now().year;
                                            final isSelected =
                                                _selectedDate.day == day &&
                                                    _selectedDate.month ==
                                                        date.month &&
                                                    _selectedDate.year ==
                                                        date.year;
                                            final isHovered =
                                                _hoveredDateStr == dateStr;

                                            Widget cell = MouseRegion(
                                              cursor: SystemMouseCursors.click,
                                              onEnter: (_) => setState(() =>
                                                  _hoveredDateStr = dateStr),
                                              onExit: (_) => setState(() {
                                                if (_hoveredDateStr ==
                                                    dateStr) {
                                                  _hoveredDateStr = null;
                                                }
                                              }),
                                              child: GestureDetector(
                                                onTap: () => setState(
                                                    () => _selectedDate = date),
                                                child: AnimatedContainer(
                                                  duration: const Duration(
                                                      milliseconds: 120),
                                                  margin: EdgeInsets.all(2),
                                                  decoration: BoxDecoration(
                                                    color: isToday
                                                        ? Colors.white
                                                        : isSelected
                                                            ? Colors.white
                                                                .withValues(
                                                                    alpha: 0.35)
                                                            : isHovered
                                                                ? Colors.white
                                                                    .withValues(
                                                                        alpha:
                                                                            0.28)
                                                                : Colors
                                                                    .transparent,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            responsive
                                                                .radiusSmall),
                                                    border: isToday
                                                        ? null
                                                        : (isSelected ||
                                                                isHovered)
                                                            ? Border.all(
                                                                color: Colors
                                                                    .white
                                                                    .withValues(
                                                                        alpha: isSelected
                                                                            ? 1.0
                                                                            : 0.6),
                                                                width: 1.5)
                                                            : null,
                                                    boxShadow:
                                                        isHovered && !isToday
                                                            ? [
                                                                BoxShadow(
                                                                  color: Colors
                                                                      .white
                                                                      .withValues(
                                                                          alpha:
                                                                              0.3),
                                                                  blurRadius: 6,
                                                                )
                                                              ]
                                                            : null,
                                                  ),
                                                  child: Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      Text(
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
                                                          fontSize: responsive
                                                              .bodyFontSize,
                                                        ),
                                                      ),
                                                      if (hasEvent)
                                                        Container(
                                                          width: 5,
                                                          height: 5,
                                                          margin: EdgeInsets.only(
                                                              top: responsive
                                                                      .spacingSmall /
                                                                  2),
                                                          decoration:
                                                              BoxDecoration(
                                                            color: isToday
                                                                ? AppColors
                                                                    .pinkLight
                                                                : Colors.white,
                                                            shape:
                                                                BoxShape.circle,
                                                          ),
                                                        ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            );

                                            // Wrap event dates in Tooltip
                                            if (hasEvent) {
                                              final eventList =
                                                  _events[dateStr]!;
                                              cell = Tooltip(
                                                message: eventList
                                                    .map((e) => '• $e')
                                                    .join('\n'),
                                                preferBelow: false,
                                                textStyle: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: responsive
                                                        .smallFontSize),
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
                          SizedBox(height: responsive.spacingLarge),
                          // Events for selected date
                          Text(
                            'Events on ${DateFormat('MMM d, yyyy').format(_selectedDate)}',
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  fontSize: responsive.titleFontSize,
                                ),
                          ),
                          SizedBox(height: responsive.spacingMedium),
                          _buildEventsForDate(responsive),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }

  Widget _buildEventsForDate(ResponsiveHelper responsive) {
    final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate);
    final eventTitles = _events[dateStr];

    if (eventTitles == null || eventTitles.isEmpty) {
      return Text(
        'No events on this date',
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontSize: responsive.bodyFontSize,
            ),
      );
    }

    return Column(
      children: eventTitles
          .map((eventTitle) => Padding(
                padding: EdgeInsets.only(bottom: responsive.spacingMedium),
                child: GradientCard(
                  child: Row(
                    children: [
                      Container(
                        width: responsive.isMediumScreen ? 55 : 50,
                        height: responsive.isMediumScreen ? 55 : 50,
                        decoration: BoxDecoration(
                          gradient: AppColors.primaryGradient,
                          borderRadius:
                              BorderRadius.circular(responsive.radiusMedium),
                        ),
                        child: Icon(
                          Icons.event_note,
                          color: Colors.white,
                          size: responsive.isMediumScreen ? 26 : 24,
                        ),
                      ),
                      SizedBox(width: responsive.spacingMedium),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              eventTitle,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    fontSize: responsive.bodyFontSize,
                                  ),
                            ),
                            SizedBox(height: responsive.spacingSmall),
                            Text(
                              DateFormat('EEEE').format(_selectedDate),
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    fontSize: responsive.smallFontSize,
                                  ),
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
