import 'package:flutter/material.dart';

import '../../../app/theme/app_theme.dart';
import '../domain/enquiry_repository.dart';

Future<void> showEnquirySheet(
  BuildContext context, {
  required EnquiryRepository repository,
  int? carId,
  String? carTitle,
  int? showroomId,
  String? showroomName,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _EnquirySheet(
      repository: repository,
      carId: carId,
      carTitle: carTitle,
      showroomId: showroomId,
      showroomName: showroomName,
    ),
  );
}

class _EnquirySheet extends StatefulWidget {
  const _EnquirySheet({
    required this.repository,
    this.carId,
    this.carTitle,
    this.showroomId,
    this.showroomName,
  });

  final EnquiryRepository repository;
  final int? carId;
  final String? carTitle;
  final int? showroomId;
  final String? showroomName;

  @override
  State<_EnquirySheet> createState() => _EnquirySheetState();
}

class _EnquirySheetState extends State<_EnquirySheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _messageController = TextEditingController();
  bool _isSubmitting = false;

  bool get _isBusy => _isSubmitting;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      await widget.repository.submitEnquiry(
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        message: _messageController.text.trim(),
        carId: widget.carId,
        showroomId: widget.showroomId,
        carTitle: widget.carTitle,
        showroomName: widget.showroomName,
      );
      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Enquiry sent. The showroom will contact you soon.'),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Enquiry fail: $e')));
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  String? _validatePhone(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'Phone number is required';
    final digits = v.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.length < 10) return 'Enter a valid phone number';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final hint = widget.carTitle != null
        ? 'Ask about ${widget.carTitle}'
        : 'Ask about ${widget.showroomName ?? 'this showroom'}';

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        decoration: AppGlass.liquid(radius: 24),
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 44,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.mutedInk,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.accent.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.forum_outlined,
                        color: AppColors.accent,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Send Enquiry',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(hint, style: Theme.of(context).textTheme.bodySmall),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Your Name *',
                    prefixIcon: Icon(Icons.person_outline),
                  ),
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
                  controller: _phoneController,
                  decoration: const InputDecoration(
                    labelText: 'Phone Number *',
                    prefixIcon: Icon(Icons.phone_outlined),
                  ),
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.next,
                  validator: _validatePhone,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _messageController,
                  decoration: const InputDecoration(
                    labelText: 'Message *',
                    prefixIcon: Icon(Icons.chat_bubble_outline),
                  ),
                  maxLines: 4,
                  textInputAction: TextInputAction.newline,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Message is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _isBusy ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(0, 52),
                    ),
                    icon: _isBusy
                        ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.onAccent,
                            ),
                          )
                        : const Icon(Icons.send_rounded, size: 18),
                    label: Text(_isBusy ? 'Sending...' : 'Send Enquiry'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
