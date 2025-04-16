import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart'; // Added for date formatting

class TicketReportScreen extends StatefulWidget {
  @override
  _TicketReportScreenState createState() => _TicketReportScreenState();
}

class _TicketReportScreenState extends State<TicketReportScreen> {
  List<dynamic> _ticketData = [];
  bool _isLoading = true;

  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();

  // Date format
  final DateFormat _dateFormat = DateFormat('yyyy-MM-dd');

  @override
  void initState() {
    super.initState();
    final String today = _dateFormat.format(DateTime.now());
    _startDateController.text = today;
    _endDateController.text = today;
    _fetchTicketReport();
  }

  // Method to show date picker for start date
  Future<void> _selectStartDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _startDateController.text.isNotEmpty
          ? _dateFormat.parse(_startDateController.text)
          : DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.purple,
              onPrimary: Colors.white,
              surface: Colors.purple.shade50,
              onSurface: Colors.purple.shade700,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _startDateController.text = _dateFormat.format(picked);
      });
    }
  }

  // Method to show date picker for end date
  Future<void> _selectEndDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _endDateController.text.isNotEmpty
          ? _dateFormat.parse(_endDateController.text)
          : DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.purple,
              onPrimary: Colors.white,
              surface: Colors.purple.shade50,
              onSurface: Colors.purple.shade700,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _endDateController.text = _dateFormat.format(picked);
      });
    }
  }

  Future<void> _fetchTicketReport() async {
    setState(() {
      _isLoading = true;
    });

    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String user = sharedPreferences.getString("username") ?? '';

    final url =
        'https://omni.ihelpbd.com/ihelpbd_social_development/api/v1/ticket_report.php';

    try {
      final response = await http.post(
        Uri.parse(url),
        body: {
          'user': user,
          'start_date': _startDateController.text,
          'end_date': _endDateController.text,
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('Response data: $data');

        if (data['status'] == 'success') {
          setState(() {
            _ticketData = data['data'];
            _isLoading = false;
          });
        } else {
          // Handle failure case
          print('Failed to fetch data: ${data['message']}');
          setState(() {
            _ticketData = [];
            _isLoading = false;
          });
        }
      } else {
        // Handle server error
        print('Server error');
        setState(() {
          _ticketData = [];
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching data: $e');
      setState(() {
        _ticketData = [];
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ticket Report'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Card(
              elevation: 0.5,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _startDateController,
                        readOnly:
                            true, // Make it read-only since we use date picker
                        decoration: InputDecoration(
                          labelText: 'Start Date',
                          border: OutlineInputBorder(),
                          suffixIcon: IconButton(
                            icon: Icon(Icons.calendar_today,
                                color: Colors.purple),
                            onPressed: () => _selectStartDate(context),
                          ),
                        ),
                        onTap: () => _selectStartDate(context),
                      ),
                    ),
                    SizedBox(width: 16.0),
                    Expanded(
                      child: TextField(
                        controller: _endDateController,
                        readOnly:
                            true, // Make it read-only since we use date picker
                        decoration: InputDecoration(
                          labelText: 'End Date',
                          border: OutlineInputBorder(),
                          suffixIcon: IconButton(
                            icon: Icon(Icons.calendar_today,
                                color: Colors.purple),
                            onPressed: () => _selectEndDate(context),
                          ),
                        ),
                        onTap: () => _selectEndDate(context),
                      ),
                    ),
                    const SizedBox(width: 16.0),
                    IconButton(
                      onPressed: () {
                        _fetchTicketReport();
                      },
                      icon: const Icon(
                        Icons.search,
                        color: Colors.purple,
                        size: 27,
                      ),
                    )
                  ],
                ),
              ),
            ),
            SizedBox(height: 16.0),
            Expanded(
              child: _buildContent(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              color: Colors.purple,
            ),
            SizedBox(height: 16),
            Text(
              'Please wait, fetching ticket data...',
              style: TextStyle(
                color: Colors.purple,
                fontWeight: FontWeight.w500,
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    } else if (_ticketData.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.event_busy,
              size: 64,
              color: Colors.purple.withOpacity(0.7),
            ),
            SizedBox(height: 16),
            Text(
              'No ticket data available for selected dates',
              style: TextStyle(
                color: Colors.purple,
                fontWeight: FontWeight.w500,
                fontSize: 16,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Try selecting different dates or try again later',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    } else {
      return Container(
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(
            width: 1,
            color: Color.fromRGBO(223, 192, 241, 0.4470588235294118),
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            columns: const [
              DataColumn(
                label: Text(
                  'Serial',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: Colors.purple,
                  ),
                ),
              ),
              DataColumn(
                label: Text(
                  'User ID',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: Colors.purple,
                  ),
                ),
              ),
              DataColumn(
                label: Text(
                  'Page',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: Colors.purple,
                  ),
                ),
              ),
              DataColumn(
                label: Text(
                  'Customer Name',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: Colors.purple,
                  ),
                ),
              ),
              DataColumn(
                label: Text(
                  'Interaction Type',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: Colors.purple,
                  ),
                ),
              ),
              DataColumn(
                label: Text(
                  'Assign Time',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: Colors.purple,
                  ),
                ),
              ),
              DataColumn(
                label: Text(
                  'Reply Time',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: Colors.purple,
                  ),
                ),
              ),
              DataColumn(
                label: Text(
                  'Closed Time',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: Colors.purple,
                  ),
                ),
              ),
              DataColumn(
                label: Text(
                  'Type',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: Colors.purple,
                  ),
                ),
              ),
              DataColumn(
                label: Text(
                  'Category',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: Colors.purple,
                  ),
                ),
              ),
              DataColumn(
                label: Text(
                  'Sub Category',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: Colors.purple,
                  ),
                ),
              ),
              DataColumn(
                label: Text(
                  'Label',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: Colors.purple,
                  ),
                ),
              ),
              DataColumn(
                label: Text(
                  'Count',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: Colors.purple,
                  ),
                ),
              ),
              DataColumn(
                label: Text(
                  'Interaction Duration',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: Colors.purple,
                  ),
                ),
              ),
              DataColumn(
                label: Text(
                  'Avg Response Time',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: Colors.purple,
                  ),
                ),
              ),
            ],
            rows: _ticketData.map((ticket) {
              return DataRow(cells: [
                DataCell(Text(ticket['serial']?.toString() ?? '')),
                DataCell(Text(ticket['user_id']?.toString() ?? '')),
                DataCell(Text(ticket['page']?.toString() ?? '')),
                DataCell(Text(ticket['customer_name']?.toString() ?? '')),
                DataCell(Text(ticket['interaction_type']?.toString() ?? '')),
                DataCell(Text(ticket['assign_time']?.toString() ?? '')),
                DataCell(Text(ticket['reply_time']?.toString() ?? '')),
                DataCell(Text(ticket['closed_time']?.toString() ?? '')),
                DataCell(Text(ticket['type']?.toString() ?? '')),
                DataCell(Text(ticket['category']?.toString() ?? '')),
                DataCell(Text(ticket['sub_category']?.toString() ?? '')),
                DataCell(Text(ticket['label']?.toString() ?? '')),
                DataCell(Text(ticket['count']?.toString() ?? '')),
                DataCell(
                    Text(ticket['interaction_duration']?.toString() ?? '')),
                DataCell(Text(ticket['avg_response_time']?.toString() ?? '')),
              ]);
            }).toList(),
          ),
        ),
      );
    }
  }

  @override
  void dispose() {
    _startDateController.dispose();
    _endDateController.dispose();
    super.dispose();
  }
}
