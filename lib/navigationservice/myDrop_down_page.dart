import 'package:flutter/material.dart';

class MyDropDownPage extends StatefulWidget {
  const MyDropDownPage({Key? key}) : super(key: key);

  @override
  State<MyDropDownPage> createState() => _MyDropDownPageState();
}

class _MyDropDownPageState extends State<MyDropDownPage> {
  List<String> templateDisTitle = [];
  List<String> templateDisMessage = [];
  bool isLoading = false;
  String dropDownValue = " --Template--";
  String selectedValue = 'Select an option';
  List<String> dropdownValues = [
    'Login',
    'Prayer',
    'Lunch Break',
    'Short Break',
    'Office Time Over',
    'Meeting',
    'Available',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(


      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            DropdownButton<String>(
              value: selectedValue,
              onChanged: (newValue) {
                setState(() {
                  selectedValue = newValue!;
                  // Perform API call or any other action based on the selected value
                  // You can add your API call logic here
                  // Example: _callApi(selectedValue);
                });
              },
              items: dropdownValues.map((value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            SizedBox(height: 20),
            Text(
              'Selected Value: $selectedValue',
              style: TextStyle(fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }

  // Example function for API call
  void _callApi(String selectedValue) {
    // Add your API call logic here
    print('API call triggered for: $selectedValue');

  }
}
