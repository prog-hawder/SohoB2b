import 'package:flutter/material.dart';

class CartProvider with ChangeNotifier {
  final List<CartItem> _cartItems = [];

  List<CartItem> get cartItems => _cartItems;

  void addToCart(
      int codigo, int quantidade, String nome, String imgPath, String preco) {
    final existingItem = _cartItems.firstWhere(
      (item) => item.codigo == codigo,
      orElse: () =>
          CartItem(codigo, 0, nome, imgPath, preco),
    );

    if (existingItem.quantidade > 0) {
      existingItem.quantidade += quantidade;
    } else {
      _cartItems.add(CartItem(codigo, quantidade,nome, imgPath, preco));
    }

    notifyListeners(); 
  }

  void removeItem(String codigo) {
    _cartItems.removeWhere((item) => item.codigo.toString() == codigo);
    notifyListeners(); // Notifica os ouvintes sobre a mudança
  }
}

class CartItem {
  final int codigo;
  int quantidade;
  String nome;
  String imgPath;
  String preco;
  CartItem(this.codigo, this.quantidade, this.nome, this.imgPath, this.preco);
}
