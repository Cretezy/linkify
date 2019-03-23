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
      [LinkElement("https://example.com")],
    );
  });

  test('Parses only links with space', () {
    expectListEqual(
      linkify("https://example.com https://google.com"),
      [
        LinkElement("https://example.com"),
        TextElement(" "),
        LinkElement("https://google.com"),
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
        LinkElement("https://example.com"),
        TextElement(" "),
        LinkElement("https://google.com"),
      ],
    );
  });

  test('Parses links with text with newlines', () {
    expectListEqual(
      linkify(
        "https://google.com\nLorem ipsum\ndolor sit amet\nhttps://example.com",
      ),
      [
        LinkElement("https://google.com"),
        TextElement("\nLorem ipsum\ndolor sit amet\n"),
        LinkElement("https://example.com"),
      ],
    );
  });

  test('Parses email', () {
    expectListEqual(
      linkify("person@example.com"),
      [EmailElement("person@example.com")],
    );
  });
}
