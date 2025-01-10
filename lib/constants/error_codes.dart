// A static map collection of error codes and their descriptions with user-friendly messages.
const Map<String, dynamic> errorMessages = {
  "invalid_credentials": {
    "message": "Invalid credentials provided.",
    "user_friendly_message":
        "The username or password you entered is incorrect. Please try again."
  },
  "user_not_found": {
    "message": "User not found.",
    "user_friendly_message":
        "We couldn't find a user with that email. Please check and try again."
  },
  "email_already_in_use": {
    "message": "Email already in use.",
    "user_friendly_message":
        "This email is already associated with an account. Please use a different email."
  },
  "weak_password": {
    "message": "Weak password provided.",
    "user_friendly_message":
        "Your password is too weak. Please choose a stronger password."
  },
  "network_error": {
    "message": "Network error occurred.",
    "user_friendly_message":
        "There was a problem connecting to the network. Please check your internet connection."
  },
  "server_error": {
    "message": "Server error occurred.",
    "user_friendly_message":
        "We're experiencing some issues on our end. Please try again later."
  },
  "content_moderation": {
    "message": "Content moderation failed.",
    "user_friendly_message":
        "The content you are trying to post does not meet our community guidelines."
  },
};
