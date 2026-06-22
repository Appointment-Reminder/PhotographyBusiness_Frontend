import 'package:photography_business_frontend/features/business/domain/entities/business.dart';
import 'package:photography_business_frontend/features/business/domain/entities/business_member.dart';
import 'package:photography_business_frontend/features/appointment/domain/entities/appointment.dart';
import 'package:photography_business_frontend/features/package/domain/entities/package.dart';

import '../features/user_create/domain/entities/user.dart';

class Fixtures {
  static final business = Business(
    id: 1,
    name: 'Léa Photography',
    description: 'Wedding & portrait studio',
    ownerId: 1,
    isActive: true,
    createdAt: DateTime(2024, 1, 10),
    updatedAt: DateTime.now(),
  );

  static final user = User(id: 1, name: 'Léa Dupont', email: 'lea@example.com');

  static final businesses = [
    business,
    Business(id: 2, name: 'Studio Nord', ownerId: 1, isActive: false,
        createdAt: DateTime(2023, 6, 1), updatedAt: DateTime.now()),
  ];

  static final member = BusinessMember(
    id: 1,
    businessId: 1,
    userId: 2,
    role: 'photographer',
    webhookToken: 'tok_123',
    invitedAt: DateTime(2024, 2, 1),
    joinedAt: DateTime(2024, 2, 2),
    isActive: true,
    createdAt: DateTime(2024, 2, 1),
    userName: 'Marie Dubois',
    userEmail: 'marie@example.com',
  );

  static final appointment = Appointment(
    id: 1,
    clientName: 'Sophie Martin',
    clientEmail: 'sophie@example.com',
    clientPhone: '+33 6 12 34 56 78',
    appointmentDate: DateTime.now().add(const Duration(days: 3)),
    userId: 2,
    businessId: 1,
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
    photographerId: 2,
    photographerName: 'Marie Dubois',
    photographerEmail: 'marie@example.com',
  );

  static final package = Package(
    id: 1,
    businessId: 1,
    categoryId: 1,
    name: 'Wedding Premium',
    description: 'Full day coverage, 2 photographers, album included',
    isActive: true,
  );
}