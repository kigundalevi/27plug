String? validatePassword(String? value) {
  String pattern = r'^(?=.*?[a-z])(?=.*?[0-9]).{8,}$';
  RegExp regex = new RegExp(pattern);
  if (value.toString().length == 0) {
    return "Password is Required";
  } else if (!regex.hasMatch(value.toString()))
    return 'Letter, number and at least 8 characterss';
  else
    return null;
}

String? validateEmail(String? value) {
  String pattern =
      r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
  RegExp regex = new RegExp(pattern);
  if (value.toString().length == 0) {
    return "Email is Required";
  } else if (!regex.hasMatch(value.toString())) {
    return 'Enter Valid Email';
  } else {
    return null;
  }
}

String? validateRegisterFirstName(String? value) {
  if (value.toString().length == 0) {
    return "Firstname is Required";
  } else {
    return null;
  }
}

String? validateRegisterLastName(String? value) {
  if (value.toString().length == 0) {
    return "Lastname is Required";
  } else {
    return null;
  }
}

String? validateRegisterEmail(String? value) {
  String pattern =
      r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
  RegExp regex = new RegExp(pattern);
  if (value.toString().length == 0) {
    return "Email is Required";
  } else if (!regex.hasMatch(value.toString())) {
    return 'Enter Valid Email';
  } else {
    return null;
  }
}

String? validateRegisterPhone(String? value) {
  String pattern = r'[0-9]{9}';
  RegExp regex = new RegExp(pattern);
  if (value.toString().length == 0) {
    return "Phone numbner is Required";
  } else if (!regex.hasMatch(value.toString())) {
    return 'Invalid Phone number';
  } else {
    return null;
  }
}

String? validateRegisterPassword(String? value) {
  String pattern = r'^(?=.*?[a-z])(?=.*?[0-9]).{8,}$';
  RegExp regex = new RegExp(pattern);
  if (value.toString().length == 0) {
    return "Password is Required";
  } else if (!regex.hasMatch(value.toString()))
    return 'Letter, number and at least 8 characterss';
  else
    return null;
}

String? validateRegisterPasswordConfirmation(String? value) {
  if (value.toString().length == 0) {
    return "Password Confirmation is required";
  } else {
    return null;
  }
}
