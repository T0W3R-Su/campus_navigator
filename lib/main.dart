import 'package:flutter/material.dart';
import 'search_page.dart'; // 假设我们有一个单独的文件用于搜索页面

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '教学楼导航',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      // 主页是搜索页面
      home: const SearchPage(),
    );
  }
}
