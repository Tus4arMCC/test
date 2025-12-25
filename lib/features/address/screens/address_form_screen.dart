import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class AddressFormScreen extends StatefulWidget {
  const AddressFormScreen({super.key});

  @override
  State<AddressFormScreen> createState() => _AddressFormScreenState();
}

class _AddressFormScreenState extends State<AddressFormScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isDefault = true;
  String? _selectedState;
  final List<String> _states = ['NY', 'CA', 'TX', 'FL'];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back),
        ),
        title: Text(
          "Add New Address",
          style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 120),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Progress Indicator
                  Row(
                    children: [
                      Expanded(child: Container(height: 4, decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(2)))),
                      const SizedBox(width: 8),
                      Expanded(child: Container(height: 4, decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(2)))),
                      const SizedBox(width: 8),
                      Expanded(child: Container(height: 4, decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(2)))),
                    ],
                  ),
                  const SizedBox(height: 32),
                  
                  _buildLabel("Full Name"),
                  _buildTextField(
                    hint: "Jane Doe",
                    icon: Icons.person_outline,
                  ),
                  const SizedBox(height: 24),
                  
                  _buildLabel("Street Address"),
                  _buildTextField(
                    hint: "123 Fashion Ave",
                    icon: Icons.location_on_outlined,
                  ),
                  const SizedBox(height: 24),
                  
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel("City"),
                            _buildTextField(hint: "New York"),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel("State"),
                            _buildDropdownField(),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel("Zip Code"),
                            _buildTextField(hint: "10001", keyboardType: TextInputType.number),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel("Phone"),
                            _buildTextField(hint: "(555) 000-0000", keyboardType: TextInputType.phone),
                          ],
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 32),
                  const Divider(),
                  const SizedBox(height: 16),
                  
                  // Default Toggle
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Set as default address", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          Text("Use this address for checkout", style: TextStyle(color: Colors.grey, fontSize: 12)),
                        ],
                      ),
                      Switch(
                        value: _isDefault,
                        onChanged: (val) => setState(() => _isDefault = val),
                        activeColor: AppColors.primary,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          // Save Button
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
              decoration: BoxDecoration(
                color: colorScheme.background.withOpacity(0.9),
                border: Border(top: BorderSide(color: colorScheme.outline.withOpacity(0.05))),
              ),
              child: ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    Navigator.pop(context);
                  }
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Save Address", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    SizedBox(width: 8),
                    Icon(Icons.check, size: 20),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        text,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.grey),
      ),
    );
  }

  Widget _buildTextField({required String hint, IconData? icon, TextInputType? keyboardType}) {
    final colorScheme = Theme.of(context).colorScheme;
    return TextFormField(
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey[400], fontSize: 15),
        suffixIcon: icon != null ? Icon(icon, color: Colors.grey[300], size: 20) : null,
        filled: true,
        fillColor: colorScheme.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }

  Widget _buildDropdownField() {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          hint: Text("Select", style: TextStyle(color: Colors.grey[400], fontSize: 15)),
          value: _selectedState,
          icon: const Icon(Icons.expand_more, color: Colors.grey),
          items: _states.map((state) {
            return DropdownMenuItem(
              value: state,
              child: Text(state),
            );
          }).toList(),
          onChanged: (val) => setState(() => _selectedState = val),
        ),
      ),
    );
  }
}
