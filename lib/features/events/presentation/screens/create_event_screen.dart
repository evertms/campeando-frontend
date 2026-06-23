import 'dart:convert';
import 'dart:typed_data';

import 'package:campeando_frontend/features/auth/presentation/auth_provider.dart';
import 'package:campeando_frontend/features/events/domain/repositories/event_repository.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class CreateEventScreen extends StatefulWidget {
  const CreateEventScreen({super.key});

  @override
  State<CreateEventScreen> createState() => _CreateEventScreenState();
}

class _CreateEventScreenState extends State<CreateEventScreen> {
  final _nameController = TextEditingController();
  final _capacityController = TextEditingController();
  DateTime _startDate = DateTime.now().add(const Duration(days: 1));
  DateTime _endDate = DateTime.now().add(const Duration(days: 1, hours: 2));
  bool _isLoading = false;

  final ImagePicker _picker = ImagePicker();
  Uint8List? _coverPreview;
  String? _coverBase64;
  Uint8List? _qrPreview;
  String? _qrBase64;

  Future<void> _pickImage({required bool isCover}) async {
    final image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 75,
      maxWidth: 1600,
    );
    if (image == null) return;

    final bytes = await image.readAsBytes();
    if (!mounted) return;
    setState(() {
      if (isCover) {
        _coverPreview = bytes;
        _coverBase64 = base64Encode(bytes);
      } else {
        _qrPreview = bytes;
        _qrBase64 = base64Encode(bytes);
      }
    });
  }

  Widget _imagePicker({
    required String label,
    required Uint8List? preview,
    required VoidCallback onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            height: 160,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade400),
            ),
            clipBehavior: Clip.antiAlias,
            child: preview != null
                ? Image.memory(preview, fit: BoxFit.cover)
                : const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add_photo_alternate_outlined, size: 36),
                      SizedBox(height: 8),
                      Text('Toca para seleccionar'),
                    ],
                  ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Crear Evento')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Nombre del Evento',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              title: const Text('Fecha de Inicio'),
              subtitle: Text(
                '${_startDate.day}/${_startDate.month}/${_startDate.year} ${_startDate.hour}:${_startDate.minute}',
              ),
              trailing: const Icon(Icons.calendar_today),
              onTap: () => _selectDate(true),
            ),
            ListTile(
              title: const Text('Fecha de Finalización'),
              subtitle: Text(
                '${_endDate.day}/${_endDate.month}/${_endDate.year} ${_endDate.hour}:${_endDate.minute}',
              ),
              trailing: const Icon(Icons.calendar_today),
              onTap: () => _selectDate(false),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _capacityController,
              decoration: const InputDecoration(
                labelText: 'Capacidad Máxima',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 24),
            _imagePicker(
              label: 'Portada del evento (opcional)',
              preview: _coverPreview,
              onTap: () => _pickImage(isCover: true),
            ),
            const SizedBox(height: 24),
            _imagePicker(
              label: 'QR de pago (opcional)',
              preview: _qrPreview,
              onTap: () => _pickImage(isCover: false),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _isLoading ? null : _create,
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Crear Evento'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate(bool isStart) async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: isStart ? _startDate : _endDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (pickedDate != null) {
      if (!mounted) {
        return;
      }
      final pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(isStart ? _startDate : _endDate),
      );

      if (pickedTime != null) {
        setState(() {
          final newDate = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
          if (isStart) {
            _startDate = newDate;
          } else {
            _endDate = newDate;
          }
        });
      }
    }
  }

  Future<void> _create() async {
    if (_nameController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('El nombre es obligatorio')));
      return;
    }

    setState(() => _isLoading = true);
    try {
      final auth = context.read<AuthProvider>();
      final orgId = auth.organizationId;
      if (orgId == null) {
        throw Exception('No se ha seleccionado una organización');
      }

      await context.read<EventRepository>().createEvent(
        name: _nameController.text,
        startDate: _startDate,
        endDate: _endDate,
        maxCapacity: int.tryParse(_capacityController.text) ?? 0,
        organizationId: orgId,
        coverImageBase64: _coverBase64,
        paymentQrBase64: _qrBase64,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Evento creado exitosamente')),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}
