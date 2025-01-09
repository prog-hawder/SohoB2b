import 'package:b2b/Pages/AcompanharPedidos/Acompanhar.dart';
import 'package:b2b/Pages/Home/home.dart';
import 'package:b2b/Themes/colors.dart';
import 'package:flutter/material.dart';

class PedidoConcluidoPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          SizedBox(height: 40),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (context) => HomePage()),
                  );
                },
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Pedido',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 19),
                  ),
                ],
              ),
              SizedBox(width: 50),
            ],
          ),
          SizedBox(
            height: 140,
          ),
          Icon(Icons.check_circle, color: Colors.green, size: 100),
          SizedBox(height: 20),
          Text(
            'Pedido Realizado com sucesso!',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => AcompanharPedidos(),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary, 
                padding: EdgeInsets.symmetric(vertical: 12, horizontal: 30),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            child: Text('Acompanhar pedidos',  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 19, color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
