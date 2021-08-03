import 'package:linkify/linkify.dart';

void main() {
  print(linkify(
      "http://mp.weixin.qq.com/s?__biz=MjM5MTA2ODI3OA==&mid=2449972191&idx=1&sn=0bfa1d94afec30c7113c3881495906ac&chksm=b14802c6863f8bd0d603db6e92fa604c03b98399ae3ccd9fa20db1776210aac90e2165ecde68&mpshare=1&scene=23&srcid=0703HOllo8ED2Ey25CqrKWzM&sharer_sharetime=1625303541359&sharer_shareid=5a67e5ce7f5b1dcf9c5153d2b078e447#rd",
      options: LinkifyOptions(humanize: false)));
  // Output: [TextElement: 'Made by ', UrlElement: 'https://cretezy.com' (cretezy.com), TextElement: ' ', EmailElement: 'person@example.com' (person@example.com)]
}
