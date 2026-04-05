import 'package:account_ledger/core/constants/app_colors.dart';
import 'package:account_ledger/core/extensions/sizedbox_extentions.dart';
import 'package:account_ledger/core/utils/date_utils.dart';
import 'package:account_ledger/features/authentication/presentation/bloc/auth_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        // Logic to extract user data safely
        final user = state is AuthAuthenticated ? state.user : null;
        final name = user?.name ?? "Guest User";
        final email = user?.email ?? "No Email!";
        final dob = user?.dateOfBirth ?? DateTime.now();
        final photoUrl = user?.avatarUrl;

        return Column(
          children: [
            CircleAvatar(
              radius: 50,
              backgroundColor: AppColors.divider, // Fallback background color
              backgroundImage: photoUrl != null && photoUrl.isNotEmpty
                  ? NetworkImage(photoUrl)
                  : null, // Set to null so child widget shows up
              child: photoUrl == null || photoUrl.isEmpty
                  ? const Icon(
                      Icons.person,
                      size: 50,
                      color: AppColors.textSecondary,
                    )
                  : null,
            ),
            const SizedBox(height: 12),
            Text(name, style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.mail,
                  size: 14,
                  color: AppColors.textSecondary,
                ),
                4.0.width,
                Text(
                  email, // You can also get this from user?.location
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,

              children: [
                const Icon(
                  Icons.cake,
                  size: 14,
                  color: AppColors.textSecondary,
                ),
                4.0.width,

                Text(
                  formatDate(
                    dob,
                  ), // You can also get this from user?.occupation
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
