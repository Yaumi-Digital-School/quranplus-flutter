import 'package:flutter/material.dart';
import 'package:qurantafsir_flutter/shared/constants/qp_colors.dart';
import 'package:qurantafsir_flutter/shared/constants/qp_text_style.dart';

class AccountDeletionInformationView extends StatelessWidget {
  const AccountDeletionInformationView({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(54.0),
        child: AppBar(
          elevation: 0.7,
          foregroundColor: Colors.black,
          centerTitle: true,
          title: Text(
            'Delete Account',
            style: QPTextStyle.subHeading2SemiBold,
          ),
          backgroundColor: QPColors.whiteFair,
          leading: IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(
              Icons.arrow_back_ios,
              size: 16,
              color: Colors.black,
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: <Widget>[
            _buildAccountDeletionInfo(
              title: 'How to delete my account?',
              detail:
                  'Please send us an email to yaumi.indonesia@gmail.com and rizaherzego@gmail.com to request your account deletion. We will send you a reply as a confirmation before permanently deleting your account.',
            ),
            const SizedBox(
              height: 24,
            ),
            _buildAccountDeletionInfo(
              title: 'What happens after I delete my account?',
              detail:
                  'After you delete your account, all data associated with this account (saved bookmarks, favorites, reading progress and target) will be permanently deleted and irrecoverable.',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountDeletionInfo({
    required String title,
    required String detail,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          title,
          style: QPTextStyle.subHeading2SemiBold,
        ),
        const SizedBox(
          height: 8,
        ),
        Text(
          detail,
          textAlign: TextAlign.justify,
          style: QPTextStyle.body3Regular.copyWith(
            color: QPColors.blackFair,
          ),
        ),
      ],
    );
  }
}
