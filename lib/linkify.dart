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

/// Represents an element containing a phone number
class PhoneElement extends LinkableElement {
  final String phoneNumber;

  PhoneElement(this.phoneNumber) : super(phoneNumber, "tel:$phoneNumber");

  @override
  String toString() {
    return "PhoneElement: '$phoneNumber' ($text)";
  }

  bool operator ==(other) => equals(other);

  bool equals(other) =>
      other is PhoneElement &&
      super.equals(other) &&
      other.phoneNumber == phoneNumber;
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

enum LinkType { url, email, phone }

final _linkifyUrlRegex = RegExp(
  r"^((?:.|\n)*?)((?:https?):\/\/[^\s/$.?#].[^\s]*)",
  caseSensitive: false,
);

final _linkifyEmailRegex = RegExp(
  r"^((?:.|\n)*?)((mailto:)?[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,4})",
  caseSensitive: false,
);

final _linkifyPhoneRegex = RegExp(
  r"^((?:.|\n)*?)((tel:)?([+0-9]{2,4}?\s?[0-9\s\(\)]{8,15}))",
  caseSensitive: false,
);

/// Turns [text] into a list of [LinkifyElement]
///
/// Use [humanize] to remove http/https from the start of the URL shown.
/// Will default to `false` (if `null`)
///
/// Uses [linkTypes] to enable some types of links (URL, email, phone).
/// Will default to URL and email (if `null`).
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
    linkTypes = <LinkType>[LinkType.email, LinkType.url];
  }

  final urlMatch = linkTypes.contains(LinkType.url)
      ? _linkifyUrlRegex.firstMatch(text)
      : null;
  final emailMatch = linkTypes.contains(LinkType.email)
      ? _linkifyEmailRegex.firstMatch(text)
      : null;
  final phoneMatch = linkTypes.contains(LinkType.phone)
      ? _linkifyPhoneRegex.firstMatch(text)
      : null;

  if (urlMatch == null && emailMatch == null && phoneMatch == null) {
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
    } else if (phoneMatch != null) {
      text = text.replaceFirst(phoneMatch.group(0), "");

      if (phoneMatch.group(1).isNotEmpty) {
        list.add(TextElement(phoneMatch.group(1)));
      }

      if (phoneMatch.group(2).isNotEmpty) {
        // Always humanize phones
        list.add(PhoneElement(
          phoneMatch.group(2).replaceFirst(RegExp(r"tel:"), ""),
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
