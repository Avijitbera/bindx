import 'package:bindx/bindx.dart';

part 'form_store.bindx.dart';

/// Form store demonstrating validation and streaming
class FormStore with StategenMixin {
  String _username = '';
  String _email = '';
  String _password = '';
  String _website = '';
  int _age = 0;

  String get username => _username;
  String get email => _email;
  String get password => _password;
  String get website => _website;
  int get age => _age;

  // Streamed form fields for reactive UI
  @Streamed(broadcast: true)
  String get usernameStream => _username;

  @Streamed(broadcast: true)
  String get emailStream => _email;

  @Streamed(broadcast: true)
  String get passwordStream => _password;

  // Validated setters
  @Validate([Validator.notEmpty])
  void setUsername(String value) {
    _username = value;
  }

  @Validate([Validator.notEmpty, Validator.email])
  void setEmailValidated(String value) {
    _email = value;
  }

  @Validate([Validator.notEmpty, Validator.minLength])
  void setPassword(String value) {
    _password = value;
  }

  @Validate([Validator.url])
  void setWebsite(String value) {
    _website = value;
  }

  @Validate([Validator.minValue])
  void setAge(int value) {
    _age = value;
  }

  // Cached form validation
  @Cache(key: 'formValid', duration: Duration(seconds: 1))
  bool get isFormValid {
    return _username.isNotEmpty &&
        _email.isNotEmpty &&
        _password.isNotEmpty &&
        _age > 0;
  }

  // Submit with debouncing to prevent multiple submissions
  @Concurrent(
    maxConcurrent: 1,
    debounce: true,
    debounceDuration: Duration(seconds: 1),
  )
  Future<bool> submitForm() async {
    await Future.delayed(Duration(seconds: 2)); // Simulate API call
    return true;
  }

  // Reset form
  void reset() {
    _username = '';
    _email = '';
    _password = '';
    _website = '';
    _age = 0;
  }
}
