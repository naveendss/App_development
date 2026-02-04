import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/api_service.dart';

class VendorRegisterScreen extends StatefulWidget {
  const VendorRegisterScreen({super.key});

  @override
  State<VendorRegisterScreen> createState() => _VendorRegisterScreenState();
}

class _VendorRegisterScreenState extends State<VendorRegisterScreen> {
  int _currentStep = 0;
  final _pageController = PageController();
  final _apiService = ApiService();
  bool _isLoading = false;
  
  // Step 1
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  
  // Step 2
  final _gymNameController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _zipController = TextEditingController();
  final _licenseController = TextEditingController();
  
  // Step 3 - Equipment/Services
  final List<Map<String, dynamic>> _selectedEquipment = [];
  final List<Map<String, dynamic>> _selectedPasses = [];
  
  // Step 4 - Operating Hours
  TimeOfDay _weekdayOpen = const TimeOfDay(hour: 6, minute: 0);
  TimeOfDay _weekdayClose = const TimeOfDay(hour: 22, minute: 0);
  TimeOfDay _weekendOpen = const TimeOfDay(hour: 8, minute: 0);
  TimeOfDay _weekendClose = const TimeOfDay(hour: 20, minute: 0);
  
  bool _obscurePassword = true;
  
  // Available equipment types
  final List<Map<String, dynamic>> _availableEquipment = [
    {'name': 'Treadmills', 'icon': '🏃', 'type': 'cardio'},
    {'name': 'Cycles', 'icon': '🚴', 'type': 'cardio'},
    {'name': 'Ellipticals', 'icon': '⚡', 'type': 'cardio'},
    {'name': 'Rowing Machines', 'icon': '🚣', 'type': 'cardio'},
    {'name': 'Dumbbells', 'icon': '🏋️', 'type': 'strength'},
    {'name': 'Barbells', 'icon': '💪', 'type': 'strength'},
    {'name': 'Bench Press', 'icon': '🛋️', 'type': 'strength'},
    {'name': 'Squat Rack', 'icon': '🦵', 'type': 'strength'},
    {'name': 'Cable Machines', 'icon': '🔗', 'type': 'strength'},
    {'name': 'Leg Press', 'icon': '🦿', 'type': 'strength'},
    {'name': 'Smith Machine', 'icon': '⚙️', 'type': 'strength'},
    {'name': 'Yoga Mats', 'icon': '🧘', 'type': 'flexibility'},
    {'name': 'Pilates Equipment', 'icon': '🤸', 'type': 'flexibility'},
    {'name': 'Stretching Area', 'icon': '🤲', 'type': 'flexibility'},
    {'name': 'Boxing Bags', 'icon': '🥊', 'type': 'combat'},
    {'name': 'Battle Ropes', 'icon': '🪢', 'type': 'functional'},
    {'name': 'Kettlebells', 'icon': '⚖️', 'type': 'functional'},
  ];

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _gymNameController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _zipController.dispose();
    _licenseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () {
            if (_currentStep > 0) {
              setState(() => _currentStep--);
              _pageController.previousPage(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            } else {
              context.pop();
            }
          },
        ),
        title: const Text('Create Vendor Account'),
      ),
      body: Column(
        children: [
          _buildProgressIndicator(),
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              onPageChanged: (index) => setState(() => _currentStep = index),
              children: [
                _buildStep1(),
                _buildStep2(),
                _buildStep3(),
                _buildStep4(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _getStepTitle(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Step ${_currentStep + 1} of 4',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.6),
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: List.generate(4, (index) {
              return Expanded(
                child: Container(
                  height: 4,
                  margin: EdgeInsets.only(right: index < 3 ? 8 : 0),
                  decoration: BoxDecoration(
                    color: index <= _currentStep
                        ? AppTheme.primaryColor
                        : Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  String _getStepTitle() {
    switch (_currentStep) {
      case 0:
        return 'Basic Information';
      case 1:
        return 'Business Details';
      case 2:
        return 'Services & Pricing';
      case 3:
        return 'Photos & Submit';
      default:
        return '';
    }
  }

  Widget _buildStep1() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTextField(
            controller: _nameController,
            label: 'Owner Full Name',
            hint: 'e.g., John Doe',
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _emailController,
            label: 'Business Email',
            hint: 'name@gym.com',
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _phoneController,
            label: 'Phone Number',
            hint: '(555) 000-0000',
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 16),
          _buildPasswordField(),
          const SizedBox(height: 32),
          _buildNextButton(),
        ],
      ),
    );
  }

  Widget _buildStep2() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTextField(
            controller: _gymNameController,
            label: 'Gym Name',
            hint: 'Enter your gym name',
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _addressController,
            label: 'Street Address',
            hint: 'Enter street address',
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _cityController,
            label: 'City',
            hint: 'Enter city',
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  controller: _stateController,
                  label: 'State',
                  hint: 'State',
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildTextField(
                  controller: _zipController,
                  label: 'ZIP Code',
                  hint: 'ZIP',
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _licenseController,
            label: 'Business License / Tax ID',
            hint: 'Enter ID if available',
            isOptional: true,
          ),
          const SizedBox(height: 32),
          _buildNextButton(),
        ],
      ),
    );
  }

  Widget _buildStep3() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Equipment & Pricing',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add equipment and set hourly rates',
            style: TextStyle(
              color: Colors.white.withOpacity(0.6),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 20),
          
          // Selected Equipment List
          if (_selectedEquipment.isNotEmpty) ...[
            ..._selectedEquipment.asMap().entries.map((entry) {
              final index = entry.key;
              final equipment = entry.value;
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildEquipmentCard(equipment, index),
              );
            }).toList(),
            const SizedBox(height: 12),
          ],
          
          // Add Equipment Button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _showAddEquipmentDialog,
              icon: const Icon(Icons.add),
              label: const Text('Add Equipment'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.primaryColor,
                side: const BorderSide(color: AppTheme.primaryColor),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 32),
          
          // Membership Passes Section
          const Text(
            'Membership Passes',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Create custom duration passes for users',
            style: TextStyle(
              color: Colors.white.withOpacity(0.6),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 20),
          
          // Selected Passes List
          if (_selectedPasses.isNotEmpty) ...[
            ..._selectedPasses.asMap().entries.map((entry) {
              final index = entry.key;
              final pass = entry.value;
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildPassCard(pass, index),
              );
            }).toList(),
            const SizedBox(height: 12),
          ],
          
          // Add Pass Button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _showAddPassDialog,
              icon: const Icon(Icons.add),
              label: const Text('Add Membership Pass'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.primaryColor,
                side: const BorderSide(color: AppTheme.primaryColor),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 32),
          _buildNextButton(),
        ],
      ),
    );
  }

  Widget _buildEquipmentCard(Map<String, dynamic> equipment, int index) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.primaryColor.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  equipment['icon'] ?? '🏋️',
                  style: const TextStyle(fontSize: 24),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      equipment['name'],
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${equipment['quantity']} units available',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.5),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.edit, color: AppTheme.primaryColor),
                onPressed: () => _editEquipment(index),
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => _removeEquipment(index),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'HOURLY RATE',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.5),
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '\$${equipment['hourly_rate']}/hr',
                        style: const TextStyle(
                          color: AppTheme.primaryColor,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'DAILY CAP',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.5),
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        equipment['daily_cap'] != null ? '\$${equipment['daily_cap']}' : 'None',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showAddEquipmentDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1A1A),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _AddEquipmentSheet(
        availableEquipment: _availableEquipment,
        onAdd: (equipment) {
          setState(() {
            _selectedEquipment.add(equipment);
          });
        },
      ),
    );
  }

  void _editEquipment(int index) {
    final equipment = _selectedEquipment[index];
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1A1A),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _AddEquipmentSheet(
        availableEquipment: _availableEquipment,
        initialEquipment: equipment,
        onAdd: (updatedEquipment) {
          setState(() {
            _selectedEquipment[index] = updatedEquipment;
          });
        },
      ),
    );
  }

  void _removeEquipment(int index) {
    setState(() {
      _selectedEquipment.removeAt(index);
    });
  }

  Widget _buildPassCard(Map<String, dynamic> pass, int index) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.primaryColor.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.card_membership,
                  color: Colors.black,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      pass['name'],
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${pass['duration_days']} days',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.5),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.edit, color: AppTheme.primaryColor),
                onPressed: () => _editPass(index),
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => _removePass(index),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'PRICE',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.5),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '\$${pass['price']}',
                  style: const TextStyle(
                    color: AppTheme.primaryColor,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showAddPassDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1A1A),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _AddPassSheet(
        onAdd: (pass) {
          setState(() {
            _selectedPasses.add(pass);
          });
        },
      ),
    );
  }

  void _editPass(int index) {
    final pass = _selectedPasses[index];
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1A1A),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _AddPassSheet(
        initialPass: pass,
        onAdd: (updatedPass) {
          setState(() {
            _selectedPasses[index] = updatedPass;
          });
        },
      ),
    );
  }

  void _removePass(int index) {
    setState(() {
      _selectedPasses.removeAt(index);
    });
  }

  Widget _buildStep4() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Operational Hours',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Set your gym opening hours',
            style: TextStyle(
              color: Colors.white.withOpacity(0.6),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 20),
          
          // Weekdays
          _buildOperatingHoursCard(
            'Weekdays (Mon - Fri)',
            _weekdayOpen,
            _weekdayClose,
            (open) => setState(() => _weekdayOpen = open),
            (close) => setState(() => _weekdayClose = close),
          ),
          
          const SizedBox(height: 16),
          
          // Weekends
          _buildOperatingHoursCard(
            'Weekends (Sat - Sun)',
            _weekendOpen,
            _weekendClose,
            (open) => setState(() => _weekendOpen = open),
            (close) => setState(() => _weekendClose = close),
          ),
          
          const SizedBox(height: 32),
          
          // Identity Verification Notice
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.primaryColor.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: AppTheme.primaryColor,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.verified,
                    color: Colors.black,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Identity Verification',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'We\'ll review your details within 24 hours.',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.6),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _handleSubmit,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                disabledBackgroundColor: AppTheme.primaryColor.withOpacity(0.5),
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                      ),
                    )
                  : const Text(
                      'Submit for Approval',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOperatingHoursCard(
    String title,
    TimeOfDay openTime,
    TimeOfDay closeTime,
    Function(TimeOfDay) onOpenChanged,
    Function(TimeOfDay) onCloseChanged,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildTimePicker(
                  'OPEN',
                  openTime,
                  onOpenChanged,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildTimePicker(
                  'CLOSE',
                  closeTime,
                  onCloseChanged,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimePicker(
    String label,
    TimeOfDay time,
    Function(TimeOfDay) onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.5),
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () async {
            final picked = await showTimePicker(
              context: context,
              initialTime: time,
              builder: (context, child) {
                return Theme(
                  data: ThemeData.dark().copyWith(
                    colorScheme: const ColorScheme.dark(
                      primary: AppTheme.primaryColor,
                      onPrimary: Colors.black,
                      surface: Color(0xFF1A1A1A),
                      onSurface: Colors.white,
                    ),
                  ),
                  child: child!,
                );
              },
            );
            if (picked != null) {
              onChanged(picked);
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withOpacity(0.1)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  time.format(context),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Icon(
                  Icons.access_time,
                  color: Colors.white.withOpacity(0.4),
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    TextInputType? keyboardType,
    int maxLines = 1,
    bool isOptional = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (isOptional) ...[
              const SizedBox(width: 8),
              Text(
                'Optional',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.4),
                  fontSize: 12,
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
            filled: true,
            fillColor: Colors.white.withOpacity(0.05),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: AppTheme.primaryColor, width: 2),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Create Password',
          style: TextStyle(
            color: Colors.white.withOpacity(0.8),
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _passwordController,
          obscureText: _obscurePassword,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Enter password',
            hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
            filled: true,
            fillColor: Colors.white.withOpacity(0.05),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: AppTheme.primaryColor, width: 2),
            ),
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword ? Icons.visibility_off : Icons.visibility,
                color: Colors.white.withOpacity(0.4),
              ),
              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Must be at least 8 characters with one number and symbol.',
          style: TextStyle(
            color: Colors.white.withOpacity(0.5),
            fontSize: 11,
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }

  Widget _buildLocationPicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Location on Map',
          style: TextStyle(
            color: Colors.white.withOpacity(0.8),
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () {},
          child: Container(
            height: 180,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withOpacity(0.1)),
            ),
            child: Stack(
              children: [
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.location_on,
                        color: AppTheme.primaryColor,
                        size: 48,
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Set Precise Location',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildServiceCard(String name, String price, String description) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  description,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.5),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            price,
            style: const TextStyle(
              color: AppTheme.primaryColor,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoUploader() {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 2,
          style: BorderStyle.solid,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.add_photo_alternate,
              color: Colors.black,
              size: 32,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Add Photos',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Upload gym photos (min. 3 required)',
            style: TextStyle(
              color: Colors.white.withOpacity(0.4),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNextButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _handleNext,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primaryColor,
          foregroundColor: Colors.black,
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: const Text(
          'Next',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  void _handleNext() {
    if (_currentStep < 3) {
      setState(() => _currentStep++);
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _handleSubmit() async {
    setState(() => _isLoading = true);

    try {
      // Register user
      final registerResponse = await _apiService.register({
        'full_name': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        'phone': _phoneController.text.trim(),
        'password': _passwordController.text,
      });

      if (!mounted) return;

      // Create gym
      final gymResponse = await _apiService.createGym({
        'name': _gymNameController.text.trim(),
        'address': _addressController.text.trim(),
        'city': _cityController.text.trim(),
        'state': _stateController.text.trim(),
        'zip_code': _zipController.text.trim(),
        'description': 'Welcome to ${_gymNameController.text}',
        'phone': _phoneController.text.trim(),
        'email': _emailController.text.trim(),
      });

      if (!mounted) return;

      final gymId = gymResponse['id'];

      // Create equipment
      for (final equipment in _selectedEquipment) {
        await _apiService.createEquipment({
          'gym_id': gymId,
          'equipment_name': equipment['name'],
          'equipment_type': equipment['type'],
          'quantity': equipment['quantity'],
          'available_quantity': equipment['quantity'],
          'hourly_rate': equipment['hourly_rate'],
          'description': equipment['description'] ?? '',
        });
      }

      // Create membership passes
      for (final pass in _selectedPasses) {
        await _apiService.createPass({
          'gym_id': gymId,
          'name': pass['name'],
          'duration_days': pass['duration_days'],
          'price': pass['price'],
          'pass_type': pass['pass_type'],
          'description': pass['description'] ?? '',
          'is_active': true,
        });
      }

      if (!mounted) return;

      // Navigate to success screen
      context.go('/onboarding-success');
    } catch (e) {
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}

// Equipment Selection Sheet
class _AddEquipmentSheet extends StatefulWidget {
  final List<Map<String, dynamic>> availableEquipment;
  final Map<String, dynamic>? initialEquipment;
  final Function(Map<String, dynamic>) onAdd;

  const _AddEquipmentSheet({
    required this.availableEquipment,
    this.initialEquipment,
    required this.onAdd,
  });

  @override
  State<_AddEquipmentSheet> createState() => _AddEquipmentSheetState();
}

class _AddEquipmentSheetState extends State<_AddEquipmentSheet> {
  Map<String, dynamic>? _selectedEquipment;
  final _quantityController = TextEditingController();
  final _hourlyRateController = TextEditingController();
  final _dailyCapController = TextEditingController();
  final _descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.initialEquipment != null) {
      _selectedEquipment = widget.availableEquipment.firstWhere(
        (e) => e['name'] == widget.initialEquipment!['name'],
      );
      _quantityController.text = widget.initialEquipment!['quantity'].toString();
      _hourlyRateController.text = widget.initialEquipment!['hourly_rate'].toString();
      _dailyCapController.text = widget.initialEquipment!['daily_cap']?.toString() ?? '';
      _descriptionController.text = widget.initialEquipment!['description'] ?? '';
    }
    
    // Add listeners to update button state
    _quantityController.addListener(() => setState(() {}));
    _hourlyRateController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _hourlyRateController.dispose();
    _dailyCapController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Add Equipment',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Equipment Type Dropdown
                      Text(
                        'Select Equipment Type',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.white.withOpacity(0.1)),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<Map<String, dynamic>>(
                            value: _selectedEquipment,
                            isExpanded: true,
                            hint: const Text(
                              'Choose equipment',
                              style: TextStyle(color: Colors.white54),
                            ),
                            dropdownColor: const Color(0xFF2A2A2A),
                            style: const TextStyle(color: Colors.white, fontSize: 16),
                            items: widget.availableEquipment.map((equipment) {
                              return DropdownMenuItem(
                                value: equipment,
                                child: Row(
                                  children: [
                                    Text(
                                      equipment['icon'],
                                      style: const TextStyle(fontSize: 20),
                                    ),
                                    const SizedBox(width: 12),
                                    Text(equipment['name']),
                                  ],
                                ),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() => _selectedEquipment = value);
                            },
                          ),
                        ),
                      ),
                      
                      if (_selectedEquipment != null) ...[
                        const SizedBox(height: 20),
                        
                        // Quantity
                        _buildTextField(
                          controller: _quantityController,
                          label: 'Number of Units',
                          hint: 'e.g., 10',
                          keyboardType: TextInputType.number,
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Hourly Rate
                        _buildTextField(
                          controller: _hourlyRateController,
                          label: 'Hourly Rate (\$)',
                          hint: 'e.g., 5.00',
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Daily Cap (Optional)
                        _buildTextField(
                          controller: _dailyCapController,
                          label: 'Daily Cap (\$)',
                          hint: 'e.g., 20.00 (optional)',
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          isOptional: true,
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Description (Optional)
                        _buildTextField(
                          controller: _descriptionController,
                          label: 'Description',
                          hint: 'Additional details (optional)',
                          maxLines: 3,
                          isOptional: true,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Add Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _selectedEquipment != null &&
                          _quantityController.text.isNotEmpty &&
                          _hourlyRateController.text.isNotEmpty
                      ? _handleAdd
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    disabledBackgroundColor: Colors.grey.shade800,
                  ),
                  child: Text(
                    widget.initialEquipment != null ? 'Update Equipment' : 'Add Equipment',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    TextInputType? keyboardType,
    int maxLines = 1,
    bool isOptional = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (isOptional) ...[
              const SizedBox(width: 8),
              Text(
                'Optional',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.4),
                  fontSize: 12,
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
            filled: true,
            fillColor: Colors.white.withOpacity(0.05),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppTheme.primaryColor, width: 2),
            ),
          ),
        ),
      ],
    );
  }

  void _handleAdd() {
    final equipment = {
      'name': _selectedEquipment!['name'],
      'icon': _selectedEquipment!['icon'],
      'type': _selectedEquipment!['type'],
      'quantity': int.parse(_quantityController.text),
      'hourly_rate': double.parse(_hourlyRateController.text),
      'daily_cap': _dailyCapController.text.isNotEmpty 
          ? double.parse(_dailyCapController.text) 
          : null,
      'description': _descriptionController.text.isNotEmpty 
          ? _descriptionController.text 
          : null,
    };
    
    widget.onAdd(equipment);
    Navigator.pop(context);
  }
}

// Pass Creation Sheet
class _AddPassSheet extends StatefulWidget {
  final Map<String, dynamic>? initialPass;
  final Function(Map<String, dynamic>) onAdd;

  const _AddPassSheet({
    this.initialPass,
    required this.onAdd,
  });

  @override
  State<_AddPassSheet> createState() => _AddPassSheetState();
}

class _AddPassSheetState extends State<_AddPassSheet> {
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _selectedDuration = '30'; // days
  String _selectedType = 'monthly';

  final List<Map<String, String>> _durations = [
    {'label': '1 Day', 'days': '1', 'type': 'daily'},
    {'label': '7 Days', 'days': '7', 'type': 'weekly'},
    {'label': '30 Days', 'days': '30', 'type': 'monthly'},
    {'label': '90 Days', 'days': '90', 'type': 'quarterly'},
    {'label': '365 Days', 'days': '365', 'type': 'annual'},
  ];

  @override
  void initState() {
    super.initState();
    if (widget.initialPass != null) {
      _nameController.text = widget.initialPass!['name'];
      _priceController.text = widget.initialPass!['price'].toString();
      _selectedDuration = widget.initialPass!['duration_days'].toString();
      _selectedType = widget.initialPass!['pass_type'];
      _descriptionController.text = widget.initialPass!['description'] ?? '';
    }
    
    // Add listeners to update button state
    _nameController.addListener(() => setState(() {}));
    _priceController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Add Membership Pass',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Pass Name
                      _buildTextField(
                        controller: _nameController,
                        label: 'Pass Name',
                        hint: 'e.g., Starter Pass, Premium Pass',
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Duration Dropdown
                      Text(
                        'Duration',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.white.withOpacity(0.1)),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedDuration,
                            isExpanded: true,
                            dropdownColor: const Color(0xFF2A2A2A),
                            style: const TextStyle(color: Colors.white, fontSize: 16),
                            items: _durations.map((duration) {
                              return DropdownMenuItem(
                                value: duration['days'],
                                child: Text(duration['label']!),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedDuration = value!;
                                _selectedType = _durations.firstWhere(
                                  (d) => d['days'] == value
                                )['type']!;
                              });
                            },
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Price
                      _buildTextField(
                        controller: _priceController,
                        label: 'Price (\$)',
                        hint: 'e.g., 50.00',
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Description
                      _buildTextField(
                        controller: _descriptionController,
                        label: 'Description',
                        hint: 'Brief description of the pass benefits',
                        maxLines: 3,
                        isOptional: true,
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Add Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _nameController.text.isNotEmpty &&
                          _priceController.text.isNotEmpty
                      ? _handleAdd
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    disabledBackgroundColor: Colors.grey.shade800,
                  ),
                  child: Text(
                    widget.initialPass != null ? 'Update Pass' : 'Add Pass',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    TextInputType? keyboardType,
    int maxLines = 1,
    bool isOptional = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (isOptional) ...[
              const SizedBox(width: 8),
              Text(
                'Optional',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.4),
                  fontSize: 12,
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
            filled: true,
            fillColor: Colors.white.withOpacity(0.05),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppTheme.primaryColor, width: 2),
            ),
          ),
        ),
      ],
    );
  }

  void _handleAdd() {
    final pass = {
      'name': _nameController.text,
      'duration_days': int.parse(_selectedDuration),
      'price': double.parse(_priceController.text),
      'pass_type': _selectedType,
      'description': _descriptionController.text.isNotEmpty 
          ? _descriptionController.text 
          : null,
    };
    
    widget.onAdd(pass);
    Navigator.pop(context);
  }
}
