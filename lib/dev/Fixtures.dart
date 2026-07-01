import 'package:photography_business_frontend/features/business/domain/entities/business.dart';
import 'package:photography_business_frontend/features/business/domain/entities/business_member.dart';
import 'package:photography_business_frontend/features/appointment/domain/entities/appointment.dart';
import 'package:photography_business_frontend/features/package/domain/entities/package.dart';
import 'package:photography_business_frontend/features/package/presentation/widgets/three_column_card.dart';

import '../features/user_create/domain/entities/user.dart';

class Fixtures {

  static final packageCategories = [
    CategoryEntry(
      id: 'tourist',
      name: 'Tourist',
      packages: [
        PackageEntry(
          id: 'tourist-a',
          name: 'Package A',
          description: '1 hour city walk, 20 edited photos',
          prices: [
            PriceEntry(amount: '120', currency: 'EUR', from: '01/2024', to: '12/2024', isCurrent: false),
            PriceEntry(amount: '140', currency: 'EUR', from: '01/2025', to: '12/2025', isCurrent: false),
            PriceEntry(amount: '160', currency: 'EUR', from: '01/2026', to: null,      isCurrent: true),
          ],
        ),
        PackageEntry(
          id: 'tourist-b',
          name: 'Package B',
          description: '2 hours, 2 locations, 40 edited photos',
          prices: [
            PriceEntry(amount: '200', currency: 'EUR', from: '01/2024', to: '12/2024', isCurrent: false),
            PriceEntry(amount: '260', currency: 'EUR', from: '01/2026', to: null,      isCurrent: true),
          ],
        ),
        PackageEntry(
          id: 'tourist-c',
          name: 'Package C',
          description: '2 hours, 2 locations, 40 edited photos',
          prices: [
            PriceEntry(amount: '200', currency: 'EUR', from: '01/2024', to: '12/2024', isCurrent: false),
            PriceEntry(amount: '260', currency: 'EUR', from: '01/2026', to: null,      isCurrent: true),
          ],
        ),
      ],
    ),
    CategoryEntry(
      id: 'wedding',
      name: 'Wedding',
      packages: [
        PackageEntry(
          id: 'wedding-a',
          name: 'Package A',
          description: 'Ceremony only, 3 hours, 100 edited photos',
          prices: [
            PriceEntry(amount: '950',   currency: 'EUR', from: '01/2025', to: '12/2025', isCurrent: false),
            PriceEntry(amount: '1 050', currency: 'EUR', from: '01/2026', to: null,      isCurrent: true),
          ],
        ),
        PackageEntry(
          id: 'wedding-b',
          name: 'Package B',
          description: 'Full day, 8 hours, 300 edited photos',
          prices: [
            PriceEntry(amount: '1 900', currency: 'EUR', from: '01/2025', to: '12/2025', isCurrent: false),
            PriceEntry(amount: '2 100', currency: 'EUR', from: '01/2026', to: null,      isCurrent: true),
          ],
        ),
      ],
    ),
    CategoryEntry(
      id: 'business',
      name: 'Business',
      packages: [
        PackageEntry(
          id: 'business-a',
          name: 'Package A',
          description: 'Headshots — 1 person, 10 final photos',
          prices: [
            PriceEntry(amount: '170', currency: 'EUR', from: '01/2025', to: '12/2025', isCurrent: false),
            PriceEntry(amount: '190', currency: 'EUR', from: '01/2026', to: null,      isCurrent: true),
          ],
        ),
      ],
    ),
  ];

  static const jotformFields = [
    'q1_name', 'q2_email', 'q3_phone',
    'q4_date', 'q5_location', 'q6_budget', 'q7_notes',
  ];

  static const targetFields = [
    'client_name', 'client_email', 'phone',
    'shoot_date', 'location', 'budget', 'notes', 'reference_id',
  ];

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