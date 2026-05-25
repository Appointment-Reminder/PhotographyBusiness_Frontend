import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:photography_business_frontend/core/Presentation/layouts/main_layout.dart';
import 'package:photography_business_frontend/features/appointment/presentation/pages/edit_appointment_page.dart';
import 'package:photography_business_frontend/features/appointment/presentation/providers/appointment_providers.dart';
import 'package:photography_business_frontend/features/appointment/presentation/providers/state/appointment_state.dart';

class AppointmentDetailPage extends ConsumerStatefulWidget {
  final int appointmentId;
  final int businessId;

  const AppointmentDetailPage({
    super.key,
    required this.appointmentId,
    required this.businessId,
  });

  @override
  ConsumerState<AppointmentDetailPage> createState() => _AppointmentDetailPageState();
}

class _AppointmentDetailPageState extends ConsumerState<AppointmentDetailPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(appointmentNotifierProvider.notifier).loadAppointmentById(
        businessId: widget.businessId,
        appointmentId: widget.appointmentId,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final appointmentState = ref.watch(appointmentNotifierProvider);

    return MainLayout(
      title: 'Appointment Details',
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Appointment Details'),
          actions: [
            // ADD THIS EDIT BUTTON
            if (appointmentState is AppointmentDetailLoaded)
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditAppointmentPage(
                        appointment: appointmentState.appointment,
                      ),
                    ),
                  );

                  // Reload appointment if edited
                  if (result == true) {
                    ref.read(appointmentNotifierProvider.notifier).loadAppointmentById(
                      businessId: widget.businessId,
                      appointmentId: widget.appointmentId,
                    );
                  }
                },
              ),
            if (appointmentState is AppointmentDetailLoaded)
              PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'delete') {
                    _showDeleteConfirmation(appointmentState.appointment.id);
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete, color: Colors.red),
                        SizedBox(width: 8),
                        Text('Delete Appointment', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                ],
              ),
          ],
        ),
        body: _buildBody(appointmentState),
      ),
    );
  }

  Widget _buildBody(AppointmentState state) {
    if (state is AppointmentLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state is AppointmentError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(state.message),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                ref.read(appointmentNotifierProvider.notifier).loadAppointmentById(
                  businessId: widget.businessId,
                  appointmentId: widget.appointmentId,
                );
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (state is AppointmentDetailLoaded) {
      final appointment = state.appointment;

      return SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.blue,
                      child: Text(
                        appointment.clientName[0].toUpperCase(),
                        style: const TextStyle(
                          fontSize: 24,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            appointment.clientName,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            appointment.clientEmail,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 16),
                _buildInfoRow(
                  icon: Icons.calendar_today,
                  label: 'Date',
                  value: DateFormat('EEEE, MMMM d, yyyy').format(appointment.appointmentDate),
                ),
                const SizedBox(height: 12),
                _buildInfoRow(
                  icon: Icons.access_time,
                  label: 'Time',
                  value: DateFormat('h:mm a').format(appointment.appointmentDate),
                ),
                if (appointment.clientPhone != null) ...[
                  const SizedBox(height: 12),
                  _buildInfoRow(
                    icon: Icons.phone,
                    label: 'Phone',
                    value: appointment.clientPhone!,
                  ),
                ],
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 8),
                _buildInfoRow(
                  icon: Icons.info_outline,
                  label: 'Created',
                  value: DateFormat('MMM d, yyyy').format(appointment.createdAt),
                ),
                const SizedBox(height: 8),
                _buildInfoRow(
                  icon: Icons.update,
                  label: 'Last Updated',
                  value: DateFormat('MMM d, yyyy').format(appointment.updatedAt),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return const Center(child: Text('Unknown state'));
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showDeleteConfirmation(int appointmentId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Appointment'),
        content: const Text(
          'Are you sure you want to delete this appointment? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(appointmentNotifierProvider.notifier).deleteAppointmentById(appointmentId);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}