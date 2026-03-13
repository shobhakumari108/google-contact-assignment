class Validators {
  static String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Name is required';
    }
    if (value.trim().length < 2) {
      return 'Name must be at least 2 characters';
    }
    if (value.trim().length > 50) {
      return 'Name cannot exceed 50 characters';
    }
    return null;
  }

  static String? validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Phone number is required';
    }
    
    final phoneRegex = RegExp(r'^[\d\s\-\+\(\)]+$');
    if (!phoneRegex.hasMatch(value.trim())) {
      return 'Please enter a valid phone number';
    }
    
    final digitsOnly = value.replaceAll(RegExp(r'[^\d]'), '');
    if (digitsOnly.length < 10) {
      return 'Phone number must have at least 10 digits';
    }
    if (digitsOnly.length > 15) {
      return 'Phone number cannot exceed 15 digits';
    }
    
    return null;
  }

  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // Email is optional
    }
    
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'
    );
    
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Please enter a valid email address';
    }
    
    if (value.trim().length > 100) {
      return 'Email cannot exceed 100 characters';
    }
    
    return null;
  }

  static String? validateAddress(String? value) {
    if (value != null && value.trim().length > 200) {
      return 'Address cannot exceed 200 characters';
    }
    return null;
  }

  static String? validateCompany(String? value) {
    if (value != null && value.trim().length > 100) {
      return 'Company name cannot exceed 100 characters';
    }
    return null;
  }

  static String? validateNotes(String? value) {
    if (value != null && value.trim().length > 500) {
      return 'Notes cannot exceed 500 characters';
    }
    return null;
  }
}
