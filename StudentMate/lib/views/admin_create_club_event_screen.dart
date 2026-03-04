import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/club_event_model.dart';
import '../services/club_event_service.dart';
import '../utils/responsive_helper.dart';

class AdminCreateClubEventScreen extends StatefulWidget {
  const AdminCreateClubEventScreen({Key? key}) : super(key: key);

  @override
  State<AdminCreateClubEventScreen> createState() =>
      _AdminCreateClubEventScreenState();
}

class _AdminCreateClubEventScreenState
    extends State<AdminCreateClubEventScreen> {
  final _formKey = GlobalKey<FormState>();
  final _clubNameController = TextEditingController();
  final _eventNameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  final _registrationLinkController = TextEditingController();
  final _activityPointsController = TextEditingController();
  final _eventService = ClubEventService();
  final ImagePicker _imagePicker = ImagePicker();

  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  File? _selectedImage;
  Uint8List? _selectedImageBytes;
  String? _selectedImageBase64;
  bool _isLoading = false;

  @override
  void dispose() {
    _clubNameController.dispose();
    _eventNameController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _registrationLinkController.dispose();
    _activityPointsController.dispose();
    super.dispose();
  }

  /// Pick image from device
  Future<void> _pickImage() async {
    try {
      final XFile? picked = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 90,
      );

      if (picked == null) return;

      final Uint8List imageBytes = await picked.readAsBytes();
      final File imageFile = File(picked.path);

      setState(() {
        _selectedImage = imageFile;
        _selectedImageBytes = imageBytes;
        _selectedImageBase64 = base64Encode(imageBytes);
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Image selected successfully')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking image: $e')),
      );
    }
  }

  /// Select event date
  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(DateTime.now().year + 2),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  /// Select event time
  Future<void> _selectTime(BuildContext context) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() => _selectedTime = picked);
    }
  }

  /// Format selected date
  String _formatDate(DateTime? date) {
    if (date == null) return 'Select Date';
    return '${date.day}/${date.month}/${date.year}';
  }

  /// Format selected time
  String _formatTime(TimeOfDay? time) {
    if (time == null) return 'Select Time';
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  /// Validate URL format
  bool _isValidUrl(String url) {
    try {
      Uri.parse(url);
      return url.startsWith('http://') || url.startsWith('https://');
    } catch (e) {
      return false;
    }
  }

  /// Validate and create event
  Future<void> _createEvent() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select event date')),
      );
      return;
    }
    if (_selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select event time')),
      );
      return;
    }

    final registrationLink = _registrationLinkController.text.trim();
    if (registrationLink.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please provide a registration link')),
      );
      return;
    }

    if (!_isValidUrl(registrationLink)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Please enter a valid URL (must start with http:// or https://)'),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final activityPoints = int.parse(_activityPointsController.text.trim());

      final event = ClubEventModel(
        clubName: _clubNameController.text.trim(),
        eventName: _eventNameController.text.trim(),
        eventDate: _selectedDate!,
        eventTime:
            '${_selectedTime!.hour.toString().padLeft(2, '0')}:${_selectedTime!.minute.toString().padLeft(2, '0')}',
        description: _descriptionController.text.trim(),
        posterImageUrl: _selectedImageBase64,
        posterImagePath: _selectedImage?.path ?? '',
        eventLocation: _locationController.text.trim(),
        registrationLink: registrationLink,
        activityPoints: activityPoints,
        createdBy: 'admin', // TODO: Replace with actual user ID
      );

      final success = await _eventService.addClubEvent(event);

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('✓ Event created successfully')),
          );
          Navigator.pop(context, true);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('✗ Failed to create event')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final responsive = ResponsiveHelper(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Club Event'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(responsive.horizontalPadding),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Image Preview Section
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!, width: 2),
                  borderRadius: BorderRadius.circular(responsive.radiusMedium),
                ),
                child: _selectedImageBytes != null
                    ? ClipRRect(
                        borderRadius:
                            BorderRadius.circular(responsive.radiusMedium),
                        child: Image.memory(
                          _selectedImageBytes!,
                          height: 250,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      )
                    : _selectedImage != null
                        ? ClipRRect(
                            borderRadius:
                                BorderRadius.circular(responsive.radiusMedium),
                            child: Image.file(
                              _selectedImage!,
                              height: 250,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          )
                        : Container(
                            height: 200,
                            color: Colors.grey[100],
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.image_not_supported,
                                    size: 48, color: Colors.grey),
                                const SizedBox(height: 8),
                                Text('No image selected',
                                    style:
                                        Theme.of(context).textTheme.bodyMedium),
                              ],
                            ),
                          ),
              ),
              SizedBox(height: responsive.spacingMedium),

              // Upload Image Button
              ElevatedButton.icon(
                onPressed: _pickImage,
                icon: const Icon(Icons.upload_file),
                label: const Text('Select Poster Image'),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(
                    vertical: responsive.buttonHeight * 0.5,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    _selectedImageBase64 != null &&
                            _selectedImageBase64!.isNotEmpty
                        ? Icons.check_circle
                        : Icons.info_outline,
                    size: 18,
                    color: _selectedImageBase64 != null &&
                            _selectedImageBase64!.isNotEmpty
                        ? Colors.green
                        : Colors.grey,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _selectedImageBase64 != null &&
                              _selectedImageBase64!.isNotEmpty
                          ? 'Image attached successfully'
                          : 'No image attached',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: _selectedImageBase64 != null &&
                                    _selectedImageBase64!.isNotEmpty
                                ? Colors.green[700]
                                : Colors.grey[700],
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: responsive.spacingMedium),

              // Club Name TextField
              TextFormField(
                controller: _clubNameController,
                decoration: InputDecoration(
                  labelText: 'Club Name',
                  hintText: 'e.g., Music Club, Tech Club',
                  border: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(responsive.radiusMedium),
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: responsive.horizontalPadding,
                    vertical: 12,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Club name is required';
                  }
                  return null;
                },
              ),
              SizedBox(height: responsive.spacingMedium),

              // Event Name TextField
              TextFormField(
                controller: _eventNameController,
                decoration: InputDecoration(
                  labelText: 'Event Name',
                  hintText: 'e.g., Campus Fashion Show',
                  border: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(responsive.radiusMedium),
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: responsive.horizontalPadding,
                    vertical: 12,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Event name is required';
                  }
                  return null;
                },
              ),
              SizedBox(height: responsive.spacingMedium),

              // Date and Time Row
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () => _selectDate(context),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: responsive.horizontalPadding,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[400]!),
                          borderRadius:
                              BorderRadius.circular(responsive.radiusMedium),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Date',
                              style: Theme.of(context)
                                  .textTheme
                                  .labelSmall
                                  ?.copyWith(color: Colors.grey),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _formatDate(_selectedDate),
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: responsive.spacingSmall),
                  Expanded(
                    child: InkWell(
                      onTap: () => _selectTime(context),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: responsive.horizontalPadding,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[400]!),
                          borderRadius:
                              BorderRadius.circular(responsive.radiusMedium),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Time',
                              style: Theme.of(context)
                                  .textTheme
                                  .labelSmall
                                  ?.copyWith(color: Colors.grey),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _formatTime(_selectedTime),
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: responsive.spacingMedium),

              // Event Location TextField
              TextFormField(
                controller: _locationController,
                decoration: InputDecoration(
                  labelText: 'Event Location',
                  hintText: 'e.g., Audi 2, PJ Block',
                  border: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(responsive.radiusMedium),
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: responsive.horizontalPadding,
                    vertical: 12,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Location is required';
                  }
                  return null;
                },
              ),
              SizedBox(height: responsive.spacingMedium),

              // Description TextField
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: 'Event Description',
                  hintText: 'Enter event details and highlights...',
                  border: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(responsive.radiusMedium),
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: responsive.horizontalPadding,
                    vertical: 12,
                  ),
                  alignLabelWithHint: true,
                ),
                maxLines: 5,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Description is required';
                  }
                  if (value.length < 10) {
                    return 'Description must be at least 10 characters';
                  }
                  return null;
                },
              ),
              SizedBox(height: responsive.spacingMedium),

              // Registration Link TextField
              TextFormField(
                controller: _registrationLinkController,
                decoration: InputDecoration(
                  labelText: 'Google Forms Registration Link',
                  hintText:
                      'e.g., https://forms.gle/xxxxx or https://docs.google.com/forms/...',
                  border: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(responsive.radiusMedium),
                  ),
                  prefixIcon: const Icon(Icons.link),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: responsive.horizontalPadding,
                    vertical: 12,
                  ),
                  helperText:
                      'Students will be directed to this form to register',
                ),
                keyboardType: TextInputType.url,
              ),
              SizedBox(height: responsive.spacingMedium),

              // Activity Points TextField
              TextFormField(
                controller: _activityPointsController,
                decoration: InputDecoration(
                  labelText: 'Activity Points',
                  hintText: 'e.g., 10, 15, 25',
                  border: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(responsive.radiusMedium),
                  ),
                  prefixIcon: const Icon(Icons.star),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: responsive.horizontalPadding,
                    vertical: 12,
                  ),
                  helperText: 'Points awarded for event participation',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Activity points are required';
                  }
                  final points = int.tryParse(value);
                  if (points == null || points <= 0) {
                    return 'Please enter a valid positive number';
                  }
                  if (points > 500) {
                    return 'Points cannot exceed 500';
                  }
                  return null;
                },
              ),
              SizedBox(height: responsive.spacingLarge),

              // Create Button
              ElevatedButton(
                onPressed: _isLoading ? null : _createEvent,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(
                    vertical: responsive.buttonHeight * 0.5,
                  ),
                  backgroundColor: Colors.blue,
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                          strokeWidth: 2,
                        ),
                      )
                    : const Text('Create Event',
                        style: TextStyle(fontSize: 16, color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
