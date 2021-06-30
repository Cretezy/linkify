import 'package:linkify/linkify.dart';

final _urlRegex = RegExp(
  r'^(.*?)((?:https?:\/\/|www\.)[^\s/$.?#].[A-Za-z0-9_.~-]*)',
  caseSensitive: false,
  dotAll: true,
);

final _looseUrlRegex = RegExp(
  r'^(.*?)((https?:\/\/)?(www\.)?[-a-zA-Z0-9@:%._\+~#=]{2,256}\.[a-z]{2,4}\b([-a-zA-Z0-9@:%_\+.~#?&//=]*))',
  caseSensitive: false,
  dotAll: true,
);

final _protocolIdentifierRegex = RegExp(
  r'^(https?:\/\/)',
  caseSensitive: false,
);

class UrlLinkifier extends Linkifier {
  const UrlLinkifier();

  @override
  List<LinkifyElement> parse(elements, options) {
    final list = <LinkifyElement>[];

    elements.forEach((element) {
      if (element is TextElement) {
        var loose = false;
        var match = _urlRegex.firstMatch(element.text);

        if (match == null && options.looseUrl) {
          match = _looseUrlRegex.firstMatch(element.text);
          loose = true;
        }

        if (match == null) {
          list.add(element);
        } else {
          final text = element.text.replaceFirst(match.group(0)!, '');

          if (match.group(1)?.isNotEmpty == true) {
            list.add(TextElement(match.group(1)!));
          }

          if (match.group(2)?.isNotEmpty == true) {
            var originalUrl = match.group(2)!;
            String? end;

            if ((options.excludeLastPeriod) &&
                originalUrl[originalUrl.length - 1] == ".") {
              end = ".";
              originalUrl = originalUrl.substring(0, originalUrl.length - 1);
            }

            var url = originalUrl;

            if (loose || !originalUrl.startsWith(_protocolIdentifierRegex)) {
              originalUrl = (options.defaultToHttps ? "https://" : "http://") +
                  originalUrl;
            }

            if ((options.humanize) || (options.removeWww)) {
              if (options.humanize) {
                url = url.replaceFirst(RegExp(r'https?://'), '');
              }
              if (options.removeWww) {
                url = url.replaceFirst(RegExp(r'www\.'), '');
              }

              list.add(UrlElement(
                originalUrl,
                url,
              ));
            } else {
              list.add(UrlElement(originalUrl));
            }

            if (end != null) {
              list.add(TextElement(end));
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
  UrlElement(String url, [String? text]) : super(text, url);

  @override
  String toString() {
    return "LinkElement: '$url' ($text)";
  }

  @override
  bool operator ==(other) => equals(other);

  @override
  bool equals(other) => other is UrlElement && super.equals(other);
}
