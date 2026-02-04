import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/booking_service.dart';

class BookingSummaryScreen extends StatefulWidget {
  final Map<String, dynamic> bookingData;

  const BookingSummaryScreen({super.key, required this.bookingData});

  @override
  State<BookingSummaryScreen> createState() => _BookingSummaryScreenState();
}

class _BookingSummaryScreenState extends State<BookingSummaryScreen> {
  bool _isProcessing = false;

  Future<void> _handlePayment() async {
    final slotId = widget.bookingData['slotId'];
    
    if (slotId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invalid slot selection'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isProcessing = true);

    try {
      // Import booking service at the top of the file
      final bookingService = BookingService();
      
      // Create the booking
      final booking = await bookingService.createBooking(
        slotId: slotId,
      );

      if (!mounted) return;

      // Navigate to success screen with real booking ID
      context.push('/booking-success', extra: booking.id);
    } catch (e) {
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Booking failed: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final gymName = widget.bookingData['gymName'] ?? 'Gym';
    final gymAddress = widget.bookingData['gymAddress'] ?? 'Address';
    final gymImage = widget.bookingData['gymImage'] ?? '';
    final equipmentName = widget.bookingData['equipmentName'] ?? 'Equipment';
    final passName = widget.bookingData['passName'];
    final date = widget.bookingData['date'] as DateTime?;
    final timeSlot = widget.bookingData['timeSlot'];
    final priceStr = widget.bookingData['price']?.toString() ?? '0';
    
    final cleanPrice = priceStr.replaceAll(RegExp(r'[^\d.]'), '');
    final basePrice = double.tryParse(cleanPrice) ?? 0.0;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.backgroundColor.withOpacity(0.8),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Booking Summary',
          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionHeader('SELECTED VENUE'),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                  child: _buildVenueCard(gymName, gymAddress, gymImage),
                ),
                if (passName != null) ...[
                  _buildSectionHeader('MEMBERSHIP PASS'),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                    child: _buildPassCard(passName),
                  ),
                ],
                if (equipmentName != null && date != null && timeSlot != null) ...[
                  _buildSectionHeader('BOOKING DETAILS'),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                    child: Column(
                      children: [
                        _buildDetailRow(Icons.fitness_center, equipmentName, 'RESOURCE'),
                        const SizedBox(height: 8),
                        _buildDetailRow(Icons.calendar_today, DateFormat('EEEE, MMM d, yyyy').format(date), 'DATE'),
                        const SizedBox(height: 8),
                        _buildDetailRow(Icons.schedule, timeSlot, 'TIME'),
                      ],
                    ),
                  ),
                ],
                _buildSectionHeader('PAYMENT SUMMARY'),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                  child: _buildPaymentSummary(basePrice),
                ),
                const SizedBox(height: 120),
              ],
            ),
          ),
          _buildBottomButton(context),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
      child: Text(title, style: const TextStyle(color: Colors.white60, fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 2)),
    );
  }

  Widget _buildVenueCard(String name, String address, String imageUrl) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Location', style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12)),
                const SizedBox(height: 4),
                Text(name, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(address, style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 14), maxLines: 2, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: AppTheme.primaryColor.withOpacity(0.2)),
                  ),
                  child: Text('VERIFIED EQUIPMENT', style: TextStyle(color: AppTheme.primaryColor, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: imageUrl.isNotEmpty
                ? CachedNetworkImage(
                    imageUrl: imageUrl,
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(width: 100, height: 100, color: AppTheme.cardColor, child: const Center(child: CircularProgressIndicator(color: AppTheme.primaryColor, strokeWidth: 2))),
                    errorWidget: (context, url, error) => Container(width: 100, height: 100, color: AppTheme.cardColor, child: const Icon(Icons.fitness_center, size: 40, color: Colors.white30)),
                  )
                : Container(width: 100, height: 100, color: AppTheme.cardColor, child: const Icon(Icons.fitness_center, size: 40, color: Colors.white30)),
          ),
        ],
      ),
    );
  }

  Widget _buildPassCard(String passName) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppTheme.surfaceColor, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppTheme.primaryColor.withOpacity(0.3))),
      child: Row(
        children: [
          Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: AppTheme.primaryColor.withOpacity(0.1), borderRadius: BorderRadius.circular(8)), child: Icon(Icons.card_membership, color: AppTheme.primaryColor, size: 24)),
          const SizedBox(width: 16),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Pass Type', style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12)), const SizedBox(height: 4), Text(passName, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500))])),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String text, String label) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppTheme.surfaceColor, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white.withOpacity(0.1))),
      child: Row(
        children: [
          Container(width: 40, height: 40, decoration: BoxDecoration(color: AppTheme.primaryColor.withOpacity(0.1), borderRadius: BorderRadius.circular(8)), child: Icon(icon, color: AppTheme.primaryColor, size: 20)),
          const SizedBox(width: 16),
          Expanded(child: Text(text, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500))),
          Text(label, style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
        ],
      ),
    );
  }

  Widget _buildPaymentSummary(double basePrice) {
    final tax = basePrice * 0.08;
    final total = basePrice + tax;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: AppTheme.surfaceColor, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white.withOpacity(0.1))),
      child: Column(
        children: [
          _buildPriceRow('Base Rate (1 Hour)', 'Rs.${basePrice.toStringAsFixed(2)}'),
          const SizedBox(height: 16),
          _buildPriceRow('Taxes & Service Fees', 'Rs.${tax.toStringAsFixed(2)}'),
          const SizedBox(height: 16),
          Container(height: 1, color: Colors.white.withOpacity(0.1)),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Total Amount', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              Text('Rs.${total.toStringAsFixed(2)}', style: const TextStyle(color: AppTheme.primaryColor, fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: -0.5)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPriceRow(String label, String price) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 14)),
        Text(price, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500)),
      ],
    );
  }

  Widget _buildBottomButton(BuildContext context) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(color: AppTheme.backgroundColor.withOpacity(0.95), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, -5))]),
        child: SafeArea(
          child: SizedBox(
            width: double.infinity,
            height: 64,
            child: ElevatedButton(
              onPressed: _isProcessing ? null : _handlePayment,
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryColor, foregroundColor: Colors.black, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), elevation: 0, disabledBackgroundColor: AppTheme.primaryColor.withOpacity(0.5)),
              child: _isProcessing
                  ? const SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                      ),
                    )
                  : const Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.lock, color: Colors.black, size: 20), SizedBox(width: 12), Text('Confirm & Pay', style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.w900))]),
            ),
          ),
        ),
      ),
    );
  }

  String _getEndTime(String startTime) {
    try {
      // If it's already a formatted range like "09:00 AM - 10:00 AM", extract the end time
      if (startTime.contains(' - ')) {
        final parts = startTime.split(' - ');
        return parts.length > 1 ? parts[1] : startTime;
      }
      
      // Otherwise, parse and add 1 hour
      final parts = startTime.split(':');
      if (parts.length < 2) return startTime;
      
      final hour = int.tryParse(parts[0]) ?? 0;
      final isPM = startTime.toUpperCase().contains('PM');
      final isAM = startTime.toUpperCase().contains('AM');
      
      var newHour = hour + 1;
      var newPeriod = isPM ? 'PM' : (isAM ? 'AM' : '');
      
      if (newHour > 12) {
        newHour = newHour - 12;
        newPeriod = isPM ? 'AM' : 'PM';
      } else if (newHour == 12) {
        newPeriod = isAM ? 'PM' : 'AM';
      }
      
      return '$newHour:00 $newPeriod';
    } catch (e) {
      return startTime;
    }
  }
}
