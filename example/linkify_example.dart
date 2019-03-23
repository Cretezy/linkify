import 'package:linkify/linkify.dart';

void main() {
  print(linkify("Made by https://cretezy.com person@example.com"));
  // Output: [TextElement: 'Made by ', LinkElement: 'https://cretezy.com' (https://cretezy.com), TextElement: ' ', EmailElement: 'person@example.com' (person@example.com)]
}
