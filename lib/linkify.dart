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

/// Represents an element containing an telephone number
class TelephoneElement extends LinkableElement {
  final String telephoneNumber;

  TelephoneElement(this.telephoneNumber, [String text])
      : super(text, "tel://$telephoneNumber");

  @override
  String toString() {
    return "TelephoneElement: '$telephoneNumber' ($text)";
  }

  bool operator ==(other) => equals(other);

  bool equals(other) =>
      other is TelephoneElement &&
      super.equals(other) &&
      other.telephoneNumber == telephoneNumber;
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

enum LinkType { url, email, href, tel }

final _linkifyUrlRegex = RegExp(
  r"^((?:.|\n)*?)((?:https?):\/\/[^\s/$.?#].[^\s]*)",
  caseSensitive: false,
);

final _linkifyFormattedEmailRegex = RegExp(
  r"^((?:.|\n)*?)(\[([^\]]+)\]\s*\()((mailto:)?[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,4}).*$",
  caseSensitive: false,
);

final _linkifyLooseEmailRegex = RegExp(
  r"^((?:.|\n)*?)([A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,4}).*$",
  caseSensitive: false,
);

final _linkifyHrefRegex = RegExp(
  r"^((?:.|\n)*?)(\[([^\]]+)\]\s*\()((http|ftp|https):\/\/[\w-]+(\.[\w-]+)+([\w.,@?^=%&amp;:\/~+#-]*[\w@?^=%&amp;\/~+#-])?)\)?",
  caseSensitive: false,
);

final _linkifyTelRegex = RegExp(
  r"^((?:.|\n)*?)(\[([^\]]+)\]\s*\()((tel:)?[+0-9.\s-]+).*$",
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
  final formattedEmailMatch = linkTypes.contains(LinkType.email)
      ? _linkifyFormattedEmailRegex.firstMatch(text)
      : null;
  final looseEmailMatch = linkTypes.contains(LinkType.email)
      ? _linkifyLooseEmailRegex.firstMatch(text)
      : null;
  final telMatch = linkTypes.contains(LinkType.tel)
      ? _linkifyTelRegex.firstMatch(text)
      : null;
  final hrefMatch = linkTypes.contains(LinkType.href)
      ? _linkifyHrefRegex.firstMatch(text)
      : null;
  if (urlMatch == null &&
      formattedEmailMatch == null &&
      hrefMatch == null &&
      telMatch == null &&
      looseEmailMatch == null) {
    list.add(TextElement(text));
  } else {
    if (hrefMatch != null) {
      text = text.replaceFirst(hrefMatch.group(0), "");

      if (hrefMatch.group(1).isNotEmpty) {
        list.add(TextElement(hrefMatch.group(1)));
      }

      if (hrefMatch.group(3).isNotEmpty && hrefMatch.group(4).isNotEmpty) {
        list.add(LinkElement(
          hrefMatch.group(4), // link
          hrefMatch.group(3), // humanized text
        ));
      }
    } else if (urlMatch != null) {
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
    } else if (formattedEmailMatch != null) {
      text = text.replaceFirst(formattedEmailMatch.group(0), "");

      if (formattedEmailMatch.group(3).isNotEmpty) {
        list.add(TextElement(formattedEmailMatch.group(3)));
      }

      if (formattedEmailMatch.group(4).isNotEmpty) {
        // Always humanize emails
        list.add(EmailElement(
          formattedEmailMatch.group(4).replaceFirst(RegExp(r"mailto:"), ""),
        ));
      }
    } else if (looseEmailMatch != null && formattedEmailMatch == null) {
      list.add(EmailElement(
          looseEmailMatch.group(0).replaceFirst(RegExp(r"mailto:"), "")));
      text = text.replaceFirst(looseEmailMatch.group(0), "");
    } else if (telMatch != null) {
      text = text.replaceFirst(telMatch.group(0), "");

      if (telMatch.group(3).isNotEmpty && telMatch.group(4).isNotEmpty) {
        list.add(TelephoneElement(
          telMatch.group(4).replaceFirst(RegExp(r"tel:"), ""), // link
          telMatch.group(3), // humanized text
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
