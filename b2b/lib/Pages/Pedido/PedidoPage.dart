// ignore_for_file: file_names, use_key_in_widget_constructors, prefer_const_constructors

import 'dart:convert';
import 'package:b2b/Lists/cart.provider.dart';
import 'package:b2b/Pages/FinalizarpedidoPage/Finalizar.dart';
import 'package:b2b/Pages/Home/home.dart';
import 'package:b2b/Themes/colors.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class Pedido extends StatefulWidget {
  @override
  State<Pedido> createState() => _PedidoState();

  static Future<List<Pedido>>? fromJson(json) {
    return null;
  }
}

class _PedidoState extends State<Pedido> {
  final formatCurrency =
      NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$ ', decimalDigits: 2);

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);
    final produtosNoCarrinho = cartProvider.cartItems;

    double totalCarrinho = produtosNoCarrinho.fold(0.0, (sum, item) {
      return sum + (double.parse(item.preco) * item.quantidade);
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          SizedBox(height: 40),
          _buildHeader(cartProvider.cartItems.length),
          Expanded(
            child: produtosNoCarrinho.isEmpty
                ? Center(child: Text('Nenhum produto no carrinho.'))
                : ListView.builder(
                    itemCount: produtosNoCarrinho.length,
                    itemBuilder: (context, index) {
                      final item = produtosNoCarrinho[index];

                      return Dismissible(
                        key: Key(item.codigo.toString()),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          color: Colors.red.shade100,
                          alignment: Alignment.centerRight,
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          child: Icon(Icons.delete, color: Colors.white),
                        ),
                        onDismissed: (direction) {
                          cartProvider.removeItem(item.codigo.toString());
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content:
                                    Text("${item.nome} removido do carrinho")),
                          );
                        },
                        child: _buildProductTile(item),
                      );
                    },
                  ),
          ),
          _buildTotalAndActions(totalCarrinho, produtosNoCarrinho),
        ],
      ),
    );
  }

  Widget _buildHeader(int itemCount) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => HomePage()));
          },
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Seu Pedido'),
            Text('$itemCount Item(s)'),
          ],
        ),
        SizedBox(width: 40),
      ],
    );
  }

  Widget _buildProductTile(CartItem item) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        height: MediaQuery.of(context).size.width * 0.32,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.primary, width: 2),
        ),
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                  height: MediaQuery.of(context).size.width * 0.27,
                  width: MediaQuery.of(context).size.width * 0.27,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: item.imgPath == 'null'
                        ? Image.asset(
                            'assets/Logo.png',
                          )
                        : Image.memory(
                            base64Decode(item.imgPath),
                            fit: BoxFit.fill,
                          ),
                  )),
            ),
            SizedBox(width:MediaQuery.of(context).size.width * 0.05),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.width * 0.15,
                  width: MediaQuery.of(context).size.width * 0.54,
                  child: Text(
                    item.nome, maxLines: 2,
  overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                Row(
                  children: [
                    Text(
                      formatCurrency.format(double.parse(item.preco)),
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary),
                    ),
                    SizedBox(width:MediaQuery.of(context).size.width * 0.01),
                    Text('x ${item.quantidade} und',
                        style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold)),
                  ],
                ),
                Text(
                  formatCurrency
                      .format(double.parse(item.preco) * item.quantidade),
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

 Widget _buildTotalAndActions(double totalCarrinho, List<CartItem> produtosNoCarrinho) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 20.0),
    child: Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 40.0),
          child: SizedBox(
            width: MediaQuery.of(context).size.width / 1.2,
            height: 60,
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (context) => HomePage()));
              },
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0),
                ),
              ),
              child: Text(
                'Continuar Comprando',
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppColors.background),
              ),
            ),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              children: [
                Text('Total:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Text(formatCurrency.format(totalCarrinho),
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.6,
              height: 60,
              child: ElevatedButton(
                onPressed: () {
                  produtosNoCarrinho.isNotEmpty
                      ? 
                  Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (context) => Pagamento())):
                      null ;
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: produtosNoCarrinho.isNotEmpty
                      ? AppColors.primary
                      : Colors.grey,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                ),
                child: Text(
                  'Fechar pedido',
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

}
