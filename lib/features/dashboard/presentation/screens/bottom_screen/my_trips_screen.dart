import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:just_hike/core/services/storage/user_session_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyTripsScreen extends ConsumerStatefulWidget {
  @override
  ConsumerState<MyTripsScreen> createState() => _MyTripsScreenState();
}

class _MyTripsScreenState extends ConsumerState<MyTripsScreen> {
  List bookings = [];
  bool isLoading = true;
  int selectedTab = 0; // 0 = Treks, 1 = Wishlist

  @override
  void initState() {
    super.initState();
    fetchBookings();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    fetchBookings();
  }

  Future<void> fetchBookings() async {
    setState(() {
      isLoading = true;
    });
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = await UserSessionService(prefs: prefs).getAccessToken();
      final response = await http.get(
        Uri.parse('http://10.0.2.2:5050/api/bookings/me'),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        List bookingsList = data is List ? data : [];
        print('Fetched bookings:');
        print(bookingsList);
        // Fetch trek details for each booking if missing
        for (var booking in bookingsList) {
          if (booking['trek'] == null && booking['trekId'] != null) {
            print('Fetching trek details for trekId: ${booking['trekId']}');
            final trekResponse = await http.get(
              Uri.parse('http://10.0.2.2:5050/api/treks/${booking['trekId']}'),
            );
            if (trekResponse.statusCode == 200) {
              print('Fetched trek details:');
              print(json.decode(trekResponse.body));
              booking['trek'] = json.decode(trekResponse.body);
            }
            print(
              'Failed to fetch trek details for trekId: ${booking['trekId']}',
            );
          }
        }
        setState(() {
          print('Final bookings with trek details:');
          print(bookingsList);
          bookings = bookingsList;
          isLoading = false;
        });
      } else {
        setState(() {
          bookings = [];
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        bookings = [];
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = Color(0xFF20D6C6);
    final Color tabBg = Color(0xFFF9F6F6);
    final Color selectedTabColor = Color(0xFF20D6C6);
    final Color unselectedTabColor = Color(0xFFBDBDBD);

    // Group bookings into upcoming and past
    final now = DateTime.now();
    List upcoming = bookings.where((b) {
      final start = DateTime.tryParse(b['startDate'] ?? '') ?? now;
      return start.isAfter(now);
    }).toList();
    List past = bookings.where((b) {
      final start = DateTime.tryParse(b['startDate'] ?? '') ?? now;
      return start.isBefore(now);
    }).toList();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60),
        child: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: Text(
            'My Treks',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
          centerTitle: false,
          actions: [
            IconButton(
              icon: Icon(Icons.notifications_none, color: Colors.black),
              onPressed: () {},
            ),
            IconButton(
              icon: Icon(Icons.favorite_border, color: Colors.black),
              onPressed: () {},
            ),
          ],
          iconTheme: IconThemeData(color: Colors.black),
        ),
      ),
      body: SafeArea(
        child: isLoading
            ? Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: fetchBookings,
                child: SingleChildScrollView(
                  physics: AlwaysScrollableScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            color: tabBg,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  onTap: () => setState(() => selectedTab = 0),
                                  child: Container(
                                    padding: EdgeInsets.symmetric(vertical: 10),
                                    decoration: BoxDecoration(
                                      color: selectedTab == 0
                                          ? selectedTabColor
                                          : tabBg,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.hiking,
                                          color: selectedTab == 0
                                              ? Colors.white
                                              : unselectedTabColor,
                                        ),
                                        SizedBox(width: 6),
                                        Text(
                                          'Treks',
                                          style: TextStyle(
                                            color: selectedTab == 0
                                                ? Colors.white
                                                : unselectedTabColor,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: GestureDetector(
                                  onTap: () => setState(() => selectedTab = 1),
                                  child: Container(
                                    padding: EdgeInsets.symmetric(vertical: 10),
                                    decoration: BoxDecoration(
                                      color: selectedTab == 1
                                          ? selectedTabColor
                                          : tabBg,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.favorite_border,
                                          color: selectedTab == 1
                                              ? Colors.white
                                              : unselectedTabColor,
                                        ),
                                        SizedBox(width: 6),
                                        Text(
                                          'Wishlist',
                                          style: TextStyle(
                                            color: selectedTab == 1
                                                ? Colors.white
                                                : unselectedTabColor,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (selectedTab == 0) ...[
                        if (upcoming.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            child: Text(
                              'Upcoming Treks',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        if (upcoming.isNotEmpty)
                          ...upcoming
                              .map(
                                (booking) => _tripCard(context, booking, true),
                              )
                              .toList(),
                        if (past.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            child: Text(
                              'Past Treks',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        if (past.isNotEmpty)
                          ...past
                              .map(
                                (booking) => _tripCard(context, booking, false),
                              )
                              .toList(),
                        if (upcoming.isEmpty && past.isEmpty)
                          Center(
                            child: Padding(
                              padding: EdgeInsets.only(top: 48),
                              child: Text(
                                'No trips found',
                                style: TextStyle(color: Colors.grey),
                              ),
                            ),
                          ),
                      ] else ...[
                        // Wishlist tab placeholder
                        SizedBox(
                          height: 300,
                          child: Center(
                            child: Text(
                              'Wishlist is empty',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget _tripCard(BuildContext context, Map booking, bool isUpcoming) {
    final trek = booking['trek'] ?? {};
    final imageUrl = fixImageUrl(trek['imageUrl'] ?? '');
    final tripName = trek['name'] ?? trek['_id'] ?? 'Unknown Trek';
    final startDate = booking['startDate'] ?? '';
    final endDate = booking['endDate'] ?? '';
    final days = trek['days'] ?? '';
    final tripType = trek['type'] ?? '';
    final status = booking['status'] ?? '';
    final now = DateTime.now();
    DateTime? start = DateTime.tryParse(startDate);
    String tripInfo = '';
    if (days != '' && tripType != '') {
      tripInfo = '$days Days $tripType';
    }
    String tripStartsIn = '';
    if (isUpcoming && start != null) {
      final diff = start.difference(now);
      if (diff.inDays > 0) {
        tripStartsIn = 'Trip starts in ${diff.inDays} days';
      } else if (diff.inDays == 0) {
        tripStartsIn = 'Trip starts today';
      }
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.08),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
          border: Border.all(color: Color(0xFFE0E0E0)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: imageUrl.isNotEmpty
                  ? Image.network(
                      imageUrl,
                      width: 80,
                      height: 64,
                      fit: BoxFit.cover,
                      errorBuilder: (c, e, s) => Container(
                        width: 80,
                        height: 64,
                        color: Colors.grey[300],
                        child: Icon(Icons.broken_image, color: Colors.grey),
                      ),
                    )
                  : Container(
                      width: 80,
                      height: 64,
                      color: Colors.grey[300],
                      child: Icon(Icons.image, color: Colors.grey),
                    ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tripName,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  SizedBox(height: 2),
                  if (startDate != '' && endDate != '')
                    Text(
                      _formatDateRange(startDate, endDate),
                      style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                    ),
                  if (tripInfo.isNotEmpty)
                    Text(
                      tripInfo,
                      style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                    ),
                  if (isUpcoming && tripStartsIn.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        tripStartsIn,
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF20D6C6),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  if (!isUpcoming)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        'Completed',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF20D6C6),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            IconButton(
              icon: Icon(Icons.favorite_border, color: Color(0xFF20D6C6)),
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }

  String _formatDateRange(String start, String end) {
    try {
      final startDate = DateTime.parse(start);
      final endDate = DateTime.parse(end);
      final startStr = '${_monthShort(startDate.month)} ${startDate.day}';
      final endStr =
          '${_monthShort(endDate.month)} ${endDate.day}, ${endDate.year}';
      return '$startStr - $endStr';
    } catch (e) {
      return '';
    }
  }

  String _monthShort(int month) {
    const months = [
      '',
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[month];
  }

  // Fixes or completes the image URL if needed
  String fixImageUrl(String url) {
    if (url.isEmpty) return '';
    if (url.startsWith('http')) return url;
    // Use your actual API base URL for local dev
    const String baseUrl = 'http://10.0.2.2:5050/';
    return baseUrl + url;
  }
}

class UserSessionService {
  final SharedPreferences prefs;

  UserSessionService({required this.prefs});

  Future<String?> getAccessToken() async {
    // Replace 'access_token' with your actual key
    return prefs.getString('access_token');
  }
}
