# `linkify` [![pub package](https://img.shields.io/pub/v/linkify.svg)](https://pub.dartlang.org/packages/linkify)

Low-level link (text, URLs, emails) parsing library in Dart.

[Flutter library](https://github.com/Cretezy/flutter_linkify).

[Pub](https://pub.dartlang.org/packages/linkify) - [API Docs](https://pub.dartlang.org/documentation/linkify/latest/) - [GitHub](https://github.com/Cretezy/linkify)

## Install

Install by adding this package to your `pubspec.yaml`:

```yaml
dependencies:
  linkify: ^1.0.1
```

## Usage

```dart
import 'package:linkify/linkify.dart';

linkify("Made by https://cretezy.com");
// Output: [TextElement: 'Made by ', LinkElement: 'https://cretezy.com' (https://cretezy.com), TextElement: ' ', EmailElement: 'person@example.com' (person@example.com)]
```
