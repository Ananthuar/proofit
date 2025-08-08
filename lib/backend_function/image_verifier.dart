import 'dart:io';

class ImageVerifier {
  // Simple logic: check if description contains keywords and image filename contains similar keywords
  static bool verify(String description, String imagePath) {
    final lowerDesc = description.toLowerCase();
    final fileName = File(imagePath).uri.pathSegments.last.toLowerCase();

    // Example keywords for electricity bill
    final billKeywords = ['bill', 'electricity', 'receipt', 'transaction', 'payment'];

    // If description contains 'electricity' or 'bill', image filename must contain one of the keywords
    if (billKeywords.any((kw) => lowerDesc.contains(kw))) {
      return billKeywords.any((kw) => fileName.contains(kw));
    }

    // Add more rules for other types of tasks if needed

    // Default: just check image exists and is not empty
    return File(imagePath).existsSync();
  }
}