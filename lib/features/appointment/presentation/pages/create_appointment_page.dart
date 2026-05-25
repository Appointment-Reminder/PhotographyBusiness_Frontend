import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photography_business_frontend/core/Presentation/layouts/main_layout.dart';
import 'package:photography_business_frontend/features/appointment/presentation/providers/appointment_providers.dart';
import 'package:photography_business_frontend/features/appointment/presentation/providers/state/appointment_state.dart';
import 'package:photography_business_frontend/features/business/domain/entities/business.dart';
import 'package:photography_business_frontend/features/business/presentation/providers/business_providers.dart';
import 'package:photography_business_frontend/features/business/presentation/providers/state/business_state.dart';
import 'package:photography_business_frontend/features/user_create/presentation/providers/auth_provders.dart';
import 'package:photography_business_frontend/features/user_create/presentation/providers/state/auth_state.dart';

class CreateAppointmentPage extends ConsumerStatefulWidget {
  const CreateAppointmentPage({super.key});

  @override
  ConsumerState<CreateAppointmentPage> createState() => _CreateAppointmentPageState();
}

class _CreateAppointmentPageState extends ConsumerState<CreateAppointmentPage> {
  final _formKey = GlobalKey<FormState>();
  final _clientNameController = TextEditingController();
  final _clientEmailController = TextEditingController();
  final _clientPhoneController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  Business? _selectedBusiness;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(businessNotifierProvider.notifier).loadMyBusinesses();
    });
  }

  @override
  void dispose() {
    _clientNameController.dispose();
    _clientEmailController.dispose();
    _clientPhoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appointmentState = ref.watch(appointmentNotifierProvider);
    final businessState = ref.watch(businessNotifierProvider);
    final authState = ref.watch(authNotifierProvider);

    ref.listen<AppointmentState>(appointmentNotifierProvider, (previous, next) {
      if (next is AppointmentDetailLoaded) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Appointment created successfully!')),
        );
        Navigator.pop(context, true);
      } else if (next is AppointmentError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.message)),
        );
      }
    });

    return MainLayout(
      title: 'Create Appointment',
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Create Appointment'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Business selector
                  if (businessState is BusinessListLoaded)
                    DropdownButtonFormField<Business>(
                      value: _selectedBusiness,
                      decoration: const InputDecoration(
                        labelText: 'Business',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.business),
                      ),
                      items: businessState.businesses.map((business) {
                        return DropdownMenuItem(
                          value: business,
                          child: Text(business.name),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedBusiness = value;
                        });
                      },
                      validator: (value) {
                        if (value == null) {
                          return 'Please select a business';
                        }
                        return null;
                      },
                    ),
                  const SizedBox(height: 16),

                  // Client name
                  TextFormField(
                    controller: _clientNameController,
                    decoration: const InputDecoration(
                      labelText: 'Client Name',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.person),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter client name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Client email
                  TextFormField(
                    controller: _clientEmailController,
                    decoration: const InputDecoration(
                      labelText: 'Client Email',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.email),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter client email';
                      }
                      if (!value.contains('@')) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Client phone
                  TextFormField(
                    controller: _clientPhoneController,
                    decoration: const InputDecoration(
                      labelText: 'Client Phone (Optional)',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.phone),
                    ),
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 16),

                  // Date picker
                  ListTile(
                    tileColor: Colors.grey[100],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: BorderSide(color: Colors.grey[300]!),
                    ),
                    leading: const Icon(Icons.calendar_today),
                    title: const Text('Appointment Date'),
                    subtitle: Text(_formatDate(_selectedDate)),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: _selectedDate,
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (date != null) {
                        setState(() {
                          _selectedDate = date;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 16),

                  // Time picker
                  ListTile(
                    tileColor: Colors.grey[100],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: BorderSide(color: Colors.grey[300]!),
                    ),
                    leading: const Icon(Icons.access_time),
                    title: const Text('Appointment Time'),
                    subtitle: Text(_selectedTime.format(context)),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () async {
                      final time = await showTimePicker(
                        context: context,
                        initialTime: _selectedTime,
                      );
                      if (time != null) {
                        setState(() {
                          _selectedTime = time;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 24),

                  // Submit button
                  if (appointmentState is AppointmentLoading)
                    const Center(child: CircularProgressIndicator())
                  else
                    ElevatedButton(
                      onPressed: _createAppointment,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text(
                        'Create Appointment',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _createAppointment() {
    if (_formKey.currentState!.validate()) {
      final authState = ref.read(authNotifierProvider);
      if (authState is! AuthAuthenticated) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('You must be logged in')),
        );
        return;
      }

      final appointmentDateTime = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _selectedTime.hour,
        _selectedTime.minute,
      );

      ref.read(appointmentNotifierProvider.notifier).createNewAppointment(
        clientName: _clientNameController.text,
        clientEmail: _clientEmailController.text,
        clientPhone: _clientPhoneController.text.isEmpty
            ? null
            : _clientPhoneController.text,
        appointmentDate: appointmentDateTime,
        userId: authState.user.id,
        businessId: _selectedBusiness!.id,
      );
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}