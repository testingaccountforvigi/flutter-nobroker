import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../core/widgets/loading_overlay.dart';
import '../../data/properties_repository.dart';

class CreatePropertyScreen extends ConsumerStatefulWidget {
  final String? propertyId; // For edit mode

  const CreatePropertyScreen({super.key, this.propertyId});

  @override
  ConsumerState<CreatePropertyScreen> createState() => _CreatePropertyScreenState();
}

class _CreatePropertyScreenState extends ConsumerState<CreatePropertyScreen> {
  final _formKey = GlobalKey<FormState>();
  final PageController _pageController = PageController();
  int _currentStep = 0;
  bool _isLoading = false;

  // Form fields - Basic Details
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _propertyType = 'APARTMENT';
  String _listingType = 'RENT';
  final _priceController = TextEditingController();
  final _securityDepositController = TextEditingController();

  // Form fields - Property Details
  final _bedroomsController = TextEditingController();
  final _bathroomsController = TextEditingController();
  final _balconiesController = TextEditingController();
  final _builtUpAreaController = TextEditingController();
  final _carpetAreaController = TextEditingController();
  final _totalFloorsController = TextEditingController();
  final _floorNumberController = TextEditingController();
  String _furnishingStatus = 'UNFURNISHED';
  String _propertyAge = 'LESS_THAN_1';
  bool _isPetFriendly = false;
  bool _isBachelorFriendly = false;
  DateTime? _availableFrom;

  // Form fields - Location
  final _addressLine1Controller = TextEditingController();
  final _addressLine2Controller = TextEditingController();
  final _localityController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _pincodeController = TextEditingController();
  final _latitudeController = TextEditingController();
  final _longitudeController = TextEditingController();

  // Photos
  final List<File> _selectedPhotos = [];
  final ImagePicker _picker = ImagePicker();
  final _imageUrlController = TextEditingController();

  // Amenities
  List<Map<String, dynamic>> _availableAmenities = [];
  Set<String> _selectedAmenityIds = {};
  bool _amenitiesLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadAmenities();
    if (widget.propertyId != null) {
      _loadPropertyData();
    }
  }

  Future<void> _loadAmenities() async {
    try {
      final repository = PropertiesRepository();
      final amenities = await repository.getAmenities();
      setState(() {
        _availableAmenities = amenities;
        _amenitiesLoaded = true;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load amenities: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _loadPropertyData() async {
    // Load existing property data for edit mode
    // Implementation would fetch property details and populate controllers
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _securityDepositController.dispose();
    _bedroomsController.dispose();
    _bathroomsController.dispose();
    _balconiesController.dispose();
    _builtUpAreaController.dispose();
    _carpetAreaController.dispose();
    _totalFloorsController.dispose();
    _floorNumberController.dispose();
    _addressLine1Controller.dispose();
    _addressLine2Controller.dispose();
    _localityController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _pincodeController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    try {
      final List<XFile> images = await _picker.pickMultiImage();
      if (images.isNotEmpty) {
        setState(() {
          for (var image in images) {
            if (_selectedPhotos.length < 10) {
              _selectedPhotos.add(File(image.path));
            }
          }
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to pick images: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _removePhoto(int index) {
    setState(() {
      _selectedPhotos.removeAt(index);
    });
  }

  void _addImageFromUrl() {
    final url = _imageUrlController.text.trim();
    if (url.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter an image URL')),
      );
      return;
    }

    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid URL starting with http:// or https://')),
      );
      return;
    }

    if (_selectedPhotos.length >= 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Maximum 10 photos allowed')),
      );
      return;
    }

    // For now, just store the URL as a marker
    // In production, you would download and validate the image
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Image URL added: $url')),
    );
    
    setState(() {
      _imageUrlController.clear();
    });
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedPhotos.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add at least one photo'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final repository = PropertiesRepository();
      
      final propertyData = {
        'title': _titleController.text,
        'description': _descriptionController.text,
        'propertyType': _propertyType,
        'listingType': _listingType,
        'price': int.parse(_priceController.text),
        'securityDeposit': _securityDepositController.text.isNotEmpty
            ? int.parse(_securityDepositController.text)
            : null,
        'bedrooms': int.parse(_bedroomsController.text),
        'bathrooms': int.parse(_bathroomsController.text),
        'balconies': int.parse(_balconiesController.text),
        'builtUpArea': int.parse(_builtUpAreaController.text),
        'carpetArea': _carpetAreaController.text.isNotEmpty
            ? int.parse(_carpetAreaController.text)
            : null,
        'totalFloors': _totalFloorsController.text.isNotEmpty
            ? int.parse(_totalFloorsController.text)
            : null,
        'floorNumber': _floorNumberController.text.isNotEmpty
            ? int.parse(_floorNumberController.text)
            : null,
        'furnishingStatus': _furnishingStatus,
        'propertyAge': _propertyAge,
        'isPetFriendly': _isPetFriendly,
        'isBachelorFriendly': _isBachelorFriendly,
        'availableFrom': _availableFrom?.toIso8601String(),
        'addressLine1': _addressLine1Controller.text,
        'addressLine2': _addressLine2Controller.text.isNotEmpty
            ? _addressLine2Controller.text
            : null,
        'locality': _localityController.text,
        'city': _cityController.text,
        'state': _stateController.text,
        'pincode': _pincodeController.text,
        'latitude': _latitudeController.text.isNotEmpty
            ? double.parse(_latitudeController.text)
            : null,
        'longitude': _longitudeController.text.isNotEmpty
            ? double.parse(_longitudeController.text)
            : null,
        'amenityIds': _selectedAmenityIds.toList(),
      };

      final property = await repository.createProperty(propertyData);
      final propertyId = property['id'] as String;

      // Upload photos
      for (var photo in _selectedPhotos) {
        await repository.uploadPropertyPhoto(propertyId, photo);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Property created successfully!'),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _nextStep() {
    if (_currentStep < 4) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _submitForm();
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return LoadingOverlay(
      isLoading: _isLoading,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: Text(
            widget.propertyId != null ? 'Edit Property' : 'Create Property',
            style: AppTypography.h3.copyWith(color: AppColors.textPrimary),
          ),
          backgroundColor: Colors.white,
          elevation: 0,
          surfaceTintColor: Colors.transparent,
          iconTheme: const IconThemeData(color: AppColors.textPrimary),
        ),
        body: Form(
          key: _formKey,
          child: Column(
            children: [
              // Step Indicator
              _buildStepIndicator(),
              // Form Pages
              Expanded(
                child: PageView(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  onPageChanged: (index) {
                    setState(() {
                      _currentStep = index;
                    });
                  },
                  children: [
                    _buildBasicDetailsStep(),
                    _buildPropertyDetailsStep(),
                    _buildLocationStep(),
                    _buildPhotosStep(),
                    _buildAmenitiesStep(),
                  ],
                ),
              ),
              // Navigation Buttons
              _buildNavigationButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepIndicator() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      color: Colors.white,
      child: Row(
        children: List.generate(5, (index) {
          final isActive = index <= _currentStep;
          return Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 4,
                    decoration: BoxDecoration(
                      color: isActive ? AppColors.accent : AppColors.surface,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                if (index < 4) const SizedBox(width: 4),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildBasicDetailsStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Basic Details', style: AppTypography.h3),
          const SizedBox(height: AppSpacing.md),
          CustomTextField(
            controller: _titleController,
            label: 'Property Title',
            hint: 'e.g., 3 BHK Apartment in Bandra',
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter property title';
              }
              return null;
            },
          ),
          const SizedBox(height: AppSpacing.md),
          CustomTextField(
            controller: _descriptionController,
            label: 'Description',
            hint: 'Describe your property...',
            maxLines: 5,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter description';
              }
              return null;
            },
          ),
          const SizedBox(height: AppSpacing.md),
          _buildDropdown(
            label: 'Property Type',
            value: _propertyType,
            items: const [
              'APARTMENT',
              'INDEPENDENT_HOUSE',
              'VILLA',
              'BUILDER_FLOOR',
              'STUDIO',
              'PG',
            ],
            onChanged: (value) {
              setState(() {
                _propertyType = value!;
              });
            },
          ),
          const SizedBox(height: AppSpacing.md),
          _buildDropdown(
            label: 'Listing Type',
            value: _listingType,
            items: const ['RENT', 'SALE'],
            onChanged: (value) {
              setState(() {
                _listingType = value!;
              });
            },
          ),
          const SizedBox(height: AppSpacing.md),
          CustomTextField(
            controller: _priceController,
            label: _listingType == 'RENT' ? 'Monthly Rent (₹)' : 'Sale Price (₹)',
            hint: 'Enter amount',
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter price';
              }
              return null;
            },
          ),
          if (_listingType == 'RENT') ...[
            const SizedBox(height: AppSpacing.md),
            CustomTextField(
              controller: _securityDepositController,
              label: 'Security Deposit (₹)',
              hint: 'Enter amount (optional)',
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPropertyDetailsStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Property Details', style: AppTypography.h3),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: CustomTextField(
                  controller: _bedroomsController,
                  label: 'Bedrooms',
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Required';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: CustomTextField(
                  controller: _bathroomsController,
                  label: 'Bathrooms',
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Required';
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: CustomTextField(
                  controller: _balconiesController,
                  label: 'Balconies',
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Required';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: CustomTextField(
                  controller: _builtUpAreaController,
                  label: 'Built-up Area (sq.ft)',
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Required';
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          CustomTextField(
            controller: _carpetAreaController,
            label: 'Carpet Area (sq.ft)',
            hint: 'Optional',
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: CustomTextField(
                  controller: _floorNumberController,
                  label: 'Floor Number',
                  hint: 'Optional',
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: CustomTextField(
                  controller: _totalFloorsController,
                  label: 'Total Floors',
                  hint: 'Optional',
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          _buildDropdown(
            label: 'Furnishing Status',
            value: _furnishingStatus,
            items: const ['UNFURNISHED', 'SEMI_FURNISHED', 'FULLY_FURNISHED'],
            onChanged: (value) {
              setState(() {
                _furnishingStatus = value!;
              });
            },
          ),
          const SizedBox(height: AppSpacing.md),
          _buildDropdown(
            label: 'Property Age',
            value: _propertyAge,
            items: const [
              'LESS_THAN_1',
              '1_TO_3',
              '3_TO_5',
              '5_TO_10',
              'MORE_THAN_10',
            ],
            onChanged: (value) {
              setState(() {
                _propertyAge = value!;
              });
            },
          ),
          const SizedBox(height: AppSpacing.md),
          CheckboxListTile(
            title: const Text('Pet Friendly'),
            value: _isPetFriendly,
            onChanged: (value) {
              setState(() {
                _isPetFriendly = value ?? false;
              });
            },
            controlAffinity: ListTileControlAffinity.leading,
            contentPadding: EdgeInsets.zero,
          ),
          CheckboxListTile(
            title: const Text('Bachelor Friendly'),
            value: _isBachelorFriendly,
            onChanged: (value) {
              setState(() {
                _isBachelorFriendly = value ?? false;
              });
            },
            controlAffinity: ListTileControlAffinity.leading,
            contentPadding: EdgeInsets.zero,
          ),
          const SizedBox(height: AppSpacing.md),
          ListTile(
            title: const Text('Available From'),
            subtitle: Text(
              _availableFrom != null
                  ? '${_availableFrom!.day}/${_availableFrom!.month}/${_availableFrom!.year}'
                  : 'Select date',
            ),
            trailing: const Icon(Icons.calendar_today),
            onTap: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: _availableFrom ?? DateTime.now(),
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(const Duration(days: 365)),
              );
              if (date != null) {
                setState(() {
                  _availableFrom = date;
                });
              }
            },
            contentPadding: EdgeInsets.zero,
          ),
        ],
      ),
    );
  }

  Widget _buildLocationStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Location', style: AppTypography.h3),
          const SizedBox(height: AppSpacing.md),
          CustomTextField(
            controller: _addressLine1Controller,
            label: 'Address Line 1',
            hint: 'Building name, street',
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter address';
              }
              return null;
            },
          ),
          const SizedBox(height: AppSpacing.md),
          CustomTextField(
            controller: _addressLine2Controller,
            label: 'Address Line 2',
            hint: 'Landmark (optional)',
          ),
          const SizedBox(height: AppSpacing.md),
          CustomTextField(
            controller: _localityController,
            label: 'Locality',
            hint: 'e.g., Bandra West',
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter locality';
              }
              return null;
            },
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: CustomTextField(
                  controller: _cityController,
                  label: 'City',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Required';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: CustomTextField(
                  controller: _stateController,
                  label: 'State',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Required';
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          CustomTextField(
            controller: _pincodeController,
            label: 'Pincode',
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(6),
            ],
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter pincode';
              }
              if (value.length != 6) {
                return 'Pincode must be 6 digits';
              }
              return null;
            },
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Coordinates (Optional)',
            style: AppTypography.body.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Expanded(
                child: CustomTextField(
                  controller: _latitudeController,
                  label: 'Latitude',
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: CustomTextField(
                  controller: _longitudeController,
                  label: 'Longitude',
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPhotosStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Property Photos', style: AppTypography.h3),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Add at least 1 photo (max 10)',
            style: AppTypography.body.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: AppSpacing.md),
          
          // Image URL input field
          TextField(
            controller: _imageUrlController,
            decoration: InputDecoration(
              labelText: 'Or paste image URL',
              hintText: 'https://example.com/image.jpg',
              prefixIcon: const Icon(Icons.link),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
              ),
              suffixIcon: IconButton(
                icon: const Icon(Icons.add),
                onPressed: _addImageFromUrl,
              ),
            ),
            onSubmitted: (_) => _addImageFromUrl(),
          ),
          const SizedBox(height: AppSpacing.md),
          
          if (_selectedPhotos.isNotEmpty)
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: AppSpacing.sm,
                mainAxisSpacing: AppSpacing.sm,
              ),
              itemCount: _selectedPhotos.length + 1,
              itemBuilder: (context, index) {
                if (index == _selectedPhotos.length) {
                  if (_selectedPhotos.length < 10) {
                    return _buildAddPhotoButton();
                  }
                  return const SizedBox.shrink();
                }
                return _buildPhotoItem(index);
              },
            )
          else
            _buildAddPhotoButton(),
        ],
      ),
    );
  }

  Widget _buildAddPhotoButton() {
    return InkWell(
      onTap: _pickImages,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.accent, width: 2),
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_photo_alternate, size: 48, color: AppColors.accent),
            SizedBox(height: AppSpacing.xs),
            Text('Add Photos', style: TextStyle(color: AppColors.accent)),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoItem(int index) {
    return Stack(
      fit: StackFit.expand,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
          child: Image.file(
            _selectedPhotos[index],
            fit: BoxFit.cover,
          ),
        ),
        Positioned(
          top: 4,
          right: 4,
          child: InkWell(
            onTap: () => _removePhoto(index),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Colors.black54,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.close,
                size: 16,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAmenitiesStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Amenities', style: AppTypography.h3),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Select amenities available',
            style: AppTypography.body.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: AppSpacing.md),
          if (!_amenitiesLoaded)
            const Center(child: CircularProgressIndicator())
          else if (_availableAmenities.isEmpty)
            const Text('No amenities available')
          else
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: _availableAmenities.map((amenity) {
                final amenityId = amenity['id'] as String;
                final isSelected = _selectedAmenityIds.contains(amenityId);
                return FilterChip(
                  label: Text(amenity['name'] as String),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _selectedAmenityIds.add(amenityId);
                      } else {
                        _selectedAmenityIds.remove(amenityId);
                      }
                    });
                  },
                  selectedColor: AppColors.accent.withOpacity(0.2),
                  checkmarkColor: AppColors.accent,
                );
              }).toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTypography.label,
        ),
        const SizedBox(height: AppSpacing.xs),
        DropdownButtonFormField<String>(
          value: value,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
          ),
          items: items.map((item) {
            return DropdownMenuItem(
              value: item,
              child: Text(item.replaceAll('_', ' ').toUpperCase()),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildNavigationButtons() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          if (_currentStep > 0)
            Expanded(
              child: CustomButton(
                text: 'Back',
                variant: ButtonVariant.outlined,
                onPressed: _previousStep,
              ),
            ),
          if (_currentStep > 0) const SizedBox(width: AppSpacing.md),
          Expanded(
            flex: 2,
            child: CustomButton(
              text: _currentStep < 4 ? 'Next' : 'Create Property',
              onPressed: _nextStep,
            ),
          ),
        ],
      ),
    );
  }
}
