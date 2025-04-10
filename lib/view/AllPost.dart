import 'dart:convert';
import 'dart:io';
import 'package:advanced_datatable/advanced_datatable_source.dart';
import 'package:advanced_datatable/datatable.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../model/PostModel.dart';
import '../navigationservice/NavigationService.dart';
import 'Dashboard.dart';

/*
  Activity name : All Post activity
  Project name : iHelpBD CRM
  Auth : Eng. Mazedul Islam
  Designation : Full Stack Software Developer
  Email : mazedulislam4970@gmail.com
*/


class AllPost extends StatefulWidget {
  const AllPost({Key? key}) : super(key: key);

  @override
  _AllPostState createState() => _AllPostState();
}

class _AllPostState extends State<AllPost> {

  var _rowsPerPage = AdvancedPaginatedDataTable.defaultRowsPerPage;
  final _source = ExampleSource();
  var _sortIndex = 0;
  var _sortAsc = true;
  final _searchController = TextEditingController();
  var _customFooter = false;

  @override
  void initState() {
    super.initState();
    _searchController.text = '';
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      navigatorKey: NavigationService.navigatorKey,

      home: Scaffold(

        appBar: AppBar(
          title: const Center(
              child: Text("All Post")),
          leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.pop(context);
                Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => DashBoardScreen()));
              }),
          actions: [
            IconButton(
              icon: const Icon(Icons.table_chart_outlined),
              tooltip: 'Change footer',
              onPressed: () {
                // handle the press
                setState(() {
                  _customFooter = !_customFooter;
                });
              },
            ),
          ],
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 10),
                      child: TextField(
                        controller: _searchController,
                        decoration: const InputDecoration(
                          labelText: 'Search by Page Name',
                        ),
                        onSubmitted: (vlaue) {
                          _source.filterServerSide(_searchController.text);
                        },
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      setState(() {
                        _searchController.text = '';
                      });
                      _source.filterServerSide(_searchController.text);
                    },
                    icon: const Icon(Icons.clear),
                  ),
                  IconButton(
                    onPressed: () =>
                        _source.filterServerSide(_searchController.text),
                    icon: const Icon(Icons.search),
                  ),
                ],
              ),
              AdvancedPaginatedDataTable(
                addEmptyRows: false,
                showCheckboxColumn: false,
                source: _source,
                columnSpacing: 20,
                showHorizontalScrollbarAlways: true,
                sortAscending: _sortAsc,
                sortColumnIndex: _sortIndex,
                showFirstLastButtons: true,
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
                  DataColumn(label: Text('Serial')),
                  DataColumn(label: Text('Page Name')),
                  DataColumn(label: Text('Status')),
                  DataColumn(label: Text('Create Time')),
                  DataColumn(label: Text('Action')),
                ],

                //Optianl override to support custom data row text / translation
                getFooterRowText:
                    (startRow, pageSize, totalFilter, totalRowsWithoutFilter) {
                  final localizations = MaterialLocalizations.of(context);
                  var amountText = localizations.pageRowsInfoTitle(
                    startRow,
                    pageSize,
                    totalFilter ?? totalRowsWithoutFilter,
                    false,
                  );

                  if (totalFilter != null) {
                    //Filtered data source show addtional information
                    amountText += ' filtered from ($totalRowsWithoutFilter)';
                  }

                  return amountText;
                },
                customTableFooter: _customFooter
                    ? (source, offset) {
                        const maxPagesToShow = 6;
                        const maxPagesBeforeCurrent = 3;
                        final lastRequestDetails = source.lastDetails!;
                        final rowsForPager = lastRequestDetails.filteredRows ??
                            lastRequestDetails.totalRows;
                        final totalPages = rowsForPager ~/ _rowsPerPage;
                        final currentPage = (offset ~/ _rowsPerPage) + 1;
                        final List<int> pageList = [];
                        if (currentPage > 1) {
                          pageList.addAll(
                            List.generate(currentPage - 1, (index) => index + 1),
                          );
                          //Keep up to 3 pages before current in the list
                          pageList.removeWhere(
                            (element) =>
                                element < currentPage - maxPagesBeforeCurrent,
                          );
                        }
                        pageList.add(currentPage);
                        //Add reminding pages after current to the list
                        pageList.addAll(
                          List.generate(
                            maxPagesToShow - (pageList.length - 1),
                            (index) => (currentPage + 1) + index,
                          ),
                        );
                        pageList.removeWhere((element) => element > totalPages);

                        return Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: pageList
                              .map(
                                (e) => TextButton(
                                  onPressed: e != currentPage
                                      ? () {
                                          //Start index is zero based
                                          source.setNextView(
                                            startIndex: (e - 1) * _rowsPerPage,
                                          );
                                        }
                                      : null,
                                  child: Text(
                                    e.toString(),
                                  ),
                                ),
                              )
                              .toList(),
                        );
                      }
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }

  //ignore: avoid_positional_boolean_parameters
  void setSort(int i, bool asc) => setState(() {
        _sortIndex = i;
        _sortAsc = asc;
      });
}

typedef SelectedCallBack = Function(String id, bool newSelectState);

class ExampleSource extends AdvancedDataTableSource<PostModel> {
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
  Future<RemoteDataSourceDetails<PostModel>> getNextPage(
      NextPageRequest pageRequest) async {
    //the remote data source has to support the pagaing and sorting
    final queryParameter = <String, dynamic>{
      'offset': pageRequest.offset.toString(),
      'pageSize': pageRequest.pageSize.toString(),
      'sortIndex': ((pageRequest.columnSortIndex ?? 0) + 1).toString(),
      'sortAsc': ((pageRequest.sortAscending ?? true) ? 1 : 0).toString(),
      if (lastSearchTerm.isNotEmpty) 'companyFilter': lastSearchTerm,
    };

    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

    //Get user data from local device
    String token = sharedPreferences.getString("token").toString();
    String authorized_by =
        sharedPreferences.getString("authorized_by").toString();

    // Api url
    String url = 'https://omni.ihelpbd.com/ihelpbd_social/api/v1/post_list.php';

    //Request API body
    Map<String, String> body = {"authorized_by": authorized_by};

    HttpClient httpClient = HttpClient();

    HttpClientRequest request = await httpClient.postUrl(Uri.parse(url));

    // content type
    request.headers.set('content-type', 'application/json');
    request.headers.set('token', token);


    /// token
    print("token :${token}");

    request.add(utf8.encode(json.encode(body)));

    //Get response
    HttpClientResponse response = await request.close();
    String reply = await response.transform(utf8.decoder).join();


    // Closed request
    httpClient.close();

    if (response.statusCode == 200) {
      final data = jsonDecode(reply);
      print(data);

      return RemoteDataSourceDetails(
        data['data'].length,
        (data['data'] as List<dynamic>)
            .map((json) => PostModel.fromJson(json))
            .toList(),
        filteredRows: lastSearchTerm.isNotEmpty
            ? (data['data'] as List<dynamic>).length
            : null,
      );
    } else {
      throw Exception('Unable to query remote server');
    }
  }
}
