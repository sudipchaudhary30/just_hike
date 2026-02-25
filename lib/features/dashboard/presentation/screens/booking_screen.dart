import 'package:flutter/material.dart';
import 'package:just_hike/features/dashboard/domain/entities/package_entity.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_hike/features/dashboard/presentation/providers/booking_provider.dart';
import 'package:just_hike/features/dashboard/presentation/providers/my_bookings_provider.dart'; // Ensure this file exists and exports 'myBookingsProvider'
import 'package:just_hike/features/dashboard/presentation/providers/profile_provider.dart';

class BookingScreen extends ConsumerStatefulWidget {
  final PackageEntity trek;
  const BookingScreen({Key? key, required this.trek}) : super(key: key);

  @override
  ConsumerState<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends ConsumerState<BookingScreen> {
  DateTime? fromDate;
  String? nationality;
  int adults = 1;
  int children = 0;

  final List<String> nationalityOptions = ['Nepali', 'Indian', 'Other'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Dates & Trekkers'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Trek Details Section
            Text(
              widget.trek.title,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              widget.trek.location,
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 4),
            Text(
              'NPR ${widget.trek.price.toStringAsFixed(0)}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF00D0B0),
              ),
            ),
            const SizedBox(height: 24),

            // Selected Dates Section FIRST
            const Text(
              'Selected Dates',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            _dateField(
              'From Date',
              fromDate,
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: fromDate ?? DateTime.now(),
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );
                if (picked != null) {
                  setState(() => fromDate = picked);
                }
              },
            ),
            const SizedBox(height: 24),

            // Your Nationality SECOND
            const Text(
              'Your Nationality',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: nationality,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Select Nationality',
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 16,
                ),
              ),
              items: nationalityOptions
                  .map((n) => DropdownMenuItem(value: n, child: Text(n)))
                  .toList(),
              onChanged: (val) => setState(() => nationality = val),
            ),
            const SizedBox(height: 24),

            // Travelers THIRD
            const Text(
              'Travelers',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            _travelerRow(
              'Adults',
              adults,
              (newValue) => setState(() => adults = newValue),
              min: 1,
            ),
            const SizedBox(height: 12),
            _travelerRow(
              'Children',
              children,
              (newValue) => setState(() => children = newValue),
            ),

            const SizedBox(height: 32),

            // Price Summary
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Price', style: const TextStyle(fontSize: 15)),
                      Text(
                        'NPR ${(widget.trek.price * (adults + children)).toStringAsFixed(0)}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Book Now Button (use theme color)
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _isFormValid() ? _handleBooking : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(
                    0xFF20D6C6,
                  ), // Matches the provided color
                  foregroundColor: Colors.white, // Ensure text color is white
                  disabledBackgroundColor: const Color.fromARGB(
                    255,
                    34,
                    225,
                    193,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 2,
                ),
                child: const Text(
                  'Confirm Booking',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white, // Ensure text color is white
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _isFormValid() {
    return fromDate != null && nationality != null && adults > 0;
  }

  Future<void> _handleBooking() async {
    try {
      final userProfile = ref.read(profileProvider);
      final bookingData = {
        'trekId': widget.trek.id,
        'trekTitle': widget.trek.title, // Add trek name
        'trekImageUrl': widget.trek.imageUrl, // Add trek image
        'bookedBy': userProfile.name, // Add user name from profile
        'fromDate': fromDate!.toIso8601String(),
        'nationality': nationality!,
        'adults': adults,
        'children': children,
        'totalPrice': widget.trek.price * (adults + children),
      };

      final bookingRepo = ref.read(bookingProvider);
      await bookingRepo.saveBooking(bookingData);

      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Booking Confirmed!'),
          content: const Text('Your trek has been booked successfully.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pushReplacementNamed(context, '/myTrips');
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } catch (e) {
      print('Booking error: $e');
      _showErrorSnackbar('Booking failed. Please try again.');
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Booking Confirmed! '),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Your booking for "${widget.trek.title}" is confirmed.'),
            const SizedBox(height: 16),
            Text('From: ${_formatDate(fromDate!)}'),
            Text('Travelers: $adults Adult(s), $children Children'),
            const SizedBox(height: 8),
            Text(
              'Total: NPR ${(widget.trek.price * (adults + children)).toStringAsFixed(0)}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              // Refresh bookings and navigate back
              ref.refresh(myBookingsProvider);
              Navigator.pop(context); // Go back to previous screen
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Widget _dateField(
    String label,
    DateTime? date, {
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              date == null ? label : _formatDate(date),
              style: TextStyle(
                color: date == null ? Colors.grey : Colors.black,
                fontSize: 15,
              ),
            ),
            Icon(
              Icons.calendar_today,
              size: 18,
              color: date == null ? Colors.grey : const Color(0xFF00D0B0),
            ),
          ],
        ),
      ),
    );
  }

  Widget _travelerRow(
    String label,
    int value,
    Function(int) onChanged, {
    int min = 0,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 15)),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.remove_circle_outline),
                onPressed: value > min ? () => onChanged(value - 1) : null,
                color: value > min ? const Color(0xFF00D0B0) : Colors.grey,
                iconSize: 24,
              ),
              Container(
                width: 35,
                alignment: Alignment.center,
                child: Text(
                  '$value',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add_circle_outline),
                onPressed: () => onChanged(value + 1),
                color: const Color(0xFF00D0B0),
                iconSize: 24,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
