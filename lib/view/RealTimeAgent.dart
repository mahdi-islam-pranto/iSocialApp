import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:advanced_datatable/advanced_datatable_source.dart';
import 'package:advanced_datatable/datatable.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../model/RealTimeAgentModel.dart';
import '../navigationservice/NavigationService.dart';
import 'Dashboard.dart';

/*
  Activity name : RealTimeAgent activity
  Project name : iHelpBD CRM
  Auth : Eng. Mazedul Islam
  Designation : Full Stack Software Developer
  Email : mazedulislam4970@gmail.com
*/

class RealTimeAgent extends StatefulWidget {
  const RealTimeAgent({Key? key}) : super(key: key);

  @override
  _RealTimeAgentState createState() => _RealTimeAgentState();
}

class _RealTimeAgentState extends State<RealTimeAgent> {
  var _rowsPerPage = AdvancedPaginatedDataTable.defaultRowsPerPage;
  final _source = ExampleSource();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      navigatorKey: NavigationService.navigatorKey,
      home: Scaffold(
        appBar: AppBar(
          title: const Text("Real Time Agent"),
          leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.pop(context);
                Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => DashBoardScreen()));
              }),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              AdvancedPaginatedDataTable(
                showFirstLastButtons: false,
                addEmptyRows: false,
                source: _source,
                showCheckboxColumn: false,
                columnSpacing: 15,
                showHorizontalScrollbarAlways: true,
                rowsPerPage: _rowsPerPage,
                availableRowsPerPage: const [10, 20, 30, 50],
                onRowsPerPageChanged: (newRowsPerPage) {
                  if (newRowsPerPage != null) {
                    setState(() {
                      _rowsPerPage = newRowsPerPage;
                    });
                  }
                },
                columns: const [
                  DataColumn(label: Text('User Name')),
                  DataColumn(label: Text('Status')),
                  DataColumn(label: Text('Start Time')),
                  DataColumn(label: Text('Total Ticket')),
                  DataColumn(label: Text('New Ticket')),
                  DataColumn(label: Text('Progress Ticket')),
                  DataColumn(label: Text('Closed Ticket')),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

typedef SelectedCallBack = Function(String id, bool newSelectState);

class ExampleSource extends AdvancedDataTableSource<RealTimeAgentModel> {
  List<String> selectedIds = [];
  String lastSearchTerm = '';

  @override
  DataRow? getRow(int index) =>
      lastDetails!.rows[index].getRow(selectedRow, selectedIds);

  @override
  int get selectedRowCount => selectedIds.length;

  void selectedRow(String id, bool newSelectState) {
    if (selectedIds.contains(id)) {
      selectedIds.remove(id);
    } else {
      selectedIds.add(id);
    }
    notifyListeners();
  }

  void filterServerSide(String filterQuery) {
    lastSearchTerm = filterQuery.toLowerCase().trim();
    setNextView();
  }

  @override
  Future<RemoteDataSourceDetails<RealTimeAgentModel>> getNextPage(
      NextPageRequest pageRequest) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

    //Get user data from local device
    String token = sharedPreferences.getString("token").toString();
    String authorized_by =
        sharedPreferences.getString("authorized_by").toString();

    // Api url
    String url =
        'https://omni.ihelpbd.com/ihelpbd_social/api/v1/realtime_agent.php';

    //Request API body
    Map<String, String> body = {"authorized_by": authorized_by};

    HttpClient httpClient = HttpClient();

    HttpClientRequest request = await httpClient.postUrl(Uri.parse(url));

    // content type
    request.headers.set('content-type', 'application/json');
    request.headers.set('token', token);

    request.add(utf8.encode(json.encode(body)));

    //Get response
    HttpClientResponse response = await request.close();
    String reply = await response.transform(utf8.decoder).join();

    // customProgress.hideDialog();

    // Closed request
    httpClient.close();

    if (response.statusCode == 200) {
      final data = jsonDecode(reply);

      return RemoteDataSourceDetails(
        data['data'].length,
        (data['data'] as List<dynamic>)
            .map((json) => RealTimeAgentModel.fromJson(json))
            .toList(),
      );
    } else {
      throw Exception('Unable to query remote server');
    }
  }
}
