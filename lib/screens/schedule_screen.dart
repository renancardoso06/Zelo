import 'package:flutter/material.dart';
import 'package:provider/provider.dart' hide Provider;
import '../models/models.dart';
import '../providers/app_provider.dart';
import '../services/api_service.dart';
import '../theme.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  final _cepCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  TimeOfDay _selectedTime = const TimeOfDay(hour: 9, minute: 0);
  int _hours = 2;
  bool _loadingCep = false;
  bool _submitting = false;

  @override
  void dispose() {
    _cepCtrl.dispose();
    _addressCtrl.dispose();
    super.dispose();
  }

  Future<void> _lookupCep() async {
    if (_cepCtrl.text.length < 8) return;
    setState(() => _loadingCep = true);
    final data = await ApiService.fetchAddress(_cepCtrl.text);
    if (mounted) {
      setState(() => _loadingCep = false);
      if (data != null) {
        _addressCtrl.text = '${data['logradouro']}, ${data['bairro']} — ${data['localidade']}/${data['uf']}';
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('CEP não encontrado')),
        );
      }
    }
  }

  Future<void> _confirm(Provider provider) async {
    if (_addressCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preencha o endereço')),
      );
      return;
    }
    setState(() => _submitting = true);
    final order = ServiceOrder(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      providerId: provider.id,
      providerName: provider.name,
      service: provider.category,
      scheduledDate: DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _selectedTime.hour,
        _selectedTime.minute,
      ),
      totalPrice: provider.pricePerHour * _hours,
      status: OrderStatus.confirmed,
      address: _addressCtrl.text,
    );
    await context.read<AppProvider>().createOrder(order);
    if (mounted) {
      setState(() => _submitting = false);
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_circle, color: ZeloColors.accent, size: 64),
              const SizedBox(height: 16),
              const Text('Pedido confirmado!', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              Text(
                'R\$ ${order.totalPrice.toStringAsFixed(2)} capturado.\nAcompanhe em "Meus Pedidos".',
                textAlign: TextAlign.center,
                style: const TextStyle(color: ZeloColors.textSecondary),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pushReplacementNamed(context, '/orders');
              },
              child: const Text('Ver meus pedidos'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = ModalRoute.of(context)!.settings.arguments as Provider;
    final total = provider.pricePerHour * _hours;

    return Scaffold(
      appBar: AppBar(title: const Text('Agendar Serviço')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8)],
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundImage: NetworkImage(provider.avatarUrl),
                  ),
                  const SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(provider.name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                      Text(provider.category, style: const TextStyle(color: ZeloColors.textSecondary, fontSize: 13)),
                    ],
                  ),
                  const Spacer(),
                  Text('R\$ ${provider.pricePerHour.toStringAsFixed(0)}/h',
                      style: const TextStyle(color: ZeloColors.primary, fontWeight: FontWeight.w700, fontSize: 15)),
                ],
              ),
            ),
            const SizedBox(height: 24),

            const Text('Data', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
            const SizedBox(height: 8),
            InkWell(
              onTap: () async {
                final d = await showDatePicker(
                  context: context,
                  initialDate: _selectedDate,
                  firstDate: DateTime.now().add(const Duration(days: 1)),
                  lastDate: DateTime.now().add(const Duration(days: 60)),
                );
                if (d != null) setState(() => _selectedDate = d);
              },
              child: _FieldBox(
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today_outlined, color: ZeloColors.primary),
                    const SizedBox(width: 12),
                    Text(
                      '${_selectedDate.day.toString().padLeft(2, '0')}/${_selectedDate.month.toString().padLeft(2, '0')}/${_selectedDate.year}',
                      style: const TextStyle(fontSize: 15),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            const Text('Horário', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
            const SizedBox(height: 8),
            InkWell(
              onTap: () async {
                final t = await showTimePicker(context: context, initialTime: _selectedTime);
                if (t != null) setState(() => _selectedTime = t);
              },
              child: _FieldBox(
                child: Row(
                  children: [
                    const Icon(Icons.access_time_outlined, color: ZeloColors.primary),
                    const SizedBox(width: 12),
                    Text('${_selectedTime.hour.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')}',
                        style: const TextStyle(fontSize: 15)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                const Text('Duração', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                const Spacer(),
                Text('$_hours hora${_hours > 1 ? 's' : ''}', style: const TextStyle(color: ZeloColors.primary, fontWeight: FontWeight.w600)),
              ],
            ),
            Slider(
              value: _hours.toDouble(),
              min: 1,
              max: 8,
              divisions: 7,
              activeColor: ZeloColors.primary,
              label: '$_hours h',
              onChanged: (v) => setState(() => _hours = v.toInt()),
            ),
            const SizedBox(height: 16),

            const Text('Endereço', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextFormField(
                    controller: _cepCtrl,
                    keyboardType: TextInputType.number,
                    maxLength: 9,
                    decoration: const InputDecoration(labelText: 'CEP', counterText: ''),
                    onChanged: (v) { if (v.length == 8) _lookupCep(); },
                  ),
                ),
                const SizedBox(width: 12),
                _loadingCep
                    ? const CircularProgressIndicator()
                    : ElevatedButton(
                        onPressed: _lookupCep,
                        style: ElevatedButton.styleFrom(minimumSize: const Size(80, 52)),
                        child: const Text('Buscar'),
                      ),
              ],
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _addressCtrl,
              decoration: const InputDecoration(
                labelText: 'Endereço completo',
                prefixIcon: Icon(Icons.location_on_outlined),
              ),
            ),
            const SizedBox(height: 24),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: ZeloColors.primary.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  _PriceRow(label: 'Valor/hora', value: 'R\$ ${provider.pricePerHour.toStringAsFixed(2)}'),
                  const SizedBox(height: 6),
                  _PriceRow(label: 'Horas', value: '$_hours h'),
                  const Divider(height: 20),
                  _PriceRow(label: 'Total estimado', value: 'R\$ ${total.toStringAsFixed(2)}', bold: true),
                ],
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _submitting ? null : () => _confirm(provider),
              icon: _submitting
                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Icon(Icons.check_circle_outline),
              label: const Text('Confirmar agendamento'),
            ),
          ],
        ),
      ),
    );
  }
}

class _FieldBox extends StatelessWidget {
  final Widget child;
  const _FieldBox({required this.child});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: ZeloColors.divider),
        ),
        child: child,
      );
}

class _PriceRow extends StatelessWidget {
  final String label;
  final String value;
  final bool bold;
  const _PriceRow({required this.label, required this.value, this.bold = false});

  @override
  Widget build(BuildContext context) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: bold ? ZeloColors.textPrimary : ZeloColors.textSecondary, fontWeight: bold ? FontWeight.w700 : FontWeight.normal, fontSize: bold ? 15 : 13)),
          Text(value, style: TextStyle(color: bold ? ZeloColors.primary : ZeloColors.textPrimary, fontWeight: bold ? FontWeight.w800 : FontWeight.w500, fontSize: bold ? 16 : 13)),
        ],
      );
}
