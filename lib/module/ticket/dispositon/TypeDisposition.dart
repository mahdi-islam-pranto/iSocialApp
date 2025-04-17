import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:isocial/module/ticket/dispositon/LabelDisposition.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'DispositonController.dart';

class TypeDisposition extends StatefulWidget {
  const TypeDisposition({Key? key}) : super(key: key);

  @override
  State<TypeDisposition> createState() => _TypeDispositionState();
}

class _TypeDispositionState extends State<TypeDisposition> {
  @override
  void initState() {
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
            const SizedBox(width: 10),
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
        const SizedBox(height: 10),
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
            const SizedBox(width: 10),
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
        const SizedBox(height: 10),
      ],
    );
  }

  /* ------------------ Type Disposition ------------------ */
  List<String> typeDisID = [];
  List<String> typeDisType = [];
  String? typeDropDownValue = " --Type--";
  bool isTypeDisLoading = false;

  void fetchTypeDispositionData() async {
    setState(() {
      isTypeDisLoading = true;
    });

    try {
      SharedPreferences sharedPreferences =
          await SharedPreferences.getInstance();
      String token = sharedPreferences.getString("token") ?? "";
      String authorizedBy = sharedPreferences.getString("authorized_by") ?? "";

      String url =
          'https://omni.ihelpbd.com/ihelpbd_social_development/api/v1/type.php';
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
          for (var item in items) {
            typeDisID.add(item["id"]);
            typeDisType.add(item["type"]);
          }
          isTypeDisLoading = false;
        });
      } else {
        _addDefaultTypeValues();
      }
    } catch (e) {
      _addDefaultTypeValues();
    }
  }

  void _addDefaultTypeValues() {
    setState(() {
      typeDisID = ["id"];
      typeDisType = ["data not found"];
      isTypeDisLoading = false;
    });
  }

  Widget getTypeDisposition() {
    if (isTypeDisLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    var template = [" --Type--"];
    template.addAll(typeDisType);

    return DropdownButton(
      isExpanded: true,
      value: typeDropDownValue,
      icon: const Icon(Icons.keyboard_arrow_down),
      items: template.map((String item) {
        return DropdownMenuItem(
            value: item,
            child: Text(item, style: const TextStyle(fontSize: 13)));
      }).toList(),
      onChanged: (newValue) {
        categoryName.clear();
        categoryID.clear();
        isCategoryDisLoading = true;

        setState(() {
          String typeID = typeDisID[typeDisType.indexOf(newValue!)];
          fetchCategoryDispositionData(typeID);
          DispositionController.dispositionType = typeID;
          typeDropDownValue = newValue;
        });
      },
    );
  }

  /* ------------------ Category Disposition ------------------ */
  List<String> categoryID = [];
  List<String> categoryName = [];
  String? categoryDropDownValue = " --Category--";
  bool isCategoryDisLoading = false;

  void fetchCategoryDispositionData(String id) async {
    setState(() {
      isCategoryDisLoading = true;
    });

    try {
      SharedPreferences sharedPreferences =
          await SharedPreferences.getInstance();
      String token = sharedPreferences.getString("token") ?? "";
      String authorizedBy = sharedPreferences.getString("authorized_by") ?? "";

      String url =
          'https://omni.ihelpbd.com/ihelpbd_social_development/api/v1/category.php';
      Map<String, dynamic> body = {
        "authorized_by": authorizedBy,
        "type_id": id,
      };
      print("category body>>${body}");

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
          for (var item in items) {
            categoryID.add(item["id"]);
            categoryName.add(item["name"]);
          }
          isCategoryDisLoading = false;
        });
      } else {
        _addDefaultCategoryValues();
      }
    } catch (e) {
      _addDefaultCategoryValues();
    }
  }

  void _addDefaultCategoryValues() {
    setState(() {
      categoryID = ["id"];
      categoryName = ["data not found"];
      isCategoryDisLoading = false;
    });
  }

  Widget getCategoryDisposition() {
    if (isCategoryDisLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    var template = [" --Category--"];
    template.addAll(categoryName);

    return DropdownButton(
      isExpanded: true,
      value: categoryDropDownValue,
      icon: const Icon(Icons.keyboard_arrow_down),
      items: template.map((String item) {
        return DropdownMenuItem(
            value: item,
            child: Text(item, style: const TextStyle(fontSize: 13)));
      }).toList(),
      onChanged: (newValue) {
        subCategoryID.clear();
        subCategoryTitle.clear();
        isSubCategoryDisLoading = true;

        setState(() {
          String catID = categoryID[categoryName.indexOf(newValue!)];
          fetchSubCategoryDispositionData(catID);
          DispositionController.dispositionCat = catID;
          categoryDropDownValue = newValue;
        });
      },
    );
  }

  /* ------------------ SubCategory Disposition ------------------ */
  List<String> subCategoryID = [];
  List<String> subCategoryTitle = [];
  String? subCategoryDropDownValue = " --Subcategory--";
  bool isSubCategoryDisLoading = false;

  void fetchSubCategoryDispositionData(String catId) async {
    setState(() {
      isSubCategoryDisLoading = true;
    });

    try {
      SharedPreferences sharedPreferences =
          await SharedPreferences.getInstance();
      String token = sharedPreferences.getString("token") ?? "";
      String authorizedBy = sharedPreferences.getString("authorized_by") ?? "";

      String url =
          'https://omni.ihelpbd.com/ihelpbd_social_development/api/v1/sub_category.php';
      Map<String, dynamic> body = {
        "authorized_by": authorizedBy,
        "category_id": catId,
      };
      print("subcategory body>>${body}");

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
          for (var item in items) {
            subCategoryID.add(item["id"]);
            subCategoryTitle.add(item["title"]);
          }
          isSubCategoryDisLoading = false;
        });
      } else {
        _addDefaultSubCategoryValues();
      }
    } catch (e) {
      _addDefaultSubCategoryValues();
    }
  }

  void _addDefaultSubCategoryValues() {
    setState(() {
      subCategoryID = ["id"];
      subCategoryTitle = ["data not found"];
      isSubCategoryDisLoading = false;
    });
  }

  Widget getSubCategoryDisposition() {
    if (isSubCategoryDisLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    var template = [" --Subcategory--"];
    template.addAll(subCategoryTitle);

    return DropdownButton(
      isExpanded: true,
      value: subCategoryDropDownValue,
      icon: const Icon(Icons.keyboard_arrow_down),
      items: template.map((String item) {
        return DropdownMenuItem(
            value: item,
            child: Text(item, style: const TextStyle(fontSize: 13)));
      }).toList(),
      onChanged: (newValue) {
        setState(() {
          String subCatId = subCategoryID[subCategoryTitle.indexOf(newValue!)];
          DispositionController.dispositionSubCat = subCatId;
          subCategoryDropDownValue = newValue;
        });
      },
    );
  }
}
