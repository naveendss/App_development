import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/booking_service.dart';
import '../../../core/services/gym_service.dart';
import '../../../core/widgets/slot_tile.dart';

class SlotSelectionScreen extends StatefulWidget {
  final String gymId;
  final String equipmentType;
  final Map<String, dynamic>? extraData;

  const SlotSelectionScreen({
    super.key,
    required this.gymId,
    required this.equipmentType,
    this.extraData,
  });

  @override
  State<SlotSelectionScreen> createState() => _SlotSelectionScreenState();
}

class _SlotSelectionScreenState extends State<SlotSelectionScreen> {
  DateTime _selectedDate = DateTime.now();
  String? _selectedSlot;
  String? _selectedSlotId; // Add this to store the actual slot ID
  final _bookingService = BookingService();
  final _gymService = GymService();
  List<Map<String, dynamic>> _slots = [];
  List<Map<String, dynamic>> _equipment = [];
  String? _selectedEquipmentId;
  bool _isLoading = true;
  
  // Gym info from navigation
  String? _gymName;
  String? _gymAddress;
  String? _gymImage;
  String? _equipmentName;
  double? _totalPrice;

  @override
  void initState() {
    super.initState();
    // Extract gym info from extraData if available
    if (widget.extraData != null) {
      _gymName = widget.extraData!['gymName']?.toString();
      _gymAddress = widget.extraData!['gymAddress']?.toString();
      _gymImage = widget.extraData!['gymImage']?.toString();
      _equipmentName = widget.extraData!['equipmentName']?.toString();
      _totalPrice = widget.extraData!['totalPrice'] as double?;
    }
    _loadEquipmentAndSlots();
  }

  Future<void> _loadEquipmentAndSlots() async {
    try {
      setState(() => _isLoading = true);
      
      // Load equipment first
      final equipment = await _gymService.getGymEquipment(widget.gymId);
      setState(() {
        _equipment = equipment;
        if (equipment.isNotEmpty) {
          _selectedEquipmentId = equipment[0]['id'];
        }
      });
      
      // Then load slots
      await _loadSlots();
    } catch (e) {
      print('Error loading equipment: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadSlots() async {
    if (_selectedEquipmentId == null) return;
    
    try {
      setState(() => _isLoading = true);
      
      final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate);
      final slots = await _bookingService.getAvailableSlots(
        gymId: widget.gymId,
        date: dateStr,
        equipmentId: _selectedEquipmentId,
      );
      
      setState(() {
        _slots = slots;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading slots: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => context.pop(),
        ),
        title: const Text('Select Time Slot'),
        actions: [
          IconButton(
            icon: Icon(Icons.info, color: AppTheme.primaryColor),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          _buildDateSelector(),
          _buildLegend(),
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
                    ),
                  )
                : _slots.isEmpty
                    ? const Center(
                        child: Text(
                          'No slots available for this date',
                          style: TextStyle(color: Colors.white60, fontSize: 14),
                        ),
                      )
                    : SingleChildScrollView(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildEquipmentSelector(),
                            const SizedBox(height: 24),
                            ..._buildSlotsByTimeOfDay(),
                          ],
                        ),
                      ),
          ),
          _buildBottomBar(),
        ],
      ),
    );
  }

  Widget _buildDateSelector() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                DateFormat('MMMM yyyy').format(_selectedDate).toUpperCase(),
                style: TextStyle(
                  color: Colors.white38,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
              Icon(Icons.calendar_month, color: AppTheme.primaryColor),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 96,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: 7,
              separatorBuilder: (context, index) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final date = DateTime.now().add(Duration(days: index));
                final isSelected = index == 0;
                return GestureDetector(
                  onTap: () => setState(() => _selectedDate = date),
                  child: Container(
                    width: 68,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppTheme.primaryColor
                          : Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected
                            ? AppTheme.primaryColor
                            : Colors.white.withOpacity(0.05),
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          DateFormat('EEE').format(date).toUpperCase(),
                          style: TextStyle(
                            color: isSelected ? Colors.black : Colors.white38,
                            fontSize: 10,
                            fontWeight: isSelected ? FontWeight.w900 : FontWeight.w500,
                            letterSpacing: 1,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          DateFormat('d').format(date),
                          style: TextStyle(
                            color: isSelected ? Colors.black : Colors.white,
                            fontSize: isSelected ? 24 : 20,
                            fontWeight: isSelected ? FontWeight.w900 : FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegend() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          _buildLegendItem('Available', AppTheme.primaryColor.withOpacity(0.2)),
          const SizedBox(width: 24),
          _buildLegendItem('Booked', Colors.white.withOpacity(0.2)),
          const SizedBox(width: 24),
          _buildLegendItem('Selected', AppTheme.primaryColor),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            color: Colors.white60,
            fontSize: 11,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
      ],
    );
  }

  Widget _buildBottomBar() {
    final displayPrice = _totalPrice ?? 25.0;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.backgroundColor.withOpacity(0.95),
        border: Border(
          top: BorderSide(color: Colors.white.withOpacity(0.05)),
        ),
      ),
      child: SafeArea(
        child: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'TOTAL PAY',
                  style: TextStyle(
                    color: Colors.white38,
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 4),
                RichText(
                  text: TextSpan(
                    text: '₹${displayPrice.toStringAsFixed(2)}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                    ),
                    children: const [
                      TextSpan(
                        text: ' / session',
                        style: TextStyle(
                          color: Colors.white38,
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(width: 24),
            Expanded(
              child: SizedBox(
                height: 56,
                child: ElevatedButton(
                  onPressed: _selectedSlotId == null
                      ? null
                      : () {
                          context.push('/booking-summary', extra: {
                            'gymId': widget.gymId,
                            'gymName': _gymName ?? 'Gym',
                            'gymAddress': _gymAddress ?? 'Address',
                            'gymImage': _gymImage ?? '',
                            'equipmentType': widget.equipmentType,
                            'equipmentName': _equipmentName ?? 'Equipment',
                            'date': _selectedDate,
                            'timeSlot': _selectedSlot,
                            'slotId': _selectedSlotId, // Pass the actual slot ID
                            'price': displayPrice,
                          });
                        },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Text(
                        'PROCEED TO PAY',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      SizedBox(width: 8),
                      Icon(Icons.arrow_forward, size: 18),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEquipmentSelector() {
    if (_equipment.isEmpty) return const SizedBox.shrink();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'SELECT EQUIPMENT',
          style: TextStyle(
            color: Colors.white38,
            fontSize: 12,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 40,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _equipment.length,
            separatorBuilder: (context, index) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              final equip = _equipment[index];
              final isSelected = _selectedEquipmentId == equip['id'];
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedEquipmentId = equip['id'];
                  });
                  _loadSlots();
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: isSelected ? AppTheme.primaryColor : AppTheme.surfaceColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    equip['equipment_type'] ?? 'Equipment',
                    style: TextStyle(
                      color: isSelected ? Colors.black : Colors.white,
                      fontSize: 13,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  List<Widget> _buildSlotsByTimeOfDay() {
    final morning = _slots.where((s) {
      final hour = int.tryParse(s['start_time']?.toString().split(':')[0] ?? '0') ?? 0;
      return hour >= 6 && hour < 12;
    }).toList();
    
    final afternoon = _slots.where((s) {
      final hour = int.tryParse(s['start_time']?.toString().split(':')[0] ?? '0') ?? 0;
      return hour >= 12 && hour < 17;
    }).toList();
    
    final evening = _slots.where((s) {
      final hour = int.tryParse(s['start_time']?.toString().split(':')[0] ?? '0') ?? 0;
      return hour >= 17;
    }).toList();

    return [
      if (morning.isNotEmpty) ...[
        const Text(
          'Morning Slots',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        _buildRealSlotGrid(morning),
        const SizedBox(height: 24),
      ],
      if (afternoon.isNotEmpty) ...[
        const Text(
          'Afternoon Slots',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        _buildRealSlotGrid(afternoon),
        const SizedBox(height: 24),
      ],
      if (evening.isNotEmpty) ...[
        const Text(
          'Evening Slots',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        _buildRealSlotGrid(evening),
      ],
    ];
  }

  Widget _buildRealSlotGrid(List<Map<String, dynamic>> slots) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 2,
      ),
      itemCount: slots.length,
      itemBuilder: (context, index) {
        final slot = slots[index];
        final slotId = slot['id']?.toString();
        final startTime = slot['start_time'] ?? '';
        final endTime = slot['end_time'] ?? '';
        final isBooked = (slot['booked_count'] ?? 0) >= (slot['capacity'] ?? 1);
        
        // Format time string for display
        final formattedTime = _formatTimeSlot(startTime, endTime);
        
        return SlotTile(
          time: startTime,
          isAvailable: !isBooked,
          isSelected: _selectedSlotId == slotId,
          onTap: () {
            if (!isBooked && slotId != null) {
              setState(() {
                _selectedSlotId = slotId; // Store the actual slot ID
                _selectedSlot = formattedTime; // Store formatted time for display
              });
            }
          },
        );
      },
    );
  }

  String _formatTimeSlot(String startTime, String endTime) {
    try {
      // Parse time strings like "09:00:00" or "09:00"
      final startParts = startTime.split(':');
      final endParts = endTime.split(':');
      
      if (startParts.isEmpty || endParts.isEmpty) return startTime;
      
      int startHour = int.tryParse(startParts[0]) ?? 0;
      int endHour = int.tryParse(endParts[0]) ?? 0;
      
      // Convert to 12-hour format
      String startPeriod = startHour >= 12 ? 'PM' : 'AM';
      String endPeriod = endHour >= 12 ? 'PM' : 'AM';
      
      if (startHour > 12) startHour -= 12;
      if (startHour == 0) startHour = 12;
      if (endHour > 12) endHour -= 12;
      if (endHour == 0) endHour = 12;
      
      return '${startHour.toString().padLeft(2, '0')}:00 $startPeriod - ${endHour.toString().padLeft(2, '0')}:00 $endPeriod';
    } catch (e) {
      return startTime;
    }
  }
}
