import 'package:flutter/material.dart';

class Buttons {
  Widget submitButton({
  required VoidCallback onPressed,
  required bool isLoading,
  String buttonText = "Submit",
  bool disable = false,
}) {
  return SizedBox(
    width: double.infinity,
    child: ElevatedButton(
      onPressed: (disable || isLoading) ? null : onPressed, // disable or loading check
      child: isLoading
          ? CircularProgressIndicator(
              color: Colors.white,
            )
          : Text(
              buttonText,
              style: TextStyle(color: Colors.white),
            ),
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.symmetric(vertical: 18.0),
        backgroundColor: Colors.black,
        disabledBackgroundColor: Colors.grey, // optional: set color when disabled
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
      ),
    ),
  );
}


  Widget buildListTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required Color color,
  }) {
    return Container(
        margin: const EdgeInsets.symmetric(vertical: 8.0),
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              blurRadius: 8,
              spreadRadius: 1,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: Colors.blueAccent.withOpacity(0.1),
            child: Icon(icon, color: color),
          ),
          title: Text(title),
          subtitle: Text(subtitle),
          trailing:
              const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          onTap: onTap,
        ));
  }

  Widget updateButton({
    String buttonText = "Update",
    required VoidCallback onPressed,
  }) {
    return Center(
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 12,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          backgroundColor: Colors.teal, // Button color
        ),
        child: Text(
          buttonText,
          style: TextStyle(fontSize: 16, color: Colors.white),
        ),
      ),
    );
  }

  Widget actionButton({
  IconData? icon,
  required String title,
  required Color color,
  required VoidCallback onPressed,
}) {
  return icon != null
      ? ElevatedButton.icon(
          onPressed: onPressed,
          icon: Icon(icon, size: 18),
          label: Text(title),
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        )
      : ElevatedButton(
          onPressed: onPressed,
          child: Text(title),
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
}

}
