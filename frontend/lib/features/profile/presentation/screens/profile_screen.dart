import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../core/widgets/loading_overlay.dart';
import '../../../auth/presentation/auth_provider.dart';
import '../../data/profile_repository.dart';
import '../../../verification/presentation/verification_screen.dart';
import '../../../notifications/presentation/notifications_screen.dart';
import '../../../reminders/presentation/reminders_screen.dart';
import '../../../movers/presentation/movers_screen.dart';
import '../../../admin/presentation/admin_dashboard_screen.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  
  bool _isEditing = false;
  bool _isLoading = false;
  Map<String, dynamic>? _userData;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final repository = ProfileRepository();
      final user = await repository.getProfile();
      
      setState(() {
        _userData = user;
        _nameController.text = user['name'] ?? '';
        _emailController.text = user['email'] ?? '';
        _phoneController.text = user['phone'] ?? '';
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading profile: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final repository = ProfileRepository();
      await repository.updateProfile({
        'name': _nameController.text,
        'phone': _phoneController.text,
      });

      setState(() {
        _isEditing = false;
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully'),
            backgroundColor: AppColors.success,
          ),
        );
      }

      // Reload profile to get updated data
      _loadProfile();
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
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
            'Profile',
            style: AppTypography.h3.copyWith(color: AppColors.textPrimary),
          ),
          backgroundColor: Colors.white,
          elevation: 0,
          surfaceTintColor: Colors.transparent,
          iconTheme: const IconThemeData(color: AppColors.textPrimary),
          actions: [
            if (!_isEditing)
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () {
                  setState(() {
                    _isEditing = true;
                  });
                },
              ),
          ],
        ),
        body: _userData == null
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      // Profile Avatar
                      Center(
                        child: Stack(
                          children: [
                            CircleAvatar(
                              radius: 60,
                              backgroundColor: AppColors.accent.withOpacity(0.1),
                              child: Text(
                                _nameController.text.isNotEmpty
                                    ? _nameController.text[0].toUpperCase()
                                    : 'U',
                                style: AppTypography.h1.copyWith(
                                  color: AppColors.accent,
                                  fontSize: 48,
                                ),
                              ),
                            ),
                            if (_isEditing)
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: CircleAvatar(
                                  radius: 18,
                                  backgroundColor: AppColors.accent,
                                  child: const Icon(
                                    Icons.camera_alt,
                                    size: 18,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),

                      // Profile Information
                      Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(AppSpacing.md),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Personal Information',
                                style: AppTypography.h4,
                              ),
                              const SizedBox(height: AppSpacing.md),
                              CustomTextField(
                                controller: _nameController,
                                label: 'Full Name',
                                enabled: _isEditing,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your name';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: AppSpacing.md),
                              CustomTextField(
                                controller: _emailController,
                                label: 'Email',
                                enabled: false, // Email cannot be changed
                                suffixIcon: const Icon(Icons.lock_outline, size: 18),
                              ),
                              const SizedBox(height: AppSpacing.md),
                              CustomTextField(
                                controller: _phoneController,
                                label: 'Phone Number',
                                enabled: _isEditing,
                                keyboardType: TextInputType.phone,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),

                      // Account Type
                      Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(AppSpacing.md),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Account Type',
                                style: AppTypography.h4,
                              ),
                              const SizedBox(height: AppSpacing.sm),
                              _buildAccountTypeBadge(_userData!['accountIntent']),
                              const SizedBox(height: AppSpacing.sm),
                              Text(
                                'Member since ${_formatDate(DateTime.parse(_userData!['createdAt']))}',
                                style: AppTypography.caption.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),

                      // Features Menu
                      Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(AppSpacing.md),
                              child: Text(
                                'Features',
                                style: AppTypography.h4,
                              ),
                            ),
                            _buildMenuTile(
                              icon: Icons.verified_user,
                              title: 'Get Verified',
                              subtitle: 'Verify your identity as an owner',
                              color: Colors.teal,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const VerificationScreen(),
                                  ),
                                );
                              },
                            ),
                            const Divider(height: 1),
                            _buildMenuTile(
                              icon: Icons.notifications,
                              title: 'Notifications',
                              subtitle: 'View your notifications',
                              color: Colors.blue,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const NotificationsScreen(),
                                  ),
                                );
                              },
                            ),
                            const Divider(height: 1),
                            _buildMenuTile(
                              icon: Icons.event,
                              title: 'Reminders',
                              subtitle: 'Rent and notice period reminders',
                              color: Colors.orange,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const RemindersScreen(),
                                  ),
                                );
                              },
                            ),
                            const Divider(height: 1),
                            _buildMenuTile(
                              icon: Icons.local_shipping,
                              title: 'Packers & Movers',
                              subtitle: 'Request moving services',
                              color: Colors.green,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const MoversScreen(),
                                  ),
                                );
                              },
                            ),
                            if (_userData!['role'] == 'ADMIN') ...[
                              const Divider(height: 1),
                              _buildMenuTile(
                                icon: Icons.admin_panel_settings,
                                title: 'Admin Dashboard',
                                subtitle: 'Manage users and properties',
                                color: Colors.red,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const AdminDashboardScreen(),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),

                      // Action Buttons
                      if (_isEditing) ...[
                        Row(
                          children: [
                            Expanded(
                              child: CustomButton(
                                text: 'Cancel',
                                variant: ButtonVariant.outlined,
                                onPressed: () {
                                  setState(() {
                                    _isEditing = false;
                                    // Reset to original values
                                    _nameController.text = _userData!['name'] ?? '';
                                    _phoneController.text = _userData!['phone'] ?? '';
                                  });
                                },
                              ),
                            ),
                            const SizedBox(width: AppSpacing.md),
                            Expanded(
                              child: CustomButton(
                                text: 'Save',
                                onPressed: _saveProfile,
                              ),
                            ),
                          ],
                        ),
                      ] else ...[
                        CustomButton(
                          text: 'Change Password',
                          variant: ButtonVariant.outlined,
                          fullWidth: true,
                          icon: const Icon(Icons.lock_outline),
                          onPressed: () {
                            // Navigate to change password screen
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Change password feature coming soon'),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: AppSpacing.md),
                        CustomButton(
                          text: 'Logout',
                          variant: ButtonVariant.outlined,
                          fullWidth: true,
                          icon: const Icon(Icons.logout),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Logout'),
                                content: const Text('Are you sure you want to logout?'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                      ref.read(authStateProvider.notifier).logout();
                                    },
                                    child: const Text(
                                      'Logout',
                                      style: TextStyle(color: AppColors.error),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ],
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildAccountTypeBadge(String accountIntent) {
    Color badgeColor;
    IconData badgeIcon;
    String badgeText;

    switch (accountIntent) {
      case 'SEEKER':
        badgeColor = Colors.blue;
        badgeIcon = Icons.search;
        badgeText = 'Property Seeker';
        break;
      case 'OWNER':
        badgeColor = AppColors.accent;
        badgeIcon = Icons.home_work;
        badgeText = 'Property Owner';
        break;
      case 'BOTH':
        badgeColor = AppColors.premium;
        badgeIcon = Icons.verified;
        badgeText = 'Owner & Seeker';
        break;
      default:
        badgeColor = AppColors.textSecondary;
        badgeIcon = Icons.person;
        badgeText = accountIntent;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: badgeColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        border: Border.all(color: badgeColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(badgeIcon, size: 18, color: badgeColor),
          const SizedBox(width: AppSpacing.xs),
          Text(
            badgeText,
            style: AppTypography.body.copyWith(
              color: badgeColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return DateFormat('MMMM yyyy').format(date);
  }

  Widget _buildMenuTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: color, size: 24),
      ),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(color: Colors.grey[600], fontSize: 13),
      ),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }
}