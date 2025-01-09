class Produtos {
  final String imgPath;
  final String preco;
  final String nome;
  final int codigo;
  final String descricao;
  final String departamento;
  Produtos(
      {required this.descricao,
      required this.departamento,
      required this.imgPath,
      required this.codigo,
      required this.preco,
      required this.nome});

  factory Produtos.fromJson(Map<String, dynamic> json) {
    return Produtos(
        descricao: json['descricao'],
        codigo: json['codigo'],
        nome: json['nome'],
        preco: json['preco'].toString(),
        imgPath: json['imagem'].toString(),
        departamento: json['codDepartamento'].toString()
        );
  }
}
