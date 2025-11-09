import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:bookswap_app/models/book_listing.dart';
import 'package:bookswap_app/providers/book_provider.dart';
import 'package:bookswap_app/providers/auth_provider.dart';

class AddEditListingScreen extends StatefulWidget {
  final BookListing? book;

  const AddEditListingScreen({super.key, this.book});

  @override
  State<AddEditListingScreen> createState() => _AddEditListingScreenState();
}

class _AddEditListingScreenState extends State<AddEditListingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _authorController = TextEditingController();
  
  BookCondition _selectedCondition = BookCondition.good;
  XFile? _selectedImage;
  String? _imageUrl;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.book != null) {
      _titleController.text = widget.book!.title;
      _authorController.text = widget.book!.author;
      _selectedCondition = widget.book!.condition;
      _imageUrl = widget.book!.imageUrl;
    }
  }

  Future<void> _pickImage() async {
    final bookProvider = Provider.of<BookProvider>(context, listen: false);
    final image = await bookProvider.storageService.pickImage();
    if (image != null) {
      setState(() {
        _selectedImage = image;
        _imageUrl = null;
      });
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    final bookProvider = Provider.of<BookProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    setState(() => _isLoading = true);

    try {
      String? finalImageUrl = _imageUrl;
      
      if (_selectedImage != null) {
        // Show progress dialog
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Uploading image...'),
              duration: Duration(seconds: 2),
            ),
          );
        }
        
        try {
          finalImageUrl = await bookProvider.storageService.uploadBookImage(
            _selectedImage!,
            authProvider.user!.id,
          );
        } on Exception catch (e) {
          // Storage upload failed, offer to use placeholder
          if (mounted) {
            final usePlaceholder = await showDialog<bool>(
              context: context,
              barrierDismissible: false,
              builder: (context) => AlertDialog(
                title: Row(
                  children: [
                    Icon(Icons.warning_amber_rounded, color: Colors.orange),
                    SizedBox(width: 8),
                    Text('Image Upload Failed'),
                  ],
                ),
                content: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.red[50],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.red[200]!),
                        ),
                        child: Text(
                          e.toString().replaceAll('Exception: ', ''),
                          style: TextStyle(fontSize: 13, color: Colors.red[900]),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.blue[50],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '💡 Continue Without Storage?',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'You can add this book with a placeholder image and continue testing the app.',
                              style: TextStyle(fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('Cancel'),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => Navigator.pop(context, true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    ),
                    icon: Icon(Icons.check_circle),
                    label: const Text('Add Book Anyway'),
                  ),
                ],
              ),
            );
            
            if (usePlaceholder == true) {
              // Use placeholder image
              finalImageUrl = bookProvider.storageService.getPlaceholderImage(
                _titleController.text.trim(),
              );
              print('📌 Using placeholder image: $finalImageUrl');
            } else {
              // User cancelled
              setState(() => _isLoading = false);
              return;
            }
          } else {
            // Dialog couldn't be shown, use placeholder anyway
            finalImageUrl = bookProvider.storageService.getPlaceholderImage(
              _titleController.text.trim(),
            );
            print('📌 Using placeholder image (no dialog): $finalImageUrl');
          }
        }
      }

      if (finalImageUrl == null) {
        throw Exception('Please select an image');
      }

      print('📚 Adding book to Firestore...');
      print('   Title: ${_titleController.text.trim()}');
      print('   Author: ${_authorController.text.trim()}');
      print('   Image: $finalImageUrl');

      bool success;
      if (widget.book == null) {
        success = await bookProvider.addBook(
          title: _titleController.text.trim(),
          author: _authorController.text.trim(),
          condition: _selectedCondition,
          imageUrl: finalImageUrl,
          ownerId: authProvider.user!.id,
          ownerName: authProvider.user!.displayName,
        );
        print(success ? '✅ Book created in Firestore!' : '❌ Failed to create book');
      } else {
        final updatedBook = BookListing(
          id: widget.book!.id,
          title: _titleController.text.trim(),
          author: _authorController.text.trim(),
          condition: _selectedCondition,
          imageUrl: finalImageUrl,
          ownerId: widget.book!.ownerId,
          ownerName: widget.book!.ownerName,
          createdAt: widget.book!.createdAt,
          isAvailable: widget.book!.isAvailable,
        );
        success = await bookProvider.updateBook(updatedBook);
      }

      setState(() => _isLoading = false);

      if (success && context.mounted) {
        print('✅ Success! Showing confirmation and closing screen...');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    widget.book == null 
                        ? 'Book added to your listings!' 
                        : 'Book updated successfully!',
                    style: TextStyle(fontSize: 15),
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );
        
        // Wait a moment then close
        await Future.delayed(Duration(milliseconds: 300));
        if (context.mounted) {
          Navigator.pop(context);
        }
      } else if (!success && context.mounted) {
        print('❌ Failed to add/update book');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${bookProvider.error ?? "Failed to save book"}'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (context.mounted) {
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
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.book == null ? 'Add Book' : 'Edit Book'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  width: 150,
                  height: 200,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: _selectedImage != null
                      ? Image.file(File(_selectedImage!.path), fit: BoxFit.cover)
                      : _imageUrl != null
                          ? Image.network(_imageUrl!, fit: BoxFit.cover)
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.add_photo_alternate, 
                                    size: 40, color: Colors.grey),
                                SizedBox(height: 8),
                                Text('Add Cover Image', 
                                    style: TextStyle(color: Colors.grey)),
                              ],
                            ),
                ),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'Book Title',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter book title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _authorController,
                decoration: InputDecoration(
                  labelText: 'Author',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter author name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<BookCondition>(
                initialValue: _selectedCondition,
                decoration: InputDecoration(
                  labelText: 'Condition',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                items: BookCondition.values.map((condition) {
                  return DropdownMenuItem(
                    value: condition,
                    child: Text(_getConditionString(condition)),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCondition = value!;
                  });
                },
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation(Colors.white),
                          ),
                        )
                      : Text(
                          widget.book == null ? 'List Book' : 'Update Book',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getConditionString(BookCondition condition) {
    switch (condition) {
      case BookCondition.newCondition:
        return 'New';
      case BookCondition.likeNew:
        return 'Like New';
      case BookCondition.good:
        return 'Good';
      case BookCondition.used:
        return 'Used';
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _authorController.dispose();
    super.dispose();
  }
}