import 'package:flutter/material.dart';

import '../../showrooms/domain/showroom.dart';
import '../data/supabase_admin_showroom_repository.dart';
import '../domain/admin_showroom_repository.dart';

class ShowroomFormPage extends StatefulWidget {
  const ShowroomFormPage({super.key, this.showroom, this.repository});

  final Showroom? showroom;
  final AdminShowroomRepository? repository;

  @override
  State<ShowroomFormPage> createState() => _ShowroomFormPageState();
}

class _ShowroomFormPageState extends State<ShowroomFormPage> {
  final _formKey = GlobalKey<FormState>();
  late final AdminShowroomRepository _repository =
      widget.repository ?? const SupabaseAdminShowroomRepository();

  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _addressController;
  late final TextEditingController _cityController;
  late final TextEditingController _phoneController;
  late final TextEditingController _whatsappController;
  late final TextEditingController _emailController;
  late final TextEditingController _websiteController;
  late final TextEditingController _latitudeController;
  late final TextEditingController _longitudeController;

  late String _status;
  bool _isSubmitting = false;

  bool get _isEditing => widget.showroom != null;

  @override
  void initState() {
    super.initState();
    final s = widget.showroom;
    _nameController = TextEditingController(text: s?.name ?? '');
    _descriptionController = TextEditingController(text: s?.description ?? '');
    _addressController = TextEditingController(text: s?.address ?? '');
    _cityController = TextEditingController(text: s?.city ?? 'Gujranwala');
    _phoneController = TextEditingController(text: s?.phone ?? '');
    _whatsappController = TextEditingController(text: s?.whatsapp ?? '');
    _emailController = TextEditingController(text: s?.email ?? '');
    _websiteController = TextEditingController(text: s?.website ?? '');
    _latitudeController = TextEditingController(
      text: s?.latitude?.toString() ?? '',
    );
    _longitudeController = TextEditingController(
      text: s?.longitude?.toString() ?? '',
    );
    _status = s?.status ?? 'pending';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _phoneController.dispose();
    _whatsappController.dispose();
    _emailController.dispose();
    _websiteController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    final showroom = Showroom(
      id: widget.showroom?.id ?? 0,
      name: _nameController.text.trim(),
      description: _emptyToNull(_descriptionController.text.trim()),
      address: _addressController.text.trim(),
      city: _cityController.text.trim().isEmpty
          ? 'Gujranwala'
          : _cityController.text.trim(),
      phone: _emptyToNull(_phoneController.text.trim()),
      whatsapp: _emptyToNull(_whatsappController.text.trim()),
      email: _emptyToNull(_emailController.text.trim()),
      website: _emptyToNull(_websiteController.text.trim()),
      latitude: _parseDouble(_latitudeController.text),
      longitude: _parseDouble(_longitudeController.text),
      status: _status,
    );

    try {
      if (_isEditing) {
        await _repository.updateShowroom(showroom);
      } else {
        await _repository.createShowroom(showroom);
      }
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to save showroom: $e')));
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  String? _emptyToNull(String value) => value.isEmpty ? null : value;

  double? _parseDouble(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return null;
    return double.tryParse(trimmed);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Showroom' : 'Add Showroom'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Name *'),
                textInputAction: TextInputAction.next,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Name is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 3,
                textInputAction: TextInputAction.newline,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(labelText: 'Address *'),
                textInputAction: TextInputAction.next,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Address is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _cityController,
                decoration: const InputDecoration(labelText: 'City'),
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: 'Phone',
                  prefixText: '+92 ',
                ),
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _whatsappController,
                decoration: const InputDecoration(
                  labelText: 'WhatsApp',
                  prefixText: '+92 ',
                ),
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                validator: (value) {
                  final v = value?.trim() ?? '';
                  if (v.isEmpty) return null;
                  final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
                  if (!emailRegex.hasMatch(v)) {
                    return 'Enter a valid email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _websiteController,
                decoration: const InputDecoration(labelText: 'Website'),
                keyboardType: TextInputType.url,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _latitudeController,
                      decoration: const InputDecoration(labelText: 'Latitude'),
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                        signed: true,
                      ),
                      textInputAction: TextInputAction.next,
                      validator: (value) =>
                          _validateCoordinate(value, -90, 90, 'Latitude'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _longitudeController,
                      decoration: const InputDecoration(labelText: 'Longitude'),
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                        signed: true,
                      ),
                      textInputAction: TextInputAction.next,
                      validator: (value) =>
                          _validateCoordinate(value, -180, 180, 'Longitude'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _status,
                decoration: const InputDecoration(labelText: 'Status'),
                items: const [
                  DropdownMenuItem(value: 'pending', child: Text('Pending')),
                  DropdownMenuItem(value: 'approved', child: Text('Approved')),
                  DropdownMenuItem(value: 'rejected', child: Text('Rejected')),
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
                            color: Colors.white,
                          ),
                        )
                      : Text(_isEditing ? 'Update Showroom' : 'Add Showroom'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String? _validateCoordinate(
    String? value,
    double min,
    double max,
    String label,
  ) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return null;
    final num = double.tryParse(v);
    if (num == null) return 'Enter a valid number';
    if (num < min || num > max) return '$label out of range';
    return null;
  }
}
