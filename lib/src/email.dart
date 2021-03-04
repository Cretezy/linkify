import 'package:linkify/linkify.dart';

final _emailRegex = RegExp(
  r'^(.*?)((mailto:)?[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,4})',
  caseSensitive: false,
  dotAll: true,
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
          final matchGroup0 = match.group(0);
          if (matchGroup0 == null) return;
          final text = element.text.replaceFirst(matchGroup0, '');

          final matchGroup1 = match.group(1);
          if (matchGroup1 == null) return;
          if (matchGroup1.isNotEmpty) {
            list.add(TextElement(matchGroup1));
          }

          final matchGroup2 = match.group(2);
          if (matchGroup2 == null) return;
          if (matchGroup2.isNotEmpty) {
            // Always humanize emails
            list.add(EmailElement(
              matchGroup2.replaceFirst(RegExp(r'mailto:'), ''),
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

  @override
  bool operator ==(other) => equals(other);

  @override
  bool equals(other) => other is EmailElement && super.equals(other) && other.emailAddress == emailAddress;
}
