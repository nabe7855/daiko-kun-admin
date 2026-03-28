import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

import '../providers/auth_provider.dart';

class DriverHistoryPage extends ConsumerStatefulWidget {
  final Map<String, dynamic> driver;
  const DriverHistoryPage({super.key, required this.driver});

  @override
  ConsumerState<DriverHistoryPage> createState() => _DriverHistoryPageState();
}

class _DriverHistoryPageState extends ConsumerState<DriverHistoryPage> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<DateTime, List<dynamic>> _events = {};
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    // Build context is not fully ready here for ref, but initialize works in post frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchHistory();
    });
  }

  Future<void> _fetchHistory() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final token = ref.read(authProvider)?.token;
      final response = await http.get(
        Uri.parse(
          'http://10.68.139.36:8080/admin/drivers/${widget.driver['id']}/history',
        ),
        headers: token != null ? {'Authorization': 'Bearer $token'} : null,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        Map<DateTime, List<dynamic>> newEvents = {};

        for (var ride in data) {
          final dateStr = ride['created_at'] as String;
          final date = DateTime.parse(dateStr).toLocal();
          final day = DateTime(date.year, date.month, date.day);

          if (newEvents[day] == null) {
            newEvents[day] = [];
          }
          newEvents[day]!.add(ride);
        }

        if (mounted) {
          setState(() {
            _events = newEvents;
          });
        }
      } else {
        debugPrint('Failed to fetch history: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error fetching history: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  List<dynamic> _getEventsForDay(DateTime day) {
    return _events[DateTime(day.year, day.month, day.day)] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    // Normalize to compare without time
    final normalizedSelected = DateTime(
      (_selectedDay ?? _focusedDay).year,
      (_selectedDay ?? _focusedDay).month,
      (_selectedDay ?? _focusedDay).day,
    );
    final selectedRides = _getEventsForDay(normalizedSelected);
    final totalSales = selectedRides.fold<double>(
      0,
      (sum, ride) =>
          sum + (ride['actual_fare'] ?? ride['estimated_fare'] ?? 0).toDouble(),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.driver['name'] ?? 'ドライバ�E'} の売上履歴'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _fetchHistory),
        ],
      ),
      body: Row(
        children: [
          // Left side: Calendar
          Expanded(
            flex: 2,
            child: Column(
              children: [
                TableCalendar(
                  firstDay: DateTime.utc(2024, 1, 1),
                  lastDay: DateTime.utc(2030, 12, 31),
                  focusedDay: _focusedDay,
                  selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                  onDaySelected: (selectedDay, focusedDay) {
                    setState(() {
                      _selectedDay = selectedDay;
                      _focusedDay = focusedDay;
                    });
                  },
                  eventLoader: _getEventsForDay,
                  calendarStyle: const CalendarStyle(
                    markerDecoration: BoxDecoration(
                      color: Colors.orange,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                const Spacer(),
              ],
            ),
          ),
          const VerticalDivider(width: 1),
          // Right side: Details
          Expanded(
            flex: 3,
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              DateFormat(
                                'yyyy年MM朁Ed日',
                              ).format(normalizedSelected),
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '日次売上合訁E ¥${NumberFormat('#,###').format(totalSales)}',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: selectedRides.isEmpty
                            ? const Center(child: Text('こ�E日の記録はありません'))
                            : ListView.builder(
                                itemCount: selectedRides.length,
                                itemBuilder: (context, index) {
                                  final ride = selectedRides[index];
                                  final fare =
                                      (ride['actual_fare'] ??
                                              ride['estimated_fare'] ??
                                              0)
                                          .toDouble();
                                  final rating =
                                      ride['rating_to_driver'] as int?;
                                  final comment =
                                      ride['review_comment'] as String?;
                                  final time = DateFormat('HH:mm').format(
                                    DateTime.parse(
                                      ride['created_at'],
                                    ).toLocal(),
                                  );

                                  return Card(
                                    margin: const EdgeInsets.symmetric(
                                      horizontal: 24,
                                      vertical: 8,
                                    ),
                                    child: ListTile(
                                      title: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            '$time - 客: ${ride['customer_name'] ?? ride['customer_id'] ?? '不�Eなユーザー'}',
                                          ),
                                          Text(
                                            '¥${NumberFormat('#,###').format(fare)}',
                                          ),
                                        ],
                                      ),
                                      subtitle: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          if (rating != null)
                                            Row(
                                              children: [
                                                const Text('評価: '),
                                                ...List.generate(
                                                  5,
                                                  (i) => Icon(
                                                    i < rating
                                                        ? Icons.star
                                                        : Icons.star_border,
                                                    size: 16,
                                                    color: Colors.amber,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          if (comment != null &&
                                              comment.isNotEmpty)
                                            Text('コメンチE $comment'),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}
