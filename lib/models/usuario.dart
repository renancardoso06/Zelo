// ignore_for_file: constant_identifier_names
// Usuário autenticado, espelhando UsuarioResponseDTO do backend.

enum TipoUsuario {
  CLIENTE,
  PRESTADOR;

  String get label => this == TipoUsuario.CLIENTE ? 'Cliente' : 'Prestador';
}

class Usuario {
  final int id;
  final String nome;
  final String email;
  final String? telefone;
  final String? endereco;
  final TipoUsuario tipo;
  final String? categoriaPrestador;
  final String? descricaoPrestador;
  final double? notaMedia;

  const Usuario({
    required this.id,
    required this.nome,
    required this.email,
    this.telefone,
    this.endereco,
    required this.tipo,
    this.categoriaPrestador,
    this.descricaoPrestador,
    this.notaMedia,
  });

  factory Usuario.fromJson(Map<String, dynamic> json) => Usuario(
        id: json['id'] as int,
        nome: json['nome'] as String,
        email: json['email'] as String,
        telefone: json['telefone'] as String?,
        endereco: json['endereco'] as String?,
        tipo: TipoUsuario.values.byName(json['tipo'] as String),
        categoriaPrestador: json['categoriaPrestador'] as String?,
        descricaoPrestador: json['descricaoPrestador'] as String?,
        notaMedia: (json['notaMedia'] as num?)?.toDouble(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'nome': nome,
        'email': email,
        'telefone': telefone,
        'endereco': endereco,
        'tipo': tipo.name,
        'categoriaPrestador': categoriaPrestador,
        'descricaoPrestador': descricaoPrestador,
        'notaMedia': notaMedia,
      };
}
