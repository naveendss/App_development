import '../models/gym_model.dart';
import '../models/booking_model.dart';

class MockDataService {
  static List<Gym> getGyms() {
    final now = DateTime.now();
    return [
      Gym(
        id: '1',
        name: 'Iron Haven',
        address: 'Industrial District, Suite 402',
        city: 'Mumbai',
        state: 'Maharashtra',
        zipCode: '400001',
        latitude: 19.0760,
        longitude: 72.8777,
        rating: 4.9,
        totalReviews: 120,
        isActive: true,
        createdAt: now,
        updatedAt: now,
        distance: 0.8,
        facilities: ['Cardio Zone', 'Free Weights', 'Power Racks', 'Sauna'],
        status: 'Open Now',
      ),
      Gym(
        id: '2',
        name: 'The Forge Studio',
        address: 'Riverside Ave, Building 2',
        city: 'Mumbai',
        state: 'Maharashtra',
        zipCode: '400002',
        latitude: 19.0728,
        longitude: 72.8326,
        rating: 4.7,
        totalReviews: 85,
        isActive: true,
        createdAt: now,
        updatedAt: now,
        distance: 1.2,
        facilities: ['Cycling Studio', 'Yoga', 'HIIT Zone'],
        status: 'Open Now',
      ),
      Gym(
        id: '3',
        name: 'Iron Paradise',
        address: '123 Muscle Way, Fitness City',
        city: 'Mumbai',
        state: 'Maharashtra',
        zipCode: '400003',
        latitude: 19.1136,
        longitude: 72.8697,
        rating: 4.9,
        totalReviews: 200,
        isActive: true,
        createdAt: now,
        updatedAt: now,
        distance: 1.5,
        facilities: ['Cardio Zone', 'Free Weights', 'Yoga Studio', 'Sauna & Spa'],
        status: 'Open 24/7',
      ),
      Gym(
        id: '4',
        name: 'Power Lift Center',
        address: '456 Strength Street',
        city: 'Mumbai',
        state: 'Maharashtra',
        zipCode: '400004',
        latitude: 19.0544,
        longitude: 72.8320,
        rating: 4.7,
        totalReviews: 95,
        isActive: true,
        createdAt: now,
        updatedAt: now,
        distance: 2.0,
        facilities: ['Crossfit', 'HIIT Zone', 'Boxing Ring'],
        status: 'Busiest at 6PM',
      ),
      Gym(
        id: '5',
        name: 'Zenith Wellness',
        address: '789 Wellness Boulevard',
        city: 'Mumbai',
        state: 'Maharashtra',
        zipCode: '400005',
        latitude: 19.0990,
        longitude: 72.8265,
        rating: 4.8,
        totalReviews: 150,
        isActive: true,
        createdAt: now,
        updatedAt: now,
        distance: 2.4,
        facilities: ['Yoga', 'Pilates', 'Pool', 'Spa'],
        status: 'Closing Soon',
      ),
    ];
  }

  static List<String> getCategories() {
    return [
      'All Equipment',
      'Treadmill',
      'Cycling',
      'One-Day Pass',
      'Monthly Pass',
      'Annual Pass',
    ];
  }

  static List<String> getTimeSlots() {
    return [
      '08:00 AM',
      '09:00 AM',
      '10:00 AM',
      '11:00 AM',
      '12:00 PM',
      '01:00 PM',
      '02:00 PM',
      '03:00 PM',
      '04:00 PM',
      '05:00 PM',
      '06:00 PM',
      '07:00 PM',
    ];
  }

  static List<Map<String, dynamic>> getSlotAvailability() {
    return [
      {'time': '08:00 AM', 'available': true},
      {'time': '09:00 AM', 'available': false},
      {'time': '10:00 AM', 'available': true},
      {'time': '11:00 AM', 'available': true},
      {'time': '12:00 PM', 'available': true},
      {'time': '01:00 PM', 'available': false},
      {'time': '02:00 PM', 'available': true},
      {'time': '03:00 PM', 'available': true},
      {'time': '04:00 PM', 'available': true},
      {'time': '05:00 PM', 'available': false},
      {'time': '06:00 PM', 'available': true},
      {'time': '07:00 PM', 'available': true},
    ];
  }

  static List<Booking> getMockBookings() {
    final now = DateTime.now();
    return [
      Booking(
        id: 'BK001',
        userId: 'user1',
        gymId: '1',
        slotId: 'slot1',
        bookingDate: now.add(const Duration(days: 2)),
        startTime: '08:00',
        endTime: '09:00',
        totalPrice: 150.0,
        status: 'upcoming',
        createdAt: now,
        updatedAt: now,
        gymName: 'Iron Haven',
        gymImage: 'https://images.unsplash.com/photo-1534438327276-14e5300c3a48?w=800',
        equipmentType: 'Treadmill - Station 4',
      ),
      Booking(
        id: 'BK002',
        userId: 'user1',
        gymId: '3',
        slotId: 'slot2',
        bookingDate: now.add(const Duration(days: 5)),
        startTime: '18:00',
        endTime: '19:00',
        totalPrice: 200.0,
        status: 'upcoming',
        createdAt: now,
        updatedAt: now,
        gymName: 'Iron Paradise',
        gymImage: 'https://images.unsplash.com/photo-1540497077202-7c8a3999166f?w=800',
        equipmentType: 'Cycling - Station 2',
      ),
      Booking(
        id: 'BK003',
        userId: 'user1',
        gymId: '2',
        slotId: 'slot3',
        bookingDate: now.subtract(const Duration(days: 3)),
        startTime: '10:00',
        endTime: '11:00',
        totalPrice: 120.0,
        status: 'completed',
        createdAt: now.subtract(const Duration(days: 5)),
        updatedAt: now.subtract(const Duration(days: 3)),
        gymName: 'The Forge Studio',
        gymImage: 'https://images.unsplash.com/photo-1571902943202-507ec2618e8f?w=800',
        equipmentType: 'Yoga Class',
      ),
    ];
  }

  static List<String> getFitnessGoals() {
    return [
      'Weight Loss',
      'Muscle Gain',
      'General Fitness',
      'Endurance',
    ];
  }
}

