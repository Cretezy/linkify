import 'package:collection/collection.dart';
import 'package:linkify/linkify.dart';
import 'package:test/test.dart';

final listEqual = const ListEquality().equals;

void expectListEqual(List actual, List expected) {
  expect(
    listEqual(
      actual,
      expected,
    ),
    true,
    reason: "Expected $actual to be $expected",
  );
}

void main() {
  test('Parses only text', () {
    expectListEqual(
      linkify("Lorem ipsum dolor sit amet"),
      [TextElement("Lorem ipsum dolor sit amet")],
    );
  });

  test('Parses only text with multiple lines', () {
    expectListEqual(
      linkify("Lorem ipsum\ndolor sit amet"),
      [TextElement("Lorem ipsum\ndolor sit amet")],
    );
  });

  test('Parses only link', () {
    expectListEqual(
      linkify("https://example.com"),
      [UrlElement("https://example.com", "example.com")],
    );

    expectListEqual(
      linkify("https://www.example.com",
          options: LinkifyOptions(removeWww: true)),
      [UrlElement("https://www.example.com", "example.com")],
    );
  });

  test('Parses only link with no humanize', () {
    expectListEqual(
      linkify("https://example.com", options: LinkifyOptions(humanize: false)),
      [UrlElement("https://example.com")],
    );
  });

  test('Parses only link with removeWwww', () {
    expectListEqual(
      linkify(
        "https://www.example.com",
        options: LinkifyOptions(removeWww: true),
      ),
      [UrlElement("https://www.example.com", "example.com")],
    );
  });

  test('Parses only links with space', () {
    expectListEqual(
      linkify("https://example.com https://google.com"),
      [
        UrlElement("https://example.com", "example.com"),
        TextElement(" "),
        UrlElement("https://google.com", "google.com"),
      ],
    );
  });

  test('Parses links with text', () {
    expectListEqual(
      linkify(
        "Lorem ipsum dolor sit amet https://example.com https://google.com",
      ),
      [
        TextElement("Lorem ipsum dolor sit amet "),
        UrlElement("https://example.com", "example.com"),
        TextElement(" "),
        UrlElement("https://google.com", "google.com"),
      ],
    );
  });

  test('Parses links with text with no humanize', () {
    expectListEqual(
      linkify(
        "Lorem ipsum dolor sit amet https://example.com https://google.com",
        options: LinkifyOptions(humanize: false),
      ),
      [
        TextElement("Lorem ipsum dolor sit amet "),
        UrlElement("https://example.com"),
        TextElement(" "),
        UrlElement("https://google.com"),
      ],
    );
  });

  test('Parses links with text with newlines', () {
    expectListEqual(
      linkify(
        "https://google.com\nLorem ipsum\ndolor sit amet\nhttps://example.com",
      ),
      [
        UrlElement("https://google.com", "google.com"),
        TextElement("\nLorem ipsum\ndolor sit amet\n"),
        UrlElement("https://example.com", "example.com"),
      ],
    );
  });

  test('Parses email', () {
    expectListEqual(
      linkify("person@example.com"),
      [EmailElement("person@example.com")],
    );
  });

  test('Parses email and link', () {
    expectListEqual(
      linkify("person@example.com at https://google.com"),
      [
        EmailElement("person@example.com"),
        TextElement(" at "),
        UrlElement("https://google.com", "google.com")
      ],
    );
  });

  test("Doesn't parses email and link with no linkifiers", () {
    expectListEqual(
      linkify("person@example.com at https://google.com", linkifiers: []),
      [
        TextElement("person@example.com at https://google.com"),
      ],
    );
  });

  test('Parses loose URL', () {
    expectListEqual(
      linkify("example.com/test", options: LinkifyOptions(looseUrl: true)),
      [UrlElement("http://example.com/test", "example.com/test")],
    );

    expectListEqual(
      linkify("www.example.com",
          options: LinkifyOptions(
            looseUrl: true,
            removeWww: true,
            defaultToHttps: true,
          )),
      [UrlElement("https://www.example.com", "example.com")],
    );

    expectListEqual(
      linkify("https://example.com", options: LinkifyOptions(looseUrl: true)),
      [UrlElement("https://example.com", "example.com")],
    );

    expectListEqual(
      linkify("https://example.com.", options: LinkifyOptions(looseUrl: true)),
      [UrlElement("https://example.com", "example.com"), TextElement(".")],
    );
  });

  test('Parses both loose and not URL on the same text', () {
    expectListEqual(
      linkify('example.com http://example.com',
          options: LinkifyOptions(looseUrl: true)),
      [
        UrlElement('http://example.com', 'example.com'),
        TextElement(' '),
        UrlElement('http://example.com', 'example.com')
      ],
    );

    expectListEqual(
      linkify(
          'This text mixes both loose urls like example.com and not loose urls like http://example.com and http://another.example.com',
          options: LinkifyOptions(looseUrl: true)),
      [
        TextElement('This text mixes both loose urls like '),
        UrlElement('http://example.com', 'example.com'),
        TextElement(' and not loose urls like '),
        UrlElement('http://example.com', 'example.com'),
        TextElement(' and '),
        UrlElement('http://another.example.com', 'another.example.com')
      ],
    );
  });

  test('Parses ending period', () {
    expectListEqual(
      linkify("https://example.com/test."),
      [
        UrlElement("https://example.com/test", "example.com/test"),
        TextElement(".")
      ],
    );
  });

  test('Parses CR correctly.', () {
    expectListEqual(
      linkify('lorem\r\nipsum https://example.com'),
      [
        TextElement('lorem\r\nipsum '),
        UrlElement('https://example.com', 'example.com'),
      ],
    );
  });

  test('Parses user tag', () {
    expectListEqual(
      linkify("@example"),
      [UserTagElement("@example")],
    );
  });

  test('Parses email, link, and user tag', () {
    expectListEqual(
      linkify("person@example.com at https://google.com @example"),
      [
        EmailElement("person@example.com"),
        TextElement(" at "),
        UrlElement("https://google.com", "google.com"),
        TextElement(" "),
        UserTagElement("@example")
      ],
    );
  });
}
