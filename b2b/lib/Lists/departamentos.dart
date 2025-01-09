class Departamento {
  final int codigo;
  final String descricao;
  final String nomeIcone;
  final int ordem;

  Departamento({required this.codigo, required this.descricao, required this.nomeIcone, required this.ordem});

  factory Departamento.fromJson(Map<String, dynamic> json) {
    return Departamento(
      codigo: json['codigo'],
      descricao: json['descricao'],
      nomeIcone: json['nomeIcone'],
      ordem: json['ordem'],
    );
  }
}