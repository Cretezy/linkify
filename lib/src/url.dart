import 'package:linkify/linkify.dart';

final _urlRegex = RegExp(
  r'^(.*?)((?:https?:\/\/|www\.)[^\s/$.?#].[^\s]*)',
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

        if (match == null && (options?.looseUrl ?? false)) {
          match = _looseUrlRegex.firstMatch(element.text);
          loose = true;
        }

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
            var originalUrl = matchGroup2;
            String? end;

            if ((options?.excludeLastPeriod ?? false) && originalUrl[originalUrl.length - 1] == ".") {
              end = ".";
              originalUrl = originalUrl.substring(0, originalUrl.length - 1);
            }

            var url = originalUrl;

            if (loose || !originalUrl.startsWith(_protocolIdentifierRegex)) {
              originalUrl = ((options?.defaultToHttps ?? false) ? "https://" : "http://") + originalUrl;
            }

            if ((options?.humanize ?? false) || (options?.removeWww ?? false)) {
              if (options?.humanize ?? false) {
                url = url.replaceFirst(RegExp(r'https?://'), '');
              }
              if (options?.removeWww ?? false) {
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
