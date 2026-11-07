import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:social_hub/core/constants/app_colors.dart';
import 'package:social_hub/core/constants/app_assets.dart';
import 'package:social_hub/presentation/providers/auth_provider.dart';
import 'package:social_hub/presentation/providers/feed_provider.dart';
import 'package:social_hub/presentation/providers/profile_provider.dart';
import 'package:social_hub/presentation/widgets/custom_button.dart';
import 'package:social_hub/presentation/widgets/custom_text_field.dart';
import 'package:social_hub/presentation/widgets/app_avatar.dart';
import 'package:social_hub/presentation/screens/camera/web_file_picker.dart';

class EditProfileSheet extends StatefulWidget {
  const EditProfileSheet({super.key});

  @override
  State<EditProfileSheet> createState() => _EditProfileSheetState();
}

class _EditProfileSheetState extends State<EditProfileSheet> {
  late TextEditingController _nameController;
  late TextEditingController _bioController;
  late String _selectedAvatar;
  String? _customUploadedName;

  final List<Map<String, String>> _avatarOptions = const [
    {
      'label': 'Wisuda S1',
      'path': AppAssets.imgAndrianPoster,
    },
    {
      'label': 'Studio Kreator',
      'path': AppAssets.imgProfile,
    },
    {
      'label': 'Aesthetic',
      'path': AppAssets.imgFeed,
    },
    {
      'label': 'Bestie Anime',
      'path': AppAssets.imgFriends,
    },
    {
      'label': 'Inisial Ungu',
      'path': 'purple_a',
    },
  ];

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().currentUser;
    _nameController = TextEditingController(text: user?.name ?? 'Andrian Pei');
    _bioController = TextEditingController(text: user?.bio ?? 'Taken 🤍');
    _selectedAvatar = user?.avatarUrl.isNotEmpty == true
        ? user!.avatarUrl
        : AppAssets.imgAndrianPoster;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  void _triggerNativeImagePicker() {
    pickImageFileNative(
      onSelected: (fileName, pathOrUrl) {
        if (pathOrUrl != null && pathOrUrl.isNotEmpty) {
          setState(() {
            _selectedAvatar = pathOrUrl;
            _customUploadedName = fileName;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('✨ Foto "$fileName" berhasil dipilih! Tekan "Simpan Perubahan" untuk menerapkan.'),
              backgroundColor: const Color(0xFF10B981),
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      },
    );
  }

  Future<void> _save() async {
    final auth = context.read<AuthProvider>();
    final user = auth.currentUser;
    final userId = user?.id ?? 1;

    final name = _nameController.text.trim();
    final bio = _bioController.text.trim();

    await auth.updateProfile(
      name: name.isNotEmpty ? name : 'Andrian Pei',
      bio: bio.isNotEmpty ? bio : 'Taken 🤍',
      avatarUrl: _selectedAvatar,
    );

    if (mounted) {
      // Synchronize across all active providers so Beranda, Rotating Disk, & Profile update immediately
      context.read<FeedProvider>().updateAuthorAvatar(userId, _selectedAvatar);
      context.read<ProfileProvider>().updateAuthorAvatar(userId, _selectedAvatar);

      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('🎉 Foto Profil berhasil disimpan dan sinkron ke Beranda & Profil!'),
          backgroundColor: Color(0xFF10B981),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: 16,
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      decoration: const BoxDecoration(
        color: Color(0xFF1E1E24),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Handle & Close
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Edit Profil',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: AppColors.textSecondary, size: 22),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Main Avatar Preview with Camera badge (Tap to open native picker)
            Center(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: _triggerNativeImagePicker,
                child: Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    AppAvatar(
                      avatarUrl: _selectedAvatar,
                      size: 92,
                      borderWidth: 3,
                      borderColor: const Color(0xFF20D5EC),
                    ),
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(color: Colors.black45, blurRadius: 4),
                        ],
                      ),
                      child: const Icon(Icons.camera_alt, color: Colors.white, size: 16),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),

            Center(
              child: Text(
                _customUploadedName != null
                    ? 'Foto Kustom: $_customUploadedName'
                    : 'Ketuk foto untuk ganti foto',
                style: TextStyle(
                  color: _customUploadedName != null ? const Color(0xFF20D5EC) : Colors.white70,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 14),

            // Prominent "Unggah Foto dari Galeri / Laptop" Button
            SizedBox(
              width: double.infinity,
              height: 44,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF20D5EC),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 2,
                ),
                icon: const Icon(Icons.photo_library_rounded, color: Colors.black, size: 20),
                label: const Text(
                  'Unggah Foto dari Galeri / Laptop',
                  style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 13.5),
                ),
                onPressed: _triggerNativeImagePicker,
              ),
            ),
            const SizedBox(height: 16),

            const Text(
              'Atau Pilih Foto Preset:',
              style: TextStyle(color: Colors.white60, fontSize: 12, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),

            // Horizontal Avatar Option Picker
            SizedBox(
              height: 86,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _avatarOptions.length,
                separatorBuilder: (_, __) => const SizedBox(width: 14),
                itemBuilder: (context, index) {
                  final opt = _avatarOptions[index];
                  final isSelected = _selectedAvatar == opt['path'];
                  return GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      setState(() {
                        _selectedAvatar = opt['path']!;
                        _customUploadedName = null;
                      });
                    },
                    child: Column(
                      children: [
                        Container(
                          width: 54,
                          height: 54,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isSelected ? const Color(0xFF20D5EC) : Colors.transparent,
                              width: 2.5,
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(2),
                            child: AppAvatar(
                              avatarUrl: opt['path']!,
                              size: 48,
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          opt['label']!,
                          style: TextStyle(
                            color: isSelected ? const Color(0xFF20D5EC) : Colors.white60,
                            fontSize: 11,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),

            // Form Inputs
            CustomTextField(
              controller: _nameController,
              labelText: 'Nama Lengkap',
              hintText: 'Andrian Pei',
            ),
            const SizedBox(height: 16),

            CustomTextField(
              controller: _bioController,
              labelText: 'Biodata',
              hintText: 'Taken 🤍',
            ),
            const SizedBox(height: 24),

            CustomButton(
              text: 'Simpan Perubahan',
              backgroundColor: AppColors.primary,
              onPressed: _save,
            ),
          ],
        ),
      ),
    );
  }
}
