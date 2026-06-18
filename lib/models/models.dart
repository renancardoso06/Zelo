// Categoria de serviço (faxina, cuidador, etc)
class ServiceCategory {
  final String id;
  final String name;
  final String icon;
  final String description;

  const ServiceCategory({
    required this.id,
    required this.name,
    required this.icon,
    required this.description,
  });
}

// Prestador de serviço
class Provider {
  final String id;
  final String name;
  final String category;
  final double rating;
  final int reviewCount;
  final double pricePerHour;
  final String avatarUrl;
  final String description;
  final List<String> specialties;
  final bool isVerified;
  final double latitude;
  final double longitude;
  final String neighborhood;
  final int completedJobs;

  const Provider({
    required this.id,
    required this.name,
    required this.category,
    required this.rating,
    required this.reviewCount,
    required this.pricePerHour,
    required this.avatarUrl,
    required this.description,
    required this.specialties,
    required this.isVerified,
    required this.latitude,
    required this.longitude,
    required this.neighborhood,
    required this.completedJobs,
  });
}

// Pedido feito pelo usuário
class ServiceOrder {
  final String id;
  final String providerId;
  final String providerName;
  final String service;
  final DateTime scheduledDate;
  final double totalPrice;
  final OrderStatus status;
  final String address;

  const ServiceOrder({
    required this.id,
    required this.providerId,
    required this.providerName,
    required this.service,
    required this.scheduledDate,
    required this.totalPrice,
    required this.status,
    required this.address,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'providerId': providerId,
        'providerName': providerName,
        'service': service,
        'scheduledDate': scheduledDate.toIso8601String(),
        'totalPrice': totalPrice,
        'status': status.name,
        'address': address,
      };

  factory ServiceOrder.fromJson(Map<String, dynamic> json) => ServiceOrder(
        id: json['id'],
        providerId: json['providerId'],
        providerName: json['providerName'],
        service: json['service'],
        scheduledDate: DateTime.parse(json['scheduledDate']),
        totalPrice: json['totalPrice'].toDouble(),
        status: OrderStatus.values.byName(json['status']),
        address: json['address'],
      );
}

enum OrderStatus {
  pending,
  confirmed,
  inProgress,
  completed,
  cancelled;

  String get label {
    switch (this) {
      case pending:
        return 'Aguardando';
      case confirmed:
        return 'Confirmado';
      case inProgress:
        return 'Em andamento';
      case completed:
        return 'Concluído';
      case cancelled:
        return 'Cancelado';
    }
  }
}

// Dados de teste (mock) já que não tem backend de verdade ainda
class MockData {
  static const categories = [
    ServiceCategory(
      id: '1',
      name: 'Faxina',
      icon: '🧹',
      description: 'Limpeza completa ou parcial',
    ),
    ServiceCategory(
      id: '2',
      name: 'Cuidador',
      icon: '🤝',
      description: 'Cuidados com idosos e dependentes',
    ),
    ServiceCategory(
      id: '3',
      name: 'Manutenção',
      icon: '🔧',
      description: 'Reparos e manutenção geral',
    ),
    ServiceCategory(
      id: '4',
      name: 'Jardinagem',
      icon: '🌿',
      description: 'Cuidados com plantas e jardim',
    ),
    ServiceCategory(
      id: '5',
      name: 'Culinária',
      icon: '🍳',
      description: 'Preparo de refeições em casa',
    ),
    ServiceCategory(
      id: '6',
      name: 'Lavanderia',
      icon: '👕',
      description: 'Lavagem e passagem de roupas',
    ),
  ];

  static const providers = [
    Provider(
      id: '1',
      name: 'Maria Silva',
      category: 'Faxina',
      rating: 4.9,
      reviewCount: 134,
      pricePerHour: 45.0,
      avatarUrl: 'https://i.pravatar.cc/150?img=47',
      description:
          'Profissional com 8 anos de experiência em limpeza residencial. Especialista em casas com idosos e crianças, usando apenas produtos hipoalergênicos.',
      specialties: ['Limpeza pesada', 'Organização', 'Produtos naturais'],
      isVerified: true,
      latitude: -23.5505,
      longitude: -46.6333,
      neighborhood: 'Pinheiros',
      completedJobs: 312,
    ),
    Provider(
      id: '2',
      name: 'João Santos',
      category: 'Cuidador',
      rating: 4.8,
      reviewCount: 89,
      pricePerHour: 60.0,
      avatarUrl: 'https://i.pravatar.cc/150?img=12',
      description:
          'Técnico em enfermagem com especialização em cuidados geriátricos. Experiência em pacientes com Alzheimer e mobilidade reduzida.',
      specialties: ['Alzheimer', 'Fisioterapia básica', 'Medicação'],
      isVerified: true,
      latitude: -23.5615,
      longitude: -46.6560,
      neighborhood: 'Vila Madalena',
      completedJobs: 201,
    ),
    Provider(
      id: '3',
      name: 'Carlos Oliveira',
      category: 'Manutenção',
      rating: 4.7,
      reviewCount: 212,
      pricePerHour: 80.0,
      avatarUrl: 'https://i.pravatar.cc/150?img=33',
      description:
          'Eletricista e encanador certificado. Atendo emergências com rapidez e transparência no orçamento.',
      specialties: ['Elétrica', 'Hidráulica', 'Pintura'],
      isVerified: true,
      latitude: -23.5420,
      longitude: -46.6200,
      neighborhood: 'Consolação',
      completedJobs: 445,
    ),
    Provider(
      id: '4',
      name: 'Ana Ferreira',
      category: 'Culinária',
      rating: 4.9,
      reviewCount: 67,
      pricePerHour: 55.0,
      avatarUrl: 'https://i.pravatar.cc/150?img=9',
      description:
          'Chef especializada em alimentação saudável para idosos. Preparo de marmitas semanais e refeições personalizadas.',
      specialties: ['Dietas especiais', 'Marmitas', 'Culinária leve'],
      isVerified: true,
      latitude: -23.5580,
      longitude: -46.6450,
      neighborhood: 'Jardins',
      completedJobs: 158,
    ),
    Provider(
      id: '5',
      name: 'Roberto Lima',
      category: 'Jardinagem',
      rating: 4.6,
      reviewCount: 45,
      pricePerHour: 40.0,
      avatarUrl: 'https://i.pravatar.cc/150?img=52',
      description:
          'Paisagista e jardineiro com foco em jardins de baixa manutenção. Ideal para famílias que desejam beleza sem esforço.',
      specialties: ['Paisagismo', 'Poda', 'Irrigação'],
      isVerified: false,
      latitude: -23.5480,
      longitude: -46.6700,
      neighborhood: 'Perdizes',
      completedJobs: 89,
    ),
  ];
}
