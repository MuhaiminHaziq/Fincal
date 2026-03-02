import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/header.dart';
import '../providers/auth_provider.dart';
import '../models/user.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _companyNameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLoading = false;
  String? _errorMessage;
  bool _showPasswordFields = false;

  @override
  void initState() {
    super.initState();
    _loadCurrentUserData();
  }

  void _loadCurrentUserData() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.user != null) {
      _firstNameController.text = authProvider.user!.firstName;
      _lastNameController.text = authProvider.user!.lastName;
      _companyNameController.text = authProvider.user!.companyName;
      _usernameController.text = authProvider.user!.username;
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _companyNameController.dispose();
    _usernameController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final prefs = await SharedPreferences.getInstance();
      final usersJson = prefs.getString('accounting_users') ?? '[]';
      final List<dynamic> users = jsonDecode(usersJson);

      // Find current user in the users list
      final currentUsername = authProvider.user!.username;
      final userIndex = users.indexWhere(
        (user) => user['username'] == currentUsername,
      );

      if (userIndex == -1) {
        setState(() {
          _errorMessage = 'User not found';
          _isLoading = false;
        });
        return;
      }

      // Check if new username already exists (if username is being changed)
      if (_usernameController.text != currentUsername) {
        final existingUser = users.firstWhere(
          (user) => user['username'] == _usernameController.text,
          orElse: () => null,
        );
        if (existingUser != null) {
          setState(() {
            _errorMessage = 'Username already exists';
            _isLoading = false;
          });
          return;
        }
      }

      // Verify current password if password is being changed
      if (_showPasswordFields && _newPasswordController.text.isNotEmpty) {
        if (users[userIndex]['password'] != _currentPasswordController.text) {
          setState(() {
            _errorMessage = 'Current password is incorrect';
            _isLoading = false;
          });
          return;
        }
      }

      // Update user data
      users[userIndex] = {
        'firstName': _firstNameController.text.trim(),
        'lastName': _lastNameController.text.trim(),
        'companyName': _companyNameController.text.trim(),
        'username': _usernameController.text.trim(),
        'password':
            _showPasswordFields && _newPasswordController.text.isNotEmpty
            ? _newPasswordController.text
            : users[userIndex]['password'],
      };

      // Save updated users list
      await prefs.setString('accounting_users', jsonEncode(users));

      // Update current user in auth provider
      final updatedUser = User(
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        companyName: _companyNameController.text.trim(),
        username: _usernameController.text.trim(),
      );

      await prefs.setString(
        'accounting_user',
        jsonEncode(updatedUser.toJson()),
      );

      // Update auth provider
      authProvider.updateUser(updatedUser);

      setState(() {
        _isLoading = false;
        _showPasswordFields = false;
        _currentPasswordController.clear();
        _newPasswordController.clear();
        _confirmPasswordController.clear();
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to update profile. Please try again.';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const Header(),
      backgroundColor: Colors.grey[50],
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 500),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 3,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Center(
                    child: Text(
                      'Edit Profile',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const Divider(height: 32),

                  // Basic Information
                  const Text(
                    'Basic Information',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 16),

                  _buildTextField('First Name', _firstNameController),
                  const SizedBox(height: 16),
                  _buildTextField('Last Name', _lastNameController),
                  const SizedBox(height: 16),
                  _buildTextField('Company Name', _companyNameController),
                  const SizedBox(height: 16),
                  _buildTextField('Username', _usernameController),
                  const SizedBox(height: 24),

                  // Password Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Change Password',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Switch(
                        value: _showPasswordFields,
                        onChanged: (value) {
                          setState(() {
                            _showPasswordFields = value;
                            if (!value) {
                              _currentPasswordController.clear();
                              _newPasswordController.clear();
                              _confirmPasswordController.clear();
                            }
                          });
                        },
                        activeColor: const Color(0xFF8B5A84),
                      ),
                    ],
                  ),

                  if (_showPasswordFields) ...[
                    const SizedBox(height: 16),
                    _buildTextField(
                      'Current Password',
                      _currentPasswordController,
                      isPassword: true,
                      isRequired: true,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      'New Password',
                      _newPasswordController,
                      isPassword: true,
                      isRequired: true,
                      validator: (value) {
                        if (_showPasswordFields &&
                            (value == null || value.isEmpty)) {
                          return 'Please enter new password';
                        }
                        if (value != null &&
                            value.isNotEmpty &&
                            value.length < 6) {
                          return 'Password must be at least 6 characters';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      'Confirm New Password',
                      _confirmPasswordController,
                      isPassword: true,
                      isRequired: true,
                      validator: (value) {
                        if (_showPasswordFields &&
                            (value == null || value.isEmpty)) {
                          return 'Please confirm new password';
                        }
                        if (value != _newPasswordController.text) {
                          return 'Passwords do not match';
                        }
                        return null;
                      },
                    ),
                  ],

                  if (_errorMessage != null) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red[200]!),
                      ),
                      child: Text(
                        _errorMessage!,
                        style: TextStyle(color: Colors.red[700], fontSize: 14),
                      ),
                    ),
                  ],

                  const SizedBox(height: 32),

                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cancel'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _updateProfile,
                          child: _isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                )
                              : const Text('Update Profile'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    bool isPassword = false,
    bool isRequired = true,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 4),
        TextFormField(
          controller: controller,
          obscureText: isPassword,
          decoration: InputDecoration(
            border: const OutlineInputBorder(),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            filled: true,
            fillColor: Colors.white,
          ),
          validator:
              validator ??
              (value) {
                if (isRequired && (value == null || value.isEmpty)) {
                  return 'Please enter $label';
                }
                return null;
              },
        ),
      ],
    );
  }
}
