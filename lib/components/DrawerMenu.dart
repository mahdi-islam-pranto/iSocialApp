import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:isocial/view/AllPost.dart';
import 'package:isocial/view/RealTimeAgent.dart';
import 'package:isocial/module/ticket/view/ticket_list_view.dart';
import 'package:isocial/view/ticket_report.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../auth/Logout.dart';
import '../module/ticket/dispositon/DispositonController.dart';

import '/constants/constants.dart';

/*
  Component name : DrawerMenu
  Project name : iHelpBD CRM
  Auth : Eng. Mazedul Islam
  Designation : Full Stack Software Developer
  Email : mazedulislam4970@gmail.com
*/

class DrawerMenu extends StatefulWidget {
  final Function(Color) onContainerColorChanged;

  const DrawerMenu({Key? key, required this.onContainerColorChanged})
      : super(key: key);

  @override
  State<DrawerMenu> createState() => _DrawerMenuState();
}

class _DrawerMenuState extends State<DrawerMenu> {
  final GlobalKey<_DrawerMenuState> expansionTile = GlobalKey();

  // Initial Selected Value
  String dropdownvalue = 'Login';

  // List of items in our dropdown menu
  var items = [
    'Login',
    'Prayer',
    'Lunch Break',
    'Short Break',
    'Office Time Over',
    'Meeting',
    'Available',
  ];

  List<String> templateDisTitle = [];
  List<String> templateDisMessage = [];
  bool isLoading = false;
  String dropDownValue = " --Template--";
  Color containerColor = Colors.grey;

  @override
  void initState() {
    super.initState();
    fetchTemplateDispositionData();
    loadBreakStatus(); // Load the saved break status when initializing
  }

  void fetchTemplateDispositionData() async {
    setState(() {
      isLoading = true;
    });

    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String token = sharedPreferences.getString("token").toString();
    String authorizedBy =
        sharedPreferences.getString("authorized_by").toString();

    String url = 'https://omni.ihelpbd.com/ihelpbd_social/api/v1/template.php';

    Map<String, String> body = {"authorized_by": authorizedBy};

    HttpClient httpClient = HttpClient();
    HttpClientRequest request = await httpClient.postUrl(Uri.parse(url));
    request.headers.set('content-type', 'application/json');
    request.headers.set('token', token);
    request.add(utf8.encode(json.encode(body)));

    HttpClientResponse response = await request.close();
    String reply = await response.transform(utf8.decoder).join();
    httpClient.close();

    if (response.statusCode == 200) {
      final items = json.decode(reply)["data"];

      setState(() {
        try {
          for (int index = 0; index < items.length; index++) {
            templateDisTitle.add(items[index]["title"].toString());
            templateDisMessage.add(items[index]["massage"].toString());
          }
          isLoading = false;
        } catch (e) {
          isLoading = true;
        }
      });
    } else {
      templateDisTitle = [];
      templateDisMessage = [];
      isLoading = false;
    }
  }

  void breakStatus(String breakStatusValue) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String token = sharedPreferences.getString("token").toString();
    String authorizedBy =
        sharedPreferences.getString("authorized_by").toString();
    String userName = sharedPreferences.getString("username").toString();

    print("username :${userName}");
    print("authorized_byyyyy :${authorizedBy}");
    print("token :${token}");

    String url =
        "https://omni.ihelpbd.com/ihelpbd_social_development/api/v1/break_status.php";
    Map<String, String> body = {
      "authorized_by": authorizedBy,
      "username": userName,
      "break_status": breakStatusValue,
    };

    HttpClient httpClient = HttpClient();
    HttpClientRequest request = await httpClient.postUrl(Uri.parse(url));
    request.headers.set('content-type', 'application/json');
    request.headers.set('token', token);
    request.add(utf8.encode(json.encode(body)));

    HttpClientResponse response = await request.close();
    String reply = await response.transform(utf8.decoder).join();

    print("breakStatus : ${reply}");

    httpClient.close();

    if (response.statusCode == 200) {
      final conversations = json.decode(reply)["data"];
      print('breakStatus::::::${conversations}');

      // Save the break status to SharedPreferences
      sharedPreferences.setString('break_status', breakStatusValue);
    } else {
      isLoading = false;
    }
  }

  void setContainerColor(String status) {
    setState(() {
      containerColor = status == 'Available' ? Colors.green : Colors.grey;
    });
    widget.onContainerColorChanged(containerColor); // Callback to parent widget
  }

  void loadBreakStatus() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String? savedBreakStatus = sharedPreferences.getString('break_status');

    if (savedBreakStatus != null) {
      setState(() {
        dropdownvalue = savedBreakStatus;
        setContainerColor(savedBreakStatus);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Drawer(
        child: ListView(
          children: [
            Container(
              color: Color.fromRGBO(191, 210, 215, 0.4470588235294118),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.only(
                        top: 15, bottom: 5, left: appPadding),
                    child: Image.asset(
                      "assets/images/ihelpbd.png",
                      height: 80,
                      width: 150,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.only(bottom: 30),
                    child: const Text(
                      "iHelpBD-Social",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: DropdownButton<String>(
                    value: dropdownvalue,
                    icon: const Icon(Icons.keyboard_arrow_down),
                    items: items.map((String item) {
                      return DropdownMenuItem<String>(
                        value: item,
                        child: Text(
                          item,
                        ),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        dropdownvalue = newValue!;
                        setContainerColor(dropdownvalue);
                        print('New value : $dropdownvalue');
                        breakStatus(dropdownvalue);
                      });
                    },
                  ),
                ),
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: containerColor,
                    borderRadius: BorderRadius.circular(
                        8), // Adjust the radius as per your requirement
                  ),
                )
              ],
            ),
            ExpansionTile(
              maintainState: false,
              title: const Text('Dashboard'),
              leading: const Icon(Icons.dashboard),
              childrenPadding:
                  const EdgeInsets.only(left: 50, top: 0, bottom: 0),
              children: <Widget>[
                ListTile(
                    title: const Text("Realtime Agent"),
                    leading: const Icon(Icons.desktop_windows),
                    onTap: () {
                      Navigator.pop(context);

                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => RealTimeAgent()));
                    }),
                ListTile(
                  title: const Text("Ticket Report"),
                  leading: const Icon(Icons.report),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => TicketReportScreen()));
                  },
                ),
              ],
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: appPadding * 2),
              child: Divider(
                color: grey,
                thickness: 0.2,
              ),
            ),
            ListTile(
              title: const Text("Post"),
              leading: const Icon(Icons.message_outlined),
              onTap: () {
                Navigator.pop(context);
                Navigator.of(context)
                    .push(MaterialPageRoute(builder: (context) => AllPost()));
              },
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: appPadding * 2),
              child: Divider(
                color: grey,
                thickness: 0.2,
              ),
            ),
            ListTile(
                title: const Text('Ticket'),
                leading: const Icon(Icons.person_add),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => TicketList()));
                }),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: appPadding * 2),
              child: Divider(
                color: grey,
                thickness: 0.2,
              ),
            ),
            ListTile(
                title: const Text('Sign Out'),
                leading: const Icon(Icons.logout_sharp),
                onTap: () {
                  Logout log = Logout(context);
                  log.logout();
                }),
          ],
        ),
      ),
    );
  }

  Widget getTemplateDisposition() {
    if (templateDisTitle.contains(null) || isLoading) {
      return const Center(
          child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
      ));
    }

    var template = [' --Template--'];
    template.addAll(templateDisTitle);

    return Container(
      color: Colors.grey,
      child: DropdownButton(
          isExpanded: true,
          value: dropDownValue,
          icon: const Icon(
            Icons.keyboard_arrow_down,
            color: Colors.black,
          ),
          items: template.map((String items) {
            return DropdownMenuItem(
              value: items,
              child: Text(
                items,
                style: TextStyle(fontSize: 13),
              ),
            );
          }).toList(),
          onChanged: (dynamic newValue) {
            setState(() {
              DispositionController.dispositionController.text =
                  templateDisMessage[templateDisTitle.indexOf(newValue)];
              dropDownValue = newValue.toString();
            });
          }),
    );
  }
}
