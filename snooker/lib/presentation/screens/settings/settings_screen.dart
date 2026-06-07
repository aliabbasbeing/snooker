import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_constants.dart';
import '../../providers/settings_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);

    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Settings'),
      ),
      child: SafeArea(
        child: ListView(
          children: [
            const SizedBox(height: 20),
            
            // Appearance Section
            _buildSectionHeader('Appearance'),
            _buildSettingsList([
              _buildSettingItem(
                icon: CupertinoIcons.moon_fill,
                title: 'Dark Mode',
                trailing: CupertinoSwitch(
                  value: settings.isDarkMode,
                  onChanged: (_) {
                    ref.read(settingsProvider.notifier).toggleDarkMode();
                  },
                ),
              ),
            ]),
            
            const SizedBox(height: 20),
            
            // Game Settings Section
            _buildSectionHeader('Game Settings'),
            _buildSettingsList([
              _buildSettingItem(
                icon: CupertinoIcons.flag_fill,
                title: 'Default Target Score',
                subtitle: '${settings.defaultTargetScore}',
                trailing: const Icon(CupertinoIcons.chevron_right),
                onTap: () => _showTargetScoreSelector(context, ref, settings.defaultTargetScore),
              ),
            ]),
            
            const SizedBox(height: 20),
            
            // About Section
            _buildSectionHeader('About'),
            _buildSettingsList([
              _buildSettingItem(
                icon: CupertinoIcons.doc_text_fill,
                title: 'Terms & Conditions',
                trailing: const Icon(CupertinoIcons.chevron_right),
                onTap: () => _showTermsAndConditions(context),
              ),
              _buildSettingItem(
                icon: CupertinoIcons.info_circle_fill,
                title: 'About',
                trailing: const Icon(CupertinoIcons.chevron_right),
                onTap: () => _showAbout(context),
              ),
              _buildSettingItem(
                icon: CupertinoIcons.cube_box_fill,
                title: 'Version',
                subtitle: AppConstants.appVersion,
              ),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: CupertinoColors.systemGrey,
        ),
      ),
    );
  }

  Widget _buildSettingsList(List<Widget> children) {
    return Container(
      decoration: const BoxDecoration(
        color: CupertinoColors.white,
        border: Border(
          top: BorderSide(color: CupertinoColors.separator, width: 0.5),
          bottom: BorderSide(color: CupertinoColors.separator, width: 0.5),
        ),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        color: CupertinoColors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(
              icon,
              color: CupertinoColors.systemBlue,
              size: 28,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 15,
                        color: CupertinoColors.systemGrey,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (trailing != null) trailing,
          ],
        ),
      ),
    );
  }

  void _showTargetScoreSelector(BuildContext context, WidgetRef ref, int currentScore) {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoActionSheet(
        title: const Text('Select Default Target Score'),
        message: const Text('This will be used for new games'),
        actions: AppConstants.targetScores.map((score) {
          return CupertinoActionSheetAction(
            isDefaultAction: score == currentScore,
            onPressed: () {
              Navigator.pop(context);
              ref.read(settingsProvider.notifier).updateDefaultTargetScore(score);
            },
            child: Text('$score'),
          );
        }).toList(),
        cancelButton: CupertinoActionSheetAction(
          child: const Text('Cancel'),
          onPressed: () => Navigator.pop(context),
        ),
      ),
    );
  }

  void _showTermsAndConditions(BuildContext context) {
    Navigator.of(context).push(
      CupertinoPageRoute(
        builder: (context) => const TermsAndConditionsScreen(),
      ),
    );
  }

  void _showAbout(BuildContext context) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text(AppConstants.appName),
        content: const Text(
          'A premium iOS-native snooker score tracking application.\n\n'
          'Version ${AppConstants.appVersion}\n\n'
          'Designed and built with Flutter and Cupertino widgets for the best iOS experience.',
        ),
        actions: [
          CupertinoDialogAction(
            child: const Text('OK'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }
}

class TermsAndConditionsScreen extends StatelessWidget {
  const TermsAndConditionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Terms & Conditions'),
      ),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: const [
            Text(
              'Terms and Conditions',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Last updated: ${AppConstants.appVersion}',
              style: TextStyle(
                color: CupertinoColors.systemGrey,
              ),
            ),
            SizedBox(height: 24),
            Text(
              '1. Acceptance of Terms',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'By using Snooker Score Tracker, you agree to these terms and conditions.',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),
            Text(
              '2. Use of Application',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'This application is provided for personal and non-commercial use. All data is stored locally on your device.',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),
            Text(
              '3. Privacy',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'We do not collect, store, or transmit any personal data. All information remains on your device.',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),
            Text(
              '4. Disclaimer',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'This application is provided "as is" without any warranties. We are not liable for any loss of data or damages.',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
