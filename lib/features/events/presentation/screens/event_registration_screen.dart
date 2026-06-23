import 'package:campeando_frontend/features/events/data/models/event_detail_model.dart';
import 'package:campeando_frontend/features/events/domain/repositories/event_repository.dart';
import 'package:campeando_frontend/features/registration/data/models/registration_request_models.dart';
import 'package:campeando_frontend/features/registration/domain/repositories/registration_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class EventRegistrationScreen extends StatefulWidget {
  final String eventId;
  const EventRegistrationScreen({super.key, required this.eventId});

  @override
  State<EventRegistrationScreen> createState() =>
      _EventRegistrationScreenState();
}

class _EventRegistrationScreenState extends State<EventRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();

  bool _isOtpSectionVisible = false;
  bool _isOtpVerified = false;
  bool _isLoading = false;
  bool _isRequestingOtp = false;
  bool _isVerifyingOtp = false;

  late Future<EventDetailModel> _eventFuture;

  @override
  void initState() {
    super.initState();
    _eventFuture = context.read<EventRepository>().getEventById(widget.eventId);
  }

  Future<void> _requestOtp() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isRequestingOtp = true);
    try {
      await context.read<RegistrationRepository>().requestOtp(
        eventId: widget.eventId,
        request: RequestOtpRequest(
          email: _emailController.text,
          fullName: _nameController.text,
        ),
      );
      setState(() {
        _isOtpSectionVisible = true;
        _isRequestingOtp = false;
      });
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('OTP enviado a tu email')));
    } catch (e) {
      setState(() => _isRequestingOtp = false);
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Future<void> _verifyOtp() async {
    if (_otpController.text.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('El OTP debe tener 6 dígitos')),
      );
      return;
    }
    setState(() => _isVerifyingOtp = true);
    final verified = await context.read<RegistrationRepository>().verifyOtp(
      eventId: widget.eventId,
      request: VerifyOtpRequest(
        email: _emailController.text,
        otp: _otpController.text,
      ),
    );
    setState(() {
      _isVerifyingOtp = false;
      if (verified) {
        _isOtpVerified = true;
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('OTP incorrecto'),
            backgroundColor: Colors.red,
          ),
        );
      }
    });
  }

  Future<void> _submitRegistration() async {
    setState(() => _isLoading = true);
    try {
      await context.read<RegistrationRepository>().submitRegistration(
        eventId: widget.eventId,
        request: SubmitRegistrationRequest(
          email: _emailController.text,
          fullName: _nameController.text,
          phone: _phoneController.text,
        ),
      );
      setState(() => _isLoading = false);
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Registro exitoso')));
      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      setState(() => _isLoading = false);
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<EventDetailModel>(
        future: _eventFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final event = snapshot.data!;

          return CustomScrollView(
            slivers: [
              SliverAppBar.large(title: Text(event.name)),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Capacidad máxima: ${event.maxCapacity}',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        if (event.paymentQrImageUrl != null) ...[
                          const SizedBox(height: 24),
                          Text(
                            'Escanea el QR para realizar tu pago',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 12),
                          Center(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(
                                event.paymentQrImageUrl!,
                                height: 220,
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) =>
                                    const SizedBox(
                                      height: 220,
                                      child: Center(
                                        child: Icon(
                                          Icons.qr_code_2,
                                          size: 80,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ),
                              ),
                            ),
                          ),
                        ],
                        const SizedBox(height: 24),
                        TextFormField(
                          controller: _nameController,
                          decoration: const InputDecoration(
                            labelText: 'Nombre completo',
                            border: OutlineInputBorder(),
                          ),
                          validator: (v) => v!.isEmpty ? 'Requerido' : null,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _emailController,
                          decoration: const InputDecoration(
                            labelText: 'Email',
                            border: OutlineInputBorder(),
                          ),
                          validator: (v) => v!.isEmpty ? 'Requerido' : null,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _phoneController,
                          decoration: const InputDecoration(
                            labelText: 'Teléfono',
                            border: OutlineInputBorder(),
                          ),
                          validator: (v) => v!.isEmpty ? 'Requerido' : null,
                        ),
                        const SizedBox(height: 24),

                        // OTP Section
                        if (!_isOtpVerified) ...[
                          if (!_isOtpSectionVisible)
                            FilledButton.tonal(
                              onPressed: _isRequestingOtp ? null : _requestOtp,
                              child: _isRequestingOtp
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(),
                                    )
                                  : const Text(
                                      'Solicitar código de validación',
                                    ),
                            ),
                          if (_isOtpSectionVisible)
                            Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    controller: _otpController,
                                    keyboardType: TextInputType.number,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly,
                                    ],
                                    maxLength: 6,
                                    decoration: const InputDecoration(
                                      labelText: 'Código OTP',
                                      border: OutlineInputBorder(),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                FilledButton(
                                  onPressed: _isVerifyingOtp
                                      ? null
                                      : _verifyOtp,
                                  child: _isVerifyingOtp
                                      ? const SizedBox(
                                          height: 20,
                                          width: 20,
                                          child: CircularProgressIndicator(
                                            color: Colors.white,
                                          ),
                                        )
                                      : const Text('Verificar'),
                                ),
                              ],
                            ),
                        ] else
                          const ListTile(
                            leading: Icon(
                              Icons.check_circle,
                              color: Colors.green,
                              size: 40,
                            ),
                            title: Text(
                              '¡Validación exitosa!',
                              style: TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),

                        const SizedBox(height: 32),

                        // Final Registration Button
                        FilledButton(
                          onPressed: (_isOtpVerified && !_isLoading)
                              ? _submitRegistration
                              : null,
                          child: _isLoading
                              ? const CircularProgressIndicator(
                                  color: Colors.white,
                                )
                              : const Text('Registrarse en el evento'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
