import 'dart:async';
import 'package:flutter/material.dart';
import '../models/models.dart';
import '../theme.dart';

class TrackingScreen extends StatefulWidget {
  final ServiceOrder order;

  const TrackingScreen({super.key, required this.order});

  @override
  State<TrackingScreen> createState() => _TrackingScreenState();
}

class _TrackingScreenState extends State<TrackingScreen> {
  int _currentStep = 0;
  bool _showDelayBanner = false;

  String _trafficLevel = 'Moderado';
  double _punctualityScore = 0.91;
  double _etaConfidence = 0.87;
  int _inferenceMs = 142;

  final _timers = <Timer>[];

  static const _etaTexts = [
    '18 min',
    '23 min',
    'Chegou!',
    'Em andamento',
    'Finalizado ✓',
  ];

  static const _statusMessages = [
    'Prestador confirmou o pedido',
    'IA recalculou a rota por tráfego intenso',
    'Prestador chegou ao endereço',
    'Serviço em execução',
    'Serviço concluído com sucesso!',
  ];

  @override
  void initState() {
    super.initState();
    _scheduleSimulation();
  }

  void _scheduleSimulation() {
    // 5 s → A caminho + banner de atraso da IA dispara simultaneamente
    _timers.add(Timer(const Duration(seconds: 5), () {
      if (!mounted) return;
      setState(() {
        _currentStep = 1;
        _showDelayBanner = true;
        _trafficLevel = 'Intenso';
        _etaConfidence = 0.73;
        _inferenceMs = 198;
      });
    }));

    // 8.5 s → esconde banner
    _timers.add(Timer(const Duration(milliseconds: 8500), () {
      if (!mounted) return;
      setState(() => _showDelayBanner = false);
    }));

    // 12 s → Chegou
    _timers.add(Timer(const Duration(seconds: 12), () {
      if (!mounted) return;
      setState(() {
        _currentStep = 2;
        _trafficLevel = 'Leve';
        _punctualityScore = 0.95;
        _etaConfidence = 0.98;
        _inferenceMs = 121;
      });
    }));

    // 17 s → Em execução
    _timers.add(Timer(const Duration(seconds: 17), () {
      if (!mounted) return;
      setState(() {
        _currentStep = 3;
        _inferenceMs = 110;
      });
    }));

    // 23 s → Concluído
    _timers.add(Timer(const Duration(seconds: 23), () {
      if (!mounted) return;
      setState(() {
        _currentStep = 4;
        _punctualityScore = 0.98;
        _etaConfidence = 1.0;
        _inferenceMs = 108;
      });
    }));
  }

  @override
  void dispose() {
    for (final t in _timers) {
      t.cancel();
    }
    super.dispose();
  }

  String get _providerInitials {
    final parts = widget.order.providerName.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return parts[0][0].toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Acompanhamento em Tempo Real'),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _ProviderCard(
                  name: widget.order.providerName,
                  initials: _providerInitials,
                  service: widget.order.service,
                ),
                const SizedBox(height: 12),
                const _MapPlaceholder(),
                const SizedBox(height: 12),
                _JourneyStepperCard(currentStep: _currentStep),
                const SizedBox(height: 12),
                _EtaCard(
                  eta: _etaTexts[_currentStep],
                  message: _statusMessages[_currentStep],
                  isDone: _currentStep == 4,
                ),
                const SizedBox(height: 12),
                _AiPanel(
                  trafficLevel: _trafficLevel,
                  punctualityScore: _punctualityScore,
                  etaConfidence: _etaConfidence,
                  inferenceMs: _inferenceMs,
                ),
              ],
            ),
          ),
          // Banner desliza do topo quando a IA detecta atraso
          AnimatedPositioned(
            duration: const Duration(milliseconds: 350),
            curve: Curves.easeOutCubic,
            top: _showDelayBanner ? 0 : -130,
            left: 0,
            right: 0,
            child: const _DelayBanner(),
          ),
        ],
      ),
    );
  }
}

// ── Card do prestador ──────────────────────────────────────────────────────────

class _ProviderCard extends StatelessWidget {
  final String name;
  final String initials;
  final String service;

  const _ProviderCard({
    required this.name,
    required this.initials,
    required this.service,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 26,
              backgroundColor: ZeloColors.primary,
              child: Text(
                initials,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 17,
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      color: ZeloColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    service,
                    style: const TextStyle(
                      color: ZeloColors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            // Badge "IA ativa"
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: ZeloColors.accent.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: ZeloColors.accent.withValues(alpha: 0.35)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 7,
                    height: 7,
                    decoration: const BoxDecoration(
                      color: ZeloColors.accent,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 5),
                  const Text(
                    'IA ativa',
                    style: TextStyle(
                      color: ZeloColors.accent,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Placeholder de mapa ────────────────────────────────────────────────────────

// Mapa visual simulado — sem Google Maps SDK por enquanto.
// API key pendente no AndroidManifest. Substituir por GoogleMap widget quando disponível.
class _MapPlaceholder extends StatelessWidget {
  const _MapPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: SizedBox(
        height: 180,
        child: Stack(
          children: [
            Container(color: const Color(0xFFE8F0E8)),
            CustomPaint(
              size: const Size(double.infinity, 180),
              painter: _MapGridPainter(),
            ),
            // Ícone do prestador em movimento + destino
            const Positioned(
              left: 0,
              right: 0,
              top: 55,
              child: Column(
                children: [
                  Icon(Icons.directions_car_rounded, color: ZeloColors.primary, size: 30),
                  SizedBox(height: 4),
                  Icon(Icons.location_pin, color: ZeloColors.error, size: 34),
                ],
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Mapa simulado',
                  style: TextStyle(color: Colors.white, fontSize: 11),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MapGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final grid = Paint()
      ..color = const Color(0xFFCCDACC)
      ..strokeWidth = 1.0;
    final road = Paint()
      ..color = const Color(0xFFB8C8B8)
      ..strokeWidth = 10;

    for (double y = 25; y < size.height; y += 30) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), grid);
    }
    for (double x = 0; x < size.width; x += 45) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), grid);
    }

    canvas.drawLine(Offset(0, size.height / 2), Offset(size.width, size.height / 2), road);
    canvas.drawLine(Offset(size.width * 0.38, 0), Offset(size.width * 0.38, size.height), road);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ── Stepper da jornada ─────────────────────────────────────────────────────────

class _JourneyStepperCard extends StatelessWidget {
  final int currentStep;

  const _JourneyStepperCard({required this.currentStep});

  static const _labels = [
    'Aceite',
    'A caminho',
    'Chegou',
    'Em execução',
    'Concluído',
  ];

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Jornada do prestador',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 14,
                color: ZeloColors.textPrimary,
              ),
            ),
            const SizedBox(height: 14),
            // Linha de círculos + conectores
            Row(
              children: [
                for (int i = 0; i < _labels.length; i++) ...[
                  _StepCircle(
                    index: i,
                    isDone: i < currentStep,
                    isActive: i == currentStep,
                  ),
                  if (i < _labels.length - 1)
                    Expanded(
                      child: Container(
                        height: 2,
                        color: i < currentStep ? ZeloColors.accent : ZeloColors.divider,
                      ),
                    ),
                ],
              ],
            ),
            const SizedBox(height: 6),
            // Labels distribuídas igualmente sob os círculos
            Row(
              children: [
                for (int i = 0; i < _labels.length; i++)
                  Expanded(
                    child: Text(
                      _labels[i],
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: i <= currentStep ? FontWeight.w600 : FontWeight.w400,
                        color: i == currentStep
                            ? ZeloColors.primary
                            : i < currentStep
                                ? ZeloColors.accent
                                : ZeloColors.textSecondary,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StepCircle extends StatelessWidget {
  final int index;
  final bool isDone;
  final bool isActive;

  const _StepCircle({
    required this.index,
    required this.isDone,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    final bg = isDone
        ? ZeloColors.accent
        : isActive
            ? ZeloColors.primary
            : ZeloColors.divider;

    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
      child: Center(
        child: isDone
            ? const Icon(Icons.check, color: Colors.white, size: 14)
            : isActive
                ? Container(
                    width: 9,
                    height: 9,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                  )
                : Text(
                    '${index + 1}',
                    style: const TextStyle(
                      color: ZeloColors.textSecondary,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
      ),
    );
  }
}

// ── Card de ETA / status ───────────────────────────────────────────────────────

class _EtaCard extends StatelessWidget {
  final String eta;
  final String message;
  final bool isDone;

  const _EtaCard({
    required this.eta,
    required this.message,
    required this.isDone,
  });

  @override
  Widget build(BuildContext context) {
    final color = isDone ? ZeloColors.accent : ZeloColors.primary;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                isDone ? Icons.check_circle_outline : Icons.access_time_rounded,
                color: color,
                size: 28,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    eta,
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 22,
                      color: color,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    message,
                    style: const TextStyle(
                      color: ZeloColors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Painel do Motor de IA ──────────────────────────────────────────────────────

class _AiPanel extends StatelessWidget {
  final String trafficLevel;
  final double punctualityScore;
  final double etaConfidence;
  final int inferenceMs;

  const _AiPanel({
    required this.trafficLevel,
    required this.punctualityScore,
    required this.etaConfidence,
    required this.inferenceMs,
  });

  Color get _trafficColor {
    if (trafficLevel == 'Intenso') return ZeloColors.error;
    if (trafficLevel == 'Moderado') return ZeloColors.warning;
    return ZeloColors.accent;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: ZeloColors.primary.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.memory_rounded,
                    color: ZeloColors.primary,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Motor de IA',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: ZeloColors.textPrimary,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFF7B2FBE).withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'simulado',
                    style: TextStyle(
                      color: Color(0xFF7B2FBE),
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 12),
            _AiMetricRow(
              label: 'Trânsito atual',
              value: trafficLevel,
              valueColor: _trafficColor,
            ),
            const SizedBox(height: 10),
            _AiMetricRow(
              label: 'Score de pontualidade',
              value: '${(punctualityScore * 100).round()}%',
              valueColor: ZeloColors.primary,
              showBar: true,
              barValue: punctualityScore,
            ),
            const SizedBox(height: 10),
            _AiMetricRow(
              label: 'Confiança do ETA',
              value: '${(etaConfidence * 100).round()}%',
              valueColor: ZeloColors.accent,
              showBar: true,
              barValue: etaConfidence,
            ),
            const SizedBox(height: 10),
            _AiMetricRow(
              label: 'Latência de inferência',
              value: '${inferenceMs}ms',
              valueColor: ZeloColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}

class _AiMetricRow extends StatelessWidget {
  final String label;
  final String value;
  final Color valueColor;
  final bool showBar;
  final double barValue;

  const _AiMetricRow({
    required this.label,
    required this.value,
    required this.valueColor,
    this.showBar = false,
    this.barValue = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(color: ZeloColors.textSecondary, fontSize: 13),
            ),
            Text(
              value,
              style: TextStyle(
                color: valueColor,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        if (showBar) ...[
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: barValue,
              minHeight: 5,
              backgroundColor: ZeloColors.divider,
              valueColor: AlwaysStoppedAnimation<Color>(valueColor),
            ),
          ),
        ],
      ],
    );
  }
}

// ── Banner de atraso ───────────────────────────────────────────────────────────

class _DelayBanner extends StatelessWidget {
  const _DelayBanner();

  @override
  Widget build(BuildContext context) {
    return const Material(
      elevation: 6,
      color: ZeloColors.warning,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.white, size: 22),
            SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'IA detectou atraso no trânsito',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                  Text(
                    'ETA recalculado: 23 min (+5 min)',
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
