import 'package:d_info/d_info.dart';
import 'package:d_view/d_view.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../config/app_assets.dart';
import '../../config/app_colors.dart';
import '../../config/app_session.dart';
import '../../config/nav.dart';
import '../../models/user_model.dart';
import '../auth/login_page.dart';

class AccountView extends StatelessWidget {
  const AccountView({super.key});

  logout(BuildContext context) {
    DInfo.dialogConfirmation(
      context,
      'Logout',
      'You sure want to logout?',
      textNo: 'Cancel',
    ).then((yes) {
      if (yes ?? false) {
        AppSession.removeUser();
        AppSession.removeBearerToken();
        Nav.replace(context, const LoginPage());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: AppSession.getUser(),
      builder: (context, snapshot) {
        if (snapshot.data == null) return DView.loadingCircle();
        UserModel user = snapshot.data!;
        return ListView(
          padding: const EdgeInsets.all(0),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 48, 24, 16),
              child: Text(
                'My Account',
                style: GoogleFonts.poppins(
                  fontSize: 28,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ),

            Container(
              margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 2,
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      image: const DecorationImage(
                        image: AssetImage(AppAssets.profile),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user.username,
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          user.email,
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            _buildSectionTitle('Account Settings'),
            _buildListTile(
              icon: Icons.person_outline,
              title: 'Edit Profile',
              onTap: () {},
            ),
            _buildListTile(
              icon: Icons.image_outlined,
              title: 'Change Profile Picture',
              onTap: () {},
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: const BorderSide(color: Colors.red),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: () => logout(context),
                child: Text(
                  'Logout',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),

            _buildSectionTitle('App Settings'),
            _buildSwitchTile(
              icon: Icons.dark_mode_outlined,
              title: 'Dark Mode',
              value: false,
              onChanged: (value) {},
            ),
            _buildListTile(
              icon: Icons.language_outlined,
              title: 'Language',
              onTap: () {},
            ),
            _buildListTile(
              icon: Icons.notifications_outlined,
              title: 'Notifications',
              onTap: () {},
            ),

            _buildSectionTitle('Support'),
            _buildListTile(
              icon: Icons.feedback_outlined,
              title: 'Send Feedback',
              onTap: () {},
            ),
            _buildListTile(
              icon: Icons.support_agent_outlined,
              title: 'Contact Support',
              onTap: () {},
            ),
            _buildListTile(
              icon: Icons.info_outline,
              title: 'About App',
              onTap: () {
                showAboutDialog(
                  context: context,
                  applicationIcon: const Icon(
                    Icons.local_laundry_service,
                    size: 50,
                    color: AppColors.primary,
                  ),
                  applicationName: 'Di Laundry',
                  applicationVersion: 'v1.0.0',
                  children: [
                    Text(
                      'Laundry Market App to monitor your laundry status',
                      style: GoogleFonts.poppins(),
                    ),
                  ],
                );
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
      child: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.grey[600],
        ),
      ),
    );
  }

  Widget _buildListTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        onTap: onTap,
        leading: Icon(icon, color: AppColors.primary),
        title: Text(
          title,
          style: GoogleFonts.poppins(),
        ),
        trailing: const Icon(Icons.chevron_right, color: Colors.grey),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      ),
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        leading: Icon(icon, color: AppColors.primary),
        title: Text(
          title,
          style: GoogleFonts.poppins(),
        ),
        trailing: Switch(
          value: value,
          onChanged: onChanged,
          activeColor: AppColors.primary,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      ),
    );
  }
}
