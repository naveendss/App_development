import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/gym_service.dart';

class EquipmentListScreen extends StatefulWidget {
  final String gymId;
  final String equipmentType;

  const EquipmentListScreen({
    super.key,
    required this.gymId,
    required this.equipmentType,
  });

  @override
  State<EquipmentListScreen> createState() => _EquipmentListScreenState();
}

class _EquipmentListScreenState extends State<EquipmentListScreen> {
  final _gymService = GymService();
  List<Map<String, dynamic>> _allEquipment = [];
  List<Map<String, dynamic>> _filteredEquipment = [];
  Map<String, int> _selectedItems = {}; // equipmentId -> quantity
  bool _isLoading = true;
  String? _error;
  String _selectedCategory = 'All Gear';

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.equipmentType; // Use passed type or default to All Gear
    _loadEquipment();
  }

  Future<void> _loadEquipment() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final equipment = await _gymService.getGymEquipment(widget.gymId);
      
      setState(() {
        _allEquipment = equipment;
        _filteredEquipment = equipment;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _filterByCategory(String category) {
    setState(() {
      _selectedCategory = category;
      if (category == 'All Gear') {
        _filteredEquipment = _allEquipment;
      } else {
        _filteredEquipment = _allEquipment.where((eq) {
          final type = eq['equipment_type']?.toString().toLowerCase() ?? '';
          return type == category.toLowerCase();
        }).toList();
      }
    });
  }

  void _toggleSelection(String equipmentId) {
    setState(() {
      if (_selectedItems.containsKey(equipmentId)) {
        _selectedItems.remove(equipmentId);
      } else {
        _selectedItems[equipmentId] = 1;
      }
    });
  }

  double _getTotalPrice() {
    double total = 0;
    for (var entry in _selectedItems.entries) {
      final equipment = _allEquipment.firstWhere(
        (eq) => eq['id']?.toString() == entry.key,
        orElse: () => {},
      );
      if (equipment.isNotEmpty) {
        final rate = equipment['hourly_rate'];
        final price = rate is num ? rate.toDouble() : double.tryParse(rate?.toString() ?? '0') ?? 0;
        total += price * entry.value;
      }
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    final categories = ['All Gear', 'Cardio', 'Weights', 'Functional', 'Yoga'];

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.backgroundColor.withOpacity(0.8),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Select Equipment',
          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: () {},
          ),
        ],
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
              ),
            )
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, color: Colors.red, size: 48),
                      const SizedBox(height: 16),
                      const Text('Error loading equipment', style: TextStyle(color: Colors.white, fontSize: 16)),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadEquipment,
                        style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryColor),
                        child: const Text('Retry', style: TextStyle(color: Colors.black)),
                      ),
                    ],
                  ),
                )
              : Stack(
                  children: [
                    Column(
                      children: [
                        // Category Filter
                        SizedBox(
                          height: 56,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            itemCount: categories.length,
                            itemBuilder: (context, index) {
                              final category = categories[index];
                              final isSelected = _selectedCategory == category;
                              return Padding(
                                padding: const EdgeInsets.only(right: 12),
                                child: GestureDetector(
                                  onTap: () => _filterByCategory(category),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                                    decoration: BoxDecoration(
                                      color: isSelected ? AppTheme.primaryColor : AppTheme.cardColor,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: isSelected ? AppTheme.primaryColor : Colors.white.withOpacity(0.1),
                                      ),
                                    ),
                                    child: Text(
                                      category,
                                      style: TextStyle(
                                        color: isSelected ? Colors.black : Colors.white70,
                                        fontSize: 14,
                                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        // Equipment List
                        Expanded(
                          child: _filteredEquipment.isEmpty
                              ? Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.fitness_center, size: 64, color: Colors.white.withOpacity(0.3)),
                                      const SizedBox(height: 16),
                                      Text(
                                        'No equipment available',
                                        style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 16),
                                      ),
                                    ],
                                  ),
                                )
                              : ListView.builder(
                                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
                                  itemCount: _filteredEquipment.length,
                                  itemBuilder: (context, index) {
                                    final equipment = _filteredEquipment[index];
                                    return _buildEquipmentCard(equipment);
                                  },
                                ),
                        ),
                      ],
                    ),
                    if (_selectedItems.isNotEmpty) _buildBottomBar(),
                  ],
                ),
    );
  }

  Widget _buildEquipmentCard(Map<String, dynamic> equipment) {
    final name = equipment['equipment_name']?.toString() ?? 'Equipment';
    final available = equipment['available_quantity'] is int
        ? equipment['available_quantity']
        : int.tryParse(equipment['available_quantity']?.toString() ?? '0') ?? 0;
    final hourlyRate = equipment['hourly_rate'];
    final imageUrl = equipment['image_url']?.toString() ?? '';
    final equipmentType = equipment['equipment_type']?.toString() ?? '';
    final equipmentId = equipment['id']?.toString() ?? '';
    final isSelected = _selectedItems.containsKey(equipmentId);

    // Get proper image URL
    final displayImageUrl = _getEquipmentImageUrl(equipmentType, imageUrl);

    String priceText = 'N/A';
    if (hourlyRate != null) {
      final price = hourlyRate is num ? hourlyRate.toDouble() : double.tryParse(hourlyRate.toString()) ?? 0;
      priceText = '₹${price.toStringAsFixed(2)}/hr';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          // Equipment Image
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.3),
              ),
              child: CachedNetworkImage(
                imageUrl: displayImageUrl,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: Colors.white.withOpacity(0.05),
                  child: const Center(
                    child: CircularProgressIndicator(
                      color: AppTheme.primaryColor,
                      strokeWidth: 2,
                    ),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  color: Colors.white.withOpacity(0.05),
                  child: Icon(
                    _getEquipmentIcon(equipmentType),
                    color: AppTheme.primaryColor,
                    size: 32,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Equipment Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: available > 0 ? AppTheme.primaryColor : Colors.red,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '$available Available',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Price and Add Button
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                priceText,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: available > 0 ? () => _toggleSelection(equipmentId) : null,
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: isSelected ? AppTheme.primaryColor.withOpacity(0.2) : AppTheme.primaryColor,
                    borderRadius: BorderRadius.circular(8),
                    border: isSelected ? Border.all(color: AppTheme.primaryColor, width: 2) : null,
                  ),
                  child: Icon(
                    isSelected ? Icons.check : Icons.add,
                    color: isSelected ? AppTheme.primaryColor : Colors.black,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    final total = _getTotalPrice();
    final itemCount = _selectedItems.length;

    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.transparent,
              AppTheme.backgroundColor.withOpacity(0.9),
              AppTheme.backgroundColor,
            ],
          ),
        ),
        child: SafeArea(
          child: GestureDetector(
            onTap: () async {
              // Get gym details
              final gymService = GymService();
              try {
                final gym = await gymService.getGymDetails(widget.gymId);
                
                // Get selected equipment names
                final selectedEquipmentNames = _selectedItems.keys.map((id) {
                  final eq = _allEquipment.firstWhere(
                    (e) => e['id']?.toString() == id,
                    orElse: () => {'equipment_name': 'Equipment'},
                  );
                  return eq['equipment_name']?.toString() ?? 'Equipment';
                }).join(', ');
                
                // Navigate to SLOT SELECTION (not booking summary)
                context.push('/slot-selection', extra: {
                  'gymId': widget.gymId,
                  'gymName': gym.name,
                  'gymAddress': gym.address,
                  'gymImage': gym.imageUrl,
                  'equipmentName': selectedEquipmentNames,
                  'selectedEquipment': _selectedItems.keys.toList(),
                  'totalPrice': total,
                  'equipmentType': widget.equipmentType,
                });
              } catch (e) {
                // Fallback if gym details fail
                context.push('/slot-selection', extra: {
                  'gymId': widget.gymId,
                  'gymName': 'Gym',
                  'gymAddress': 'Address',
                  'gymImage': '',
                  'equipmentName': 'Selected Equipment',
                  'selectedEquipment': _selectedItems.keys.toList(),
                  'totalPrice': total,
                  'equipmentType': widget.equipmentType,
                });
              }
            },
            child: Container(
              height: 64,
              padding: const EdgeInsets.symmetric(horizontal: 24),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryColor.withOpacity(0.3),
                    blurRadius: 30,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '$itemCount',
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            'View Selected Items',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '₹${total.toStringAsFixed(2)}',
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.chevron_right, color: Colors.black, size: 24),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _getEquipmentImageUrl(String? type, String? imageUrl) {
    // If equipment has its own image, use it
    if (imageUrl != null && imageUrl.isNotEmpty) {
      return imageUrl;
    }
    
    // Otherwise use default images based on type
    switch (type?.toLowerCase()) {
      case 'cardio':
      case 'treadmill':
        return 'https://lh3.googleusercontent.com/aida-public/AB6AXuCS_OD3aLEskIFkLDws4WPMJKHARso6N_GLqzgaVGmu7s_DtDNUtDdumgF5pPlsQSnA7J_xBrh5SVV7BP_LDPgc01CLkJrE654xh6nf34gs1_Ac18IerGS1ps4-gIFnhavzibIrlOxz2b61IycXy3CuJ9UDuAXtG2J7MOcpqZWTuqDpv92hC10QOxOJJyWDG5ulxc2rUOE6Uv9jHilM3lvmT11T3ESwJmi4KGqfnCZ5aQwHuDrhvs57c62SLzuRdDy2v5m-hFYePx4D';
      case 'cycling':
      case 'bike':
        return 'https://lh3.googleusercontent.com/aida-public/AB6AXuCabzIts6AveVEfTuWYSpCmTk5SZJ136oFZz3Llg-fdfHHPltlYyEdzVD11p6h4BtZuJOd7bqCedvSqQOmBt5iSepHJFQ08WuRx-COhqrJpmjc9v_VXV_w5ikb1LuVXu3xp7s05hN2wJt9UbU2MX1Xm-Y-c8_MtU60kymgXf3qhuW-QI-qo84ZDgLrX_8nDG3BM3C7H2Wq0n58HTx8hsQrTtfzl7AYestCUuKrdmnlSyliVcYpMT2BB20g9UMCPEzJ0JOJh1bR4UHB_';
      case 'weights':
      case 'kettlebell':
        return 'https://lh3.googleusercontent.com/aida-public/AB6AXuDLdpiYVYNiu8rn_P2y6TTtJpBBwH9aDwByRNH5DZWecM5XvAMUsdYCRA2DUsgVTz5gMRxlUkxwIDsLxC6OxOKauHvJF6zEJ-aHIg7fd3mB5TiLdVY7cRo0Py-iL4VaEhKZ3ljtVHGiFp86FzYOnZeLAUI5izoET2kJOh6PmWOMnqbelsdO84dpE34pwalSBI47-v1aVsQtB4BbV4NCPLk2DX8CCEGPGK9wkj2ORz2SBqra-pZklbQ6vD_MTw2khFWzf2GxNfHSK_zn';
      case 'strength':
      case 'power rack':
        return 'https://lh3.googleusercontent.com/aida-public/AB6AXuA3CKthMMSjl35-CjfodYUWNFJ4vxN1nhP4BQx6OZGZ9JsXaB6Qm18HO1UtLmcnuPRPN0RmHSOPMbTbPgVYtaVBsUhIsvCKagcsfQUQrMApNXhLzlDz-9Aw4S5_hsYPigG3MQSiu2skR7L3uGKzPsXViEpP5jDdrzfl9q8GHDPTxY5LBAPerk6LdvkUHXBYtnJQeb3_Io0lB5zNz_Ga6JqhdhHlKAIm4itqgUjymcglRyunxNOWjeuONCTMHoNYCDK2TiOjPIuHW1WX';
      case 'dumbbell':
        return 'https://lh3.googleusercontent.com/aida-public/AB6AXuCb_jsO2OU63IXB-2JI9RVEZu7PDoAk_VeInSTjm1m6RVdVNIMjrCDALukWfJhQcpRiA3HPeGkhtoP1rUAZt-BvNdpd1_wqfRVPXwuvL5yXueNelznTnqy1pZwNKzWH3QYxtLnTbH3grU_g6P4eE9QeNcVagW_8jfxMzNJvmk421RYt3T5tNySME6N9BrgLwxVVQhubiAPjZ_0KIpSmbeQCndBmOqH4Ax1GJJt4cAxAeyRd9hnn1K3ZIaqj5vArZoXGrQTkGZfMRLIn';
      case 'yoga':
        return 'https://images.unsplash.com/photo-1544367567-0f2fcb009e0b?w=400';
      case 'functional':
        return 'https://images.unsplash.com/photo-1517836357463-d25dfeac3438?w=400';
      default:
        return 'https://images.unsplash.com/photo-1534438327276-14e5300c3a48?w=400';
    }
  }

  IconData _getEquipmentIcon(String? type) {
    switch (type?.toLowerCase()) {
      case 'cardio':
      case 'treadmill':
        return Icons.directions_run;
      case 'cycling':
      case 'bike':
        return Icons.pedal_bike;
      case 'strength':
      case 'weights':
      case 'dumbbell':
        return Icons.fitness_center;
      case 'yoga':
        return Icons.self_improvement;
      case 'functional':
        return Icons.sports_gymnastics;
      default:
        return Icons.fitness_center;
    }
  }
}
