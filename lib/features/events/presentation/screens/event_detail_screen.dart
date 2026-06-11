import 'package:campeando_frontend/features/events/data/models/event_detail_model.dart';
import 'package:campeando_frontend/features/events/domain/repositories/event_repository.dart';
import 'package:campeando_frontend/features/registration/data/models/registration_request_models.dart';
import 'package:campeando_frontend/features/registration/domain/repositories/registration_repository.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class EventDetailScreen extends StatefulWidget {
  final String eventId;
  const EventDetailScreen({super.key, required this.eventId});

  @override
  State<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends State<EventDetailScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();

  bool _isOtpSectionVisible = false;
  bool _isOtpVerified = false;
  bool _isLoading = false;

  late Future<EventDetailModel> _eventFuture;

  @override
  void initState() {
    super.initState();
    _eventFuture = context.read<EventRepository>().getEventById(widget.eventId);
  }

  Future<void> _requestOtp() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
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
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Future<void> _verifyOtp() async {
    setState(() => _isLoading = true);
    final verified = await context.read<RegistrationRepository>().verifyOtp(
          eventId: widget.eventId,
          request: VerifyOtpRequest(
            email: _emailController.text,
            otp: _otpController.text,
          ),
        );
    setState(() {
      _isLoading = false;
      if (verified) {
        _isOtpVerified = true;
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('OTP incorrecto')));
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
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Registro exitoso')));
      Navigator.pop(context);
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
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
          if (snapshot.hasError) return Center(child: Text('Error: ${snapshot.error}'));
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
                        Text('Capacidad: ${event.maxCapacity}', style: Theme.of(context).textTheme.bodyLarge),
                        const SizedBox(height: 16),
                        TextFormField(controller: _nameController, decoration: const InputDecoration(labelText: 'Nombre completo'), validator: (v) => v!.isEmpty ? 'Requerido' : null),
                        const SizedBox(height: 8),
                        TextFormField(controller: _emailController, decoration: const InputDecoration(labelText: 'Email'), validator: (v) => v!.isEmpty ? 'Requerido' : null),
                        const SizedBox(height: 8),
                        TextFormField(controller: _phoneController, decoration: const InputDecoration(labelText: 'Teléfono'), validator: (v) => v!.isEmpty ? 'Requerido' : null),
                        const SizedBox(height: 24),
                        if (!_isOtpVerified) ...[
                          if (!_isOtpSectionVisible)
                            FilledButton(onPressed: _isLoading ? null : _requestOtp, child: const Text('Solicitar OTP')),
                          if (_isOtpSectionVisible)
                            Row(children: [
                              Expanded(child: TextFormField(controller: _otpController, decoration: const InputDecoration(labelText: 'OTP'))),
                              const SizedBox(width: 8),
                              FilledButton(onPressed: _isLoading ? null : _verifyOtp, child: const Text('Verificar')),
                            ]),
                        ] else
                          const Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.check_circle, color: Colors.green), SizedBox(width: 8), Text('OTP Verificado')]),
                        const SizedBox(height: 24),
                        FilledButton(onPressed: (_isOtpVerified && !_isLoading) ? _submitRegistration : null, child: const Text('Registrarse')),
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
