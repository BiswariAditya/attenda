// ignore_for_file: depend_on_referenced_packages

import 'package:attendance/screens/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:attendance/screens/scanner_screen.dart';
import 'package:supabase/supabase.dart';
import 'dart:async';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String qrResult = "You have not scanned a QR";

  // Initialize Supabase client
  final client = SupabaseClient('supabaseUrl', 'supabaseKey');

  Future<String?> _scanQRCode(BuildContext context) async {
    // Navigate to the ScannerPage to initiate scanning
    String? scannedResult; // Declare a variable to store the result

    try {
      scannedResult = await Navigator.push<String>(
        context,
        MaterialPageRoute(builder: (context) => const ScannerPage()),
      );
    } catch (error) {
      // Handle any errors that may arise during navigation or scanning
      print('Error occurred during QR code scanning: $error');
    }

    // Return the scanned QR code data, or null if an error occurred or no data was scanned
    return scannedResult;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 2,
        leading: Row(
          children: [
            const SizedBox(width: 10), // Adjust the width for desired spacing
            Image.asset(
              'assets/logo.png',
              width: 40,
            ),
          ],
        ),
        title: const Text('Attenda',
            style: TextStyle(
                color: Colors.lightGreen,
                fontWeight: FontWeight.w900,
                fontSize: 30)),
        centerTitle: true,
        actions: [
          IconButton(
              onPressed: () {
                _signout();
              },
              icon: const Icon(Icons.logout))
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image.asset('assets/hero.png'),
            Center(
              child: RichText(
                text: const TextSpan(
                  children: [
                    TextSpan(
                      text: 'Mark your attendees as ',
                      style: TextStyle(fontSize: 24, color: Colors.black38),
                    ),
                    TextSpan(
                      text: 'present',
                      style: TextStyle(fontSize: 24, color: Colors.lightGreen),
                    ),
                    TextSpan(
                      text: ' ', // Add a space after "present"
                      style: TextStyle(fontSize: 24, color: Colors.black38),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: () async {
                  final qrResult = await _scanQRCode(context);
                  if (qrResult != null) {
                    _handleScanResult(qrResult);
                  }
                },
                icon: const Icon(Icons.qr_code_scanner_outlined),
                label: const Text('Scan QR Code'),
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Colors.lightGreen),
                  elevation: MaterialStateProperty.all(0),
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12.0))),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleScanResult(String qrResult) {
    final parts = qrResult.split(' ');
    if (parts.length >= 2) {
      _showAttendeeDetails(parts[0], parts.sublist(1).join(' '));
    } else {
      _showInvalidQRCodeDialog(context); // Pass context here
    }
  }

  void _showAttendeeDetails(String registrationNo, String name) async {
    final isPresent = await _checkAttendanceInDatabase(
        registrationNo); // Check attendance status

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Attendee Details'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Reg No.: $registrationNo'),
            const SizedBox(height: 10),
            Text('Name: $name'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: isPresent
                ? null
                : () =>
                    _markPresent(registrationNo), // Disable if already present
            child: Text(isPresent ? 'Already Present' : 'Present'),
          ),
        ],
      ),
    );
  }

  // Function to check attendance in database (replace with your actual implementation)
  Future<bool> _checkAttendanceInDatabase(String registrationNo) async {
    // Implement your logic to query the database for attendance status
    // This example assumes a placeholder function that always returns false
    return false;
  }

  // Function to mark attendee as present (replace with your actual implementation)
  Future<void> _markPresent(String registrationNo) async {
    // Implement your logic to update the database with attendance status
    // (e.g., using Firebase, Cloud Firestore, or your preferred database)
    print('Marking $registrationNo as present'); // Placeholder for now
  }

  void _showInvalidQRCodeDialog(BuildContext context) {
    // Pass context here
    showDialog(
      context: context,
      builder: (context) {
        // Set up a flag to prevent dismissing the dialog after it's popped
        bool isDialogDismissed = false;

        // Create a timer to automatically dismiss the dialog after 5 seconds
        Timer(const Duration(seconds: 5), () {
          if (!isDialogDismissed) {
            // Check if the dialog is still showing before attempting to dismiss
            Navigator.pop(context);
          }
        });

        // Build and return the AlertDialog
        return PopScope(
          // Prevent dialog dismissal via the back button
          child: AlertDialog(
            backgroundColor: Colors.white,
            content: const Text('Invalid QR code format'),
            actions: [
              TextButton(
                onPressed: () {
                  // Set the flag to true to indicate dialog dismissal
                  isDialogDismissed = true;
                  Navigator.pop(context); // Dismiss the dialog manually
                },
                child: const Text('OK'),
              ),
            ],
          ),
        );
      },
    );
  }

  void _signout() async {
    await client.auth.signOut();
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => const LoginScreen()));
  }
}
