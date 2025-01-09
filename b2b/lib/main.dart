// ignore_for_file: prefer_const_constructors

import 'package:b2b/Lists/cart.provider.dart';
import 'package:b2b/Pages/Login/login.dart';
import 'package:b2b/Pages/Home/home.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => CartProvider()),
      ],
      child:  const MyApp(), 
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const LoginScreen(),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/menu': (context) =>   HomePage(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}
