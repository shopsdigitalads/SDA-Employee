import 'package:flutter/material.dart';
import 'package:sdaemployee/Widgets/Dialog.dart';
import 'package:sdaemployee/Widgets/ErrorContainer.dart';

class Inputfield {
  Widget textFieldInput(
      {required BuildContext context,
      required TextEditingController controller,
      required String labelText,
      required String hintText,
      required IconData prefixIcon,
      required TextInputType keyboardType,
      bool enabled = true}) {
    try {
      return TextFormField(
        enabled: enabled,
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: labelText,
          hintText: hintText,
          prefixIcon: Icon(prefixIcon),
          fillColor: Colors.grey.shade100,
          filled: true,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
        ),
      );
    } catch (e) {
      DialogClass().showCustomDialog(
          context: context,
          icon: Icons.error,
          title: "Error",
          message: "Something Went Wrong");
       return ErrorContainer(errorMessage: 'An unexpected error occurred. Please try again.');
    }
  }

  Widget buildDropdownField({
    required BuildContext context,
    required dynamic selectedValue,
    required String value,
    required String name,
    required List<dynamic> items,
    required String labelText,
    required void Function(String?) onChanged,
    Color fillColor = const Color.fromARGB(255, 238, 238, 238),
    Color textColor = Colors.black,
    Color dropdownColor = Colors.white,
  }) {
    try {
      return DropdownButtonFormField<String>(
        value: selectedValue,
        items: items.map<DropdownMenuItem<String>>((item) {
          return DropdownMenuItem<String>(
              value: item[value].toString(),
              child: Container(
                child: Text(
                  item[name] ?? '',
                  style: TextStyle(color: textColor),
                ),
              ));
        }).toList(),
        onChanged: onChanged,
        decoration: InputDecoration(
          fillColor: fillColor,
          filled: true, // Ensures the background is filled
          labelText: labelText,
          labelStyle: TextStyle(color: textColor),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
        ),
        dropdownColor: dropdownColor,
        style: TextStyle(color: textColor),
      );
    } catch (e) {
      DialogClass().showCustomDialog(
          context: context,
          icon: Icons.error,
          title: "Error",
          message: "Something Went Wrong");
       return ErrorContainer(errorMessage: 'An unexpected error occurred. Please try again.');
    }
  }

  Widget buildDropdownFieldForAddress({
    required BuildContext context,
    required dynamic selectedValue,
    required List<dynamic> items, // List of dropdown options
    required String labelText,
    required void Function(String?) onChanged,
    Color fillColor = const Color.fromARGB(255, 238, 238, 238),
    Color textColor = Colors.black,
    Color dropdownColor = Colors.white,
  }) {
    try {
      return DropdownButtonFormField<String>(
        value: selectedValue, // Selected value must match one of the items
        items: items.map<DropdownMenuItem<String>>((item) {
          return DropdownMenuItem<String>(
            value: item, // Assign each item's value
            child: Text(
              item,
              style: TextStyle(color: textColor),
            ),
          );
        }).toList(),
        onChanged: onChanged,
        decoration: InputDecoration(
          fillColor: fillColor,
          filled: true, // Ensures the background is filled
          labelText: labelText,
          labelStyle: TextStyle(color: textColor),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
        ),
        dropdownColor: dropdownColor,
        style: TextStyle(color: textColor),
      );
    } catch (e) {
      DialogClass().showCustomDialog(
          context: context,
          icon: Icons.error,
          title: "Error",
          message: "Something Went Wrong");
       return ErrorContainer(errorMessage: 'An unexpected error occurred. Please try again.');
    }
  }

  Widget datePickerInput({
    required BuildContext context,
    required TextEditingController controller,
    required String labelText,
    required String hintText,
    required IconData prefixIcon,
    bool enabled = true,
  }) {
    try {
      return TextFormField(
        enabled: enabled,
        controller: controller,
        readOnly: true, // Prevent manual input
        decoration: InputDecoration(
          labelText: labelText,
          hintText: hintText,
          prefixIcon: Icon(prefixIcon),
          fillColor: Colors.grey.shade100,
          filled: true,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
        ),
        onTap: enabled
            ? () async {
                DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime.now(), // Start date
                  lastDate:DateTime.now().add(Duration(days: 365)), // End date
                );

                if (pickedDate != null) {
                  controller.text = "${pickedDate.toLocal()}".split(' ')[0];
                }
              }
            : null,
      );
    } catch (e) {
      DialogClass().showCustomDialog(
          context: context,
          icon: Icons.error,
          title: "Error",
          message: "Something Went Wrong");
      return ErrorContainer(errorMessage: 'An unexpected error occurred. Please try again.');
    }
  }
}
