// Enum of Error codes
class ErrorCodes {
  static String invalidToken = "invalid_token";
  static String contentModeration = "content_moderation";
}

class ErrorMessage {
  String message;
  String userFriendlyMessage;

  ErrorMessage({required this.message, required this.userFriendlyMessage});
}

// A static map collection of error codes and their descriptions with user-friendly messages.
Map<String, dynamic> errorMessages = {
  "invalid_credentials": ErrorMessage(
      message: "Invalid credentials provided.",
      userFriendlyMessage:
          "The email or password you entered is incorrect. Please try again."),
  "invalid_token": ErrorMessage(
      message: "Invalid token detected.",
      userFriendlyMessage:
          "Your session has expired. Please log in again to continue."),
  "content_moderation": ErrorMessage(
      message: "Content moderation failed.",
      userFriendlyMessage:
          "The content you are trying to post has been flagged as inappropriate."),
};
