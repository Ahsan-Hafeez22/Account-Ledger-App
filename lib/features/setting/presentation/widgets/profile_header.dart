import 'package:account_ledger/core/constants/app_colors.dart';
import 'package:account_ledger/core/extensions/sizedbox_extentions.dart';
import 'package:account_ledger/core/routes/route_names.dart';
import 'package:account_ledger/core/utils/date_utils.dart';
import 'package:account_ledger/features/authentication/presentation/bloc/auth_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

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
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                CircleAvatar(
                  radius: 54.r,
                  backgroundColor: Theme.of(
                    context,
                  ).colorScheme.surfaceContainerHighest,
                  backgroundImage: photoUrl != null && photoUrl.isNotEmpty
                      ? NetworkImage(photoUrl)
                      : null,
                  child: photoUrl == null || photoUrl.isEmpty
                      ? const Icon(
                          Icons.person,
                          size: 50,
                          color: AppColors.textSecondary,
                        )
                      : null,
                ),
                Positioned(
                  right: 2,
                  bottom: 2,
                  child: InkWell(
                    onTap: user == null
                        ? null
                        : () => context.push(RouteEndpoints.editProfile),
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.edit_rounded,
                        size: 16,
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                    ),
                  ),
                ),
              ],
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
