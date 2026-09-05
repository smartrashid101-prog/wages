class EmployeeValidator {
  static String? validateName(String value) {
    if (value.isEmpty) {
      return 'Name is required';
    }
    if (value.length < 2) {
      return 'Name must be at least 2 characters';
    }
    if (value.length > 50) {
      return 'Name must be less than 50 characters';
    }
    return null;
  }
  
  static String? validateRate(int cents) {
    if (cents < 0) {
      return 'Rate cannot be negative';
    }
    if (cents > 1000000) {
      return 'Rate cannot exceed £10,000';
    }
    return null;
  }
  
  static String? validateOvertimeMultiplier(double multiplier) {
    if (multiplier < 0) {
      return 'Multiplier cannot be negative';
    }
    if (multiplier > 10) {
      return 'Multiplier cannot exceed 10';
    }
    return null;
  }
}