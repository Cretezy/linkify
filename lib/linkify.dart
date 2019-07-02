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

  bool operator ==(other) => equals(other);

  bool equals(other) =>
      other is LinkableElement && super.equals(other) && other.url == url;
}

/// Represents an element containing a link
class LinkElement extends LinkableElement {
  LinkElement(String url, [String text]) : super(text, url);

  @override
  String toString() {
    return "LinkElement: '$url' ($text)";
  }

  bool operator ==(other) => equals(other);

  bool equals(other) => other is LinkElement && super.equals(other);
}

/// Represents an element containing an email address
class EmailElement extends LinkableElement {
  final String emailAddress;

  EmailElement(this.emailAddress) : super(emailAddress, "mailto:$emailAddress");

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

/// Represents an element containing text
class TextElement extends LinkifyElement {
  TextElement(String text) : super(text);

  @override
  String toString() {
    return "TextElement: '$text'";
  }

  bool operator ==(other) => equals(other);

  bool equals(other) => other is TextElement && super.equals(other);
}

enum LinkType { url, email }

final _linkifyUrlRegex = RegExp(
  r"((?:[a-z0-9](?:[a-z0-9-]{0,61}[a-z0-9])?\.)+[a-z0-9][a-z0-9-]{0,61}[a-z0-9])(:?\d*)\/?([a-z_\/0-9\-#.]*)\??([a-z_\/0-9\-#=&]*)",
  caseSensitive: false,
);

final _linkifyEmailRegex = RegExp(
  r"^((?:.|\n)*?)((mailto:)?[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,4})",
  caseSensitive: false,
);

/// Turns [text] into a list of [LinkifyElement]
///
/// Use [humanize] to remove http/https from the start of the URL shown.
/// Will default to `false` (if `null`)
///
/// Uses [linkTypes] to enable some types of links (URL, email).
/// Will default to all (if `null`).
List<LinkifyElement> linkify(
  String text, {
  bool humanize,
  List<LinkType> linkTypes,
}) {
  final list = List<LinkifyElement>();

  if (text == null || text.isEmpty) {
    return list;
  }

  if (humanize == null) {
    humanize = false;
  }

  if (linkTypes == null) {
    linkTypes = LinkType.values;
  }

  final urlMatch = linkTypes.contains(LinkType.url)
      ? _linkifyUrlRegex.firstMatch(text)
      : null;
  final emailMatch = linkTypes.contains(LinkType.email)
      ? _linkifyEmailRegex.firstMatch(text)
      : null;

  if (urlMatch == null && emailMatch == null) {
    list.add(TextElement(text));
  } else {
    if (urlMatch != null) {
      text = text.replaceFirst(urlMatch.group(0), "");

      if (urlMatch.group(1).isNotEmpty) {
        list.add(TextElement(urlMatch.group(1)));
      }

      if (urlMatch.group(2).isNotEmpty) {
        if (humanize ?? false) {
          list.add(LinkElement(
            urlMatch.group(2),
            urlMatch.group(2).replaceFirst(RegExp(r"https?://"), ""),
          ));
        } else {
          list.add(LinkElement(urlMatch.group(2)));
        }
      }
    } else if (emailMatch != null) {
      text = text.replaceFirst(emailMatch.group(0), "");

      if (emailMatch.group(1).isNotEmpty) {
        list.add(TextElement(emailMatch.group(1)));
      }

      if (emailMatch.group(2).isNotEmpty) {
        // Always humanize emails
        list.add(EmailElement(
          emailMatch.group(2).replaceFirst(RegExp(r"mailto:"), ""),
        ));
      }
    }

    list.addAll(linkify(
      text,
      humanize: humanize,
      linkTypes: linkTypes,
    ));
  }

  return list;
}


void main() {
  print(_linkifyUrlRegex.allMatches('google.com'));
}