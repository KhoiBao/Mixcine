import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mixcine_movie_app/data/models/user_model.dart';

import '../../providers/auth_provider.dart';
import '../../widgets/primary_button.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _fullNameController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;

  @override
  void initState() {
    super.initState();
    final authState = ref.read(authStateProvider);
    _emailController = TextEditingController(text: authState.user?.email ?? '');
    _fullNameController = TextEditingController(
      text: authState.user?.fullName ?? '',
    );
    _phoneController = TextEditingController(
      text: authState.user?.phoneNumber ?? '',
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _fullNameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final updatedUser = UserModel(
      email: _emailController.text.trim(),
      fullName: _fullNameController.text.trim(),
      phoneNumber: _phoneController.text.trim(),
    );

    await ref.read(authStateProvider.notifier).updateProfile(updatedUser);

    if (!mounted) return;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Cập nhật hồ sơ thành công')));

    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Chỉnh sửa hồ sơ')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(labelText: 'Email'),
                    enabled: false,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Email không được để trống';
                      }
                      if (!value.contains('@')) {
                        return 'Email không hợp lệ';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _fullNameController,
                    decoration: const InputDecoration(labelText: 'Họ và tên'),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Họ và tên không được để trống';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      labelText: 'Số điện thoại',
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Số điện thoại không được để trống';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  PrimaryButton(
                    label: authState.isLoading
                        ? 'Đang cập nhật...'
                        : 'Lưu thay đổi',
                    onPressed: authState.isLoading ? null : _submit,
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
