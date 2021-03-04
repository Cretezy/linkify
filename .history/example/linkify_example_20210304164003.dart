import 'package:linkify/linkify.dart';

void main() {
  print(linkify("Made by https://cretezy.com person@example.com"));
  // Output: [TextElement: 'Made by ', UrlElement: 'https://cretezy.com' (cretezy.com), TextElement: ' ', EmailElement: 'person@example.com' (person@example.com)]
}
