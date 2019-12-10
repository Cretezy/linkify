import 'package:linkify/linkify.dart';

void main() {
  print(linkify("Made by https://cretezy.com person@example.com"));
  // Output: [TextElement: 'Made by ', LinkElement: 'https://cretezy.com' (https://cretezy.com), TextElement: ' ', EmailElement: 'person@example.com' (person@example.com)]

  print(linkify(
      "Made by https://cretezy.com [e-mail](mailto:person@example.com)"));
  // Output [TextElement: 'Made by ', LinkElement: 'https://cretezy.com' (https://cretezy.com), TextElement: 'e-mail', EmailElement: 'person@example.com' (person@example.com)]

  print(linkify("[e-mail](mailto:person@example.com)"));
  // Output [TextElement: 'e-mail', EmailElement: 'person@example.com' (person@example.com)]

  print(linkify("person@example.com"));
  // Output [EmailElement: 'person@example.com' (person@example.com)]

  print(linkify("[telephone](tel:123-232-124)"));
  //Output [LinkElement: 'tel://123-232-124' (telephone)]
}
