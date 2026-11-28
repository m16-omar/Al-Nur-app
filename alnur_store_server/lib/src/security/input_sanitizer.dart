import 'dart:convert';

/// Input cleaning shared by all endpoints.
///
/// Free-text fields from customers (names, addresses, bios…) never need HTML,
/// so markup characters are stripped before they are stored. That keeps
/// stored-XSS payloads out of the admin panels and outgoing emails even if a
/// screen forgets to escape something.
class InputSanitizer {
  InputSanitizer._();

  static final RegExp _control = RegExp(r'[\u0000-\u0008\u000B\u000C\u000E-\u001F\u007F]');
  static final RegExp _markup = RegExp(r'[<>`]');
  static final RegExp _email = RegExp(r'^[^@\s<>"]+@[^@\s<>"]+\.[^@\s<>"]+$');

  /// Trims, removes control characters and HTML markup characters, and
  /// clips to [maxLength]. Newlines are kept only when [multiline] is true.
  static String text(String? value, {int maxLength = 200, bool multiline = false}) {
    var v = (value ?? '').replaceAll(_control, '').replaceAll(_markup, '');
    v = v.replaceAll('"', "'");
    if (!multiline) v = v.replaceAll(RegExp(r'[\r\n\t]+'), ' ');
    v = v.trim();
    return v.length <= maxLength ? v : v.substring(0, maxLength);
  }

  /// Like [text] but returns null for empty input.
  static String? optionalText(String? value, {int maxLength = 200, bool multiline = false}) {
    if (value == null) return null;
    final v = text(value, maxLength: maxLength, multiline: multiline);
    return v.isEmpty ? null : v;
  }

  /// Lower-cased, trimmed email. Returns '' if it is not a plausible address.
  static String email(String? value) {
    final v = (value ?? '').trim().toLowerCase();
    if (v.length > 254 || !_email.hasMatch(v)) return '';
    return v;
  }

  static bool isEmail(String? value) => email(value).isNotEmpty;

  /// Phone numbers: digits, spaces and + ( ) - only.
  static String phone(String? value) {
    final v = (value ?? '').replaceAll(RegExp(r'[^0-9+()\-\s]'), '').trim();
    return v.length <= 32 ? v : v.substring(0, 32);
  }

  /// Accepts only absolute http(s) URLs (blocks `javascript:` / `data:`).
  /// Returns null when the value is empty or unsafe.
  static String? url(String? value, {int maxLength = 2048}) {
    final v = (value ?? '').trim();
    if (v.isEmpty || v.length > maxLength) return null;
    final uri = Uri.tryParse(v);
    if (uri == null || !uri.hasAuthority) return null;
    if (uri.scheme != 'https' && uri.scheme != 'http') return null;
    if (v.contains(RegExp(r'[<>"`\s]'))) return null;
    return v;
  }

  /// Like [url] but also allows `data:image/...` URIs (inline previews).
  static String? imageUrl(String? value) {
    final v = (value ?? '').trim();
    if (v.startsWith('data:image/') && !v.contains(RegExp(r'[<>"`]'))) return v;
    return url(v);
  }

  /// Escapes text for safe use inside HTML (emails).
  static String html(String? value) => const HtmlEscape().convert(value ?? '');
}
