import { PrismaClient, AccountIntent, PropertyPurpose, PropertyType, FurnishingType, PropertyStatus, UserRole } from '@prisma/client';
import * as bcrypt from 'bcrypt';

const prisma = new PrismaClient();

async function main() {
  console.log('🌱 Starting database seed...');

  // Clear existing data
  console.log('Clearing existing data...');
  await prisma.auditLog.deleteMany();
  await prisma.inAppNotification.deleteMany();
  await prisma.report.deleteMany();
  await prisma.premiumOrder.deleteMany();
  await prisma.reminder.deleteMany();
  await prisma.moverBooking.deleteMany();
  await prisma.moverQuote.deleteMany();
  await prisma.movingItem.deleteMany();
  await prisma.movingRequest.deleteMany();
  await prisma.mover.deleteMany();
  await prisma.agreementSignature.deleteMany();
  await prisma.agreement.deleteMany();
  await prisma.verificationRequest.deleteMany();
  await prisma.call.deleteMany();
  await prisma.visitRequest.deleteMany();
  await prisma.inquiry.deleteMany();
  await prisma.propertyView.deleteMany();
  await prisma.favorite.deleteMany();
  await prisma.propertyAmenity.deleteMany();
  await prisma.floorPlan.deleteMany();
  await prisma.propertyPhoto.deleteMany();
  await prisma.property.deleteMany();
  await prisma.amenity.deleteMany();
  await prisma.refreshToken.deleteMany();
  await prisma.user.deleteMany();

  // Create Amenities
  console.log('Creating amenities...');
  const amenities = await Promise.all([
    prisma.amenity.create({ data: { name: 'Parking', icon: '🚗' } }),
    prisma.amenity.create({ data: { name: 'Lift', icon: '🛗' } }),
    prisma.amenity.create({ data: { name: 'Power Backup', icon: '⚡' } }),
    prisma.amenity.create({ data: { name: 'Gym', icon: '💪' } }),
    prisma.amenity.create({ data: { name: 'Swimming Pool', icon: '🏊' } }),
    prisma.amenity.create({ data: { name: 'Garden', icon: '🌳' } }),
    prisma.amenity.create({ data: { name: 'Security', icon: '🛡️' } }),
    prisma.amenity.create({ data: { name: 'Playground', icon: '🎮' } }),
    prisma.amenity.create({ data: { name: 'Club House', icon: '🏛️' } }),
    prisma.amenity.create({ data: { name: 'Gas Pipeline', icon: '🔥' } }),
  ]);

  // Create Users
  console.log('Creating users...');
  const passwordHash = await bcrypt.hash('password123', 10);

  const admin = await prisma.user.create({
    data: {
      name: 'Admin User',
      email: 'admin@nobroker.com',
      passwordHash,
      role: UserRole.ADMIN,
      intent: AccountIntent.BOTH,
    },
  });

  const owner1 = await prisma.user.create({
    data: {
      name: 'Rajesh Kumar',
      email: 'rajesh@example.com',
      passwordHash,
      role: UserRole.USER,
      intent: AccountIntent.OWNER,
    },
  });

  const owner2 = await prisma.user.create({
    data: {
      name: 'Priya Sharma',
      email: 'priya@example.com',
      passwordHash,
      role: UserRole.USER,
      intent: AccountIntent.OWNER,
    },
  });

  const seeker1 = await prisma.user.create({
    data: {
      name: 'Amit Patel',
      email: 'amit@example.com',
      passwordHash,
      role: UserRole.USER,
      intent: AccountIntent.SEEKER,
    },
  });

  const seeker2 = await prisma.user.create({
    data: {
      name: 'Sneha Reddy',
      email: 'sneha@example.com',
      passwordHash,
      role: UserRole.USER,
      intent: AccountIntent.SEEKER,
    },
  });

  // Create Properties
  console.log('Creating properties...');

  const property1 = await prisma.property.create({
    data: {
      ownerId: owner1.id,
      title: 'Spacious 3BHK Apartment in Bandra West',
      description: 'Beautiful 3BHK apartment with sea view, modern amenities, and excellent connectivity. Perfect for families looking for comfort and convenience in the heart of Mumbai.',
      purpose: PropertyPurpose.RENT,
      type: PropertyType.APARTMENT,
      address: 'Hill Road, Bandra West',
      locality: 'Bandra West',
      city: 'Mumbai',
      state: 'Maharashtra',
      postalCode: '400050',
      price: 75000,
      securityDeposit: 150000,
      areaSqFt: 1450,
      bedrooms: 3,
      bathrooms: 2,
      balconies: 2,
      furnishing: FurnishingType.SEMI_FURNISHED,
      floor: 8,
      totalFloors: 15,
      availableFrom: new Date('2024-11-01'),
      status: PropertyStatus.PUBLISHED,
      isVerifiedOwnerSnapshot: true,
      isPremium: true,
      premiumUntil: new Date(Date.now() + 30 * 24 * 60 * 60 * 1000),
    },
  });

  await prisma.propertyPhoto.createMany({
    data: [
      { propertyId: property1.id, url: 'https://images.unsplash.com/photo-1522708323590-d24dbb6b0267', roomTag: 'Living Room', sortOrder: 0, isCover: true },
      { propertyId: property1.id, url: 'https://images.unsplash.com/photo-1540518614846-7eded433c457', roomTag: 'Bedroom', sortOrder: 1, isCover: false },
      { propertyId: property1.id, url: 'https://images.unsplash.com/photo-1556912172-45b7abe8b7e1', roomTag: 'Kitchen', sortOrder: 2, isCover: false },
      { propertyId: property1.id, url: 'https://images.unsplash.com/photo-1552321554-5fefe8c9ef14', roomTag: 'Balcony', sortOrder: 3, isCover: false },
    ],
  });

  await prisma.propertyAmenity.createMany({
    data: [
      { propertyId: property1.id, amenityId: amenities[0].id }, // Parking
      { propertyId: property1.id, amenityId: amenities[1].id }, // Lift
      { propertyId: property1.id, amenityId: amenities[2].id }, // Power Backup
      { propertyId: property1.id, amenityId: amenities[3].id }, // Gym
      { propertyId: property1.id, amenityId: amenities[6].id }, // Security
    ],
  });

  const property2 = await prisma.property.create({
    data: {
      ownerId: owner1.id,
      title: '2BHK Flat Near Andheri Station',
      description: 'Well-maintained 2BHK flat with easy access to Andheri station. Ideal for working professionals. Close to markets, schools, and hospitals.',
      purpose: PropertyPurpose.RENT,
      type: PropertyType.APARTMENT,
      address: 'SV Road, Andheri West',
      locality: 'Andheri West',
      city: 'Mumbai',
      state: 'Maharashtra',
      postalCode: '400058',
      price: 45000,
      securityDeposit: 90000,
      areaSqFt: 950,
      bedrooms: 2,
      bathrooms: 2,
      balconies: 1,
      furnishing: FurnishingType.FULLY_FURNISHED,
      floor: 5,
      totalFloors: 10,
      availableFrom: new Date('2024-10-15'),
      status: PropertyStatus.PUBLISHED,
      isVerifiedOwnerSnapshot: true,
    },
  });

  await prisma.propertyPhoto.createMany({
    data: [
      { propertyId: property2.id, url: 'https://images.unsplash.com/photo-1502672260266-1c1ef2d93688', roomTag: 'Living Room', sortOrder: 0, isCover: true },
      { propertyId: property2.id, url: 'https://images.unsplash.com/photo-1560448204-e02f11c3d0e2', roomTag: 'Bedroom', sortOrder: 1, isCover: false },
      { propertyId: property2.id, url: 'https://images.unsplash.com/photo-1556911220-bff31c812dba', roomTag: 'Kitchen', sortOrder: 2, isCover: false },
    ],
  });

  await prisma.propertyAmenity.createMany({
    data: [
      { propertyId: property2.id, amenityId: amenities[0].id },
      { propertyId: property2.id, amenityId: amenities[1].id },
      { propertyId: property2.id, amenityId: amenities[6].id },
    ],
  });

  const property3 = await prisma.property.create({
    data: {
      ownerId: owner2.id,
      title: 'Luxury 4BHK Villa in Juhu',
      description: 'Premium 4BHK independent villa with private garden and parking. Perfect for large families seeking luxury and privacy.',
      purpose: PropertyPurpose.BUY,
      type: PropertyType.VILLA,
      address: 'Juhu Tara Road',
      locality: 'Juhu',
      city: 'Mumbai',
      state: 'Maharashtra',
      postalCode: '400049',
      price: 85000000,
      securityDeposit: null,
      areaSqFt: 3500,
      bedrooms: 4,
      bathrooms: 4,
      balconies: 3,
      furnishing: FurnishingType.SEMI_FURNISHED,
      floor: null,
      totalFloors: null,
      availableFrom: new Date('2024-10-20'),
      status: PropertyStatus.PUBLISHED,
      isVerifiedOwnerSnapshot: true,
      isPremium: true,
      premiumUntil: new Date(Date.now() + 25 * 24 * 60 * 60 * 1000),
    },
  });

  await prisma.propertyPhoto.createMany({
    data: [
      { propertyId: property3.id, url: 'https://images.unsplash.com/photo-1613490493576-7fde63acd811', roomTag: 'Exterior', sortOrder: 0, isCover: true },
      { propertyId: property3.id, url: 'https://images.unsplash.com/photo-1600210492486-724fe5c67fb0', roomTag: 'Living Room', sortOrder: 1, isCover: false },
      { propertyId: property3.id, url: 'https://images.unsplash.com/photo-1616594039964-ae9021a400a0', roomTag: 'Bedroom', sortOrder: 2, isCover: false },
      { propertyId: property3.id, url: 'https://images.unsplash.com/photo-1600607687939-ce8a6c25118c', roomTag: 'Garden', sortOrder: 3, isCover: false },
    ],
  });

  await prisma.propertyAmenity.createMany({
    data: [
      { propertyId: property3.id, amenityId: amenities[0].id },
      { propertyId: property3.id, amenityId: amenities[2].id },
      { propertyId: property3.id, amenityId: amenities[3].id },
      { propertyId: property3.id, amenityId: amenities[4].id },
      { propertyId: property3.id, amenityId: amenities[5].id },
      { propertyId: property3.id, amenityId: amenities[6].id },
    ],
  });

  // Create more properties for variety
  const property4 = await prisma.property.create({
    data: {
      ownerId: owner2.id,
      title: 'Affordable 1BHK in Thane',
      description: 'Compact and cozy 1BHK apartment perfect for bachelors or couples. Well-connected to Mumbai and Navi Mumbai.',
      purpose: PropertyPurpose.RENT,
      type: PropertyType.APARTMENT,
      address: 'Ghodbunder Road',
      locality: 'Ghodbunder',
      city: 'Thane',
      state: 'Maharashtra',
      postalCode: '400607',
      price: 18000,
      securityDeposit: 36000,
      areaSqFt: 600,
      bedrooms: 1,
      bathrooms: 1,
      balconies: 1,
      furnishing: FurnishingType.UNFURNISHED,
      floor: 3,
      totalFloors: 7,
      availableFrom: new Date('2024-10-10'),
      status: PropertyStatus.PUBLISHED,
      isVerifiedOwnerSnapshot: false,
    },
  });

  await prisma.propertyPhoto.createMany({
    data: [
      { propertyId: property4.id, url: 'https://images.unsplash.com/photo-1502672023488-70e25813eb80', roomTag: 'Living Room', sortOrder: 0, isCover: true },
      { propertyId: property4.id, url: 'https://images.unsplash.com/photo-1617806118233-18e1de247200', roomTag: 'Bedroom', sortOrder: 1, isCover: false },
    ],
  });

  await prisma.propertyAmenity.createMany({
    data: [
      { propertyId: property4.id, amenityId: amenities[1].id },
      { propertyId: property4.id, amenityId: amenities[6].id },
    ],
  });

  // Create Movers
  console.log('Creating mover companies...');
  await prisma.mover.createMany({
    data: [
      { name: 'MoveMate Express', rating: 4.5, reviewCount: 234, phone: '+91 9876543210', description: 'Professional movers with 10+ years experience', isActive: true },
      { name: 'UrbanShift Packers', rating: 4.3, reviewCount: 187, phone: '+91 9876543211', description: 'Fast and reliable moving services', isActive: true },
      { name: 'HomeTransit Pro', rating: 4.7, reviewCount: 312, phone: '+91 9876543212', description: 'Premium moving and packing solutions', isActive: true },
      { name: 'QuickMove Logistics', rating: 4.2, reviewCount: 156, phone: '+91 9876543213', description: 'Budget-friendly moving services', isActive: true },
      { name: 'SafeShift Movers', rating: 4.6, reviewCount: 278, phone: '+91 9876543214', description: 'Insured and secure relocation services', isActive: true },
    ],
  });

  // Create some sample favorites
  console.log('Creating sample favorites and inquiries...');
  await prisma.favorite.createMany({
    data: [
      { userId: seeker1.id, propertyId: property1.id },
      { userId: seeker1.id, propertyId: property3.id },
      { userId: seeker2.id, propertyId: property2.id },
    ],
  });

  // Create sample inquiries
  await prisma.inquiry.createMany({
    data: [
      {
        propertyId: property1.id,
        seekerId: seeker1.id,
        ownerId: owner1.id,
        message: 'Hi, I am interested in this property. Is it still available? Can I schedule a visit?',
      },
      {
        propertyId: property2.id,
        seekerId: seeker2.id,
        ownerId: owner1.id,
        message: 'Is the rent negotiable? Also, when is the earliest move-in date possible?',
      },
    ],
  });

  console.log('✅ Database seeded successfully!');
  console.log('\n📋 Test Accounts:');
  console.log('Admin: admin@nobroker.com / password123');
  console.log('Owner 1: rajesh@example.com / password123');
  console.log('Owner 2: priya@example.com / password123');
  console.log('Seeker 1: amit@example.com / password123');
  console.log('Seeker 2: sneha@example.com / password123');
  console.log('\n🏠 Created 4 properties with photos and amenities');
  console.log('🚚 Created 5 mover companies');
  console.log('⭐ Created sample favorites and inquiries');
}

main()
  .catch((e) => {
    console.error('Error seeding database:', e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
