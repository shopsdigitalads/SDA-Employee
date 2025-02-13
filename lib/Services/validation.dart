class Validation {
  // Function to validate email addresses
  bool validateEmail(String? email) {
    if (isEmpty(email)) return false; // Check for empty or null
    final RegExp emailRegex = RegExp(
      r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$"
    );
    return emailRegex.hasMatch(email!);
  }

  // Function to validate mobile numbers (10 digits)
  bool validateMobile(String? mobile) {
    if (isEmpty(mobile)) return false; // Check for empty or null
    final RegExp mobileRegex = RegExp(r"^[6-9]\d{9}$");
    return mobileRegex.hasMatch(mobile!);
  }

  // Function to validate Aadhaar numbers (12 digits)
  bool validateAadhaar(String? aadhaar) {
    if (isEmpty(aadhaar)) return false; // Check for empty or null
    final RegExp aadhaarRegex = RegExp(r"^\d{12}$");
    return aadhaarRegex.hasMatch(aadhaar!);
  }

  // Function to validate PAN card numbers (Format: 5 letters, 4 digits, 1 letter)
  bool validatePAN(String? pan) {
    if (isEmpty(pan)) return false; // Check for empty or null
    final RegExp panRegex = RegExp(r"^[A-Z]{5}[0-9]{4}[A-Z]{1}$");
    return panRegex.hasMatch(pan!);
  }

  // Function to check if a value is empty or null
  bool isEmpty(String? value) {
    return value == null || value.trim().isEmpty;
  }
}
