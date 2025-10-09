import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../models/event_outfit.dart';
import '../services/event_outfit_service.dart';

class CalendarScreen extends StatefulWidget {
  final String userEmail;
  CalendarScreen({required this.userEmail});

  @override
  _CalendarScreenState createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  List<EventOutfit> _events = [];
  final EventOutfitService _service = EventOutfitService();

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  void _loadEvents() async {
    final events = await _service.getUserEvents(widget.userEmail);
    setState(() {
      _events = events;
    });
  }

  List<EventOutfit> _getEventsForDay(DateTime day) {
    return _events.where((event) =>
        event.eventDate.year == day.year &&
        event.eventDate.month == day.month &&
        event.eventDate.day == day.day).toList();
  }

  void _showAddEventDialog(DateTime day) {
    final _eventNameController = TextEditingController();
    final _outfitNameController = TextEditingController();
    String _selectedType = 'Casual';
    final outfitTypes = ['Casual', 'Formal', 'Party', 'Other'];

    DateTime? _reminderDate;

    if (day.isBefore(DateTime.now())) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("You can't add events to past dates."),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Add Event'),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: _eventNameController,
                decoration: InputDecoration(labelText: 'Event Name'),
              ),
              TextField(
                controller: _outfitNameController,
                decoration: InputDecoration(labelText: 'Outfit Name'),
              ),
              DropdownButtonFormField<String>(
                value: _selectedType,
                items: outfitTypes.map((type) => DropdownMenuItem(
                      value: type,
                      child: Text(type),
                    )).toList(),
                onChanged: (val) {
                  if (val != null) _selectedType = val;
                },
                decoration: InputDecoration(labelText: 'Outfit Type'),
              ),
              SizedBox(height: 12),
              Text("Select Reminder Date"),
              ElevatedButton(
                onPressed: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: day.subtract(Duration(days: 1)),
                    firstDate: DateTime.now(),
                    lastDate: day.subtract(Duration(days: 1)),
                    helpText: 'Reminder Date (before the event)',
                  );
                  if (picked != null && picked.isBefore(day)) {
                    setState(() => _reminderDate = picked);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Reminder set for $_reminderDate")),
                    );
                  } else if (picked != null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Reminder must be before event date."),
                        backgroundColor: Colors.orange,
                      ),
                    );
                  }
                },
                child: Text("Pick Reminder Date"),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (_eventNameController.text.isEmpty ||
                  _outfitNameController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("Please fill all fields."),
                    backgroundColor: Colors.orange,
                  ),
                );
                return;
              }

              if (_reminderDate == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("Please select a reminder date."),
                    backgroundColor: Colors.orange,
                  ),
                );
                return;
              }

              EventOutfit newEvent = EventOutfit(
                userEmail: widget.userEmail,
                eventName: _eventNameController.text,
                eventDate: day,
                outfitName: _outfitNameController.text,
                outfitType: _selectedType,
                reminderDate: _reminderDate, // make sure your model supports this
              );

              bool success = await _service.addEvent(newEvent);
              if (success) {
                _loadEvents();
                Navigator.pop(context);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Failed to add event')),
                );
              }
            },
            child: Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Calendar & Events')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TableCalendar(
              firstDay: DateTime.utc(2020, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
              focusedDay: _focusedDay,
              calendarFormat: _calendarFormat,
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
                _showAddEventDialog(selectedDay);
              },
              onFormatChanged: (format) {
                setState(() {
                  _calendarFormat = format;
                });
              },
              calendarStyle: CalendarStyle(
                todayDecoration: BoxDecoration(
                  color: Colors.blueAccent,
                  shape: BoxShape.circle,
                ),
                selectedDecoration: BoxDecoration(
                  color: Colors.orangeAccent,
                  shape: BoxShape.circle,
                ),
                markerDecoration: BoxDecoration(
                  color: Colors.redAccent,
                  shape: BoxShape.circle,
                ),
              ),
              eventLoader: (day) {
                return _getEventsForDay(day);
              },
            ),
            SizedBox(height: 16),
            Expanded(
              child: _selectedDay == null
                  ? Center(child: Text('Select a day to view events'))
                  : ListView(
                      children: _getEventsForDay(_selectedDay!).map((event) {
                        return Card(
                          child: ListTile(
                            title: Text(event.eventName),
                            subtitle: Text(
                              '${event.outfitName} (${event.outfitType})',
                            ),
                          ),
                        );
                      }).toList(),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
