import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TicketReportScreen extends StatefulWidget {
  @override
  _TicketReportScreenState createState() => _TicketReportScreenState();
}

class _TicketReportScreenState extends State<TicketReportScreen> {
  List<dynamic> _ticketData = [];

  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final String today = DateTime.now().toIso8601String().split('T').first;
    _startDateController.text = today;
    _endDateController.text = today;
    _fetchTicketReport();
  }

  Future<void> _fetchTicketReport() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String user = sharedPreferences.getString("username") ?? '';

    final url =
        'https://omni.ihelpbd.com/ihelpbd_social_development/api/v1/ticket_report.php';
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
      print('Response data: $data'); // Add this line to see the response data

      if (data['status'] == 'success') {
        setState(() {
          _ticketData = data['data'];
        });
      } else {
        // Handle failure case
        print('Failed to fetch data: ${data['message']}');
      }
    } else {
      // Handle server error
      print('Server error');
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
                        decoration: InputDecoration(
                          labelText: 'Start Date',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    SizedBox(width: 16.0),
                    Expanded(
                      child: TextField(
                        controller: _endDateController,
                        decoration: const InputDecoration(
                          labelText: 'End Date',
                          border: OutlineInputBorder(),
                        ),
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
            _ticketData.isEmpty
                ? Center(child: CircularProgressIndicator())
                : Container(
                    width: MediaQuery.sizeOf(context).width,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(
                        width: 1,
                        color:
                            Color.fromRGBO(223, 192, 241, 0.4470588235294118),
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Expanded(
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
                              DataCell(
                                  Text(ticket['serial']?.toString() ?? '')),
                              DataCell(
                                  Text(ticket['user_id']?.toString() ?? '')),
                              DataCell(Text(ticket['page']?.toString() ?? '')),
                              DataCell(Text(
                                  ticket['customer_name']?.toString() ?? '')),
                              DataCell(Text(
                                  ticket['interaction_type']?.toString() ??
                                      '')),
                              DataCell(Text(
                                  ticket['assign_time']?.toString() ?? '')),
                              DataCell(
                                  Text(ticket['reply_time']?.toString() ?? '')),
                              DataCell(Text(
                                  ticket['closed_time']?.toString() ?? '')),
                              DataCell(Text(ticket['type']?.toString() ?? '')),
                              DataCell(
                                  Text(ticket['category']?.toString() ?? '')),
                              DataCell(Text(
                                  ticket['sub_category']?.toString() ?? '')),
                              DataCell(Text(ticket['label']?.toString() ?? '')),
                              DataCell(Text(ticket['count']?.toString() ?? '')),
                              DataCell(Text(
                                  ticket['interaction_duration']?.toString() ??
                                      '')),
                              DataCell(Text(
                                  ticket['avg_response_time']?.toString() ??
                                      '')),
                            ]);
                          }).toList(),
                        ),
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
