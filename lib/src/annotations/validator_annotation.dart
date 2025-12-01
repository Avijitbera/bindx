import 'package:meta/meta.dart';

@immutable
class Validate {
  final List<Validator> validators;

  const Validate(this.validators);
}

enum Validator {
  notEmpty,
  email,
  url,
  minLength,
  maxLenght,
  minValue,
  maxValue,
  pattern,
}

class ValidationConfig {
  final bool immediate;
  final String? errorMessage;

  const ValidationConfig({this.immediate = false, this.errorMessage});
}
