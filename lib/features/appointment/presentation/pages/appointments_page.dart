import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photography_business_frontend/core/Presentation/layouts/main_layout.dart';
import 'package:photography_business_frontend/features/appointment/presentation/pages/appointment_detail_page.dart';
import 'package:photography_business_frontend/features/appointment/presentation/pages/create_appointment_page.dart';
import 'package:photography_business_frontend/features/appointment/presentation/providers/appointment_providers.dart';
import 'package:photography_business_frontend/features/appointment/presentation/providers/state/appointment_state.dart';
import 'package:photography_business_frontend/features/appointment/presentation/widgets/appointment_card.dart';
import 'package:photography_business_frontend/features/business/presentation/providers/business_providers.dart';
import 'package:photography_business_frontend/features/business/presentation/providers/state/business_state.dart';

class AppointmentsPage extends ConsumerStatefulWidget {
  const AppointmentsPage({super.key});

  @override
  ConsumerState<AppointmentsPage> createState() => _AppointmentsPageState();
}

class _AppointmentsPageState extends ConsumerState<AppointmentsPage> {
  int? _selectedBusinessId; // null = "All"

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      // Load businesses for the selector
      ref.read(businessNotifierProvider.notifier).loadMyBusinesses();
      // Load all appointments initially
      _loadAppointments();
    });
  }

  void _loadAppointments() {
    if (_selectedBusinessId == null) {
      // Load all appointments
      ref.read(appointmentNotifierProvider.notifier).loadMyAppointments();
    } else {
      // Load appointments for specific business
      ref.read(appointmentNotifierProvider.notifier).loadAppointmentsForBusiness(
        businessId: _selectedBusinessId!,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final appointmentState = ref.watch(appointmentNotifierProvider);
    final businessState = ref.watch(businessNotifierProvider);

    return MainLayout(
      title: 'Appointments',
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Appointments'),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _loadAppointments,
            ),
          ],
        ),
        body: Column(
          children: [

            // Appointments list
            Expanded(
              child: _buildBody(appointmentState),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const CreateAppointmentPage()),
            );

            if (result == true) {
              _loadAppointments();
            }
          },
          child: const Icon(Icons.add),
        ),
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
            Text(
              state.message,
              style: const TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadAppointments,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (state is AppointmentListLoaded) {
      if (state.appointments.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.event_busy, size: 64, color: Colors.grey[400]),
              const SizedBox(height: 16),
              Text(
                'No appointments yet',
                style: TextStyle(fontSize: 18, color: Colors.grey[600]),
              ),
              const SizedBox(height: 8),
              Text(
                _selectedBusinessId == null
                    ? 'Create your first appointment to get started'
                    : 'No appointments for this business',
                style: TextStyle(color: Colors.grey[500]),
              ),
            ],
          ),
        );
      }

      return RefreshIndicator(
        onRefresh: () async {
          _loadAppointments();
        },
        child: ListView.builder(
          itemCount: state.appointments.length,
          itemBuilder: (context, index) {
            final appointment = state.appointments[index];
            return AppointmentCard(
              appointment: appointment,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AppointmentDetailPage(
                      appointmentId: appointment.id,
                      businessId: appointment.businessId ?? 0,
                    ),
                  ),
                );
              },
            );
          },
        ),
      );
    }

    return const Center(child: Text('Unknown state'));
  }
}