import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'DispositonController.dart';
import 'LabelDisposition.dart';

/*
  Activity name : Type disposition
  Project name : iHelpBD CRM
  Auth : Eng. Sk Nayeem Ur Rahman & pranto
  Designation : Full Stack Software Developer
  Email : nayeemdeveloperbd@gmail.com
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

  // /Type Disposition/

  List<String> typeDisID = [];
  List<String> typeDisType = [];
  String? typeDropDownValue = " --Type--";
  bool isTypeDisLoading = false;

  //Fetch type disposition data
  void fetchTypeDispositionData() async {
    setState(() {
      isTypeDisLoading = true;
    });

    //Show progress dialog
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

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
          isTypeDisLoading = true;
        }
      });
    } else {
      typeDisID = [];
      typeDisType = [];
      isTypeDisLoading = false;
    }
  }

  //Show Type dropdown disposition
  Widget getTypeDisposition() {
    // if (typeDisType.contains(null) || typeDisID.contains(null) || isTypeDisLoading) {
    //   return const Center(
    //       child: CircularProgressIndicator(
    //         valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
    //       ));
    // }

    if (isTypeDisLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
        ),
      );
    } else if (typeDisType.contains(null) || typeDisID.contains(null)) {
      return const Center(
        child: Text(
          'data not found',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey,
            fontWeight: FontWeight.w500,
          ),
        ),
      );
    }

    try {
      // List of items in our dropdown menu
      var template = [" --Type--"];

      //Add template title
      template.addAll(typeDisType);

      return DropdownButton(
          underline: SizedBox(),
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
      return const Text("data not found");
    }
  }

  // /Category Disposition/

  List<String> categoryID = [];
  List<String> categoryName = [];
  String? categoryDropDownValue = " --Category--";
  bool isCategoryDisLoading = false;

  //Fetch category disposition data
  void fetchCategoryDispositionData(String id) async {
    setState(() {
      isCategoryDisLoading = true;
      categoryID.clear();
      categoryName.clear();
      categoryDropDownValue = " --Category--";
    });

    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String token = sharedPreferences.getString("token").toString();
    String authorizedBy =
        sharedPreferences.getString("authorized_by").toString();

    String url =
        'https://omni.ihelpbd.com/ihelpbd_social_development/api/v1/category.php';

    Map<String, dynamic> body = {
      "authorized_by": authorizedBy,
      "type_id": id,
    };

    HttpClient httpClient = HttpClient();
    HttpClientRequest request = await httpClient.postUrl(Uri.parse(url));
    request.headers.set('content-type', 'application/json');
    request.headers.set('token', token);
    request.add(utf8.encode(json.encode(body)));

    HttpClientResponse response = await request.close();
    String reply = await response.transform(utf8.decoder).join();
    httpClient.close();

    setState(() {
      if (response.statusCode == 200) {
        final decoded = json.decode(reply);
        final items = decoded["data"];

        if (items is List) {
          for (int index = 0; index < items.length; index++) {
            categoryID.add(items[index]["id"]);
            categoryName.add(items[index]["name"]);
          }
        } else {
          // If "data" is not a list (like "No data found")
          categoryID = [];
          categoryName = [];
        }
      } else {
        categoryID = [];
        categoryName = [];
      }

      isCategoryDisLoading = false;
    });
  }

  //Show Category dropdown disposition
  Widget getCategoryDisposition() {
    if (isCategoryDisLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
        ),
      );
    }

    List<String> dropdownItems = [" --Category--"];
    dropdownItems.addAll(categoryName);

    return DropdownButton(
      isExpanded: true,
      underline: const SizedBox(),
      value: categoryDropDownValue,
      icon: const Icon(Icons.keyboard_arrow_down),
      items: dropdownItems.map((String item) {
        return DropdownMenuItem(
          value: item,
          child: Text(item, style: const TextStyle(fontSize: 13)),
        );
      }).toList(),
      onChanged: (dynamic newValue) {
        if (newValue == " --Category--") {
          // Default value, don't do anything
          return;
        }

        setState(() {
          subCategoryID.clear();
          subCategoryTitle.clear();
          isSubCategoryDisLoading = true;

          int index = categoryName.indexOf(newValue);
          if (index != -1) {
            String dispositionCat = categoryID[index];
            fetchSubCategoryDispositionData(dispositionCat);
            DispositionController.dispositionCat = dispositionCat;
          } else {
            DispositionController.dispositionCat = "";
          }

          categoryDropDownValue = newValue;
        });
      },
    );
  }

  // /Sub Category Disposition/

  List<String> subCategoryID = [];
  List<String> subCategoryTitle = [];
  String? subCategoryDropDownValue = " --Sub Category--";
  bool isSubCategoryDisLoading = false;

  //Fetch type disposition data
  void fetchSubCategoryDispositionData(String catId) async {
    setState(() {
      isSubCategoryDisLoading = true;
      subCategoryID.clear();
      subCategoryTitle.clear();
      subCategoryDropDownValue = " --Sub Category--";
    });

    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

    String token = sharedPreferences.getString("token").toString();
    String authorizedBy =
        sharedPreferences.getString("authorized_by").toString();

    String url =
        'https://omni.ihelpbd.com/ihelpbd_social_development/api/v1/sub_category.php';

    Map<String, dynamic> body = {
      "authorized_by": authorizedBy,
      "cat_id": catId,
    };

    HttpClient httpClient = HttpClient();
    HttpClientRequest request = await httpClient.postUrl(Uri.parse(url));
    request.headers.set('content-type', 'application/json');
    request.headers.set('token', token);
    request.add(utf8.encode(json.encode(body)));

    HttpClientResponse response = await request.close();
    String reply = await response.transform(utf8.decoder).join();
    httpClient.close();

    setState(() {
      isSubCategoryDisLoading = false;
    });

    if (response.statusCode == 200) {
      final decoded = json.decode(reply);

      if (decoded["status"] == "200" && decoded["data"] is List) {
        final items = decoded["data"];
        for (var item in items) {
          subCategoryID.add(item["id"]);
          subCategoryTitle.add(item["sub_cat"]);
        }
      } else {
        // No data found or not a list
        subCategoryID.clear();
        subCategoryTitle.clear();
      }
    } else {
      // Error case
      subCategoryID.clear();
      subCategoryTitle.clear();
    }
  }

  //Show Type dropdown disposition
  Widget getSubCategoryDisposition() {
    if (isSubCategoryDisLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
        ),
      );
    }

    // Initial option
    List<String> dropdownOptions = [" --Sub Category--"];
    dropdownOptions.addAll(subCategoryTitle); // Only adds if data exists

    return DropdownButton(
      isExpanded: true,
      underline: const SizedBox(),
      value: subCategoryDropDownValue,
      icon: const Icon(Icons.keyboard_arrow_down),
      items: dropdownOptions.map((String item) {
        return DropdownMenuItem(
          value: item,
          child: Text(item, style: const TextStyle(fontSize: 13)),
        );
      }).toList(),
      onChanged: (dynamic newValue) {
        setState(() {
          subCategoryDropDownValue = newValue;

          int index = subCategoryTitle.indexOf(newValue);
          if (index != -1) {
            DispositionController.dispositionSubCat = subCategoryID[index];
          } else {
            DispositionController.dispositionSubCat = "";
          }
        });
      },
    );
  }
}
