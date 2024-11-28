import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'DiaryPage.dart';

class Calendar extends StatefulWidget {
  @override
  _CalendarState createState() => _CalendarState();
}

class _CalendarState extends State<Calendar> {
  DateTime? _selectedDate;
  DateTime _focusedDay = DateTime.now();
  String _statsText = '';
  late CalendarFormat _calendarFormat = CalendarFormat.month;
  Map<DateTime, Map<String, dynamic>> _dateEntries = {};

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    _loadDiaryEntries();
    _loadFoodTypeStats();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadDiaryEntries();
  }

  Future<void> _loadDiaryEntries() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      final entries = await loadDiaryEntries(uid);
      if (mounted) {
        setState(() {
          _dateEntries = entries;
        });
      }
    }
  }

  Future<Map<String, int>> countFoodTypes(String userId) async {
    try {
      final querySnapshot =
          await FirebaseFirestore.instance.collection('calendar').get();

      Map<String, int> foodTypeCounts = {
        '한식': 0,
        '중식': 0,
        '일식': 0,
        '양식': 0,
        '야식': 0,
        '디저트': 0
      };

      for (var doc in querySnapshot.docs) {
        String foodType = doc.data()['foodType'];
        if (foodTypeCounts.containsKey(foodType)) {
          foodTypeCounts[foodType] = foodTypeCounts[foodType]! + 1;
        }
      }

      return foodTypeCounts;
    } catch (e) {
      print('Failed to count food types: $e');
      return {};
    }
  }

  Future<void> _loadFoodTypeStats() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    var counts = await countFoodTypes(user.uid);

    // 가장 많이 먹은 음식 찾기
    String mostEatenFoodType =
        counts.entries.reduce((a, b) => a.value > b.value ? a : b).key;

    // 상태 업데이트를 비동기적으로 처리
    setState(() {
      _statsText = '          🍴 가장 많이 먹은 음식은 "$mostEatenFoodType" 입니다! 🍴\n'
          '🍚 한식        ${counts['한식']}번  |  🥡 중식        ${counts['중식']}번  |  🍣 일식        ${counts['일식']}번\n'
          '🍝 양식        ${counts['양식']}번  |  🌙 야식        ${counts['야식']}번  |  🍰 디저트      ${counts['디저트']}번';
    });
  }

  void _onMonthChange(int direction) {
    setState(() {
      _focusedDay = DateTime(
        _focusedDay.year,
        _focusedDay.month + direction,
        1,
      );
      if (_focusedDay.month > 12) {
        _focusedDay = DateTime(_focusedDay.year + 1, 1, 1);
      } else if (_focusedDay.month < 1) {
        _focusedDay = DateTime(_focusedDay.year - 1, 12, 1);
      }
      if (_selectedDate != null &&
          (_selectedDate!.month != _focusedDay.month ||
              _selectedDate!.year != _focusedDay.year)) {
        _selectedDate = DateTime(_focusedDay.year, _focusedDay.month, 1);
      }
    });
  }

  void _selectDate(DateTime date) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DiaryPage(
          date: date,
          initialImageUrl: _dateEntries[date]?['imageUrl'],
          initialNote: _dateEntries[date]?['note'],
          initialFoodType: _dateEntries[date]?['foodType'],
          onSave: (imageUrl, foodType, note) {
            setState(() {
              _dateEntries[date] = {
                'imageUrl': imageUrl,
                'foodType': foodType,
                'note': note,
              };
            });
            _loadDiaryEntries();
          },
          onDelete: () {
            setState(() {
              _dateEntries.remove(date);
            });
            _loadDiaryEntries();
          },
        ),
      ),
    ).then((_) => _loadDiaryEntries());
  }

  @override
  Widget build(BuildContext context) {
    final DateFormat monthFormat = DateFormat('MMMM');
    final DateFormat yearFormat = DateFormat('yyyy');
    final DateFormat selectedDateFormat = DateFormat('yyyy.MM.dd');
    String formattedMonth = _focusedDay != null
        ? monthFormat.format(_focusedDay)
        : 'No month selected!';
    String formattedYear =
        _focusedDay != null ? yearFormat.format(_focusedDay) : '';
    String formattedSelectedDate =
        _selectedDate != null ? selectedDateFormat.format(_selectedDate!) : '';

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: <Widget>[
          Container(
            height: 220,
            color: Color(0XFFD76F69),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    const SizedBox(height: 40),
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new_rounded,
                          color: Colors.white),
                      onPressed: () => _onMonthChange(-1),
                    ),
                    Expanded(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text(
                              formattedMonth,
                              style: const TextStyle(
                                fontSize: 30,
                                fontFamily: "Quando",
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              formattedYear,
                              style: const TextStyle(
                                fontSize: 20,
                                fontFamily: "Quando",
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              formattedSelectedDate,
                              style: const TextStyle(
                                fontSize: 16,
                                fontFamily: "Quando",
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.arrow_forward_ios_rounded,
                        color: Colors.white,
                      ),
                      onPressed: () => _onMonthChange(1),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.date_range, color: Colors.white),
                      onPressed: () {
                        showDatePicker(
                          context: context,
                          initialDate: _selectedDate!,
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                          cancelText: 'CANCEL',
                          confirmText: 'OK',
                          builder: (BuildContext context, Widget? child) {
                            return Theme(
                              data: ThemeData.light().copyWith(
                                primaryColor:
                                    Theme.of(context).colorScheme.secondary,
                                dialogBackgroundColor: Colors.white,
                              ),
                              child: AlertDialog(
                                backgroundColor: Colors.white,
                                contentPadding: EdgeInsets.zero,
                                shape: const RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(20.0)),
                                ),
                                content: SizedBox(
                                  width: 330,
                                  height: 500,
                                  child: child,
                                ),
                              ),
                            );
                          },
                        ).then((pickedDate) {
                          if (pickedDate != null &&
                              pickedDate != _selectedDate) {
                            setState(() {
                              _selectedDate = pickedDate;
                              _focusedDay = pickedDate;
                            });
                          }
                        });
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                  child: TableCalendar(
                    firstDay: DateTime(2000),
                    lastDay: DateTime(2100),
                    focusedDay: _focusedDay,
                    selectedDayPredicate: (day) {
                      return isSameDay(_selectedDate, day);
                    },
                    onDaySelected: (selectedDay, focusedDay) {
                      setState(() {
                        _selectedDate = selectedDay;
                        _focusedDay = focusedDay;
                      });
                      _selectDate(selectedDay);
                    },
                    calendarFormat: _calendarFormat,
                    onFormatChanged: (format) {
                      setState(() {
                        _calendarFormat = format;
                      });
                    },
                    headerVisible: false,
                    daysOfWeekStyle: const DaysOfWeekStyle(
                      weekdayStyle: TextStyle(
                        fontFamily: "Quando",
                        fontWeight: FontWeight.w600,
                        fontSize: 17,
                        color: Colors.black,
                      ),
                      weekendStyle: TextStyle(
                        fontFamily: "Quando",
                        fontWeight: FontWeight.w600,
                        fontSize: 17,
                        color: Colors.black,
                      ),
                    ),
                    calendarBuilders: CalendarBuilders(
                      defaultBuilder: (context, date, focusedDay) {
                        return _buildCalendarCell(date);
                      },
                      selectedBuilder: (context, date, focusedDay) {
                        return _buildCalendarCell(date);
                      },
                      todayBuilder: (context, date, focusedDay) {
                        return _buildCalendarCell(date);
                      },
                    ),
                    calendarStyle: CalendarStyle(
                      outsideDaysVisible: false,
                      defaultDecoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    rowHeight: 58,
                    daysOfWeekHeight: 30,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 17),
            child: Container(
              height: 100,
              width: 370,
              child: Card(
                child: Center(
                  child: Text(
                    _statsText,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildCalendarCell(DateTime date) {
    bool hasImage = _dateEntries[date]?['imageUrl'] != null;
    bool hasNote = _dateEntries[date]?['note'] != null &&
        _dateEntries[date]!['note'].isNotEmpty;
    bool isToday = isSameDay(date, DateTime.now());

    return Container(
      width: 36,
      height: 37,
      decoration: BoxDecoration(
        color: isToday
            ? (hasNote && !hasImage ? const Color(0XFFFFBAB6) : Colors.white)
            : (hasNote && !hasImage
                ? const Color(0XFFD76F69)
                : Colors.transparent),
        image: hasImage
            ? DecorationImage(
                image: NetworkImage(_dateEntries[date]!['imageUrl']),
                fit: BoxFit.cover,
              )
            : null,
        shape: BoxShape.circle,
        border: isToday
            ? Border.all(color: const Color(0XFFD76F69), width: 2)
            : null,
      ),
      child: Center(
        child: Text(
          date.day.toString(),
          style: TextStyle(
            fontFamily: 'Pretendard Variable',
            fontWeight: FontWeight.w600,
            fontSize: 17,
            color: (hasImage || (hasNote && !isToday))
                ? Colors.white.withOpacity(0.8)
                : Colors.black,
          ),
        ),
      ),
    );
  }
}

Future<Map<DateTime, Map<String, dynamic>>> loadDiaryEntries(String uid) async {
  try {
    final querySnapshot =
        await FirebaseFirestore.instance.collection('calendar').get();
    final Map<DateTime, Map<String, dynamic>> entries = {};
    for (var doc in querySnapshot.docs) {
      final data = doc.data();
      final date = DateTime.parse(doc.id);
      entries[date] = {
        'foodType': data['foodType'],
        'note': data['note'],
        'imageUrl': data['imageUrl'],
      };
    }
    return entries;
  } catch (e) {
    print('Error loading diary entries: $e');
    return {};
  }
}
