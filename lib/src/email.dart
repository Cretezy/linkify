import 'package:linkify/linkify.dart';

final _emailRegex = RegExp(
  r'^((?:.|\n)*?)((mailto:)?[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,4})',
  caseSensitive: false,
);

class EmailLinkifier extends Linkifier {
  const EmailLinkifier();

  @override
  List<LinkifyElement> parse(elements, options) {
    final list = <LinkifyElement>[];

    elements.forEach((element) {
      if (element is TextElement) {
        final match = _emailRegex.firstMatch(element.text);

        if (match == null) {
          list.add(element);
        } else {
          final text = element.text.replaceFirst(match.group(0), '');

          if (match.group(1).isNotEmpty) {
            list.add(TextElement(match.group(1)));
          }

          if (match.group(2).isNotEmpty) {
            // Always humanize emails
            list.add(EmailElement(
              match.group(2).replaceFirst(RegExp(r'mailto:'), ''),
            ));
          }

          if (text.isNotEmpty) {
            list.addAll(parse([TextElement(text)], options));
          }
        }
      } else {
        list.add(element);
      }
    });

    return list;
  }
}

/// Represents an element containing an email address
class EmailElement extends LinkableElement {
  final String emailAddress;

  EmailElement(this.emailAddress) : super(emailAddress, 'mailto:$emailAddress');

  @override
  String toString() {
    return "EmailElement: '$emailAddress' ($text)";
  }

  bool operator ==(other) => equals(other);

  bool equals(other) =>
      other is EmailElement &&
      super.equals(other) &&
      other.emailAddress == emailAddress;
}
