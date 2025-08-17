import 'package:flutter/material.dart';
import 'package:flutter_native_video_pageview/video_pager_page.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Native Video PageView',
      theme: ThemeData(colorSchemeSeed: Colors.indigo, useMaterial3: true),
      home: const VideoPagerPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}
