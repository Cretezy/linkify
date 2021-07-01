import 'package:linkify/linkify.dart';

void main() {
  print(linkify(
      "![](https://cdn.jsdelivr.net/gh/fduhole/web@img/2021-06-30/23:14:38.320266.jpg)",
      options: LinkifyOptions(humanize: false)));
  // Output: [TextElement: 'Made by ', UrlElement: 'https://cretezy.com' (cretezy.com), TextElement: ' ', EmailElement: 'person@example.com' (person@example.com)]
}
