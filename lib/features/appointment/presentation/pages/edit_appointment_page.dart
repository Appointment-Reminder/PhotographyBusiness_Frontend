import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photography_business_frontend/core/Presentation/layouts/main_layout.dart';
import 'package:photography_business_frontend/features/appointment/domain/entities/appointment.dart';
import 'package:photography_business_frontend/features/appointment/presentation/providers/appointment_providers.dart';
import 'package:photography_business_frontend/features/appointment/presentation/providers/state/appointment_state.dart';
import 'package:photography_business_frontend/features/appointment/presentation/widgets/user_selector.dart';
import 'package:photography_business_frontend/features/business/presentation/providers/business_providers.dart';
import 'package:photography_business_frontend/features/business/presentation/providers/state/business_member_state.dart';


class EditAppointmentPage extends ConsumerStatefulWidget {
  final Appointment appointment;

  const EditAppointmentPage({
    super.key,
    required this.appointment,
  });

  @override
  ConsumerState<EditAppointmentPage> createState() => _EditAppointmentPageState();
}

class _EditAppointmentPageState extends ConsumerState<EditAppointmentPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _clientNameController;
  late TextEditingController _clientEmailController;
  late TextEditingController _clientPhoneController;

  late DateTime _selectedDate;
  late TimeOfDay _selectedTime;
  int? _selectedUserId;

  @override
  void initState() {
    super.initState();
    _clientNameController = TextEditingController(text: widget.appointment.clientName);
    _clientEmailController = TextEditingController(text: widget.appointment.clientEmail);
    _clientPhoneController = TextEditingController(text: widget.appointment.clientPhone ?? '');

    _selectedDate = widget.appointment.appointmentDate;
    _selectedTime = TimeOfDay(
      hour: widget.appointment.appointmentDate.hour,
      minute: widget.appointment.appointmentDate.minute,
    );

    // Load members for the business
    if (widget.appointment.businessId != null) {
      Future.microtask(() {
        ref.read(businessMemberNotifierProvider.notifier)
            .loadMembers(widget.appointment.businessId!);
      });
    }
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

    ref.listen<AppointmentState>(appointmentNotifierProvider, (previous, next) {
      if (next is AppointmentDetailLoaded) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Appointment updated successfully!')),
        );
        Navigator.pop(context, true);
      } else if (next is AppointmentError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.message)),
        );
      }
    });

    return MainLayout(
      title: 'Edit Appointment',
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Edit Appointment'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Business info (read-only)
                  if (widget.appointment.businessId != null)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.blue[200]!),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.business, color: Colors.blue[700]),
                          const SizedBox(width: 12),
                          Text(
                            'Business ID: ${widget.appointment.businessId}',
                            style: TextStyle(
                              color: Colors.blue[700],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 16),

                  // Photographer selector
                  Builder(
                    builder: (context) {
                      final memberState = ref.watch(businessMemberNotifierProvider);

                      if (memberState is MembersLoaded) {
                        return UserSelector(
                          members: memberState.members,
                          selectedUserId: _selectedUserId ?? widget.appointment.userId,
                          onUserSelected: (userId) {
                            setState(() {
                              _selectedUserId = userId;
                            });
                          },
                        );
                      } else if (memberState is MemberLoading) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(16.0),
                            child: CircularProgressIndicator(),
                          ),
                        );
                      }

                      return const SizedBox.shrink();
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
                        firstDate: DateTime.now().subtract(const Duration(days: 365)),
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
                      onPressed: _updateAppointment,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text(
                        'Update Appointment',
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

  // Then update _updateAppointment method to use _selectedUserId:
  void _updateAppointment() {
    if (_formKey.currentState!.validate()) {
      if (widget.appointment.businessId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Business ID is required')),
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

      ref.read(appointmentNotifierProvider.notifier).updateExistingAppointment(
        businessId: widget.appointment.businessId!,
        appointmentId: widget.appointment.id,
        clientName: _clientNameController.text,
        clientEmail: _clientEmailController.text,
        clientPhone: _clientPhoneController.text.isEmpty
            ? null
            : _clientPhoneController.text,
        appointmentDate: appointmentDateTime,
        userId: _selectedUserId ?? widget.appointment.userId, // Use selected or keep current
      );
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}