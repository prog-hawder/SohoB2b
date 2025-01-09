// ignore_for_file: prefer_const_constructors, unused_field

import 'package:b2b/Pages/Pedido/PedidoPage.dart';
import 'package:b2b/Pages/Pesquisa/PesquisaPage.dart';
import 'package:b2b/Themes/colors.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:b2b/Lists/cart.provider.dart'; // Importar o CartProvider

class Appbarwidget extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  const Appbarwidget({
    super.key,
    required GlobalKey<ScaffoldState> scaffoldKey,
    required this.icon,
    required this.onPressed,
  }) : _scaffoldKey = scaffoldKey;

  final GlobalKey<ScaffoldState> _scaffoldKey;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 20, 10, 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          // Botão de ação (ícone passado como argumento)
          Container(
            height: MediaQuery.of(context).size.width * 0.12,
            width: MediaQuery.of(context).size.width * 0.12,
            decoration: BoxDecoration(
              color: AppColors.backgroudbutton,
              borderRadius: BorderRadius.circular(50),
            ),
            child: Center(
              child: IconButton(
                icon: Icon(icon),
                onPressed: onPressed,
              ),
            ),
          ),

          // Campo de pesquisa
          Container(
            width: MediaQuery.of(context).size.width * 0.58,
            height: MediaQuery.of(context).size.width * 0.12,
            decoration: BoxDecoration(
              color: AppColors.backgroudbutton,
              borderRadius: BorderRadius.circular(15),
            ),
            child: TextFormField(
              decoration: InputDecoration(
                hintText: 'Procurar produto',
                prefixIcon: Icon(Icons.search_outlined),
                floatingLabelBehavior: FloatingLabelBehavior.always,
                border: OutlineInputBorder(
                  borderSide: BorderSide.none,
                  borderRadius: BorderRadius.circular(20.0),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide.none,
                  borderRadius: BorderRadius.circular(20.0),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide.none,
                  borderRadius: BorderRadius.circular(20.0),
                ),
              ),
              onFieldSubmitted: (value) {
                if (value.isNotEmpty) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Pesquisa(query: value),
                    ),
                  );
                }
              },
            ),
          ),

          // Ícone do carrinho com contador
          Consumer<CartProvider>(
            builder: (context, cartProvider, child) {
              int itemCount = cartProvider.cartItems.length;

              return Container(
                height: MediaQuery.of(context).size.width * 0.12,
                width: MediaQuery.of(context).size.width * 0.12,
                decoration: BoxDecoration(
                  color: AppColors.backgroudbutton,
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Center(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      IconButton(
                        icon: Icon(Icons.shopping_cart_outlined),
                        onPressed: () {
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(builder: (context) => Pedido()),
                          );
                        },
                      ),
                      if (itemCount > 0)
                        Positioned(
                          right: 0,
                          top: 0,
                          child: Container(
                            height: 20,
                            width: 20,
                            padding: EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(50),
                            ),
                            child: Text(
                              '$itemCount',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
