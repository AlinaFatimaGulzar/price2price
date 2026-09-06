import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../app/theme/app_theme.dart';
import '../../../core/storage/image_storage_repository.dart';
import '../../../core/widgets/image_picker_field.dart';

import '../../showrooms/domain/showroom.dart';
import '../data/supabase_admin_car_repository.dart';
import '../domain/admin_car_repository.dart';
import '../domain/car.dart';

class CarFormPage extends StatefulWidget {
  const CarFormPage({super.key, this.car, this.repository, this.imageStorage});

  final Car? car;
  final AdminCarRepository? repository;
  final ImageStorageRepository? imageStorage;

  @override
  State<CarFormPage> createState() => _CarFormPageState();
}

class _CarFormPageState extends State<CarFormPage> {
  final _formKey = GlobalKey<FormState>();
  late final AdminCarRepository _repository =
      widget.repository ?? const SupabaseAdminCarRepository();
  late final ImageStorageRepository _imageStorage =
      widget.imageStorage ?? const SupabaseImageStorageRepository();

  late final TextEditingController _titleController;
  late final TextEditingController _brandController;
  late final TextEditingController _modelController;
  late final TextEditingController _yearController;
  late final TextEditingController _priceController;
  late final TextEditingController _kmController;
  late final TextEditingController _descriptionController;

  late int? _showroomId;
  late String _fuel;
  late String _transmission;
  late String _condition;
  late String _status;

  bool _isSubmitting = false;
  bool _isUploadingImage = false;
  XFile? _pickedImage;
  Uint8List? _pickedBytes;
  String? _imageUrl;
  List<Showroom> _showrooms = [];
  bool _loadingShowrooms = false;

  bool get _isEditing => widget.car != null;

  @override
  void initState() {
    super.initState();
    final c = widget.car;
    _imageUrl = c?.imageUrl;
    _titleController = TextEditingController(text: c?.title ?? '');
    _brandController = TextEditingController(text: c?.brand ?? '');
    _modelController = TextEditingController(text: c?.model ?? '');
    _yearController = TextEditingController(text: c?.year?.toString() ?? '');
    _priceController = TextEditingController(text: c?.price?.toString() ?? '');
    _kmController = TextEditingController(text: c?.km?.toString() ?? '');
    _descriptionController = TextEditingController(text: c?.description ?? '');
    _showroomId = c?.showroomId;
    _fuel = c?.fuel ?? 'petrol';
    _transmission = c?.transmission ?? 'automatic';
    _condition = c?.condition ?? 'used';
    _status = c?.status ?? 'pending';

    _loadShowrooms();
  }

  Future<void> _loadShowrooms() async {
    setState(() => _loadingShowrooms = true);
    final result = await _repository.getShowroomsForDropdown();
    if (!mounted) return;
    setState(() {
      _showrooms = result;
      _loadingShowrooms = false;
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _brandController.dispose();
    _modelController.dispose();
    _yearController.dispose();
    _priceController.dispose();
    _kmController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  int? _parseInt(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return null;
    return int.tryParse(trimmed);
  }

  num? _parseNum(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return null;
    return num.tryParse(trimmed);
  }

  String? _emptyToNull(String value) =>
      value.trim().isEmpty ? null : value.trim();

  Future<void> _pickImage() async {
    try {
      final picker = ImagePicker();
      final file = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1600,
        imageQuality: 85,
      );
      if (file == null) return;
      final bytes = await file.readAsBytes();
      if (!mounted) return;
      setState(() {
        _pickedImage = file;
        _pickedBytes = bytes;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Image select nahi hui: $e')));
    }
  }

  void _clearImage() {
    setState(() {
      _pickedImage = null;
      _pickedBytes = null;
      _imageUrl = null;
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    String? imageUrl = _imageUrl;
    if (_pickedBytes != null) {
      setState(() => _isUploadingImage = true);
      try {
        imageUrl = await _imageStorage.uploadImage(
          bucket: ImageBuckets.carImages,
          folder: 'cars',
          bytes: _pickedBytes!,
          contentType: _pickedImage?.mimeType ?? 'image/jpeg',
          fileName: _pickedImage?.name ?? 'car.jpg',
        );
      } catch (e) {
        if (!mounted) return;
        setState(() => _isSubmitting = false);
        setState(() => _isUploadingImage = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Image upload fail: $e')));
        return;
      }
    }

    final car = Car(
      id: widget.car?.id ?? 0,
      showroomId: _showroomId ?? 0,
      title: _titleController.text.trim(),
      brand: _brandController.text.trim(),
      model: _emptyToNull(_modelController.text),
      year: _parseInt(_yearController.text),
      price: _parseNum(_priceController.text),
      km: _parseInt(_kmController.text),
      fuel: _fuel,
      transmission: _transmission,
      condition: _condition,
      description: _emptyToNull(_descriptionController.text),
      imageUrl: imageUrl,
      status: _status,
    );

    try {
      if (_isEditing) {
        await _repository.updateCar(car);
      } else {
        await _repository.createCar(car);
      }
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to save car: $e')));
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
          _isUploadingImage = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final fuelTypes = ['petrol', 'diesel', 'hybrid', 'electric', 'cng'];
    final transmissions = ['automatic', 'manual'];
    final conditions = ['new', 'used'];

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Car' : 'Add Car'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Showroom dropdown
                  if (_loadingShowrooms)
                    TextFormField(
                      enabled: false,
                      decoration: const InputDecoration(
                        labelText: 'Showroom *',
                        prefixIcon: Icon(Icons.store),
                        hintText: 'Loading showrooms...',
                      ),
                    )
                  else
                    DropdownButtonFormField<int?>(
                      initialValue: _showroomId,
                      decoration: const InputDecoration(
                        labelText: 'Showroom *',
                        prefixIcon: Icon(Icons.store),
                      ),
                      items: _showrooms
                          .map(
                            (s) => DropdownMenuItem<int?>(
                              value: s.id,
                              child: Text(s.name),
                            ),
                          )
                          .toList(),
                      onChanged: (value) => setState(() => _showroomId = value),
                      validator: (value) =>
                          value == null ? 'Select a showroom' : null,
                    ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      labelText: 'Title *',
                      hintText: 'e.g. Honda Civic 2019',
                      prefixIcon: Icon(Icons.directions_car),
                    ),
                    textInputAction: TextInputAction.next,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Title is required';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _brandController,
                          decoration: const InputDecoration(
                            labelText: 'Brand *',
                            hintText: 'e.g. Honda',
                          ),
                          textInputAction: TextInputAction.next,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Brand is required';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          controller: _modelController,
                          decoration: const InputDecoration(
                            labelText: 'Model',
                            hintText: 'e.g. Civic',
                          ),
                          textInputAction: TextInputAction.next,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _yearController,
                          decoration: const InputDecoration(
                            labelText: 'Year',
                            hintText: '2019',
                          ),
                          keyboardType: TextInputType.number,
                          textInputAction: TextInputAction.next,
                          validator: (value) {
                            final v = value?.trim() ?? '';
                            if (v.isEmpty) return null;
                            final parsed = int.tryParse(v);
                            if (parsed == null) return 'Invalid year';
                            if (parsed < 1980 ||
                                parsed > DateTime.now().year + 1) {
                              return 'Year out of range';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          controller: _priceController,
                          decoration: const InputDecoration(
                            labelText: 'Price (PKR)',
                            hintText: '4500000',
                          ),
                          keyboardType: TextInputType.number,
                          textInputAction: TextInputAction.next,
                          validator: (value) {
                            final v = value?.trim() ?? '';
                            if (v.isEmpty) return null;
                            if (num.tryParse(v) == null) return 'Invalid price';
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _kmController,
                          decoration: const InputDecoration(
                            labelText: 'Km driven',
                            hintText: '45000',
                          ),
                          keyboardType: TextInputType.number,
                          textInputAction: TextInputAction.next,
                          validator: (value) {
                            final v = value?.trim() ?? '';
                            if (v.isEmpty) return null;
                            if (int.tryParse(v) == null) return 'Invalid km';
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          initialValue: _fuel,
                          decoration: const InputDecoration(labelText: 'Fuel'),
                          items: fuelTypes
                              .map(
                                (f) =>
                                    DropdownMenuItem(value: f, child: Text(f)),
                              )
                              .toList(),
                          onChanged: (value) {
                            if (value != null) setState(() => _fuel = value);
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          initialValue: _transmission,
                          decoration: const InputDecoration(
                            labelText: 'Transmission',
                          ),
                          items: transmissions
                              .map(
                                (t) =>
                                    DropdownMenuItem(value: t, child: Text(t)),
                              )
                              .toList(),
                          onChanged: (value) {
                            if (value != null) {
                              setState(() => _transmission = value);
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          initialValue: _condition,
                          decoration: const InputDecoration(
                            labelText: 'Condition',
                          ),
                          items: conditions
                              .map(
                                (c) =>
                                    DropdownMenuItem(value: c, child: Text(c)),
                              )
                              .toList(),
                          onChanged: (value) {
                            if (value != null) {
                              setState(() => _condition = value);
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(labelText: 'Description'),
                    maxLines: 4,
                    textInputAction: TextInputAction.newline,
                  ),
                  const SizedBox(height: 20),
                  ImagePickerField(
                    label: 'Car Photo',
                    bytes: _pickedBytes,
                    existingUrl: _imageUrl,
                    isUploading: _isUploadingImage,
                    onPick: _pickImage,
                    onClear: _clearImage,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    initialValue: _status,
                    decoration: const InputDecoration(labelText: 'Status'),
                    items: const [
                      DropdownMenuItem(
                        value: 'pending',
                        child: Text('Pending'),
                      ),
                      DropdownMenuItem(
                        value: 'approved',
                        child: Text('Approved'),
                      ),
                      DropdownMenuItem(
                        value: 'rejected',
                        child: Text('Rejected'),
                      ),
                    ],
                    onChanged: (value) {
                      if (value != null) setState(() => _status = value);
                    },
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isSubmitting ? null : _submit,
                      child: _isSubmitting
                          ? const SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.onAccent,
                              ),
                            )
                          : Text(_isEditing ? 'Update Car' : 'Add Car'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
