import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:isocial/module/ticket/dispositon/LabelDisposition.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'DispositonController.dart';

/*
  Activity name : Type disposition
  Project name : iHelpBD CRM
  Auth : Eng. Mazedul Islam
  Designation : Full Stack Software Developer
  Email : mazedulislam4970@gmail.com
*/

class TypeDisposition extends StatefulWidget {
  const TypeDisposition({Key? key}) : super(key: key);

  @override
  State<TypeDisposition> createState() => _TypeDispositionState();
}

class _TypeDispositionState extends State<TypeDisposition> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchTypeDispositionData();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: 40,
              width: MediaQuery.of(context).size.width / 2 - 15,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black87),
                borderRadius: BorderRadius.circular(3),
              ),
              child: Center(child: getTypeDisposition()),
            ),
            const SizedBox(
              width: 10,
            ),
            Container(
              height: 40,
              width: MediaQuery.of(context).size.width / 2 - 15,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black87),
                borderRadius: BorderRadius.circular(3),
              ),
              child: Center(child: getCategoryDisposition()),
            ),
          ],
        ),
        const SizedBox(
          height: 10,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: 40,
              width: MediaQuery.of(context).size.width / 2 - 15,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black87),
                borderRadius: BorderRadius.circular(3),
              ),
              child: Center(child: getSubCategoryDisposition()),
            ),
            const SizedBox(
              width: 10,
            ),
            Container(
              height: 40,
              width: MediaQuery.of(context).size.width / 2 - 15,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black87),
                borderRadius: BorderRadius.circular(3),
              ),
              child: const Center(child: LabelDisposition()),
            ),
          ],
        ),
        const SizedBox(height: 10)
      ],
    );
  }

  /*Type Disposition*/

  List<String> typeDisID = [];
  List<String> typeDisType = [];
  String? typeDropDownValue = " --Type--";
  bool isTypeDisLoading = false;

  //Fetch type disposition data
  void fetchTypeDispositionData() async {
    setState(() {
      isTypeDisLoading = true;
    });

    try {
      //Show progress dialog
      SharedPreferences sharedPreferences =
          await SharedPreferences.getInstance();

      //Get user data from local device
      String token = sharedPreferences.getString("token").toString();
      String authorizedBy =
          sharedPreferences.getString("authorized_by").toString();

      // Api url
      String url =
          'https://omni.ihelpbd.com/ihelpbd_social_development/api/v1/type.php';

      //Request API body
      Map<String, String> body = {"authorized_by": authorizedBy};

      HttpClient httpClient = HttpClient();

      HttpClientRequest request = await httpClient.postUrl(Uri.parse(url));

      // content type
      request.headers.set('content-type', 'application/json');
      request.headers.set('token', token);

      request.add(utf8.encode(json.encode(body)));

      //Get response
      HttpClientResponse response = await request.close();
      String reply = await response.transform(utf8.decoder).join();

      // Closed request
      httpClient.close();

      if (response.statusCode == 200) {
        final items = json.decode(reply)["data"];

        setState(() {
          try {
            for (int index = 0; index < items.length; index++) {
              typeDisID.add(items[index]["id"]);
              typeDisType.add(items[index]["type"]);
            }
            isTypeDisLoading = false;
          } catch (e) {
            // Add default values if API data parsing fails
            _addDefaultTypeValues();
          }
        });
      } else {
        // Add default values if API response is not 200
        _addDefaultTypeValues();
      }
    } catch (e) {
      // Add default values if any exception occurs during API call
      _addDefaultTypeValues();
    }
  }

  // Add default type values when API fails
  void _addDefaultTypeValues() {
    setState(() {
      typeDisID = ["1", "2", "3", "4", "5"];
      typeDisType = [
        "Category1",
        "Category2",
        "Category3",
        "Category4",
        "Category5"
      ];
      isTypeDisLoading = false;
    });
  }

  //Show Type dropdown disposition
  Widget getTypeDisposition() {
    // If still loading, show progress indicator for a short time
    if (isTypeDisLoading) {
      return const Center(
          child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
      ));
    }

    // If lists are empty or contain null after loading is complete, show default dropdown
    if (typeDisType.isEmpty ||
        typeDisID.isEmpty ||
        typeDisType.contains(null) ||
        typeDisID.contains(null)) {
      _addDefaultTypeValues();
    }

    try {
      // List of items in our dropdown menu
      var template = [" --Type--"];

      //Add template title
      template.addAll(typeDisType);

      return DropdownButton(
          isExpanded: true,
          // Initial Value
          value: typeDropDownValue,
          icon: const Icon(Icons.keyboard_arrow_down),

          // Array list of items
          items: template.map((String items) {
            return DropdownMenuItem(
              value: items,
              child: Text(
                items,
                style: const TextStyle(fontSize: 13),
              ),
            );
          }).toList(),
          onChanged: (dynamic newValue) {
            categoryName.clear();
            categoryID.clear();
            isCategoryDisLoading = true;

            setState(() {
              String dispositionType =
                  typeDisID[typeDisType.indexOf(newValue)].toString();

              //Fetching Category Disposition data
              fetchCategoryDispositionData(dispositionType);

              //set disposition type value
              DispositionController.dispositionType = dispositionType;

              // Assign new dropdown value
              typeDropDownValue = newValue;
            });
          });
    } catch (e) {
      return const Text("Select Type");
    }
  }

  /*Category Disposition*/

  List<String> categoryID = [];
  List<String> categoryName = [];
  String? categoryDropDownValue = " --Category--";
  bool isCategoryDisLoading = false;

  //Fetch category disposition data
  void fetchCategoryDispositionData(String id) async {
    setState(() {
      isCategoryDisLoading = true;
    });

    try {
      //Show progress dialog
      SharedPreferences sharedPreferences =
          await SharedPreferences.getInstance();

      //Get user data from local device
      String token = sharedPreferences.getString("token").toString();
      String authorizedBy =
          sharedPreferences.getString("authorized_by").toString();

      // Api url
      String url =
          'https://omni.ihelpbd.com/ihelpbd_social/api/v1/category.php';

      //Request API body
      Map<String, dynamic> body = {
        "authorized_by": authorizedBy,
        "type_id": id,
      };

      HttpClient httpClient = HttpClient();

      HttpClientRequest request = await httpClient.postUrl(Uri.parse(url));

      // content type
      request.headers.set('content-type', 'application/json');
      request.headers.set('token', token);

      request.add(utf8.encode(json.encode(body)));

      //Get response
      HttpClientResponse response = await request.close();
      String reply = await response.transform(utf8.decoder).join();

      // Closed request
      httpClient.close();

      if (response.statusCode == 200) {
        setState(() {
          try {
            final items = json.decode(reply)["data"];
            for (int index = 0; index < items.length; index++) {
              categoryID.add(items[index]["id"]);
              categoryName.add(items[index]["name"]);
            }
            isCategoryDisLoading = false;
          } catch (e) {
            // Add default values if API data parsing fails
            _addDefaultCategoryValues();
          }
        });
      } else {
        // Add default values if API response is not 200
        _addDefaultCategoryValues();
      }
    } catch (e) {
      // Add default values if any exception occurs during API call
      _addDefaultCategoryValues();
    }
  }

  // Add default category values when API fails
  void _addDefaultCategoryValues() {
    setState(() {
      categoryID = ["1", "2", "3", "4"];
      categoryName = [
        "SubCategory1",
        "SubCategory2",
        "SubCategory3",
        "SubCategory4"
      ];
      isCategoryDisLoading = false;
    });
  }

  //Show Category dropdown disposition
  Widget getCategoryDisposition() {
    // If still loading, show progress indicator for a short time
    if (isCategoryDisLoading) {
      return const Center(
          child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
      ));
    }

    // If lists are empty or contain null after loading is complete, show default dropdown
    if (categoryName.isEmpty ||
        categoryID.isEmpty ||
        categoryName.contains(null) ||
        categoryID.contains(null)) {
      _addDefaultCategoryValues();
    }

    try {
      // List of items in our dropdown menu
      var template = [" --Category--"];

      //Add template title
      template.addAll(categoryName);

      return DropdownButton(
          isExpanded: true,

          // Initial Value
          value: categoryDropDownValue,
          icon: const Icon(Icons.keyboard_arrow_down),

          // Array list of items
          items: template.map((String items) {
            return DropdownMenuItem(
              value: items,
              child: Text(
                items,
                style: const TextStyle(fontSize: 13),
              ),
            );
          }).toList(),
          onChanged: (dynamic newValue) {
            subCategoryID.clear();
            subCategoryTitle.clear();
            isSubCategoryDisLoading = true;

            setState(() {
              String dispositionCat =
                  categoryID[categoryName.indexOf(newValue)].toString();

              //Fetching Sub category disposition data
              fetchSubCategoryDispositionData(dispositionCat);

              //Set disposition category
              DispositionController.dispositionCat = dispositionCat;

              // Assign new dropdown value
              categoryDropDownValue = newValue;
            });
          });
    } catch (e) {
      return const Text("Select Category");
    }
  }

  /*Sub Category Disposition*/

  List<String> subCategoryID = [];
  List<String> subCategoryTitle = [];
  String? subCategoryDropDownValue = " --Sub Category--";
  bool isSubCategoryDisLoading = false;

  //Fetch sub category disposition data
  void fetchSubCategoryDispositionData(String catId) async {
    setState(() {
      isSubCategoryDisLoading = true;
    });

    try {
      //Show progress dialog
      SharedPreferences sharedPreferences =
          await SharedPreferences.getInstance();

      //Get user data from local device
      String token = sharedPreferences.getString("token").toString();
      String authorizedBy =
          sharedPreferences.getString("authorized_by").toString();

      // Api url
      String url =
          'https://omni.ihelpbd.com/ihelpbd_social/api/v1/sub_category.php';

      //Request API body
      Map<String, dynamic> body = {
        "authorized_by": authorizedBy,
        "cat_id": catId,
      };

      HttpClient httpClient = HttpClient();

      HttpClientRequest request = await httpClient.postUrl(Uri.parse(url));

      // content type
      request.headers.set('content-type', 'application/json');
      request.headers.set('token', token);

      request.add(utf8.encode(json.encode(body)));

      //Get response
      HttpClientResponse response = await request.close();
      String reply = await response.transform(utf8.decoder).join();

      // Closed request
      httpClient.close();

      if (response.statusCode == 200) {
        final items = json.decode(reply)["data"];

        setState(() {
          try {
            for (int index = 0; index < items.length; index++) {
              subCategoryID.add(items[index]["id"]);
              subCategoryTitle.add(items[index]["sub_cat"]);
            }
            isSubCategoryDisLoading = false;
          } catch (e) {
            // Add default values if API data parsing fails
            _addDefaultSubCategoryValues();
          }
        });
      } else {
        // Add default values if API response is not 200
        _addDefaultSubCategoryValues();
      }
    } catch (e) {
      // Add default values if any exception occurs during API call
      _addDefaultSubCategoryValues();
    }
  }

  // Add default sub category values when API fails
  void _addDefaultSubCategoryValues() {
    setState(() {
      subCategoryID = ["1", "2", "3"];
      subCategoryTitle = ["SubItem1", "SubItem2", "SubItem3"];
      isSubCategoryDisLoading = false;
    });
  }

  //Show Sub Category dropdown disposition
  Widget getSubCategoryDisposition() {
    // If still loading, show progress indicator for a short time
    if (isSubCategoryDisLoading) {
      return const Center(
          child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
      ));
    }

    // If lists are empty or contain null after loading is complete, show default dropdown
    if (subCategoryTitle.isEmpty ||
        subCategoryID.isEmpty ||
        subCategoryTitle.contains(null) ||
        subCategoryID.contains(null)) {
      _addDefaultSubCategoryValues();
    }

    try {
      // List of items in our dropdown menu
      var template = [" --Sub Category--"];

      //Add template title
      template.addAll(subCategoryTitle);

      return DropdownButton(
          isExpanded: true,

          // Initial Value
          value: subCategoryDropDownValue,
          icon: const Icon(Icons.keyboard_arrow_down),

          // Array list of items
          items: template.map((String items) {
            return DropdownMenuItem(
              value: items,
              child: Text(
                items,
                style: const TextStyle(fontSize: 13),
              ),
            );
          }).toList(),
          onChanged: (dynamic newValue) {
            setState(() {
              String dispositionSubCat =
                  subCategoryID[subCategoryTitle.indexOf(newValue)].toString();

              //Set sub category disposition
              DispositionController.dispositionSubCat = dispositionSubCat;

              subCategoryDropDownValue = newValue;
            });
          });
    } catch (e) {
      return const Text("Select Sub Category");
    }
  }
}
