String? validateVideoTitle(String? value) {
  if (value.toString().length == 0) {
    return "Video title is required";
  } else {
    return null;
  }
}

String? validateVideoDescription(String? value) {
  if (value.toString().length == 0) {
    return "Video description is required";
  } else {
    return null;
  }
}

String? validateVideoThumbNail(bool value) {
  if (!value) {
    return "Video thumbnail is required";
  } else {
    return null;
  }
}
