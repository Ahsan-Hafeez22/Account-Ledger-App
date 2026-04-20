import 'package:account_ledger/core/extensions/sizedbox_extentions.dart';
import 'package:account_ledger/features/authentication/presentation/bloc/auth_bloc.dart';
import 'package:account_ledger/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _phoneCtrl;
  late final String? _photoUrl;
  DateTime? _dob;
  String? _selectedAvatarAsset;
  Uint8List? _selectedAvatarBytes;

  // These should exist in `assets/images/` and already be included in pubspec.
  // Example: assets/images/avatar_1.png ... avatar_9.png
  final List<String> _avatars = List.generate(
    9,
    (i) => 'assets/images/avatar_${i + 1}.png',
  );

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthBloc>().state is AuthAuthenticated
        ? (context.read<AuthBloc>().state as AuthAuthenticated).user
        : null;
    _nameCtrl = TextEditingController(text: user?.name ?? '');
    _phoneCtrl = TextEditingController(text: user?.phone ?? '');
    _photoUrl = user?.avatarUrl;
    _dob = user?.dateOfBirth;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDob() async {
    final initial = _dob ?? DateTime(2000, 1, 1);
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: initial.isAfter(now) ? now : initial,
      firstDate: DateTime(1900, 1, 1),
      lastDate: now,
    );
    if (picked == null) return;
    setState(() => _dob = picked);
  }

  Future<void> _pickAvatar() async {
    final picked = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Choose an avatar',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                ),
                12.0.height,
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _avatars.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                  ),
                  itemBuilder: (_, index) {
                    final asset = _avatars[index];
                    final isSelected = asset == _selectedAvatarAsset;
                    return InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () => Navigator.of(context).pop(asset),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected
                                ? Theme.of(context).colorScheme.primary
                                : Theme.of(context).colorScheme.outlineVariant,
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        padding: const EdgeInsets.all(10),
                        child: Image.asset(asset, fit: BoxFit.contain),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );

    if (picked == null) return;
    try {
      final bytes = (await rootBundle.load(picked)).buffer.asUint8List();
      setState(() {
        _selectedAvatarAsset = picked;
        _selectedAvatarBytes = bytes;
      });
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Avatar assets not found. Please add avatar_1..avatar_9 to assets/images.',
          ),
        ),
      );
    }
  }

  String _dobLabel(DateTime? d) {
    if (d == null) return 'Select date of birth';
    return '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated) return;
    context.read<ProfileBloc>().add(
      ProfileUpdateRequested(
        currentUser: authState.user,
        name: _nameCtrl.text,
        phone: _phoneCtrl.text,
        dateOfBirth: _dob,
        avatarBytes: _selectedAvatarBytes,
        avatarFilename: _selectedAvatarAsset?.split('/').last,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return BlocConsumer<ProfileBloc, ProfileState>(
      listenWhen: (p, c) =>
          p.updatedUser != c.updatedUser || p.errorMessage != c.errorMessage,
      listener: (context, state) {
        final user = state.updatedUser;
        if (user != null) {
          context.read<AuthBloc>().add(AuthUserLoaded(user));
          Navigator.of(context).pop();
          return;
        }
        final err = state.errorMessage;
        if (err != null) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(err)));
        }
      },
      builder: (context, state) {
        final submitting = state.submitting;
        return Scaffold(
          appBar: AppBar(title: const Text('Edit profile')),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: InkWell(
                        onTap: submitting ? null : _pickAvatar,
                        borderRadius: BorderRadius.circular(60),
                        child: CircleAvatar(
                          radius: 54.r,
                          backgroundColor: scheme.surfaceContainerHighest,
                          backgroundImage: _selectedAvatarAsset != null
                              ? AssetImage(_selectedAvatarAsset!)
                              : (_photoUrl != null && _photoUrl.isNotEmpty)
                              ? NetworkImage(_photoUrl)
                              : null,
                          child:
                              (_selectedAvatarAsset == null &&
                                  (_photoUrl == null || _photoUrl.isEmpty))
                              ? Icon(
                                  Icons.camera_alt_rounded,
                                  color: scheme.onSurfaceVariant,
                                )
                              : null,
                        ),
                      ),
                    ),
                    8.0.height,
                    Center(
                      child: TextButton(
                        onPressed: submitting ? null : _pickAvatar,
                        child: const Text('Change avatar'),
                      ),
                    ),
                    16.0.height,
                    TextFormField(
                      controller: _nameCtrl,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        labelText: 'Name',
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty)
                          return 'Name is required';
                        return null;
                      },
                    ),
                    12.0.height,
                    TextFormField(
                      controller: _phoneCtrl,
                      keyboardType: TextInputType.phone,
                      textInputAction: TextInputAction.done,
                      decoration: const InputDecoration(
                        labelText: 'Phone',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    12.0.height,
                    InkWell(
                      onTap: submitting ? null : _pickDob,
                      borderRadius: BorderRadius.circular(12),
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Date of birth',
                          border: OutlineInputBorder(),
                        ),
                        child: Row(
                          children: [
                            Expanded(child: Text(_dobLabel(_dob))),
                            Icon(
                              Icons.calendar_month_rounded,
                              color: scheme.onSurfaceVariant,
                            ),
                          ],
                        ),
                      ),
                    ),
                    20.0.height,
                    FilledButton(
                      onPressed: submitting ? null : _submit,
                      child: submitting
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Save changes'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
