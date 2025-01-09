// ignore_for_file: prefer_const_constructors, use_key_in_widget_constructors

import 'package:b2b/Pages/AcompanharPedidos/Acompanhar.dart';
import 'package:b2b/Themes/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:b2b/Pages/Home/home.dart';

class BottomNavBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60.0,
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(15.0), topRight: Radius.circular(15.0)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(6.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              icon: SvgPicture.asset(
                'assets/icons/svgicons/store.svg',
                color: Colors.white,
                width: 50,
                height: 50,
              ),
              onPressed: () {
                Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (context) => HomePage()));
              },
            ),
            IconButton(
              icon: SvgPicture.asset(
                'assets/icons/svgicons/receipt.svg',
                color: Colors.white,
                width: 25,
                height: 25,
              ),
              onPressed: () {
                Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => AcompanharPedidos(),
                ),
              );
              },
            ),
            IconButton(
              icon: SvgPicture.asset(
                'assets/icons/svgicons/whatsapp.svg',
                color: Colors.white,
                width: 50,
                height: 50,
              ),
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }
}
