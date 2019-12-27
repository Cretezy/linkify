import 'package:linkify/linkify.dart';

final _urlRegex = RegExp(
  r"^((?:.|\n)*?)((?:https?):\/\/[^\s/$.?#].[^\s]*)",
  caseSensitive: false,
);

class UrlLinkifier extends Linkifier {
  const UrlLinkifier();

  @override
  parse(elements, options) {
    final list = <LinkifyElement>[];

    elements.forEach((element) {
      if (element is TextElement) {
        final match = _urlRegex.firstMatch(element.text);

        if (match == null) {
          list.add(element);
        } else {
          final text = element.text.replaceFirst(match.group(0), "");

          if (match.group(1).isNotEmpty) {
            list.add(TextElement(match.group(1)));
          }

          if (match.group(2).isNotEmpty) {
            if (options.humanize ?? false) {
              list.add(UrlElement(
                match.group(2),
                match.group(2).replaceFirst(RegExp(r"https?://"), ""),
              ));
            } else {
              list.add(UrlElement(match.group(2)));
            }
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

/// Represents an element containing a link
class UrlElement extends LinkableElement {
  UrlElement(String url, [String text]) : super(text, url);

  @override
  String toString() {
    return "LinkElement: '$url' ($text)";
  }

  bool operator ==(other) => equals(other);

  bool equals(other) => other is UrlElement && super.equals(other);
}
