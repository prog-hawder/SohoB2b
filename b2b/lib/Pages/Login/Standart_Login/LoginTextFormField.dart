// ignore: file_names
// ignore: file_names
// ignore_for_file: file_names, duplicate_ignore, prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class SenhaField extends StatelessWidget {
  const SenhaField({
    super.key,
    required TextEditingController passwordController,
  }) : _passwordController = passwordController;

  final TextEditingController _passwordController;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: _passwordController,
      obscureText: true,
      decoration: InputDecoration(
          labelText: 'Senha',
          hintText: 'Entre com sua Senha',
          contentPadding:
              const EdgeInsets.symmetric(vertical: 20, horizontal: 42),
          floatingLabelBehavior: FloatingLabelBehavior.always,
          border: OutlineInputBorder(
              // ignore: prefer_const_constructors
              borderSide: BorderSide(color: Colors.grey),
              borderRadius: BorderRadius.circular(40.0)),
          focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey),
              borderRadius: BorderRadius.circular(40.0)),
          enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey),
              borderRadius: BorderRadius.circular(40.0)),
          suffixIcon: Padding(
            padding: const EdgeInsets.fromLTRB(10, 5, 25, 5),
            child: SvgPicture.asset(
              'assets/icons/svgicons/lock.svg',
              color: Colors.black.withOpacity(0.5),
              width: 30,
              height: 30,
            ),
          )),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Digite sua senha';
        }
        return null;
      },
    );
  }
}

class LoginField extends StatelessWidget {
  const LoginField({
    super.key,
    required TextEditingController usernameController,
  }) : _usernameController = usernameController;

  final TextEditingController _usernameController;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: _usernameController,
      decoration: InputDecoration(
          labelText: 'Login',
          hintText: 'Entre com seu Login',
          contentPadding:
              const EdgeInsets.symmetric(vertical: 20, horizontal: 42),
          floatingLabelBehavior: FloatingLabelBehavior.always,
          border: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey),
              borderRadius: BorderRadius.circular(40.0)),
          focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey),
              borderRadius: BorderRadius.circular(40.0)),
          enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey),
              borderRadius: BorderRadius.circular(40.0)),
          suffixIcon: Padding(
            padding: const EdgeInsets.fromLTRB(10, 5, 20, 5),
            child: SvgPicture.asset(
              'assets/icons/svgicons/store.svg',
              color: Colors.orange,
              width: 40,
              height: 40,
            ),
          )),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Utilize o CNPJ da sua empresa';
        }
        return null;
      },
    );
  }
}