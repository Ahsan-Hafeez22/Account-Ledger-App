extension StringExtensions on String {
  String get capitalize =>
      isEmpty ? this : '${this[0].toUpperCase()}${substring(1)}';

  String get initials => split(' ')
      .where((w) => w.isNotEmpty)
      .take(2)
      .map((w) => w[0].toUpperCase())
      .join();

  bool get isValidEmail =>
      RegExp(r'^[\w\.-]+@([\w-]+\.)+[\w-]{2,}$').hasMatch(this);

  String truncate(int maxLength) =>
      length <= maxLength ? this : '${substring(0, maxLength)}...';
}


/*
String name = "ahsan";
print(name.capitalize); // Ahsan

String fullName = "Ahsan Hafeez";
print(fullName.initials); // AH

String email = "test@gmail.com";

if (email.isValidEmail) {
  print("Valid email");
} else {
  print("Invalid email");
}

*/