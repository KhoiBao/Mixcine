import 'dart:typed_data'; // Cần thiết để xài Uint8List hiển thị ảnh từ bytes
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

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

  // Biến phục vụ tính năng chọn và lưu ảnh cục bộ trước khi push
  XFile? _pickedFile;
  List<int>? _imageBytes;

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

  // Hàm kích hoạt bộ chọn ảnh hệ thống công khai
  Future<void> _pickImage() async {
    try {
      final picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality:
            70, // Nén nhẹ ảnh giúp upload lên Supabase Storage nhanh hơn
      );

      if (image != null) {
        final bytes = await image.readAsBytes();
        setState(() {
          _pickedFile = image;
          _imageBytes = bytes;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Không thể chọn ảnh: $e')));
      }
    }
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      // Gọi notifier cập nhật profile với đầy đủ các tham số text và bytes ảnh mới
      await ref
          .read(authStateProvider.notifier)
          .updateProfile(
            newFullName: _fullNameController.text.trim(),
            newPhoneNumber: _phoneController.text.trim(), // ĐẢM BẢO CÓ DÒNG NÀY
            imageBytes: _imageBytes,
            fileName: _pickedFile?.name,
          );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cập nhật hồ sơ thành công')),
      );

      context.pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Cập nhật thất bại: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);
    final user = authState.user;

    return Scaffold(
      appBar: AppBar(title: const Text('Chỉnh sửa hồ sơ')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // =======================================================================
                    // KHU VỰC CHỌN ẢNH ĐẠI DIỆN (AVATAR) MỚI
                    // =======================================================================
                    GestureDetector(
                      onTap: authState.isLoading ? null : _pickImage,
                      child: Stack(
                        children: [
                          CircleAvatar(
                            radius: 55,
                            backgroundColor: Colors.grey[800],
                            backgroundImage: _imageBytes != null
                                ? MemoryImage(Uint8List.fromList(_imageBytes!))
                                : (user?.avatar != null &&
                                      user!.avatar!.isNotEmpty)
                                ? NetworkImage(user.avatar!)
                                : null,
                            child:
                                (_imageBytes == null &&
                                    (user?.avatar == null ||
                                        user!.avatar!.isEmpty))
                                ? const Icon(
                                    Icons.person,
                                    size: 55,
                                    color: Colors.grey,
                                  )
                                : null,
                          ),
                          if (!authState.isLoading)
                            Positioned(
                              bottom: 0,
                              right: 2,
                              child: CircleAvatar(
                                radius: 16,
                                backgroundColor: Theme.of(context).primaryColor,
                                child: const Icon(
                                  Icons.camera_alt,
                                  size: 16,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        border: OutlineInputBorder(),
                      ),
                      enabled: false,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _fullNameController,
                      decoration: const InputDecoration(
                        labelText: 'Họ và tên',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Họ và tên không được để trống';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        labelText: 'Số điện thoại',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Số điện thoại không được để trống';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 28),
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
      ),
    );
  }
}
