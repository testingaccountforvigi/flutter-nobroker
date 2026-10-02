/// Application-wide constants.
class AppConstants {
  AppConstants._();

  // Property Types
  static const List<String> propertyTypes = [
    'Apartment',
    'House',
    'Villa',
    'PG',
    'Studio',
    'Other',
  ];

  // Furnishing Types
  static const List<String> furnishingTypes = [
    'Fully Furnished',
    'Semi Furnished',
    'Unfurnished',
  ];

  // BHK Options
  static const List<String> bhkOptions = [
    '1 BHK',
    '2 BHK',
    '3 BHK',
    '4 BHK',
    '4+ BHK',
  ];

  // Common Amenities
  static const List<String> commonAmenities = [
    'Parking',
    'Lift',
    'Power Backup',
    'Gym',
    'Swimming Pool',
    'Garden',
    'Security',
    'Playground',
    'Club House',
    'Intercom',
    'Gas Pipeline',
    'Maintenance Staff',
  ];

  // Room Tags
  static const List<String> roomTags = [
    'Living Room',
    'Bedroom',
    'Kitchen',
    'Bathroom',
    'Balcony',
    'Dining',
    'Study',
    'Exterior',
    'Other',
  ];

  // Document Types for Verification
  static const List<String> documentTypes = [
    'Aadhaar',
    'PAN',
    'Driving License',
    'Passport',
    'Voter ID',
    'Other',
  ];

  // Major Cities
  static const List<String> majorCities = [
    'Mumbai',
    'Navi Mumbai',
    'Thane',
    'Pune',
    'Bangalore',
    'Delhi',
    'Gurgaon',
    'Noida',
    'Hyderabad',
    'Chennai',
  ];
}
