import 'package:chat_project/datas/data.dart';
import 'package:chat_project/pages/home_page.dart';
import 'package:chat_project/pages/log_in.dart';
import 'package:flutter/material.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  // ignore: prefer_typing_uninitialized_variables
  var routingPage;

  @override
  void initState() {
    super.initState();
    checkAuthAndNavigate();
  }

  Future<void> checkAuthAndNavigate() async {
    String? authToken = await Auth.getRA();
    setState(() {
      routingPage = authToken != null ? const ChattingContacts() : const LogInPage();
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: routingPage,
    );
  }
  
}