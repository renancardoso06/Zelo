// ignore_for_file: constant_identifier_names
// Pedido vindo do backend real, espelhando PedidoResponseDTO. Não confundir
// com ServiceOrder (lib/models/models.dart), que é o pedido local/mockado
// usado pelos fluxos de agendamento e tracking.

import 'usuario.dart';

enum StatusPedido {
  PENDENTE,
  ACEITO,
  EM_ANDAMENTO,
  CONCLUIDO,
  CANCELADO;

  String get label {
    switch (this) {
      case StatusPedido.PENDENTE:
        return 'Aguardando';
      case StatusPedido.ACEITO:
        return 'Aceito';
      case StatusPedido.EM_ANDAMENTO:
        return 'Em andamento';
      case StatusPedido.CONCLUIDO:
        return 'Concluído';
      case StatusPedido.CANCELADO:
        return 'Cancelado';
    }
  }
}

class Servico {
  final int id;
  final String nome;
  final String? descricao;
  final String? categoria;
  final double precoBase;
  final bool? ativo;

  const Servico({
    required this.id,
    required this.nome,
    this.descricao,
    this.categoria,
    required this.precoBase,
    this.ativo,
  });

  factory Servico.fromJson(Map<String, dynamic> json) => Servico(
        id: json['id'] as int,
        nome: json['nome'] as String,
        descricao: json['descricao'] as String?,
        categoria: json['categoria'] as String?,
        precoBase: (json['precoBase'] as num).toDouble(),
        ativo: json['ativo'] as bool?,
      );
}

class Pedido {
  final int id;
  final Usuario? cliente;
  final Usuario? prestador;
  final Servico? servico;
  final StatusPedido status;
  final DateTime? dataAgendamento;
  final String? enderecoAtendimento;
  final double? latitudeAtual;
  final double? longitudeAtual;
  final String? observacoes;
  final DateTime? criadoEm;
  final DateTime? atualizadoEm;

  const Pedido({
    required this.id,
    this.cliente,
    this.prestador,
    this.servico,
    required this.status,
    this.dataAgendamento,
    this.enderecoAtendimento,
    this.latitudeAtual,
    this.longitudeAtual,
    this.observacoes,
    this.criadoEm,
    this.atualizadoEm,
  });

  factory Pedido.fromJson(Map<String, dynamic> json) => Pedido(
        id: json['id'] as int,
        cliente: json['cliente'] != null
            ? Usuario.fromJson(json['cliente'] as Map<String, dynamic>)
            : null,
        prestador: json['prestador'] != null
            ? Usuario.fromJson(json['prestador'] as Map<String, dynamic>)
            : null,
        servico: json['servico'] != null
            ? Servico.fromJson(json['servico'] as Map<String, dynamic>)
            : null,
        status: StatusPedido.values.byName(json['status'] as String),
        dataAgendamento: json['dataAgendamento'] != null
            ? DateTime.parse(json['dataAgendamento'] as String)
            : null,
        enderecoAtendimento: json['enderecoAtendimento'] as String?,
        latitudeAtual: (json['latitudeAtual'] as num?)?.toDouble(),
        longitudeAtual: (json['longitudeAtual'] as num?)?.toDouble(),
        observacoes: json['observacoes'] as String?,
        criadoEm: json['criadoEm'] != null
            ? DateTime.parse(json['criadoEm'] as String)
            : null,
        atualizadoEm: json['atualizadoEm'] != null
            ? DateTime.parse(json['atualizadoEm'] as String)
            : null,
      );
}
