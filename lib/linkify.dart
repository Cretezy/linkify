import 'package:linkify/src/email.dart';
import 'package:linkify/src/url.dart';

export 'package:linkify/src/email.dart' show EmailLinkifier, EmailElement;
export 'package:linkify/src/url.dart' show UrlLinkifier, UrlElement;

abstract class LinkifyElement {
  final String text;

  LinkifyElement(this.text);

  @override
  bool operator ==(other) => equals(other);

  bool equals(other) => other is LinkifyElement && other.text == text;
}

class LinkableElement extends LinkifyElement {
  final String url;

  LinkableElement(String text, this.url) : super(text ?? url);

  @override
  bool operator ==(other) => equals(other);

  @override
  bool equals(other) =>
      other is LinkableElement && super.equals(other) && other.url == url;
}

/// Represents an element containing text
class TextElement extends LinkifyElement {
  TextElement(String text) : super(text);

  @override
  String toString() {
    return "TextElement: '$text'";
  }

  @override
  bool operator ==(other) => equals(other);

  @override
  bool equals(other) => other is TextElement && super.equals(other);
}

abstract class Linkifier {
  const Linkifier();

  List<LinkifyElement> parse(
      List<LinkifyElement> elements, LinkifyOptions options);
}

class LinkifyOptions {
  /// Removes http/https from shown URLS.
  final bool humanize;

  LinkifyOptions({this.humanize = true});
}

const _urlLinkifier = UrlLinkifier();
const _emailLinkifier = EmailLinkifier();
const defaultLinkifiers = [_urlLinkifier, _emailLinkifier];

/// Turns [text] into a list of [LinkifyElement]
///
/// Use [humanize] to remove http/https from the start of the URL shown.
/// Will default to `false` (if `null`)
///
/// Uses [linkTypes] to enable some types of links (URL, email).
/// Will default to all (if `null`).
List<LinkifyElement> linkify(
  String text, {
  LinkifyOptions options,
  List<Linkifier> linkifiers = defaultLinkifiers,
}) {
  var list = <LinkifyElement>[TextElement(text)];

  if (text == null || text.isEmpty) {
    return [];
  }

  if (linkifiers == null || linkifiers.isEmpty) {
    return list;
  }

  options ??= LinkifyOptions();

  linkifiers.forEach((linkifier) {
    list = linkifier.parse(list, options);
  });

  return list;
}
