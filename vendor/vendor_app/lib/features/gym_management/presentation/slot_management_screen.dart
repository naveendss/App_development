import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/api_service.dart';

class SlotManagementScreen extends StatefulWidget {
  const SlotManagementScreen({super.key});

  @override
  State<SlotManagementScreen> createState() => _SlotManagementScreenState();
}

class _SlotManagementScreenState extends State<SlotManagementScreen> {
  final _apiService = ApiService();
  String _gymId = '';
  List<dynamic> _equipment = [];
  List<dynamic> _passes = [];
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      // Get vendor's gyms
      final gyms = await _apiService.getMyGyms();
      
      if (gyms.isEmpty) {
        setState(() => _isLoading = false);
        return;
      }
      
      final gymId = gyms[0]['id'].toString();
      
      // Get equipment and passes
      final equipment = await _apiService.getGymEquipment(gymId);
      final passes = await _apiService.getGymPasses(gymId);
      
      setState(() {
        _gymId = gymId;
        _equipment = equipment;
        _passes = passes;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading data: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _generateSlots() async {
    if (_gymId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please wait for gym data to load'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: const Text('Generate Time Slots', style: TextStyle(color: Colors.white)),
        content: const Text(
          'This will create hourly time slots (6 AM - 10 PM) for the next 7 days for all equipment. Continue?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryColor),
            child: const Text('Generate', style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      setState(() => _isLoading = true);
      
      // Generate slots for the gym (will apply to all equipment)
      await _apiService.generateDefaultSlots(_gymId);
      
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Time slots generated successfully!'),
          backgroundColor: AppTheme.primaryColor,
        ),
      );
      
      await _loadData();
    } catch (e) {
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error generating slots: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  List<dynamic> get _filteredItems {
    final allItems = [..._equipment, ..._passes];
    if (_searchQuery.isEmpty) return allItems;
    
    return allItems.where((item) {
      final name = (item['equipment_name'] ?? item['name'] ?? '').toString().toLowerCase();
      return name.contains(_searchQuery.toLowerCase());
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black.withOpacity(0.8),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Inventory & Slot Overview',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.schedule, color: AppTheme.primaryColor),
            onPressed: _generateSlots,
            tooltip: 'Generate Slots',
          ),
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadData,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryColor))
          : Column(
              children: [
                _buildSearchBar(),
                Expanded(
                  child: _filteredItems.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.inventory_2_outlined, size: 64, color: Colors.white.withOpacity(0.3)),
                              const SizedBox(height: 16),
                              Text(
                                'No equipment or passes yet',
                                style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 16),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Tap + to add',
                                style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 14),
                              ),
                            ],
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: _loadData,
                          color: AppTheme.primaryColor,
                          child: ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: _filteredItems.length,
                            itemBuilder: (context, index) {
                              final item = _filteredItems[index];
                              final isEquipment = item.containsKey('equipment_name');
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 16),
                                child: isEquipment
                                    ? _buildEquipmentCard(item)
                                    : _buildPassCard(item),
                              );
                            },
                          ),
                        ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddOptions,
        backgroundColor: Colors.white,
        child: const Icon(Icons.add, color: Colors.black, size: 32),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.black,
      child: TextField(
        onChanged: (value) => setState(() => _searchQuery = value),
        style: const TextStyle(color: Colors.white, fontSize: 14),
        decoration: InputDecoration(
          hintText: 'Search equipment or passes...',
          hintStyle: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 14),
          prefixIcon: Icon(Icons.search, color: Colors.white.withOpacity(0.5)),
          filled: true,
          fillColor: Colors.white.withOpacity(0.05),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }

  Widget _buildEquipmentCard(Map<String, dynamic> equipment) {
    final name = equipment['equipment_name'] ?? 'Equipment';
    final quantity = equipment['quantity'] ?? 0;
    final availableQuantity = equipment['available_quantity'] ?? 0;
    final hourlyRate = equipment['hourly_rate'] ?? 0;
    final imageUrl = equipment['image_url'] ?? 'https://images.unsplash.com/photo-1534438327276-14e5300c3a48?w=400';
    
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    image: DecorationImage(
                      image: NetworkImage(imageUrl),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  name,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '$quantity Units Available',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.4),
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 6,
                                  height: 6,
                                  decoration: const BoxDecoration(
                                    color: Colors.green,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '$availableQuantity/$quantity active',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.4),
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Text(
                            '\$$hourlyRate',
                            style: const TextStyle(
                              color: AppTheme.primaryColor,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Base Rate / hr',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.5),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: ElevatedButton(
              onPressed: () => _editEquipment(equipment),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.black,
                minimumSize: const Size(double.infinity, 44),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.settings_input_component, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Manage Pricing & Slots',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPassCard(Map<String, dynamic> pass) {
    final name = pass['name'] ?? 'Pass';
    final price = pass['price'] ?? 0;
    final durationDays = pass['duration_days'] ?? 0;
    final isActive = pass['is_active'] ?? false;
    
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.card_membership, color: AppTheme.primaryColor, size: 48),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  name,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '$durationDays Days Membership',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.4),
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: isActive ? Colors.green.withOpacity(0.2) : Colors.red.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              isActive ? 'Active' : 'Inactive',
                              style: TextStyle(
                                color: isActive ? Colors.green : Colors.red,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Text(
                            '\$$price',
                            style: const TextStyle(
                              color: AppTheme.primaryColor,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Base Rate / pass',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.5),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: ElevatedButton(
              onPressed: () => _editPass(pass),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.black,
                minimumSize: const Size(double.infinity, 44),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.edit, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Edit Pass Details',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1A1A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Add New',
              style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            ListTile(
              leading: const Icon(Icons.fitness_center, color: AppTheme.primaryColor),
              title: const Text('Add Equipment', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                _showAddEquipmentDialog();
              },
            ),
            ListTile(
              leading: const Icon(Icons.card_membership, color: AppTheme.primaryColor),
              title: const Text('Add Membership Pass', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                _showAddPassDialog();
              },
            ),
          ],
        ),
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
        gymId: _gymId,
        apiService: _apiService,
        onSuccess: () {
          _loadData();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Equipment added successfully'),
              backgroundColor: AppTheme.primaryColor,
            ),
          );
        },
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
        gymId: _gymId,
        apiService: _apiService,
        onSuccess: () {
          _loadData();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Pass added successfully'),
              backgroundColor: AppTheme.primaryColor,
            ),
          );
        },
      ),
    );
  }

  void _editEquipment(Map<String, dynamic> equipment) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1A1A),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _AddEquipmentSheet(
        gymId: _gymId,
        apiService: _apiService,
        initialEquipment: equipment,
        onSuccess: () {
          _loadData();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Equipment updated successfully'),
              backgroundColor: AppTheme.primaryColor,
            ),
          );
        },
      ),
    );
  }

  void _editPass(Map<String, dynamic> pass) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1A1A),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _AddPassSheet(
        gymId: _gymId,
        apiService: _apiService,
        initialPass: pass,
        onSuccess: () {
          _loadData();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Pass updated successfully'),
              backgroundColor: AppTheme.primaryColor,
            ),
          );
        },
      ),
    );
  }
}

// Equipment Sheet Widget
class _AddEquipmentSheet extends StatefulWidget {
  final String gymId;
  final ApiService apiService;
  final Map<String, dynamic>? initialEquipment;
  final VoidCallback onSuccess;

  const _AddEquipmentSheet({
    required this.gymId,
    required this.apiService,
    this.initialEquipment,
    required this.onSuccess,
  });

  @override
  State<_AddEquipmentSheet> createState() => _AddEquipmentSheetState();
}

class _AddEquipmentSheetState extends State<_AddEquipmentSheet> {
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

  Map<String, dynamic>? _selectedEquipment;
  final _quantityController = TextEditingController();
  final _hourlyRateController = TextEditingController();
  final _descriptionController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialEquipment != null) {
      final equipmentName = widget.initialEquipment!['equipment_name'];
      _selectedEquipment = _availableEquipment.firstWhere(
        (e) => e['name'] == equipmentName,
        orElse: () => {'name': equipmentName, 'icon': '🏋️', 'type': 'other'},
      );
      _quantityController.text = widget.initialEquipment!['quantity'].toString();
      _hourlyRateController.text = widget.initialEquipment!['hourly_rate'].toString();
      _descriptionController.text = widget.initialEquipment!['description'] ?? '';
    }
    
    _quantityController.addListener(() => setState(() {}));
    _hourlyRateController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _hourlyRateController.dispose();
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
                  Expanded(
                    child: Text(
                      widget.initialEquipment != null ? 'Edit Equipment' : 'Add Equipment',
                      style: const TextStyle(
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
                            items: _availableEquipment.map((equipment) {
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
                        
                        _buildTextField(
                          controller: _quantityController,
                          label: 'Number of Units',
                          hint: 'e.g., 10',
                          keyboardType: TextInputType.number,
                        ),
                        
                        const SizedBox(height: 16),
                        
                        _buildTextField(
                          controller: _hourlyRateController,
                          label: 'Hourly Rate (\$)',
                          hint: 'e.g., 5.00',
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        ),
                        
                        const SizedBox(height: 16),
                        
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
              
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _selectedEquipment != null &&
                          _quantityController.text.isNotEmpty &&
                          _hourlyRateController.text.isNotEmpty &&
                          !_isLoading
                      ? _handleSave
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
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                          ),
                        )
                      : Text(
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

  Future<void> _handleSave() async {
    setState(() => _isLoading = true);

    try {
      final equipmentData = {
        'gym_id': widget.gymId,
        'equipment_name': _selectedEquipment!['name'],
        'equipment_type': _selectedEquipment!['type'],
        'quantity': int.parse(_quantityController.text),
        'available_quantity': int.parse(_quantityController.text),
        'hourly_rate': double.parse(_hourlyRateController.text),
        'description': _descriptionController.text.isNotEmpty 
            ? _descriptionController.text 
            : '',
      };

      if (widget.initialEquipment != null) {
        // Update existing equipment
        await widget.apiService.updateEquipment(
          widget.initialEquipment!['id'].toString(),
          equipmentData,
        );
      } else {
        // Create new equipment
        await widget.apiService.createEquipment(equipmentData);
      }

      if (!mounted) return;
      
      Navigator.pop(context);
      widget.onSuccess();
    } catch (e) {
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}

// Pass Sheet Widget
class _AddPassSheet extends StatefulWidget {
  final String gymId;
  final ApiService apiService;
  final Map<String, dynamic>? initialPass;
  final VoidCallback onSuccess;

  const _AddPassSheet({
    required this.gymId,
    required this.apiService,
    this.initialPass,
    required this.onSuccess,
  });

  @override
  State<_AddPassSheet> createState() => _AddPassSheetState();
}

class _AddPassSheetState extends State<_AddPassSheet> {
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _selectedDuration = '30';
  String _selectedType = 'monthly';
  bool _isLoading = false;

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
      _selectedType = widget.initialPass!['pass_type'] ?? 'monthly';
      _descriptionController.text = widget.initialPass!['description'] ?? '';
    }
    
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
                  Expanded(
                    child: Text(
                      widget.initialPass != null ? 'Edit Membership Pass' : 'Add Membership Pass',
                      style: const TextStyle(
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
                      _buildTextField(
                        controller: _nameController,
                        label: 'Pass Name',
                        hint: 'e.g., Starter Pass, Premium Pass',
                      ),
                      
                      const SizedBox(height: 16),
                      
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
                      
                      _buildTextField(
                        controller: _priceController,
                        label: 'Price (\$)',
                        hint: 'e.g., 50.00',
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      ),
                      
                      const SizedBox(height: 16),
                      
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
              
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _nameController.text.isNotEmpty &&
                          _priceController.text.isNotEmpty &&
                          !_isLoading
                      ? _handleSave
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
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                          ),
                        )
                      : Text(
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

  Future<void> _handleSave() async {
    setState(() => _isLoading = true);

    try {
      final passData = {
        'gym_id': widget.gymId,
        'name': _nameController.text,
        'duration_days': int.parse(_selectedDuration),
        'price': double.parse(_priceController.text),
        'pass_type': _selectedType,
        'description': _descriptionController.text.isNotEmpty 
            ? _descriptionController.text 
            : '',
        'is_active': true,
      };

      if (widget.initialPass != null) {
        // Update existing pass
        await widget.apiService.updatePass(
          widget.initialPass!['id'].toString(),
          passData,
        );
      } else {
        // Create new pass
        await widget.apiService.createPass(passData);
      }

      if (!mounted) return;
      
      Navigator.pop(context);
      widget.onSuccess();
    } catch (e) {
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}
