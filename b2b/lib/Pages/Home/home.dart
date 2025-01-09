import 'package:b2b/Pages/Home/Standart_Home/drawer.dart';
import 'package:flutter/material.dart';
import 'package:b2b/Pages/Home/Standart_Home/produtoscard.dart';
import 'package:b2b/Standart/appbar.dart';
import 'package:b2b/Pages/Home/Standart_Home/icons_departaments.dart';
import 'package:b2b/Themes/colors.dart';
import 'package:b2b/Themes/text.dart';
import 'package:b2b/Standart/bottomnav.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: const Drawer(
        child: DrawerWidget(),
      ),
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          const SizedBox(height: 40),
          Appbarwidget(
            scaffoldKey: _scaffoldKey,
            icon: Icons.menu,
            onPressed: () {
              _scaffoldKey.currentState?.openDrawer();
            },
          ),
          const SizedBox(height: 30),
          const Depart(),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 15, 20, 0),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(0, 15, 0, 5),
              child: Row(
                children: [
                  Text(
                    'Selecionados para você:',
                    style: TextStyle(
                        fontSize: 18,
                        color: Colors.black,
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
          const Produtoscard(),
        ],
      ),
      bottomNavigationBar: BottomNavBar(), // Use const quando possível
    );
  }
}
