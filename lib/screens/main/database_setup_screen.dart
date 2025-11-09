import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bookswap_app/providers/auth_provider.dart';
import 'package:bookswap_app/providers/book_provider.dart';
import 'package:bookswap_app/services/firestore_setup.dart';

class DatabaseSetupScreen extends StatefulWidget {
  const DatabaseSetupScreen({super.key});

  @override
  State<DatabaseSetupScreen> createState() => _DatabaseSetupScreenState();
}

class _DatabaseSetupScreenState extends State<DatabaseSetupScreen> {
  final _firestoreSetup = FirestoreSetup();
  bool _isLoading = false;
  String _statusMessage = 'Ready to set up database...';
  final List<String> _logs = [];

  void _addLog(String message) {
    setState(() {
      _logs.add('${DateTime.now().toString().substring(11, 19)} - $message');
    });
  }

  Future<void> _verifyCollections() async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'Verifying collections...';
      _logs.clear();
    });

    try {
      _addLog('Starting verification...');
      
      // Check Firebase Storage first
      final bookProvider = Provider.of<BookProvider>(context, listen: false);
      _addLog('Checking Firebase Storage...');
      final storageOk = await bookProvider.storageService.checkStorageConfiguration();
      _addLog(storageOk ? '✅ Storage: OK' : '⚠️  Storage: Need to configure rules');
      
      final result = await _firestoreSetup.verifyCollections();
      
      _addLog('Users: ${result['users'] ? '✅ OK' : '❌ Failed'}');
      _addLog('Book Listings: ${result['book_listings'] ? '✅ OK' : '❌ Failed'}');
      _addLog('Swap Offers: ${result['swap_offers'] ? '✅ OK' : '❌ Failed'}');
      _addLog('Chats: ${result['chats'] ? '✅ OK' : '❌ Failed'}');
      
      await _firestoreSetup.printCollectionStats();
      
      setState(() {
        _statusMessage = 'Verification complete!';
        _isLoading = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Collections verified successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      _addLog('❌ Error: $e');
      setState(() {
        _statusMessage = 'Verification failed!';
        _isLoading = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _createSampleData() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    if (authProvider.user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please sign in first!'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _statusMessage = 'Creating sample data...';
      _logs.clear();
    });

    try {
      _addLog('Creating user profile...');
      await _firestoreSetup.createUserProfile(authProvider.user!);
      _addLog('✅ User profile created');
      
      _addLog('Creating sample books...');
      await _firestoreSetup.createSampleBooks(
        authProvider.user!.id,
        authProvider.user!.displayName,
      );
      _addLog('✅ Sample books created');
      
      await _firestoreSetup.printCollectionStats();
      
      setState(() {
        _statusMessage = 'Sample data created successfully!';
        _isLoading = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Sample data created! Check your Firestore console.'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      _addLog('❌ Error: $e');
      setState(() {
        _statusMessage = 'Failed to create sample data!';
        _isLoading = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _showStats() async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'Loading statistics...';
      _logs.clear();
    });

    try {
      _addLog('Fetching collection statistics...');
      await _firestoreSetup.printCollectionStats();
      
      setState(() {
        _statusMessage = 'Statistics loaded!';
        _isLoading = false;
      });
    } catch (e) {
      _addLog('❌ Error: $e');
      setState(() {
        _statusMessage = 'Failed to load statistics!';
        _isLoading = false;
      });
    }
  }

  Future<void> _clearAllData() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('⚠️ Clear All Data'),
        content: const Text(
          'This will permanently delete ALL data from Firestore!\n\n'
          'This action cannot be undone. Are you sure?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete All'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() {
      _isLoading = true;
      _statusMessage = 'Clearing all data...';
      _logs.clear();
    });

    try {
      _addLog('⚠️  Deleting all data...');
      await _firestoreSetup.clearAllTestData();
      _addLog('✅ All data cleared');
      
      setState(() {
        _statusMessage = 'All data cleared!';
        _isLoading = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('All data has been cleared from Firestore'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      _addLog('❌ Error: $e');
      setState(() {
        _statusMessage = 'Failed to clear data!';
        _isLoading = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Database Setup'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // User Info Card
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Current User',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text('Name: ${authProvider.user?.displayName ?? 'Not signed in'}'),
                    Text('Email: ${authProvider.user?.email ?? 'N/A'}'),
                    Text('ID: ${authProvider.user?.id ?? 'N/A'}'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Status Card
            Card(
              elevation: 2,
              color: Colors.blue[50],
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    if (_isLoading)
                      const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    if (_isLoading) const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _statusMessage,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Action Buttons
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _verifyCollections,
              icon: const Icon(Icons.check_circle_outline),
              label: const Text('Verify Collections'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.all(16),
              ),
            ),
            const SizedBox(height: 12),
            
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _createSampleData,
              icon: const Icon(Icons.add_circle_outline),
              label: const Text('Create Sample Data'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.all(16),
              ),
            ),
            const SizedBox(height: 12),
            
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _showStats,
              icon: const Icon(Icons.bar_chart),
              label: const Text('Show Statistics'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.all(16),
              ),
            ),
            const SizedBox(height: 12),
            
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _clearAllData,
              icon: const Icon(Icons.delete_forever),
              label: const Text('Clear All Data'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.all(16),
              ),
            ),
            const SizedBox(height: 24),
            
            // Logs Card
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Activity Log',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Divider(),
                    if (_logs.isEmpty)
                      const Padding(
                        padding: EdgeInsets.all(16),
                        child: Center(
                          child: Text(
                            'No activity yet',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                      )
                    else
                      Container(
                        constraints: const BoxConstraints(maxHeight: 300),
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: _logs.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Text(
                                _logs[index],
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontFamily: 'monospace',
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
