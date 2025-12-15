class EmailNotConfirmedException implements Exception {
  final String message;
  final String email;

  EmailNotConfirmedException(this.message, this.email);
}
